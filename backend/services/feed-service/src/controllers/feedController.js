const axios = require('axios');
const mongoose = require('mongoose');

// Feed Algorithm Schema
const feedItemSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentType: { type: String, enum: ['post', 'story', 'reel'], required: true },
  score: { type: Number, required: true },
  reasons: [String],
  createdAt: { type: Date, default: Date.now },
  seenAt: Date,
  interactedAt: Date
});

const FeedItem = mongoose.model('FeedItem', feedItemSchema);

// User Interaction Schema
const userInteractionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentType: String,
  interactionType: { type: String, enum: ['like', 'comment', 'share', 'save', 'view', 'skip'] },
  duration: Number,
  timestamp: { type: Date, default: Date.now }
});

const UserInteraction = mongoose.model('UserInteraction', userInteractionSchema);

class FeedController {
  // Get personalized home feed
  async getHomeFeed(req, res) {
    try {
      const userId = req.user.id;
      const { page = 1, limit = 20 } = req.query;
      const skip = (page - 1) * limit;

      const feedItems = await FeedItem.find({ userId, seenAt: { $exists: false } })
        .sort({ score: -1, createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit));

      const contentPromises = feedItems.map(async (item) => {
        try {
          const response = await axios.get(`http://localhost:3003/api/content/${item.contentType}s/${item.contentId}`);
          return {
            ...response.data,
            feedScore: item.score,
            feedReasons: item.reasons,
            feedId: item._id
          };
        } catch (error) {
          console.error('Error fetching content:', error);
          return null;
        }
      });

      const content = (await Promise.all(contentPromises)).filter(Boolean);

      res.json({
        success: true,
        data: {
          feed: content,
          hasMore: content.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Home feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get explore feed
  async getExploreFeed(req, res) {
    try {
      const { page = 1, limit = 20 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/posts?page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          feed: response.data.posts || [],
          hasMore: response.data.posts?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Explore feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get reels feed
  async getReelsFeed(req, res) {
    try {
      const { page = 1, limit = 10 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/reels?page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          reels: response.data.reels || [],
          hasMore: response.data.reels?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Reels feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get stories feed
  async getStoriesFeed(req, res) {
    try {
      const userId = req.user.id;

      const response = await axios.get(`http://localhost:3003/api/content/stories?userId=${userId}`);
      
      res.json({
        success: true,
        data: {
          stories: response.data.stories || []
        }
      });
    } catch (error) {
      console.error('Stories feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get trending feed
  async getTrendingFeed(req, res) {
    try {
      const { page = 1, limit = 20 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/trending?page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          feed: response.data.posts || [],
          hasMore: response.data.posts?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Trending feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get user feed
  async getUserFeed(req, res) {
    try {
      const { userId } = req.params;
      const { page = 1, limit = 20 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/posts?userId=${userId}&page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          feed: response.data.posts || [],
          hasMore: response.data.posts?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('User feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get hashtag feed
  async getHashtagFeed(req, res) {
    try {
      const { hashtag } = req.params;
      const { page = 1, limit = 20 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/posts?hashtag=${hashtag}&page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          feed: response.data.posts || [],
          hasMore: response.data.posts?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Hashtag feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Get location feed
  async getLocationFeed(req, res) {
    try {
      const { locationId } = req.params;
      const { page = 1, limit = 20 } = req.query;

      const response = await axios.get(`http://localhost:3003/api/content/posts?location=${locationId}&page=${page}&limit=${limit}`);
      
      res.json({
        success: true,
        data: {
          feed: response.data.posts || [],
          hasMore: response.data.posts?.length === parseInt(limit),
          page: parseInt(page)
        }
      });
    } catch (error) {
      console.error('Location feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Refresh feed
  async refreshFeed(req, res) {
    try {
      const userId = req.user.id;

      // Clear old feed items
      await FeedItem.deleteMany({ userId });

      // Generate new feed
      await this.generatePersonalizedFeed(userId);

      res.json({
        success: true,
        message: 'Feed refreshed successfully'
      });
    } catch (error) {
      console.error('Refresh feed error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Mark content as seen
  async markContentSeen(req, res) {
    try {
      const { feedId, duration } = req.body;

      await FeedItem.findByIdAndUpdate(feedId, {
        seenAt: new Date(),
        viewDuration: duration
      });

      res.json({ 
        success: true, 
        message: 'Content marked as seen' 
      });
    } catch (error) {
      console.error('Mark seen error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Report content
  async reportContent(req, res) {
    try {
      const { contentId, reason } = req.body;
      const userId = req.user.id;

      // Forward to moderation service
      await axios.post('http://localhost:3005/api/ai/report', {
        contentId,
        reason,
        reportedBy: userId
      });

      res.json({
        success: true,
        message: 'Content reported successfully'
      });
    } catch (error) {
      console.error('Report content error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Internal server error' 
      });
    }
  }

  // Generate personalized feed
  async generatePersonalizedFeed(userId) {
    try {
      // Get user interactions
      const recentInteractions = await UserInteraction.find({ userId })
        .sort({ timestamp: -1 })
        .limit(100);

      // Get available content
      const contentResponse = await axios.get('http://localhost:3003/api/content/posts?limit=100');
      const posts = contentResponse.data.posts || [];

      // Score content
      const scoredContent = posts.map(post => {
        const score = this.calculateContentScore(post, recentInteractions);
        return {
          userId,
          contentId: post._id,
          contentType: 'post',
          score,
          reasons: this.getScoreReasons(post, recentInteractions)
        };
      });

      // Save to feed
      if (scoredContent.length > 0) {
        await FeedItem.insertMany(scoredContent);
      }
    } catch (error) {
      console.error('Generate feed error:', error);
    }
  }

  // Calculate content score
  calculateContentScore(content, userInteractions) {
    let score = 5; // Base score

    // Recency factor
    const hoursOld = (Date.now() - new Date(content.createdAt)) / (1000 * 60 * 60);
    score += Math.max(0, 10 - hoursOld);

    // Engagement factor
    const engagementRate = (content.likes?.length || 0 + content.comments?.length || 0) / Math.max(1, content.views || 1);
    score += engagementRate * 10;

    // User preference factor
    const userLikedSimilar = userInteractions.filter(i => 
      i.interactionType === 'like' && 
      content.tags?.some(tag => i.contentTags?.includes(tag))
    ).length;
    score += userLikedSimilar * 2;

    // AI quality score
    if (content.aiScore) {
      score += content.aiScore;
    }

    return Math.min(100, Math.max(0, score));
  }

  // Get score reasons
  getScoreReasons(content, userInteractions) {
    const reasons = [];
    
    if (content.aiScore > 8) reasons.push('High quality content');
    if ((content.likes?.length || 0) > 100) reasons.push('Popular post');
    if (new Date(content.createdAt) > new Date(Date.now() - 3600000)) reasons.push('Recent post');
    
    return reasons;
  }
}

module.exports = new FeedController();
module.exports.FeedItem = FeedItem;
module.exports.UserInteraction = UserInteraction;