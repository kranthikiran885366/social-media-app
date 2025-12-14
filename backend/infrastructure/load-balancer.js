const express = require('express');
const httpProxy = require('http-proxy-middleware');
const redis = require('redis');

const app = express();
const redisClient = redis.createClient();

// Service Registry
const services = {
  auth: [
    { url: 'http://localhost:3001', healthy: true, load: 0 },
    { url: 'http://localhost:3002', healthy: true, load: 0 }
  ],
  content: [
    { url: 'http://localhost:3003', healthy: true, load: 0 }
  ],
  analytics: [
    { url: 'http://localhost:3008', healthy: true, load: 0 }
  ],
  chat: [
    { url: 'http://localhost:3010', healthy: true, load: 0 }
  ],
  recommendations: [
    { url: 'http://localhost:3013', healthy: true, load: 0 }
  ],
  media: [
    { url: 'http://localhost:3014', healthy: true, load: 0 }
  ]
};

// Load Balancing Algorithms
class LoadBalancer {
  static roundRobin(serviceList) {
    const healthy = serviceList.filter(s => s.healthy);
    if (healthy.length === 0) return null;
    
    const index = Math.floor(Math.random() * healthy.length);
    return healthy[index];
  }

  static leastConnections(serviceList) {
    const healthy = serviceList.filter(s => s.healthy);
    if (healthy.length === 0) return null;
    
    return healthy.reduce((min, service) => 
      service.load < min.load ? service : min
    );
  }

  static weightedRoundRobin(serviceList) {
    const healthy = serviceList.filter(s => s.healthy);
    if (healthy.length === 0) return null;
    
    // Simple implementation - can be enhanced with actual weights
    return this.leastConnections(healthy);
  }
}

// Health Check System
class HealthChecker {
  static async checkHealth() {
    for (const [serviceName, instances] of Object.entries(services)) {
      for (const instance of instances) {
        try {
          const response = await fetch(`${instance.url}/health`);
          instance.healthy = response.ok;
        } catch (error) {
          instance.healthy = false;
        }
      }
    }
  }

  static startHealthChecks() {
    setInterval(this.checkHealth, 30000); // Check every 30 seconds
  }
}

// Auto-scaling Logic
class AutoScaler {
  static async checkScaling() {
    for (const [serviceName, instances] of Object.entries(services)) {
      const avgLoad = instances.reduce((sum, i) => sum + i.load, 0) / instances.length;
      
      if (avgLoad > 80 && instances.length < 5) {
        await this.scaleUp(serviceName);
      } else if (avgLoad < 20 && instances.length > 1) {
        await this.scaleDown(serviceName);
      }
    }
  }

  static async scaleUp(serviceName) {
    console.log(`Scaling up ${serviceName} service`);
    // In production, this would trigger container orchestration
    // For now, just log the action
  }

  static async scaleDown(serviceName) {
    console.log(`Scaling down ${serviceName} service`);
    // In production, this would remove instances
  }

  static startAutoScaling() {
    setInterval(this.checkScaling, 60000); // Check every minute
  }
}

// Rate Limiting
const rateLimiter = async (req, res, next) => {
  const clientId = req.ip;
  const key = `rate_limit:${clientId}`;
  
  try {
    const current = await redisClient.get(key);
    const requests = current ? parseInt(current) : 0;
    
    if (requests >= 100) { // 100 requests per minute
      return res.status(429).json({ error: 'Rate limit exceeded' });
    }
    
    await redisClient.setex(key, 60, requests + 1);
    next();
  } catch (error) {
    next(); // Continue on Redis error
  }
};

// Proxy Middleware Factory
const createProxy = (serviceName, algorithm = 'leastConnections') => {
  return httpProxy({
    target: 'http://localhost:3000', // Placeholder
    changeOrigin: true,
    router: (req) => {
      const service = LoadBalancer[algorithm](services[serviceName]);
      if (!service) {
        throw new Error(`No healthy ${serviceName} service available`);
      }
      
      // Update load counter
      service.load++;
      setTimeout(() => service.load--, 1000); // Decrease after 1 second
      
      return service.url;
    },
    onError: (err, req, res) => {
      res.status(503).json({ error: 'Service unavailable' });
    }
  });
};

// Apply rate limiting
app.use(rateLimiter);

// Route to services
app.use('/api/auth', createProxy('auth'));
app.use('/api/content', createProxy('content'));
app.use('/api/analytics', createProxy('analytics'));
app.use('/api/chat', createProxy('chat'));
app.use('/api/recommendations', createProxy('recommendations'));
app.use('/api/media', createProxy('media'));

// Health endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Service status endpoint
app.get('/api/status', (req, res) => {
  const status = {};
  
  for (const [serviceName, instances] of Object.entries(services)) {
    status[serviceName] = {
      total: instances.length,
      healthy: instances.filter(i => i.healthy).length,
      avgLoad: instances.reduce((sum, i) => sum + i.load, 0) / instances.length
    };
  }
  
  res.json(status);
});

// Metrics endpoint
app.get('/api/metrics', async (req, res) => {
  try {
    const metrics = {
      timestamp: new Date().toISOString(),
      services: {},
      system: {
        memory: process.memoryUsage(),
        uptime: process.uptime()
      }
    };
    
    for (const [serviceName, instances] of Object.entries(services)) {
      metrics.services[serviceName] = {
        instances: instances.length,
        healthy: instances.filter(i => i.healthy).length,
        totalLoad: instances.reduce((sum, i) => sum + i.load, 0)
      };
    }
    
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start health checks and auto-scaling
HealthChecker.startHealthChecks();
AutoScaler.startAutoScaling();

const PORT = process.env.PORT || 8000;

app.listen(PORT, () => {
  console.log(`Load balancer running on port ${PORT}`);
  console.log('Starting health checks and auto-scaling...');
});