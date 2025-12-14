require('dotenv').config();
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const promClient = require('prom-client');
const promMiddleware = require('express-prometheus-middleware');

const { authMiddleware } = require('./middleware/authMiddleware');
const { rateLimitMiddleware } = require('./middleware/rateLimitMiddleware');
const { loggingMiddleware } = require('./middleware/loggingMiddleware');
const { healthCheckMiddleware } = require('./middleware/healthCheckMiddleware');
const { ServiceRegistry } = require('./utils/serviceRegistry');
const { LoadBalancer } = require('./utils/loadBalancer');
const { CircuitBreaker } = require('./utils/circuitBreaker');
const { SocketManager } = require('./utils/socketManager');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    methods: ['GET', 'POST'],
    credentials: true
  }
});

const PORT = process.env.PORT || 8000;

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'api-gateway' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Initialize service registry and load balancer
const serviceRegistry = new ServiceRegistry();
const loadBalancer = new LoadBalancer(serviceRegistry);
const socketManager = new SocketManager(io);

// Prometheus metrics
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'X-API-Key']
}));

// Basic middleware
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Prometheus metrics middleware
app.use(promMiddleware({
  metricsPath: '/metrics',
  collectDefaultMetrics: true,
  requestDurationBuckets: [0.1, 0.5, 1, 1.5, 2, 3, 5, 10]
}));

// Custom middleware
app.use(loggingMiddleware);
app.use(healthCheckMiddleware);

// Rate limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // limit each IP to 1000 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use(globalLimiter);

// Service-specific rate limiting
app.use('/api/auth', rateLimitMiddleware.auth);
app.use('/api/content', rateLimitMiddleware.content);
app.use('/api/search', rateLimitMiddleware.search);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'API Gateway is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    services: serviceRegistry.getHealthStatus(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(promClient.register.metrics());
});

// Service discovery endpoint
app.get('/api/services', authMiddleware, (req, res) => {
  res.json({
    success: true,
    data: {
      services: serviceRegistry.getAllServices(),
      loadBalancer: loadBalancer.getStats()
    }
  });
});

// Circuit breaker for each service
const circuitBreakers = {
  auth: new CircuitBreaker('auth-service'),
  content: new CircuitBreaker('content-service'),
  feed: new CircuitBreaker('feed-service'),
  search: new CircuitBreaker('search-service'),
  notification: new CircuitBreaker('notification-service'),
  analytics: new CircuitBreaker('analytics-service'),
  chat: new CircuitBreaker('chat-service'),
  ai: new CircuitBreaker('ai-moderation-service'),
  media: new CircuitBreaker('media-service'),
  live: new CircuitBreaker('live-service')
};

// Proxy configuration for each service
const createServiceProxy = (serviceName, pathRewrite = {}) => {
  return createProxyMiddleware({
    target: `http://localhost:${getServicePort(serviceName)}`,
    changeOrigin: true,
    pathRewrite,
    timeout: 30000,
    proxyTimeout: 30000,
    onProxyReq: (proxyReq, req, res) => {
      // Add service token for inter-service communication
      proxyReq.setHeader('X-Service-Token', process.env.SERVICE_TOKEN);
      proxyReq.setHeader('X-Request-ID', req.headers['x-request-id'] || require('uuid').v4());
      
      // Log request
      logger.info(`Proxying request to ${serviceName}`, {
        method: req.method,
        url: req.url,
        userAgent: req.get('User-Agent'),
        ip: req.ip
      });
    },
    onProxyRes: (proxyRes, req, res) => {
      // Add CORS headers
      proxyRes.headers['Access-Control-Allow-Origin'] = req.headers.origin || '*';
      proxyRes.headers['Access-Control-Allow-Credentials'] = 'true';
      
      // Log response
      logger.info(`Response from ${serviceName}`, {
        statusCode: proxyRes.statusCode,
        method: req.method,
        url: req.url
      });
    },
    onError: (err, req, res) => {
      logger.error(`Proxy error for ${serviceName}:`, err);
      
      // Circuit breaker logic
      circuitBreakers[serviceName]?.recordFailure();
      
      res.status(503).json({
        success: false,
        message: `Service ${serviceName} is temporarily unavailable`,
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  });
};

// Service port mapping
function getServicePort(serviceName) {
  const ports = {
    'auth-service': 3001,
    'content-service': 3003,
    'feed-service': 3004,
    'search-service': 3006,
    'notification-service': 3007,
    'analytics-service': 3008,
    'chat-service': 3010,
    'ai-moderation-service': 3005,
    'media-service': 3009,
    'live-service': 3011
  };
  return ports[serviceName] || 3000;
}

// Authentication service routes
app.use('/api/auth', 
  (req, res, next) => {
    if (circuitBreakers.auth.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Authentication service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('auth-service', { '^/api/auth': '/api/auth' })
);

// Content service routes
app.use('/api/content', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.content.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Content service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('content-service', { '^/api/content': '/api/content' })
);

// Feed service routes
app.use('/api/feed', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.feed.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Feed service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('feed-service', { '^/api/feed': '/api/feed' })
);

// Search service routes
app.use('/api/search', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.search.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Search service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('search-service', { '^/api/search': '/api/search' })
);

// Notification service routes
app.use('/api/notifications', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.notification.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Notification service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('notification-service', { '^/api/notifications': '/api/notifications' })
);

// Analytics service routes
app.use('/api/analytics', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.analytics.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Analytics service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('analytics-service', { '^/api/analytics': '/api/analytics' })
);

// Chat service routes
app.use('/api/chat', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.chat.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Chat service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('chat-service', { '^/api/chat': '/api/chat' })
);

// AI Moderation service routes
app.use('/api/ai', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.ai.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'AI service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('ai-moderation-service', { '^/api/ai': '/api/ai' })
);

// Media service routes
app.use('/api/media', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.media.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Media service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('media-service', { '^/api/media': '/api/media' })
);

// Live streaming service routes
app.use('/api/live', 
  authMiddleware,
  (req, res, next) => {
    if (circuitBreakers.live.isOpen()) {
      return res.status(503).json({
        success: false,
        message: 'Live streaming service is temporarily unavailable'
      });
    }
    next();
  },
  createServiceProxy('live-service', { '^/api/live': '/api/live' })
);

// WebSocket connection handling
io.use(socketManager.authenticateSocket);

io.on('connection', (socket) => {
  logger.info(`Socket connected: ${socket.id}`, {
    userId: socket.userId,
    userAgent: socket.handshake.headers['user-agent']
  });

  socketManager.handleConnection(socket);

  socket.on('disconnect', (reason) => {
    logger.info(`Socket disconnected: ${socket.id}`, {
      userId: socket.userId,
      reason
    });
    socketManager.handleDisconnection(socket, reason);
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl
  });
});

// Global error handler
app.use((error, req, res, next) => {
  logger.error('Global error handler:', error);
  
  res.status(error.status || 500).json({
    success: false,
    message: error.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Service health monitoring
setInterval(async () => {
  try {
    await serviceRegistry.checkServicesHealth();
    
    // Reset circuit breakers for healthy services
    Object.keys(circuitBreakers).forEach(serviceName => {
      if (serviceRegistry.isServiceHealthy(serviceName)) {
        circuitBreakers[serviceName].recordSuccess();
      }
    });
  } catch (error) {
    logger.error('Service health check error:', error);
  }
}, 30000); // Check every 30 seconds

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

// Unhandled promise rejection handler
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Uncaught exception handler
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Start server
server.listen(PORT, () => {
  logger.info(`API Gateway running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info('Services will be proxied to their respective ports');
});

module.exports = { app, server, io };