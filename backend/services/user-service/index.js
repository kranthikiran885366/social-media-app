const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const app = express();
const redisClient = redis.createClient();

app.use(express.json());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// Advanced User Schema with Business Logic
const UserSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true, index: true },
  email: { type: String, unique: true, required: true, index: true },
  password: { type: String, required: true },
  profile: {
    fullName: String,
    bio: String,
    avatar: String,
    website: String,
    phoneNumber: String,
    dateOfBirth: Date,
    gender: String,
    location: { type: { type: String }, coordinates: [Number] }
  },
  verification: {
    isVerified: { type: Boolean, default: false },
    verificationBadge: String,
    businessAccount: { type: Boolean, default: false },
    creatorAccount: { type: Boolean, default: false }
  },
  privacy: {
    isPrivate: { type: Boolean, default: false },
    allowTagging: { type: Boolean, default: true },
    showActivity: { type: Boolean, default: true },
    allowMessages: { type: String, enum: ['everyone', 'followers', 'none'], default: 'everyone' }
  },
  stats: {
    followersCount: { type: Number, default: 0, index: true },
    followingCount: { type: Number, default: 0 },
    postsCount: { type: Number, default: 0 },
    engagementRate: { type: Number, default: 0 },
    lastActive: { type: Date, default: Date.now }
  },
  monetization: {
    isEligible: { type: Boolean, default: false },
    earnings: { type: Number, default: 0 },
    subscriptionPrice: Number,
    payoutInfo: {
      bankAccount: String,
      taxId: String,
      paypalEmail: String
    }
  },
  preferences: {
    language: { type: String, default: 'en' },
    timezone: String,
    notifications: {
      likes: { type: Boolean, default: true },
      comments: { type: Boolean, default: true },
      follows: { type: Boolean, default: true },
      mentions: { type: Boolean, default: true },
      directMessages: { type: Boolean, default: true }
    },
    contentPreferences: [String],
    aiPersonalization: { type: Boolean, default: true }
  },
  security: {
    twoFactorEnabled: { type: Boolean, default: false },
    twoFactorSecret: String,
    loginAttempts: { type: Number, default: 0 },
    lockUntil: Date,
    devices: [{
      deviceId: String,
      deviceName: String,
      lastLogin: Date,
      location: String,
      isActive: Boolean
    }]
  },
  business: {
    category: String,
    contactEmail: String,
    address: String,
    website: String,
    hours: String,
    promotions: [{
      title: String,
      description: String,
      startDate: Date,
      endDate: Date,
      budget: Number,
      targetAudience: Object
    }]
  }
}, { timestamps: true });

// Advanced Relationship Schema
const RelationshipSchema = new mongoose.Schema({
  follower: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  following: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: { type: String, enum: ['pending', 'accepted', 'blocked'], default: 'accepted' },
  closeFriend: { type: Boolean, default: false },
  notifications: { type: Boolean, default: true },
  mutualFollowers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  relationshipScore: { type: Number, default: 0 }, // AI-calculated engagement score
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', UserSchema);
const Relationship = mongoose.model('Relationship', RelationshipSchema);

// Advanced Business Logic Services
class UserService {
  static async createUser(userData) {
    const hashedPassword = await bcrypt.hash(userData.password, 12);
    const user = new User({
      ...userData,
      password: hashedPassword,
      'stats.lastActive': new Date()
    });
    
    await user.save();
    await this.initializeUserRecommendations(user._id);
    return this.sanitizeUser(user);
  }

  static async authenticateUser(email, password, deviceInfo) {
    const user = await User.findOne({ email }).select('+password');
    if (!user || user.security.lockUntil > Date.now()) {
      throw new Error('Account locked or invalid credentials');
    }

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      await this.handleFailedLogin(user);
      throw new Error('Invalid credentials');
    }

    await this.handleSuccessfulLogin(user, deviceInfo);
    return this.generateTokens(user);
  }

  static async followUser(followerId, followingId) {
    const [follower, following] = await Promise.all([
      User.findById(followerId),
      User.findById(followingId)
    ]);

    if (!follower || !following) throw new Error('User not found');
    if (following.privacy.isPrivate) {
      return this.sendFollowRequest(followerId, followingId);
    }

    const relationship = new Relationship({
      follower: followerId,
      following: followingId,
      status: 'accepted'
    });

    await Promise.all([
      relationship.save(),
      User.findByIdAndUpdate(followerId, { $inc: { 'stats.followingCount': 1 } }),
      User.findByIdAndUpdate(followingId, { $inc: { 'stats.followersCount': 1 } }),
      this.updateRelationshipScore(followerId, followingId),
      this.sendNotification(followingId, 'follow', { userId: followerId })
    ]);

    return relationship;
  }

  static async getPersonalizedFeed(userId, page = 1, limit = 20) {
    const user = await User.findById(userId);
    const following = await Relationship.find({ 
      follower: userId, 
      status: 'accepted' 
    }).select('following relationshipScore');

    // AI-powered feed ranking
    const feedAlgorithm = {
      recency: 0.3,
      engagement: 0.4,
      relationship: 0.2,
      contentType: 0.1
    };

    const feedQuery = {
      $or: [
        { author: { $in: following.map(f => f.following) } },
        { isSponsored: true, targetAudience: { $in: user.preferences.contentPreferences } }
      ],
      createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } // Last 7 days
    };

    return await this.rankFeedContent(feedQuery, user, feedAlgorithm, page, limit);
  }

  static async updateEngagementMetrics(userId, action, targetId) {
    const engagementWeights = {
      like: 1,
      comment: 3,
      share: 5,
      save: 4,
      view: 0.1
    };

    await Promise.all([
      User.findByIdAndUpdate(userId, {
        $inc: { 'stats.engagementRate': engagementWeights[action] * 0.01 }
      }),
      redisClient.zincrby(`user:engagement:${userId}`, engagementWeights[action], targetId),
      this.updateAIPersonalization(userId, action, targetId)
    ]);
  }

  static async getBusinessInsights(userId) {
    const user = await User.findById(userId);
    if (!user.verification.businessAccount) {
      throw new Error('Business account required');
    }

    const insights = await Promise.all([
      this.getFollowerDemographics(userId),
      this.getEngagementAnalytics(userId),
      this.getContentPerformance(userId),
      this.getRevenueMetrics(userId)
    ]);

    return {
      demographics: insights[0],
      engagement: insights[1],
      content: insights[2],
      revenue: insights[3],
      recommendations: await this.getBusinessRecommendations(userId)
    };
  }

  // Advanced AI & ML Integration
  static async updateAIPersonalization(userId, action, targetId) {
    const key = `ai:personalization:${userId}`;
    const data = {
      action,
      targetId,
      timestamp: Date.now(),
      context: await this.getContextualData(userId)
    };
    
    await redisClient.lpush(key, JSON.stringify(data));
    await redisClient.ltrim(key, 0, 999); // Keep last 1000 actions
  }

  static async initializeUserRecommendations(userId) {
    // Initialize ML model for user
    await redisClient.hset(`user:ml:${userId}`, {
      'content_preferences': JSON.stringify([]),
      'engagement_patterns': JSON.stringify({}),
      'optimal_posting_times': JSON.stringify([]),
      'audience_insights': JSON.stringify({})
    });
  }

  // Real-time Features
  static async updateUserActivity(userId, activity) {
    await Promise.all([
      User.findByIdAndUpdate(userId, { 'stats.lastActive': new Date() }),
      redisClient.setex(`user:online:${userId}`, 300, 'true'), // 5 min TTL
      redisClient.publish('user:activity', JSON.stringify({ userId, activity, timestamp: Date.now() }))
    ]);
  }

  // Helper Methods
  static sanitizeUser(user) {
    const userObj = user.toObject();
    delete userObj.password;
    delete userObj.security.twoFactorSecret;
    return userObj;
  }

  static generateTokens(user) {
    const payload = { userId: user._id, email: user.email };
    return {
      accessToken: jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' }),
      refreshToken: jwt.sign(payload, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' })
    };
  }
}

// API Routes with Advanced Business Logic
app.post('/api/users/register', async (req, res) => {
  try {
    const user = await UserService.createUser(req.body);
    res.status(201).json({ user, message: 'User created successfully' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/api/users/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const deviceInfo = {
      userAgent: req.headers['user-agent'],
      ip: req.ip,
      deviceId: req.headers['x-device-id']
    };
    
    const tokens = await UserService.authenticateUser(email, password, deviceInfo);
    res.json(tokens);
  } catch (error) {
    res.status(401).json({ error: error.message });
  }
});

app.post('/api/users/:userId/follow', async (req, res) => {
  try {
    const relationship = await UserService.followUser(req.user.id, req.params.userId);
    res.json(relationship);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/users/:userId/feed', async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const feed = await UserService.getPersonalizedFeed(req.params.userId, page, limit);
    res.json(feed);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/:userId/insights', async (req, res) => {
  try {
    const insights = await UserService.getBusinessInsights(req.params.userId);
    res.json(insights);
  } catch (error) {
    res.status(403).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3001;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_users')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`User service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));