const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');
const admin = require('firebase-admin');
const { EventEmitter } = require('events');

const app = express();
const redisClient = redis.createClient();
const notificationEmitter = new EventEmitter();

app.use(express.json());

// Advanced Notification Schema
const NotificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  type: { 
    type: String, 
    enum: ['like', 'comment', 'follow', 'mention', 'story_view', 'live_start', 'post_reminder', 'business_insight', 'security_alert'],
    required: true 
  },
  priority: { type: String, enum: ['low', 'medium', 'high', 'urgent'], default: 'medium' },
  category: { type: String, enum: ['social', 'business', 'security', 'system'], required: true },
  
  content: {
    title: { type: String, required: true },
    body: { type: String, required: true },
    imageUrl: String,
    actionUrl: String,
    deepLink: String
  },
  
  actors: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    username: String,
    avatar: String
  }],
  
  metadata: {
    postId: mongoose.Schema.Types.ObjectId,
    commentId: mongoose.Schema.Types.ObjectId,
    storyId: mongoose.Schema.Types.ObjectId,
    businessMetric: String,
    securityEvent: String,
    customData: Object
  },
  
  delivery: {
    channels: [{ type: String, enum: ['push', 'email', 'sms', 'in_app'] }],
    status: { type: String, enum: ['pending', 'sent', 'delivered', 'read', 'failed'], default: 'pending' },
    sentAt: Date,
    deliveredAt: Date,
    readAt: Date,
    failureReason: String
  },
  
  targeting: {
    deviceTokens: [String],
    platforms: [{ type: String, enum: ['ios', 'android', 'web'] }],
    timeZones: [String],
    optimalTime: Date,
    frequency: { type: String, enum: ['immediate', 'batched', 'scheduled'] }
  },
  
  analytics: {
    impressions: { type: Number, default: 0 },
    clicks: { type: Number, default: 0 },
    conversions: { type: Number, default: 0 },
    ctr: { type: Number, default: 0 },
    engagementScore: { type: Number, default: 0 }
  }
}, { timestamps: true });

// User Notification Preferences Schema
const NotificationPreferencesSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  
  channels: {
    push: { enabled: { type: Boolean, default: true }, quietHours: { start: String, end: String } },
    email: { enabled: { type: Boolean, default: true }, frequency: String },
    sms: { enabled: { type: Boolean, default: false }, number: String },
    inApp: { enabled: { type: Boolean, default: true } }
  },
  
  categories: {
    social: {
      likes: { type: Boolean, default: true },
      comments: { type: Boolean, default: true },
      follows: { type: Boolean, default: true },
      mentions: { type: Boolean, default: true },
      stories: { type: Boolean, default: true }
    },
    business: {
      insights: { type: Boolean, default: true },
      promotions: { type: Boolean, default: true },
      analytics: { type: Boolean, default: true }
    },
    security: {
      loginAlerts: { type: Boolean, default: true },
      passwordChanges: { type: Boolean, default: true },
      suspiciousActivity: { type: Boolean, default: true }
    }
  },
  
  smartSettings: {
    aiOptimization: { type: Boolean, default: true },
    batchSimilar: { type: Boolean, default: true },
    respectQuietHours: { type: Boolean, default: true },
    adaptToTimezone: { type: Boolean, default: true }
  }
}, { timestamps: true });

const Notification = mongoose.model('Notification', NotificationSchema);
const NotificationPreferences = mongoose.model('NotificationPreferences', NotificationPreferencesSchema);

// Advanced Notification Service
class NotificationService {
  static async sendNotification(notificationData) {
    try {
      // Create notification record
      const notification = new Notification(notificationData);
      
      // Get user preferences
      const preferences = await this.getUserPreferences(notification.userId);
      
      // Apply smart filtering
      if (!this.shouldSendNotification(notification, preferences)) {
        notification.delivery.status = 'filtered';
        await notification.save();
        return { success: false, reason: 'filtered_by_preferences' };
      }
      
      // Optimize delivery timing
      const optimalTime = await this.calculateOptimalDeliveryTime(notification.userId, preferences);
      notification.targeting.optimalTime = optimalTime;
      
      // Batch similar notifications if enabled
      if (preferences.smartSettings.batchSimilar) {
        const batched = await this.batchSimilarNotifications(notification);
        if (batched) {
          return { success: true, batched: true };
        }
      }
      
      // Deliver notification
      const deliveryResults = await this.deliverNotification(notification, preferences);
      
      // Update notification status
      notification.delivery.status = deliveryResults.success ? 'sent' : 'failed';
      notification.delivery.sentAt = new Date();
      notification.delivery.failureReason = deliveryResults.error;
      
      await notification.save();
      
      // Track analytics
      await this.trackNotificationAnalytics(notification, 'sent');
      
      return deliveryResults;
      
    } catch (error) {
      console.error('Notification send error:', error);
      return { success: false, error: error.message };
    }
  }

  static async deliverNotification(notification, preferences) {
    const deliveryPromises = [];
    
    // Push notification
    if (preferences.channels.push.enabled && notification.delivery.channels.includes('push')) {
      deliveryPromises.push(this.sendPushNotification(notification));
    }
    
    // Email notification
    if (preferences.channels.email.enabled && notification.delivery.channels.includes('email')) {
      deliveryPromises.push(this.sendEmailNotification(notification));
    }
    
    // SMS notification
    if (preferences.channels.sms.enabled && notification.delivery.channels.includes('sms')) {
      deliveryPromises.push(this.sendSMSNotification(notification));
    }
    
    // In-app notification
    if (preferences.channels.inApp.enabled && notification.delivery.channels.includes('in_app')) {
      deliveryPromises.push(this.sendInAppNotification(notification));
    }
    
    const results = await Promise.allSettled(deliveryPromises);
    const successful = results.filter(r => r.status === 'fulfilled' && r.value.success);
    
    return {
      success: successful.length > 0,
      channels: successful.length,
      total: results.length,
      errors: results.filter(r => r.status === 'rejected').map(r => r.reason)
    };
  }

  static async sendPushNotification(notification) {
    try {
      const user = await this.getUserDeviceTokens(notification.userId);
      
      if (!user.deviceTokens || user.deviceTokens.length === 0) {
        return { success: false, error: 'No device tokens' };
      }
      
      const message = {
        notification: {
          title: notification.content.title,
          body: notification.content.body,
          imageUrl: notification.content.imageUrl
        },
        data: {
          type: notification.type,
          postId: notification.metadata.postId?.toString(),
          userId: notification.userId.toString(),
          deepLink: notification.content.deepLink
        },
        tokens: user.deviceTokens,
        android: {
          priority: notification.priority === 'urgent' ? 'high' : 'normal',
          notification: {
            channelId: notification.category,
            priority: notification.priority,
            defaultSound: true,
            defaultVibrateTimings: true
          }
        },
        apns: {
          payload: {
            aps: {
              badge: await this.getUnreadCount(notification.userId),
              sound: 'default',
              contentAvailable: true
            }
          }
        }
      };
      
      const response = await admin.messaging().sendMulticast(message);
      
      // Handle failed tokens
      if (response.failureCount > 0) {
        await this.handleFailedTokens(response.responses, user.deviceTokens);
      }
      
      return { 
        success: response.successCount > 0,
        successCount: response.successCount,
        failureCount: response.failureCount
      };
      
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  static async sendEmailNotification(notification) {
    // Email service integration (SendGrid, AWS SES, etc.)
    try {
      const emailData = {
        to: await this.getUserEmail(notification.userId),
        subject: notification.content.title,
        html: this.generateEmailTemplate(notification),
        category: notification.category
      };
      
      // Mock email sending - integrate with actual service
      console.log('Sending email:', emailData);
      
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  static async batchSimilarNotifications(notification) {
    const batchKey = `batch:${notification.userId}:${notification.type}`;
    const existingBatch = await redisClient.get(batchKey);
    
    if (existingBatch) {
      // Add to existing batch
      const batch = JSON.parse(existingBatch);
      batch.notifications.push(notification);
      batch.count++;
      
      await redisClient.setex(batchKey, 300, JSON.stringify(batch)); // 5 min TTL
      
      // Send batched notification if threshold reached
      if (batch.count >= 5) {
        await this.sendBatchedNotification(batch);
        await redisClient.del(batchKey);
      }
      
      return true;
    } else {
      // Create new batch
      const batch = {
        userId: notification.userId,
        type: notification.type,
        notifications: [notification],
        count: 1,
        createdAt: new Date()
      };
      
      await redisClient.setex(batchKey, 300, JSON.stringify(batch));
      return false;
    }
  }

  static async getSmartNotificationInsights(userId) {
    const insights = await Promise.all([
      this.getEngagementMetrics(userId),
      this.getOptimalTimingAnalysis(userId),
      this.getChannelPerformance(userId),
      this.getNotificationFatigue(userId)
    ]);
    
    return {
      engagement: insights[0],
      timing: insights[1],
      channels: insights[2],
      fatigue: insights[3],
      recommendations: await this.generateNotificationRecommendations(userId)
    };
  }

  // Real-time notification streaming
  static async streamNotifications(userId) {
    const stream = redisClient.duplicate();
    await stream.subscribe(`notifications:${userId}`);
    
    return stream;
  }

  // Business notification analytics
  static async getBusinessNotificationMetrics(businessId) {
    const metrics = await Notification.aggregate([
      { $match: { userId: mongoose.Types.ObjectId(businessId) } },
      {
        $group: {
          _id: '$type',
          count: { $sum: 1 },
          avgEngagement: { $avg: '$analytics.engagementScore' },
          totalClicks: { $sum: '$analytics.clicks' },
          totalImpressions: { $sum: '$analytics.impressions' }
        }
      }
    ]);
    
    return metrics;
  }

  // AI-powered notification optimization
  static async optimizeNotificationTiming(userId) {
    const userActivity = await this.getUserActivityPattern(userId);
    const engagementHistory = await this.getNotificationEngagementHistory(userId);
    
    // ML model to predict optimal timing
    const optimalTimes = this.calculateOptimalTimes(userActivity, engagementHistory);
    
    await redisClient.hset(`user:optimal_times:${userId}`, {
      morning: optimalTimes.morning,
      afternoon: optimalTimes.afternoon,
      evening: optimalTimes.evening
    });
    
    return optimalTimes;
  }
}

// Real-time event handlers
notificationEmitter.on('notification:sent', async (data) => {
  await NotificationService.trackNotificationAnalytics(data.notification, 'delivered');
});

notificationEmitter.on('notification:clicked', async (data) => {
  await NotificationService.trackNotificationAnalytics(data.notification, 'clicked');
});

// API Routes
app.post('/api/notifications/send', async (req, res) => {
  try {
    const result = await NotificationService.sendNotification(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/notifications/:userId', async (req, res) => {
  try {
    const { page = 1, limit = 20, category } = req.query;
    const query = { userId: req.params.userId };
    if (category) query.category = category;
    
    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('actors.userId', 'username avatar');
    
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/notifications/:notificationId/read', async (req, res) => {
  try {
    await Notification.findByIdAndUpdate(req.params.notificationId, {
      'delivery.status': 'read',
      'delivery.readAt': new Date()
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/notifications/:userId/insights', async (req, res) => {
  try {
    const insights = await NotificationService.getSmartNotificationInsights(req.params.userId);
    res.json(insights);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3007;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_notifications')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Notification service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));