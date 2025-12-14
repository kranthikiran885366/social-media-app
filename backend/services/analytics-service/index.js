const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');

const app = express();
const redisClient = redis.createClient();

app.use(express.json());

const AnalyticsEventSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sessionId: String,
  eventType: { type: String, required: true },
  eventData: Object,
  metadata: {
    platform: String,
    device: String,
    location: { type: { type: String }, coordinates: [Number] },
    userAgent: String,
    referrer: String
  },
  timestamp: { type: Date, default: Date.now }
});

const UserSessionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sessionId: { type: String, required: true },
  startTime: { type: Date, default: Date.now },
  endTime: Date,
  duration: Number,
  events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'AnalyticsEvent' }],
  metrics: {
    postsViewed: { type: Number, default: 0 },
    reelsWatched: { type: Number, default: 0 },
    storiesViewed: { type: Number, default: 0 },
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    timeSpent: { type: Number, default: 0 }
  }
});

const BusinessMetricsSchema = new mongoose.Schema({
  businessId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  period: { type: String, enum: ['daily', 'weekly', 'monthly'], required: true },
  date: { type: Date, required: true },
  metrics: {
    reach: Number,
    impressions: Number,
    engagement: Number,
    followers: Number,
    revenue: Number,
    conversions: Number,
    ctr: Number,
    cpm: Number
  },
  demographics: {
    ageGroups: Object,
    genders: Object,
    locations: Object,
    interests: Object
  }
});

const AnalyticsEvent = mongoose.model('AnalyticsEvent', AnalyticsEventSchema);
const UserSession = mongoose.model('UserSession', UserSessionSchema);
const BusinessMetrics = mongoose.model('BusinessMetrics', BusinessMetricsSchema);

class AnalyticsService {
  static async trackEvent(eventData) {
    const event = new AnalyticsEvent(eventData);
    await event.save();
    
    await Promise.all([
      this.updateRealTimeMetrics(eventData),
      this.updateUserSession(eventData),
      this.updateBusinessMetrics(eventData)
    ]);
    
    return event;
  }

  static async updateRealTimeMetrics(eventData) {
    const { userId, eventType, sessionId } = eventData;
    const key = `metrics:realtime:${userId}`;
    
    await Promise.all([
      redisClient.hincrby(key, eventType, 1),
      redisClient.hincrby(key, 'total_events', 1),
      redisClient.expire(key, 86400), // 24 hours TTL
      redisClient.setex(`user:last_activity:${userId}`, 3600, Date.now())
    ]);
  }

  static async getUserAnalytics(userId, timeRange = '30d') {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(timeRange.replace('d', '')));
    
    const [events, sessions, engagement] = await Promise.all([
      this.getEventAnalytics(userId, startDate),
      this.getSessionAnalytics(userId, startDate),
      this.getEngagementAnalytics(userId, startDate)
    ]);
    
    return {
      events,
      sessions,
      engagement,
      insights: await this.generateInsights(userId, events, sessions)
    };
  }

  static async getBusinessAnalytics(businessId, timeRange = '30d') {
    const metrics = await BusinessMetrics.find({
      businessId,
      date: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
    }).sort({ date: -1 });
    
    const analytics = {
      overview: this.calculateOverviewMetrics(metrics),
      growth: this.calculateGrowthMetrics(metrics),
      audience: this.calculateAudienceMetrics(metrics),
      content: await this.getContentPerformance(businessId, timeRange),
      revenue: this.calculateRevenueMetrics(metrics)
    };
    
    return analytics;
  }

  static async trackTimeSpent(userId, sessionId, timeSpent) {
    await Promise.all([
      UserSession.findOneAndUpdate(
        { userId, sessionId },
        { 
          $inc: { 'metrics.timeSpent': timeSpent },
          endTime: new Date(),
          duration: timeSpent
        }
      ),
      redisClient.hincrby(`metrics:time:${userId}`, 'daily', timeSpent),
      this.checkTimeLimit(userId, timeSpent)
    ]);
  }

  static async checkTimeLimit(userId, currentTime) {
    const dailyLimit = await redisClient.hget(`user:settings:${userId}`, 'daily_limit') || 900000; // 15 min default
    const todayTime = await redisClient.hget(`metrics:time:${userId}`, 'daily') || 0;
    
    if (parseInt(todayTime) >= parseInt(dailyLimit)) {
      await this.sendTimeLimitNotification(userId);
    }
  }

  static async getContentAnalytics(contentId, contentType) {
    const analytics = await AnalyticsEvent.aggregate([
      { $match: { 'eventData.contentId': contentId } },
      {
        $group: {
          _id: '$eventType',
          count: { $sum: 1 },
          uniqueUsers: { $addToSet: '$userId' }
        }
      }
    ]);
    
    const metrics = {
      views: 0,
      likes: 0,
      comments: 0,
      shares: 0,
      saves: 0,
      uniqueViewers: 0,
      engagementRate: 0
    };
    
    analytics.forEach(item => {
      metrics[item._id] = item.count;
      if (item._id === 'view') {
        metrics.uniqueViewers = item.uniqueUsers.length;
      }
    });
    
    metrics.engagementRate = ((metrics.likes + metrics.comments + metrics.shares) / metrics.views) * 100;
    
    return metrics;
  }

  static async generateDashboard(userId, userType = 'user') {
    if (userType === 'business') {
      return this.generateBusinessDashboard(userId);
    }
    
    const [analytics, recommendations, insights] = await Promise.all([
      this.getUserAnalytics(userId),
      this.getPersonalizedRecommendations(userId),
      this.getUsageInsights(userId)
    ]);
    
    return { analytics, recommendations, insights };
  }

  static async generateBusinessDashboard(businessId) {
    const [analytics, competitors, trends] = await Promise.all([
      this.getBusinessAnalytics(businessId),
      this.getCompetitorAnalysis(businessId),
      this.getTrendAnalysis(businessId)
    ]);
    
    return { analytics, competitors, trends };
  }

  static async getRealtimeMetrics(userId) {
    const key = `metrics:realtime:${userId}`;
    const metrics = await redisClient.hgetall(key);
    
    return {
      activeUsers: await redisClient.scard('users:online'),
      currentSessions: await redisClient.scard('sessions:active'),
      eventsPerMinute: await this.getEventsPerMinute(),
      userMetrics: metrics
    };
  }

  static async exportAnalytics(userId, format = 'json', timeRange = '30d') {
    const data = await this.getUserAnalytics(userId, timeRange);
    
    if (format === 'csv') {
      return this.convertToCSV(data);
    }
    
    return data;
  }
}

app.post('/api/analytics/track', async (req, res) => {
  try {
    const event = await AnalyticsService.trackEvent(req.body);
    res.json({ success: true, eventId: event._id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics/user/:userId', async (req, res) => {
  try {
    const { timeRange } = req.query;
    const analytics = await AnalyticsService.getUserAnalytics(req.params.userId, timeRange);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics/business/:businessId', async (req, res) => {
  try {
    const { timeRange } = req.query;
    const analytics = await AnalyticsService.getBusinessAnalytics(req.params.businessId, timeRange);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics/content/:contentId', async (req, res) => {
  try {
    const { contentType } = req.query;
    const analytics = await AnalyticsService.getContentAnalytics(req.params.contentId, contentType);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics/realtime/:userId', async (req, res) => {
  try {
    const metrics = await AnalyticsService.getRealtimeMetrics(req.params.userId);
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3008;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_analytics')
  .then(() => app.listen(PORT, () => console.log(`Analytics service running on port ${PORT}`)));