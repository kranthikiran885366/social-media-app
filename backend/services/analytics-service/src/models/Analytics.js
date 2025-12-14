const mongoose = require('mongoose');

// User Analytics Schema
const userAnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  
  // Engagement Metrics
  engagement: {
    postsCreated: { type: Number, default: 0 },
    storiesCreated: { type: Number, default: 0 },
    reelsCreated: { type: Number, default: 0 },
    commentsPosted: { type: Number, default: 0 },
    likesGiven: { type: Number, default: 0 },
    sharesGiven: { type: Number, default: 0 },
    savesGiven: { type: Number, default: 0 },
    
    // Received engagement
    likesReceived: { type: Number, default: 0 },
    commentsReceived: { type: Number, default: 0 },
    sharesReceived: { type: Number, default: 0 },
    savesReceived: { type: Number, default: 0 },
    mentionsReceived: { type: Number, default: 0 },
    
    // Engagement rate
    engagementRate: { type: Number, default: 0 },
    averageEngagementPerPost: { type: Number, default: 0 }
  },
  
  // Activity Metrics
  activity: {
    sessionCount: { type: Number, default: 0 },
    totalTimeSpent: { type: Number, default: 0 }, // in minutes
    averageSessionDuration: { type: Number, default: 0 }, // in minutes
    screenTimeByFeature: {
      feed: { type: Number, default: 0 },
      explore: { type: Number, default: 0 },
      reels: { type: Number, default: 0 },
      stories: { type: Number, default: 0 },
      profile: { type: Number, default: 0 },
      search: { type: Number, default: 0 },
      chat: { type: Number, default: 0 },
      live: { type: Number, default: 0 },
      shopping: { type: Number, default: 0 }
    },
    actionsPerformed: {
      scrolls: { type: Number, default: 0 },
      taps: { type: Number, default: 0 },
      swipes: { type: Number, default: 0 },
      searches: { type: Number, default: 0 },
      profileVisits: { type: Number, default: 0 }
    }
  },
  
  // Social Metrics
  social: {
    followersGained: { type: Number, default: 0 },
    followersLost: { type: Number, default: 0 },
    followingAdded: { type: Number, default: 0 },
    followingRemoved: { type: Number, default: 0 },
    messagesExchanged: { type: Number, default: 0 },
    groupsJoined: { type: Number, default: 0 },
    eventsAttended: { type: Number, default: 0 }
  },
  
  // Content Performance
  contentPerformance: {
    totalReach: { type: Number, default: 0 },
    totalImpressions: { type: Number, default: 0 },
    uniqueViewers: { type: Number, default: 0 },
    topPerformingPost: {
      postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post' },
      engagementScore: { type: Number, default: 0 }
    },
    contentCategories: [{
      category: String,
      postCount: Number,
      averageEngagement: Number
    }]
  },
  
  // Monetization Metrics
  monetization: {
    earningsGenerated: { type: Number, default: 0 },
    sponsoredPostsCreated: { type: Number, default: 0 },
    productsTagged: { type: Number, default: 0 },
    affiliateClicks: { type: Number, default: 0 },
    subscriptionsGained: { type: Number, default: 0 },
    tipsReceived: { type: Number, default: 0 }
  },
  
  // Demographics Insights
  audienceDemographics: {
    ageGroups: [{
      range: String, // "18-24", "25-34", etc.
      percentage: Number
    }],
    genderDistribution: [{
      gender: String,
      percentage: Number
    }],
    topLocations: [{
      country: String,
      city: String,
      percentage: Number
    }],
    deviceTypes: [{
      type: String, // "mobile", "desktop", "tablet"
      percentage: Number
    }]
  }
}, {
  timestamps: true
});

// Post Analytics Schema
const postAnalyticsSchema = new mongoose.Schema({
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  
  // Performance Metrics
  performance: {
    views: { type: Number, default: 0 },
    uniqueViews: { type: Number, default: 0 },
    reach: { type: Number, default: 0 },
    impressions: { type: Number, default: 0 },
    
    // Engagement
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    saves: { type: Number, default: 0 },
    
    // Calculated metrics
    engagementRate: { type: Number, default: 0 },
    clickThroughRate: { type: Number, default: 0 },
    completionRate: { type: Number, default: 0 }, // for videos
    averageWatchTime: { type: Number, default: 0 } // for videos
  },
  
  // Audience Insights
  audience: {
    demographics: {
      ageGroups: [{
        range: String,
        count: Number,
        percentage: Number
      }],
      genders: [{
        gender: String,
        count: Number,
        percentage: Number
      }],
      locations: [{
        country: String,
        city: String,
        count: Number,
        percentage: Number
      }]
    },
    
    // Engagement by demographics
    engagementByAge: [{
      ageRange: String,
      engagementRate: Number
    }],
    engagementByGender: [{
      gender: String,
      engagementRate: Number
    }],
    engagementByLocation: [{
      location: String,
      engagementRate: Number
    }]
  },
  
  // Traffic Sources
  trafficSources: [{
    source: String, // 'feed', 'explore', 'hashtag', 'profile', 'external'
    views: Number,
    percentage: Number
  }],
  
  // Time-based Analytics
  timeAnalytics: {
    hourlyViews: [{ hour: Number, views: Number }],
    peakEngagementHour: Number,
    totalEngagementTime: Number, // in seconds
    averageEngagementTime: Number // in seconds
  },
  
  // Hashtag Performance
  hashtagPerformance: [{
    hashtag: String,
    reach: Number,
    impressions: Number,
    clicks: Number
  }],
  
  // A/B Testing Results
  abTestResults: {
    variant: String,
    conversionRate: Number,
    engagementRate: Number,
    preferenceScore: Number
  }
}, {
  timestamps: true
});

// Live Stream Analytics Schema
const liveStreamAnalyticsSchema = new mongoose.Schema({
  streamId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveStream', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  // Stream Metrics
  streamMetrics: {
    duration: { type: Number, required: true }, // in seconds
    peakViewers: { type: Number, default: 0 },
    averageViewers: { type: Number, default: 0 },
    totalViewers: { type: Number, default: 0 },
    uniqueViewers: { type: Number, default: 0 },
    
    // Engagement during stream
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    giftsReceived: { type: Number, default: 0 },
    
    // Viewer behavior
    averageWatchTime: { type: Number, default: 0 },
    dropOffRate: { type: Number, default: 0 },
    returnViewerRate: { type: Number, default: 0 }
  },
  
  // Time-series data
  viewerTimeline: [{
    timestamp: Date,
    viewerCount: Number,
    newViewers: Number,
    leftViewers: Number
  }],
  
  // Audience Analytics
  audienceAnalytics: {
    demographics: {
      ageGroups: [{ range: String, count: Number }],
      genders: [{ gender: String, count: Number }],
      locations: [{ country: String, count: Number }]
    },
    
    // Engagement patterns
    chatParticipation: { type: Number, default: 0 }, // percentage
    giftGivers: { type: Number, default: 0 },
    subscribersGained: { type: Number, default: 0 }
  },
  
  // Revenue Analytics
  revenueAnalytics: {
    totalRevenue: { type: Number, default: 0 },
    giftRevenue: { type: Number, default: 0 },
    subscriptionRevenue: { type: Number, default: 0 },
    sponsorshipRevenue: { type: Number, default: 0 },
    averageRevenuePerViewer: { type: Number, default: 0 }
  }
}, {
  timestamps: true
});

// Search Analytics Schema
const searchAnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  sessionId: String,
  
  // Search Details
  searchDetails: {
    query: { type: String, required: true },
    type: { type: String, enum: ['all', 'users', 'posts', 'hashtags', 'locations', 'sounds'] },
    filters: mongoose.Schema.Types.Mixed,
    resultCount: { type: Number, default: 0 },
    clickedResults: [{ 
      resultId: String,
      resultType: String,
      position: Number,
      clickedAt: Date
    }]
  },
  
  // Performance Metrics
  performance: {
    responseTime: Number, // in milliseconds
    relevanceScore: Number,
    clickThroughRate: Number,
    conversionRate: Number
  },
  
  // Context
  context: {
    source: String, // 'search_bar', 'hashtag_click', 'suggestion'
    previousQuery: String,
    userLocation: {
      country: String,
      city: String
    },
    deviceType: String,
    timestamp: { type: Date, default: Date.now }
  }
}, {
  timestamps: true
});

// Business Analytics Schema
const businessAnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  businessId: { type: mongoose.Schema.Types.ObjectId, ref: 'Business' },
  period: { type: String, enum: ['daily', 'weekly', 'monthly'], required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  
  // Business Metrics
  businessMetrics: {
    // Profile metrics
    profileViews: { type: Number, default: 0 },
    websiteClicks: { type: Number, default: 0 },
    callClicks: { type: Number, default: 0 },
    directionClicks: { type: Number, default: 0 },
    
    // Content performance
    contentReach: { type: Number, default: 0 },
    contentImpressions: { type: Number, default: 0 },
    contentEngagement: { type: Number, default: 0 },
    
    // Shopping metrics
    productViews: { type: Number, default: 0 },
    productClicks: { type: Number, default: 0 },
    addToCarts: { type: Number, default: 0 },
    purchases: { type: Number, default: 0 },
    revenue: { type: Number, default: 0 },
    
    // Lead generation
    leads: { type: Number, default: 0 },
    conversions: { type: Number, default: 0 },
    costPerLead: { type: Number, default: 0 },
    returnOnAdSpend: { type: Number, default: 0 }
  },
  
  // Audience Insights
  audienceInsights: {
    totalFollowers: { type: Number, default: 0 },
    followerGrowth: { type: Number, default: 0 },
    audienceRetention: { type: Number, default: 0 },
    
    // Demographics
    demographics: {
      ageGroups: [{ range: String, percentage: Number }],
      genders: [{ gender: String, percentage: Number }],
      locations: [{ location: String, percentage: Number }],
      interests: [{ interest: String, percentage: Number }]
    },
    
    // Behavior patterns
    peakActivityHours: [{ hour: Number, activity: Number }],
    engagementPatterns: [{
      day: String,
      engagementRate: Number
    }]
  },
  
  // Competitive Analysis
  competitiveAnalysis: {
    industryBenchmarks: {
      averageEngagementRate: Number,
      averageFollowerGrowth: Number,
      averageReach: Number
    },
    competitorComparison: [{
      competitorId: String,
      metric: String,
      ourValue: Number,
      theirValue: Number,
      difference: Number
    }]
  }
}, {
  timestamps: true
});

// Indexes for performance
userAnalyticsSchema.index({ userId: 1, date: -1 });
postAnalyticsSchema.index({ postId: 1, date: -1 });
postAnalyticsSchema.index({ userId: 1, date: -1 });
liveStreamAnalyticsSchema.index({ streamId: 1 });
liveStreamAnalyticsSchema.index({ userId: 1, createdAt: -1 });
searchAnalyticsSchema.index({ userId: 1, createdAt: -1 });
searchAnalyticsSchema.index({ 'searchDetails.query': 1 });
businessAnalyticsSchema.index({ userId: 1, period: 1, startDate: -1 });

// Static methods for aggregations
userAnalyticsSchema.statics.getEngagementTrend = function(userId, days = 30) {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  
  return this.aggregate([
    {
      $match: {
        userId: mongoose.Types.ObjectId(userId),
        date: { $gte: startDate }
      }
    },
    {
      $group: {
        _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
        engagementRate: { $avg: "$engagement.engagementRate" },
        totalEngagement: {
          $sum: {
            $add: [
              "$engagement.likesReceived",
              "$engagement.commentsReceived",
              "$engagement.sharesReceived"
            ]
          }
        }
      }
    },
    { $sort: { _id: 1 } }
  ]);
};

postAnalyticsSchema.statics.getTopPerformingPosts = function(userId, limit = 10) {
  return this.aggregate([
    {
      $match: {
        userId: mongoose.Types.ObjectId(userId)
      }
    },
    {
      $sort: { "performance.engagementRate": -1 }
    },
    {
      $limit: limit
    },
    {
      $lookup: {
        from: 'posts',
        localField: 'postId',
        foreignField: '_id',
        as: 'post'
      }
    }
  ]);
};

// Export models
module.exports = {
  UserAnalytics: mongoose.model('UserAnalytics', userAnalyticsSchema),
  PostAnalytics: mongoose.model('PostAnalytics', postAnalyticsSchema),
  LiveStreamAnalytics: mongoose.model('LiveStreamAnalytics', liveStreamAnalyticsSchema),
  SearchAnalytics: mongoose.model('SearchAnalytics', searchAnalyticsSchema),
  BusinessAnalytics: mongoose.model('BusinessAnalytics', businessAnalyticsSchema)
};