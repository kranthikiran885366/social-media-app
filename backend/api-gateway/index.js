const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const winston = require('winston');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

// Logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
  transports: [new winston.transports.Console()]
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // requests per window
  message: { error: 'Too many requests' }
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { error: 'Too many authentication attempts' }
});

app.use(globalLimiter);

// Service endpoints
const services = {
  auth: process.env.AUTH_SERVICE_URL || 'http://localhost:3001',
  content: process.env.CONTENT_SERVICE_URL || 'http://localhost:3003',
  feed: process.env.FEED_SERVICE_URL || 'http://localhost:3004',
  ai: process.env.AI_SERVICE_URL || 'http://localhost:3005',
  notification: process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3007',
  analytics: process.env.ANALYTICS_SERVICE_URL || 'http://localhost:3008',
  search: process.env.SEARCH_SERVICE_URL || 'http://localhost:3009',
  chat: process.env.CHAT_SERVICE_URL || 'http://localhost:3010'
};

// JWT Authentication middleware
const authenticateToken = (req, res, next) => {
  // Skip auth for public endpoints
  const publicPaths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/health',
    '/api/docs'
  ];

  if (publicPaths.some(path => req.path.startsWith(path))) {
    return next();
  }

  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret', (err, user) => {
    if (err) {
      logger.warn(`Invalid token attempt: ${req.ip}`);
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Request logging middleware
const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.userId
    });
  });
  
  next();
};

app.use(requestLogger);

// Service health check aggregator
app.get('/health', async (req, res) => {
  const healthChecks = {};
  
  for (const [serviceName, serviceUrl] of Object.entries(services)) {
    try {
      const response = await fetch(`${serviceUrl}/health`, { 
        timeout: 5000 
      });
      healthChecks[serviceName] = {
        status: response.ok ? 'healthy' : 'unhealthy',
        url: serviceUrl
      };
    } catch (error) {
      healthChecks[serviceName] = {
        status: 'unhealthy',
        error: error.message,
        url: serviceUrl
      };
    }
  }

  const allHealthy = Object.values(healthChecks).every(check => check.status === 'healthy');
  
  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    services: healthChecks,
    gateway: {
      status: 'healthy',
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      version: process.env.npm_package_version || '1.0.0'
    }
  });
});

// API Documentation
app.get('/api/docs', (req, res) => {
  res.json({
    title: 'Smart Social Platform API',
    version: '1.0.0',
    description: 'Next-generation social media platform with AI moderation and time management',
    services: {
      auth: {
        baseUrl: '/api/auth',
        endpoints: [
          'POST /register - User registration',
          'POST /login - User login',
          'POST /refresh - Refresh token',
          'GET /profile - Get user profile',
          'PUT /profile - Update profile',
          'POST /follow/:userId - Follow/unfollow user'
        ]
      },
      content: {
        baseUrl: '/api/content',
        endpoints: [
          'POST /posts - Create post',
          'GET /posts - Get posts',
          'POST /posts/:id/like - Like/unlike post',
          'POST /posts/:id/comments - Add comment',
          'POST /stories - Create story',
          'POST /reels - Create reel'
        ]
      },
      feed: {
        baseUrl: '/api/feed',
        endpoints: [
          'GET /home - Get personalized feed',
          'GET /explore - Get explore feed',
          'GET /stories - Get stories',
          'GET /reels - Get reels feed'
        ]
      },
      ai: {
        baseUrl: '/api/ai',
        endpoints: [
          'POST /analyze - Analyze content',
          'POST /analyze-batch - Batch analyze',
          'GET /stats - Moderation statistics'
        ]
      },
      analytics: {
        baseUrl: '/api/analytics',
        endpoints: [
          'POST /session/start - Start session tracking',
          'POST /session/end - End session tracking',
          'POST /track - Track user action',
          'GET /user/:userId - Get user analytics',
          'POST /reel-limit - Check reel limit'
        ]
      },
      chat: {
        baseUrl: '/api/chat',
        endpoints: [
          'GET /chats - Get user chats',
          'GET /messages/:chatId - Get chat messages',
          'POST /create - Create new chat',
          'GET /online-users - Get online users'
        ]
      }
    },
    authentication: {
      type: 'Bearer Token',
      header: 'Authorization: Bearer <token>',
      note: 'Most endpoints require authentication except login, register, and public content'
    },
    rateLimit: {
      global: '1000 requests per 15 minutes',
      auth: '10 requests per 15 minutes for auth endpoints'
    }
  });
});

// Proxy configurations with load balancing and circuit breaker
const createProxy = (target, options = {}) => {
  return createProxyMiddleware({
    target,
    changeOrigin: true,
    timeout: 30000,
    proxyTimeout: 30000,
    onError: (err, req, res) => {
      logger.error(`Proxy error for ${req.url}:`, err.message);
      res.status(503).json({ 
        error: 'Service temporarily unavailable',
        service: target,
        timestamp: new Date().toISOString()
      });
    },
    onProxyReq: (proxyReq, req, res) => {
      // Add user context to service requests
      if (req.user) {
        proxyReq.setHeader('X-User-ID', req.user.userId);
        proxyReq.setHeader('X-User-Type', req.user.type || 'user');
      }
      
      // Add request ID for tracing
      const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      proxyReq.setHeader('X-Request-ID', requestId);
      req.requestId = requestId;
    },
    onProxyRes: (proxyRes, req, res) => {
      // Add CORS headers
      proxyRes.headers['Access-Control-Allow-Origin'] = '*';
      proxyRes.headers['Access-Control-Allow-Methods'] = 'GET,PUT,POST,DELETE,OPTIONS';
      proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Content-Length, X-Requested-With';
      
      // Add request ID to response
      if (req.requestId) {
        proxyRes.headers['X-Request-ID'] = req.requestId;
      }
    },
    ...options
  });
};

// Apply authentication middleware
app.use(authenticateToken);

// Route to services
app.use('/api/auth', authLimiter, createProxy(services.auth));
app.use('/api/content', createProxy(services.content));
app.use('/api/feed', createProxy(services.feed));
app.use('/api/ai', createProxy(services.ai));
app.use('/api/notifications', createProxy(services.notification));
app.use('/api/analytics', createProxy(services.analytics));
app.use('/api/search', createProxy(services.search));
app.use('/api/chat', createProxy(services.chat));

// WebSocket proxy for real-time features
const { createProxyMiddleware: createWSProxy } = require('http-proxy-middleware');

// Chat WebSocket proxy
app.use('/socket.io', createWSProxy({
  target: services.chat,
  ws: true,
  changeOrigin: true,
  onError: (err, req, socket) => {
    logger.error('WebSocket proxy error:', err.message);
    socket.end();
  }
}));

// Global error handler
app.use((error, req, res, next) => {
  logger.error('Gateway error:', {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    userId: req.user?.userId
  });

  res.status(500).json({
    error: 'Internal gateway error',
    timestamp: new Date().toISOString(),
    requestId: req.requestId
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method,
    availableServices: Object.keys(services),
    documentation: '/api/docs'
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

app.listen(PORT, () => {
  logger.info(`API Gateway running on port ${PORT}`);
  logger.info('Available services:', services);
});

module.exports = app;