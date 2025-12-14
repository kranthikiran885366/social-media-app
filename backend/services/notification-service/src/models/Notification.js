const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  // Basic Info
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { 
    type: String, 
    enum: [
      // Engagement notifications
      'like', 'comment', 'share', 'save', 'mention', 'tag',
      
      // Social notifications
      'follow', 'follow_request', 'follow_accepted', 'unfollow',
      
      // Content notifications
      'post_uploaded', 'story_uploaded', 'reel_uploaded', 'live_started',
      'post_featured', 'content_approved', 'content_rejected',
      
      // Interactive notifications
      'poll_vote', 'quiz_answer', 'challenge_participation',
      'collaboration_invite', 'collaboration_accepted',
      
      // Shopping notifications
      'product_tagged', 'order_placed', 'payment_received',
      'product_sold', 'shop_visit', 'wishlist_item_sale',
      
      // Live streaming notifications
      'live_viewer_joined', 'live_comment', 'live_gift_received',
      'live_ended', 'live_recording_ready',
      
      // Creator notifications
      'monetization_enabled', 'earnings_milestone', 'subscriber_milestone',
      'brand_collaboration', 'sponsorship_offer',
      
      // System notifications
      'account_verified', 'security_alert', 'login_alert',
      'password_changed', 'email_changed', 'phone_verified',
      
      // Moderation notifications
      'content_reported', 'account_warned', 'account_suspended',
      'content_removed', 'appeal_approved', 'appeal_rejected',
      
      // Marketing notifications
      'feature_announcement', 'app_update', 'promotional_offer',
      'event_invitation', 'contest_announcement',
      
      // Reminder notifications
      'time_limit_reminder', 'break_reminder', 'weekly_report',
      'birthday_reminder', 'anniversary_reminder'
    ], 
    required: true 
  },
  
  // Content
  title: { type: String, required: true, maxlength: 100 },
  message: { type: String, required: true, maxlength: 500 },
  actionText: String, // "View Post", "Accept Request", etc.
  actionUrl: String,
  
  // Related entities
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post' },
  commentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Comment' },
  storyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Story' },
  reelId: { type: mongoose.Schema.Types.ObjectId, ref: 'Reel' },
  liveStreamId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveStream' },
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
  
  // Media
  imageUrl: String,
  thumbnailUrl: String,
  iconUrl: String,
  
  // Metadata
  data: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  
  // Status
  isRead: { type: Boolean, default: false },
  readAt: Date,
  isClicked: { type: Boolean, default: false },
  clickedAt: Date,
  isArchived: { type: Boolean, default: false },
  archivedAt: Date,
  
  // Delivery channels
  channels: {
    push: {
      enabled: { type: Boolean, default: true },
      sent: { type: Boolean, default: false },
      sentAt: Date,
      messageId: String,
      error: String
    },
    email: {
      enabled: { type: Boolean, default: false },
      sent: { type: Boolean, default: false },
      sentAt: Date,
      messageId: String,
      error: String
    },
    sms: {
      enabled: { type: Boolean, default: false },
      sent: { type: Boolean, default: false },
      sentAt: Date,
      messageId: String,
      error: String
    },
    inApp: {
      enabled: { type: Boolean, default: true },
      shown: { type: Boolean, default: false },
      shownAt: Date
    }
  },
  
  // Scheduling
  scheduledFor: Date,
  expiresAt: Date,
  
  // Priority and grouping
  priority: { 
    type: String, 
    enum: ['low', 'normal', 'high', 'urgent'], 
    default: 'normal' 
  },
  groupKey: String, // For grouping similar notifications
  batchId: String, // For batch notifications
  
  // Personalization
  personalizedContent: {
    title: String,
    message: String,
    imageUrl: String
  },
  
  // Analytics
  impressions: { type: Number, default: 0 },
  clicks: { type: Number, default: 0 },
  conversions: { type: Number, default: 0 },
  
  // A/B Testing
  variant: String,
  experimentId: String
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ type: 1, createdAt: -1 });
notificationSchema.index({ fromUserId: 1, createdAt: -1 });
notificationSchema.index({ scheduledFor: 1 });
notificationSchema.index({ expiresAt: 1 });
notificationSchema.index({ groupKey: 1, userId: 1 });
notificationSchema.index({ batchId: 1 });

// Virtual for time ago
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diffMs = now - this.createdAt;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)}w ago`;
  return this.createdAt.toLocaleDateString();
});

// Virtual for delivery status
notificationSchema.virtual('deliveryStatus').get(function() {
  const channels = this.channels;
  const status = {
    push: channels.push.enabled ? (channels.push.sent ? 'sent' : 'pending') : 'disabled',
    email: channels.email.enabled ? (channels.email.sent ? 'sent' : 'pending') : 'disabled',
    sms: channels.sms.enabled ? (channels.sms.sent ? 'sent' : 'pending') : 'disabled',
    inApp: channels.inApp.enabled ? (channels.inApp.shown ? 'shown' : 'pending') : 'disabled'
  };
  
  return status;
});

// Pre-save middleware
notificationSchema.pre('save', function(next) {
  // Set expiration date if not set
  if (!this.expiresAt) {
    const expirationDays = this.type.includes('reminder') ? 1 : 30;
    this.expiresAt = new Date(Date.now() + expirationDays * 24 * 60 * 60 * 1000);
  }
  
  // Generate group key for similar notifications
  if (!this.groupKey) {
    this.groupKey = `${this.type}_${this.fromUserId || 'system'}_${this.postId || 'general'}`;
  }
  
  next();
});

// Methods
notificationSchema.methods.markAsRead = function() {
  this.isRead = true;
  this.readAt = new Date();
  return this.save();
};

notificationSchema.methods.markAsClicked = function() {
  this.isClicked = true;
  this.clickedAt = new Date();
  this.clicks += 1;
  return this.save();
};

notificationSchema.methods.archive = function() {
  this.isArchived = true;
  this.archivedAt = new Date();
  return this.save();
};

notificationSchema.methods.updateDeliveryStatus = function(channel, status, messageId = null, error = null) {
  if (this.channels[channel]) {
    this.channels[channel].sent = status === 'sent';
    this.channels[channel].sentAt = status === 'sent' ? new Date() : null;
    this.channels[channel].messageId = messageId;
    this.channels[channel].error = error;
    
    if (channel === 'inApp' && status === 'shown') {
      this.channels[channel].shown = true;
      this.channels[channel].shownAt = new Date();
      this.impressions += 1;
    }
  }
  return this.save();
};

notificationSchema.methods.shouldSendToChannel = function(channel, userSettings) {
  // Check if channel is enabled for this notification
  if (!this.channels[channel] || !this.channels[channel].enabled) {
    return false;
  }
  
  // Check if already sent
  if (this.channels[channel].sent) {
    return false;
  }
  
  // Check user's notification settings
  if (!userSettings || !userSettings[channel]) {
    return false;
  }
  
  // Check type-specific settings
  const typeSettings = userSettings.types || {};
  if (typeSettings[this.type] === false) {
    return false;
  }
  
  // Check quiet hours for push notifications
  if (channel === 'push' && userSettings.quietHours) {
    const now = new Date();
    const currentHour = now.getHours();
    const { start, end } = userSettings.quietHours;
    
    if (start < end) {
      // Same day quiet hours (e.g., 22:00 to 06:00 next day)
      if (currentHour >= start || currentHour < end) {
        return false;
      }
    } else {
      // Cross-day quiet hours (e.g., 22:00 to 06:00)
      if (currentHour >= start && currentHour < end) {
        return false;
      }
    }
  }
  
  return true;
};

notificationSchema.methods.getPersonalizedContent = function(userProfile) {
  if (this.personalizedContent && Object.keys(this.personalizedContent).length > 0) {
    return this.personalizedContent;
  }
  
  // Generate personalized content based on user profile
  let personalizedTitle = this.title;
  let personalizedMessage = this.message;
  
  // Add user's name if available
  if (userProfile && userProfile.firstName) {
    personalizedTitle = personalizedTitle.replace('{{userName}}', userProfile.firstName);
    personalizedMessage = personalizedMessage.replace('{{userName}}', userProfile.firstName);
  }
  
  // Add time-based personalization
  const hour = new Date().getHours();
  let greeting = 'Hi';
  if (hour < 12) greeting = 'Good morning';
  else if (hour < 18) greeting = 'Good afternoon';
  else greeting = 'Good evening';
  
  personalizedTitle = personalizedTitle.replace('{{greeting}}', greeting);
  personalizedMessage = personalizedMessage.replace('{{greeting}}', greeting);
  
  return {
    title: personalizedTitle,
    message: personalizedMessage,
    imageUrl: this.imageUrl
  };
};

notificationSchema.methods.toSafeObject = function() {
  const notificationObject = this.toObject();
  
  // Remove sensitive delivery information
  delete notificationObject.channels;
  delete notificationObject.batchId;
  delete notificationObject.experimentId;
  delete notificationObject.variant;
  
  return notificationObject;
};

// Static methods
notificationSchema.statics.getUnreadCount = function(userId) {
  return this.countDocuments({
    userId,
    isRead: false,
    isArchived: false,
    expiresAt: { $gt: new Date() }
  });
};

notificationSchema.statics.markAllAsRead = function(userId) {
  return this.updateMany(
    {
      userId,
      isRead: false,
      isArchived: false
    },
    {
      $set: {
        isRead: true,
        readAt: new Date()
      }
    }
  );
};

notificationSchema.statics.getGroupedNotifications = function(userId, limit = 50) {
  return this.aggregate([
    {
      $match: {
        userId: mongoose.Types.ObjectId(userId),
        isArchived: false,
        expiresAt: { $gt: new Date() }
      }
    },
    {
      $sort: { createdAt: -1 }
    },
    {
      $group: {
        _id: '$groupKey',
        notifications: { $push: '$$ROOT' },
        count: { $sum: 1 },
        latestNotification: { $first: '$$ROOT' },
        hasUnread: { $max: { $cond: [{ $eq: ['$isRead', false] }, 1, 0] } }
      }
    },
    {
      $sort: { 'latestNotification.createdAt': -1 }
    },
    {
      $limit: limit
    }
  ]);
};

module.exports = mongoose.model('Notification', notificationSchema);