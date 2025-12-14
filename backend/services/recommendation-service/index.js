const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');
const tf = require('@tensorflow/tfjs-node');

const app = express();
app.use(express.json());

const redisClient = redis.createClient();

// User Interaction Schema
const UserInteractionSchema = new mongoose.Schema({
  userId: String,
  contentId: String,
  type: { type: String, enum: ['view', 'like', 'comment', 'share', 'save'] },
  timestamp: { type: Date, default: Date.now },
  duration: Number,
  engagement: Number
});

const UserInteraction = mongoose.model('UserInteraction', UserInteractionSchema);

// AI Recommendation Engine
class RecommendationEngine {
  constructor() {
    this.model = null;
    this.userEmbeddings = new Map();
    this.contentEmbeddings = new Map();
  }

  async initialize() {
    // Load pre-trained model or create new one
    this.model = tf.sequential({
      layers: [
        tf.layers.dense({ inputShape: [100], units: 64, activation: 'relu' }),
        tf.layers.dense({ units: 32, activation: 'relu' }),
        tf.layers.dense({ units: 1, activation: 'sigmoid' })
      ]
    });
    
    this.model.compile({
      optimizer: 'adam',
      loss: 'binaryCrossentropy',
      metrics: ['accuracy']
    });
  }

  async getFeedRecommendations(userId, limit = 20) {
    const cacheKey = `feed:${userId}:${limit}`;
    const cached = await redisClient.get(cacheKey);
    
    if (cached) {
      return JSON.parse(cached);
    }

    const userInteractions = await UserInteraction.find({ userId }).limit(1000);
    const userProfile = this.buildUserProfile(userInteractions);
    
    // Graph-based ranking
    const candidates = await this.getCandidateContent(userId);
    const rankedContent = this.rankContent(candidates, userProfile);
    
    await redisClient.setex(cacheKey, 300, JSON.stringify(rankedContent));
    return rankedContent;
  }

  async getReelsRecommendations(userId, limit = 10) {
    const userInteractions = await UserInteraction.find({ 
      userId, 
      type: { $in: ['view', 'like', 'share'] } 
    }).limit(500);
    
    const preferences = this.extractReelsPreferences(userInteractions);
    const candidates = await this.getReelsCandidates(userId);
    
    return this.rankReels(candidates, preferences).slice(0, limit);
  }

  buildUserProfile(interactions) {
    const profile = {
      interests: {},
      engagementPatterns: {},
      timePreferences: {},
      contentTypes: {}
    };

    interactions.forEach(interaction => {
      // Extract features from interactions
      profile.interests[interaction.contentId] = (profile.interests[interaction.contentId] || 0) + 1;
      profile.engagementPatterns[interaction.type] = (profile.engagementPatterns[interaction.type] || 0) + 1;
    });

    return profile;
  }

  async getCandidateContent(userId) {
    // Mock candidate generation
    return Array.from({ length: 100 }, (_, i) => ({
      id: `content_${i}`,
      score: Math.random(),
      type: ['post', 'reel', 'story'][Math.floor(Math.random() * 3)],
      authorId: `user_${Math.floor(Math.random() * 1000)}`,
      timestamp: new Date(Date.now() - Math.random() * 86400000 * 7)
    }));
  }

  rankContent(candidates, userProfile) {
    return candidates
      .map(content => ({
        ...content,
        relevanceScore: this.calculateRelevanceScore(content, userProfile),
        qualityScore: Math.random() * 10,
        diversityScore: Math.random() * 5
      }))
      .sort((a, b) => {
        const scoreA = a.relevanceScore * 0.5 + a.qualityScore * 0.3 + a.diversityScore * 0.2;
        const scoreB = b.relevanceScore * 0.5 + b.qualityScore * 0.3 + b.diversityScore * 0.2;
        return scoreB - scoreA;
      });
  }

  calculateRelevanceScore(content, userProfile) {
    let score = 0;
    
    // Interest matching
    if (userProfile.interests[content.id]) {
      score += userProfile.interests[content.id] * 0.3;
    }
    
    // Engagement pattern matching
    score += (userProfile.engagementPatterns.like || 0) * 0.2;
    score += (userProfile.engagementPatterns.share || 0) * 0.3;
    
    // Recency boost
    const hoursSincePost = (Date.now() - content.timestamp) / (1000 * 60 * 60);
    score += Math.max(0, 24 - hoursSincePost) * 0.1;
    
    return Math.min(10, score);
  }

  extractReelsPreferences(interactions) {
    return {
      avgWatchTime: interactions.reduce((sum, i) => sum + (i.duration || 0), 0) / interactions.length,
      preferredCategories: ['entertainment', 'education', 'lifestyle'],
      engagementRate: interactions.filter(i => i.type !== 'view').length / interactions.length
    };
  }

  async getReelsCandidates(userId) {
    // Mock reels candidates
    return Array.from({ length: 50 }, (_, i) => ({
      id: `reel_${i}`,
      category: ['entertainment', 'education', 'lifestyle'][Math.floor(Math.random() * 3)],
      duration: 15 + Math.random() * 45,
      engagement: Math.random() * 100,
      views: Math.floor(Math.random() * 10000)
    }));
  }

  rankReels(candidates, preferences) {
    return candidates
      .map(reel => ({
        ...reel,
        score: this.calculateReelScore(reel, preferences)
      }))
      .sort((a, b) => b.score - a.score);
  }

  calculateReelScore(reel, preferences) {
    let score = 0;
    
    // Duration preference
    const durationDiff = Math.abs(reel.duration - preferences.avgWatchTime);
    score += Math.max(0, 30 - durationDiff) * 0.2;
    
    // Category preference
    if (preferences.preferredCategories.includes(reel.category)) {
      score += 5;
    }
    
    // Engagement boost
    score += reel.engagement * 0.1;
    
    // Popularity factor
    score += Math.log(reel.views + 1) * 0.3;
    
    return score;
  }
}

const recommendationEngine = new RecommendationEngine();

// Routes
app.get('/api/recommendations/feed/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 20 } = req.query;
    
    const recommendations = await recommendationEngine.getFeedRecommendations(userId, parseInt(limit));
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/recommendations/reels/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10 } = req.query;
    
    const recommendations = await recommendationEngine.getReelsRecommendations(userId, parseInt(limit));
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/interactions', async (req, res) => {
  try {
    const interaction = new UserInteraction(req.body);
    await interaction.save();
    
    // Update user profile in real-time
    const cacheKey = `feed:${req.body.userId}:*`;
    await redisClient.del(cacheKey);
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/recommendations/ads/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Simple ads delivery algorithm
    const userInteractions = await UserInteraction.find({ userId }).limit(100);
    const interests = userInteractions.reduce((acc, interaction) => {
      acc[interaction.contentId] = (acc[interaction.contentId] || 0) + 1;
      return acc;
    }, {});
    
    const ads = [
      { id: 'ad_1', category: 'fashion', targetScore: Math.random() * 10 },
      { id: 'ad_2', category: 'tech', targetScore: Math.random() * 10 },
      { id: 'ad_3', category: 'food', targetScore: Math.random() * 10 }
    ].sort((a, b) => b.targetScore - a.targetScore);
    
    res.json(ads.slice(0, 2));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3013;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_recommendations')
  .then(async () => {
    await recommendationEngine.initialize();
    app.listen(PORT, () => {
      console.log(`Recommendation service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));