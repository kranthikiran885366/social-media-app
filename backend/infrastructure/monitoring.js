const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');

const app = express();
const redisClient = redis.createClient();

// Analytics Schema
const AnalyticsEventSchema = new mongoose.Schema({
  userId: String,
  eventType: String,
  eventData: Object,
  timestamp: { type: Date, default: Date.now },
  sessionId: String,
  platform: String,
  version: String
});

const CrashReportSchema = new mongoose.Schema({
  userId: String,
  errorMessage: String,
  stackTrace: String,
  deviceInfo: Object,
  timestamp: { type: Date, default: Date.now },
  version: String,
  resolved: { type: Boolean, default: false }
});

const ABTestSchema = new mongoose.Schema({
  testId: String,
  userId: String,
  variant: String,
  conversionEvent: String,
  timestamp: { type: Date, default: Date.now }
});

const AnalyticsEvent = mongoose.model('AnalyticsEvent', AnalyticsEventSchema);
const CrashReport = mongoose.model('CrashReport', CrashReportSchema);
const ABTest = mongoose.model('ABTest', ABTestSchema);

// Data Analytics Engine
class AnalyticsEngine {
  static async trackEvent(eventData) {
    const event = new AnalyticsEvent(eventData);
    await event.save();
    
    // Real-time processing
    await this.processRealTimeEvent(eventData);
  }

  static async processRealTimeEvent(eventData) {
    const { userId, eventType, eventData: data } = eventData;
    
    // Update user session metrics
    const sessionKey = `session:${userId}:${eventData.sessionId}`;
    await redisClient.hincrby(sessionKey, 'events', 1);
    await redisClient.expire(sessionKey, 3600); // 1 hour TTL
    
    // Track specific events
    switch (eventType) {
      case 'post_view':
        await this.trackContentEngagement(userId, data.postId, 'view');
        break;
      case 'post_like':
        await this.trackContentEngagement(userId, data.postId, 'like');
        break;
      case 'app_crash':
        await this.handleCrashEvent(eventData);
        break;
    }
  }

  static async trackContentEngagement(userId, contentId, action) {
    const key = `engagement:${contentId}`;
    await redisClient.hincrby(key, action, 1);
    await redisClient.expire(key, 86400); // 24 hours TTL
  }

  static async handleCrashEvent(eventData) {
    const crashReport = new CrashReport({
      userId: eventData.userId,
      errorMessage: eventData.eventData.error,
      stackTrace: eventData.eventData.stackTrace,
      deviceInfo: eventData.eventData.deviceInfo,
      version: eventData.version
    });
    
    await crashReport.save();
    
    // Alert if crash rate is high
    const recentCrashes = await CrashReport.countDocuments({
      timestamp: { $gte: new Date(Date.now() - 3600000) } // Last hour
    });
    
    if (recentCrashes > 10) {
      console.log('HIGH CRASH RATE ALERT:', recentCrashes, 'crashes in the last hour');
    }
  }

  static async getUserAnalytics(userId, timeRange = '7d') {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(timeRange.replace('d', '')));
    
    const events = await AnalyticsEvent.find({
      userId,
      timestamp: { $gte: startDate }
    });
    
    const analytics = {
      totalEvents: events.length,
      eventTypes: {},
      dailyActivity: {},
      sessionCount: new Set(events.map(e => e.sessionId)).size
    };
    
    events.forEach(event => {
      analytics.eventTypes[event.eventType] = (analytics.eventTypes[event.eventType] || 0) + 1;
      
      const day = event.timestamp.toISOString().split('T')[0];
      analytics.dailyActivity[day] = (analytics.dailyActivity[day] || 0) + 1;
    });
    
    return analytics;
  }
}

// A/B Testing Engine
class ABTestEngine {
  static async assignUserToTest(userId, testId) {
    const existingAssignment = await ABTest.findOne({ userId, testId });
    if (existingAssignment) {
      return existingAssignment.variant;
    }
    
    // Simple random assignment (50/50 split)
    const variant = Math.random() < 0.5 ? 'A' : 'B';
    
    const assignment = new ABTest({
      testId,
      userId,
      variant,
      timestamp: new Date()
    });
    
    await assignment.save();
    return variant;
  }

  static async trackConversion(userId, testId, conversionEvent) {
    await ABTest.findOneAndUpdate(
      { userId, testId },
      { conversionEvent, conversionTimestamp: new Date() }
    );
  }

  static async getTestResults(testId) {
    const results = await ABTest.aggregate([
      { $match: { testId } },
      {
        $group: {
          _id: '$variant',
          totalUsers: { $sum: 1 },
          conversions: {
            $sum: { $cond: [{ $ne: ['$conversionEvent', null] }, 1, 0] }
          }
        }
      }
    ]);
    
    const testResults = {};
    results.forEach(result => {
      testResults[result._id] = {
        users: result.totalUsers,
        conversions: result.conversions,
        conversionRate: result.conversions / result.totalUsers
      };
    });
    
    return testResults;
  }
}

// Push Notification Server
class NotificationServer {
  static async sendPushNotification(userId, notification) {
    // Mock implementation - in production would integrate with FCM/APNS
    const payload = {
      userId,
      title: notification.title,
      body: notification.body,
      data: notification.data || {},
      timestamp: new Date()
    };
    
    // Store notification for delivery tracking
    await redisClient.lpush(`notifications:${userId}`, JSON.stringify(payload));
    await redisClient.expire(`notifications:${userId}`, 86400 * 7); // 7 days
    
    console.log('Push notification sent:', payload);
    return { success: true, notificationId: Date.now().toString() };
  }

  static async getNotificationStatus(userId, notificationId) {
    // Mock delivery status
    return {
      notificationId,
      status: Math.random() > 0.1 ? 'delivered' : 'failed',
      timestamp: new Date()
    };
  }
}

// Routes
app.use(express.json());

// Analytics endpoints
app.post('/api/analytics/track', async (req, res) => {
  try {
    await AnalyticsEngine.trackEvent(req.body);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { timeRange = '7d' } = req.query;
    
    const analytics = await AnalyticsEngine.getUserAnalytics(userId, timeRange);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// A/B Testing endpoints
app.post('/api/ab-test/assign', async (req, res) => {
  try {
    const { userId, testId } = req.body;
    const variant = await ABTestEngine.assignUserToTest(userId, testId);
    res.json({ variant });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/ab-test/convert', async (req, res) => {
  try {
    const { userId, testId, conversionEvent } = req.body;
    await ABTestEngine.trackConversion(userId, testId, conversionEvent);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/ab-test/results/:testId', async (req, res) => {
  try {
    const { testId } = req.params;
    const results = await ABTestEngine.getTestResults(testId);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Crash reporting
app.post('/api/crash-report', async (req, res) => {
  try {
    await AnalyticsEngine.handleCrashEvent({
      userId: req.body.userId,
      eventType: 'app_crash',
      eventData: req.body,
      version: req.body.version
    });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Push notifications
app.post('/api/notifications/send', async (req, res) => {
  try {
    const { userId, notification } = req.body;
    const result = await NotificationServer.sendPushNotification(userId, notification);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// In-app updates
app.get('/api/app-update/check', (req, res) => {
  const { version, platform } = req.query;
  
  // Mock update check
  const latestVersion = '1.2.0';
  const updateRequired = version !== latestVersion;
  
  res.json({
    updateAvailable: updateRequired,
    latestVersion,
    currentVersion: version,
    updateUrl: updateRequired ? `https://updates.smartsocial.com/${platform}/${latestVersion}` : null,
    forceUpdate: false
  });
});

const PORT = process.env.PORT || 3015;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_monitoring')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Monitoring service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));