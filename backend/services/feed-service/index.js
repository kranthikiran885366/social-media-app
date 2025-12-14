const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');
const { EventEmitter } = require('events');

const app = express();
const redisClient = redis.createClient();
const feedEmitter = new EventEmitter();

app.use(express.json());

// Advanced Feed Algorithm Schema
const FeedAlgorithmSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  preferences: {
    contentTypes: [{ type: String, weight: Number }],
    topics: [{ topic: String, interest: Number }],
    creators: [{ creatorId: mongoose.Schema.Types.ObjectId, affinity: Number }],
    timePreferences: {
      optimalTimes: [Number], // Hours of day
      sessionDuration: Number,
      scrollSpeed: Number
    }
  },
  engagement: {
    likeRate: Number,
    commentRate: Number,
    shareRate: Number,
    saveRate: Number,
    skipRate: Number,
    watchTime: Number
  },
  aiModel: {
    version: String,
    lastTrained: Date,
    accuracy: Number,
    parameters: Object
  }
}, { timestamps: true });

// Content Ranking Schema
const ContentRankingSchema = new mongoose.Schema({
  contentId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentType: { type: String, enum: ['post', 'reel', 'story', 'ad'], required: true },
  authorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  metrics: {
    views: { type: Number, default: 0 },
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    saves: { type: Number, default: 0 },
    engagementRate: { type: Number, default: 0 },
    viralityScore: { type: Number, default: 0 },
    qualityScore: { type: Number, default: 0 }
  },
  targeting: {
    demographics: {
      ageRange: [Number],
      genders: [String],
      locations: [String],
      interests: [String]
    },
    behavioral: {
      deviceTypes: [String],
      platforms: [String],
      timeZones: [String],
      languages: [String]
    }
  },
  performance: {
    ctr: Number, // Click-through rate
    cpm: Number, // Cost per mille
    cpc: Number, // Cost per click
    roi: Number, // Return on investment
    reach: Number,
    impressions: Number
  }
}, { timestamps: true });

const FeedAlgorithm = mongoose.model('FeedAlgorithm', FeedAlgorithmSchema);
const ContentRanking = mongoose.model('ContentRanking', ContentRankingSchema);

// Advanced Feed Service with ML Integration
class FeedService {
  static async generatePersonalizedFeed(userId, options = {}) {
    const { page = 1, limit = 20, feedType = 'home' } = options;
    
    // Get user's AI model
    const userModel = await FeedAlgorithm.findOne({ userId });
    if (!userModel) {
      return this.generateDefaultFeed(userId, options);
    }

    // Multi-stage ranking algorithm
    const candidates = await this.getCandidateContent(userId, userModel);
    const rankedContent = await this.rankContent(candidates, userModel);
    const diversifiedFeed = this.diversifyFeed(rankedContent, userModel);
    
    // Real-time personalization
    const personalizedFeed = await this.applyRealTimeSignals(diversifiedFeed, userId);
    
    // A/B testing integration
    const finalFeed = await this.applyABTests(personalizedFeed, userId);
    
    return this.paginateFeed(finalFeed, page, limit);
  }

  static async getCandidateContent(userId, userModel) {
    const timeWindow = new Date(Date.now() - 24 * 60 * 60 * 1000); // Last 24 hours
    
    // Multi-source content aggregation
    const [
      followingContent,
      recommendedContent,
      trendingContent,
      sponsoredContent
    ] = await Promise.all([
      this.getFollowingContent(userId, timeWindow),
      this.getRecommendedContent(userId, userModel),
      this.getTrendingContent(userModel.preferences.topics),
      this.getSponsoredContent(userId, userModel)
    ]);

    return {
      following: followingContent,
      recommended: recommendedContent,
      trending: trendingContent,
      sponsored: sponsoredContent
    };
  }

  static async rankContent(candidates, userModel) {
    const rankingFactors = {
      relevance: 0.35,      // Content relevance to user interests
      recency: 0.25,        // How recent the content is
      engagement: 0.20,     // Historical engagement metrics
      relationship: 0.15,   // Relationship with content creator
      diversity: 0.05       // Content type diversity
    };

    const rankedContent = [];
    
    for (const [source, contents] of Object.entries(candidates)) {
      for (const content of contents) {
        const score = await this.calculateContentScore(content, userModel, rankingFactors);
        rankedContent.push({ ...content, score, source });
      }
    }

    return rankedContent.sort((a, b) => b.score - a.score);
  }

  static async calculateContentScore(content, userModel, factors) {
    const relevanceScore = this.calculateRelevance(content, userModel);
    const recencyScore = this.calculateRecency(content.createdAt);
    const engagementScore = this.calculateEngagement(content.metrics);
    const relationshipScore = await this.calculateRelationship(content.authorId, userModel.userId);
    const diversityScore = this.calculateDiversity(content.contentType, userModel);

    return (
      relevanceScore * factors.relevance +
      recencyScore * factors.recency +
      engagementScore * factors.engagement +
      relationshipScore * factors.relationship +
      diversityScore * factors.diversity
    );
  }

  static diversifyFeed(rankedContent, userModel) {
    const diversified = [];
    const typeCount = {};
    const authorCount = {};
    
    for (const content of rankedContent) {
      const type = content.contentType;
      const author = content.authorId;
      
      // Ensure content type diversity
      if ((typeCount[type] || 0) >= 3) continue;
      
      // Ensure author diversity
      if ((authorCount[author] || 0) >= 2) continue;
      
      diversified.push(content);
      typeCount[type] = (typeCount[type] || 0) + 1;
      authorCount[author] = (authorCount[author] || 0) + 1;
      
      if (diversified.length >= 50) break; // Limit candidate pool
    }
    
    return diversified;
  }

  static async applyRealTimeSignals(feed, userId) {
    // Get real-time user context
    const context = await this.getRealTimeContext(userId);
    
    return feed.map(content => {
      let boost = 0;
      
      // Time-based boosting
      if (this.isOptimalTime(context.currentTime, context.userTimezone)) {
        boost += 0.1;
      }
      
      // Device-based adjustments
      if (content.contentType === 'reel' && context.device === 'mobile') {
        boost += 0.15;
      }
      
      // Location-based relevance
      if (content.location && this.isNearUser(content.location, context.location)) {
        boost += 0.2;
      }
      
      return { ...content, score: content.score + boost };
    }).sort((a, b) => b.score - a.score);
  }

  static async updateUserEngagement(userId, contentId, action, metadata = {}) {
    const engagementWeights = {
      view: 1,
      like: 5,
      comment: 10,
      share: 15,
      save: 12,
      skip: -2,
      hide: -10
    };

    // Update real-time engagement
    await Promise.all([
      redisClient.zincrby(`user:engagement:${userId}`, engagementWeights[action], contentId),
      redisClient.setex(`user:last_action:${userId}`, 3600, JSON.stringify({
        action,
        contentId,
        timestamp: Date.now(),
        metadata
      })),
      this.updateMLModel(userId, action, contentId, metadata)
    ]);

    // Trigger real-time feed updates
    feedEmitter.emit('engagement', { userId, contentId, action, metadata });
  }

  static async getBusinessFeedInsights(businessId) {
    const insights = await Promise.all([
      this.getContentPerformance(businessId),
      this.getAudienceInsights(businessId),
      this.getOptimalPostingTimes(businessId),
      this.getCompetitorAnalysis(businessId),
      this.getROIMetrics(businessId)
    ]);

    return {
      performance: insights[0],
      audience: insights[1],
      timing: insights[2],
      competition: insights[3],
      roi: insights[4],
      recommendations: await this.generateBusinessRecommendations(businessId)
    };
  }

  // Advanced ML Model Updates
  static async updateMLModel(userId, action, contentId, metadata) {
    const modelKey = `ml:user:${userId}`;
    const update = {
      action,
      contentId,
      timestamp: Date.now(),
      context: metadata
    };
    
    await redisClient.lpush(`${modelKey}:training_data`, JSON.stringify(update));
    await redisClient.ltrim(`${modelKey}:training_data`, 0, 9999); // Keep last 10k interactions
    
    // Trigger model retraining if enough new data
    const dataCount = await redisClient.llen(`${modelKey}:training_data`);
    if (dataCount % 1000 === 0) {
      await this.scheduleModelRetraining(userId);
    }
  }

  // Real-time Feed Updates
  static async broadcastFeedUpdate(userId, update) {
    await redisClient.publish(`feed:updates:${userId}`, JSON.stringify(update));
  }

  // Advanced Analytics
  static async getFeedAnalytics(userId, timeRange = '7d') {
    const analytics = await Promise.all([
      this.getEngagementMetrics(userId, timeRange),
      this.getContentTypePerformance(userId, timeRange),
      this.getTimeBasedInsights(userId, timeRange),
      this.getAudienceGrowth(userId, timeRange)
    ]);

    return {
      engagement: analytics[0],
      contentTypes: analytics[1],
      timing: analytics[2],
      growth: analytics[3],
      predictions: await this.generatePredictions(userId)
    };
  }
}

// Real-time Event Handlers
feedEmitter.on('engagement', async (data) => {
  await FeedService.broadcastFeedUpdate(data.userId, {
    type: 'engagement',
    data
  });
});

// API Routes
app.get('/api/feed/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const options = req.query;
    const feed = await FeedService.generatePersonalizedFeed(userId, options);
    res.json(feed);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/feed/engagement', async (req, res) => {
  try {
    const { userId, contentId, action, metadata } = req.body;
    await FeedService.updateUserEngagement(userId, contentId, action, metadata);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/feed/:businessId/insights', async (req, res) => {
  try {
    const insights = await FeedService.getBusinessFeedInsights(req.params.businessId);
    res.json(insights);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/feed/:userId/analytics', async (req, res) => {
  try {
    const { timeRange } = req.query;
    const analytics = await FeedService.getFeedAnalytics(req.params.userId, timeRange);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3004;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_feed')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Feed service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));