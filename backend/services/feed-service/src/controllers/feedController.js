const axios = require('axios');
const { RecommendationEngine } = require('../utils/recommendationEngine');
const { FeedAlgorithm } = require('../utils/feedAlgorithm');
const { CacheManager } = require('../utils/cacheManager');
const { validateInput } = require('../utils/validation');
const logger = require('../utils/logger');

class FeedController {
  constructor() {
    this.recommendationEngine = new RecommendationEngine();
    this.feedAlgorithm = new FeedAlgorithm();
    this.cacheManager = new CacheManager();
  }

  // Get personalized home feed
  async getHomeFeed(req, res) {
    try {
      const userId = req.user.id;
      const { 
        page = 1, 
        limit = 20,
        refresh = false,
        algorithm = 'personalized' // 'chronological', 'personalized', 'trending'
      } = req.query;

      // Check cache first
      const cacheKey = `feed:${userId}:${algorithm}:${page}:${limit}`;
      if (!refresh) {
        const cachedFeed = await this.cacheManager.get(cacheKey);
        if (cachedFeed) {
          return res.json({
            success: true,
            data: cachedFeed,
            cached: true
          });
        }
      }

      // Get user preferences and behavior data
      const userProfile = await this.getUserProfile(userId);
      const userInteractions = await this.getUserInteractions(userId);
      const followingUsers = await this.getFollowingUsers(userId);

      let feedPosts = [];
      let sponsoredPosts = [];
      let suggestedUsers = [];

      switch (algorithm) {
        case 'chronological':
          feedPosts = await this.getChronologicalFeed(userId, followingUsers, page, limit);
          break;
        case 'trending':
          feedPosts = await this.getTrendingFeed(userId, page, limit);
          break;
        case 'personalized':
        default:
          feedPosts = await this.getPersonalizedFeed(userId, userProfile, userInteractions, followingUsers, page, limit);
          break;
      }

      // Add sponsored content (every 5th post)
      if (page === 1 || (page - 1) * limit % 5 === 0) {
        sponsoredPosts = await this.getSponsoredContent(userId, userProfile, 2);
      }

      // Add suggested users (first page only)
      if (page === 1) {
        suggestedUsers = await this.getSuggestedUsers(userId, userProfile, userInteractions, 5);
      }

      // Merge and sort content
      const mergedFeed = this.mergeFeedContent(feedPosts, sponsoredPosts, suggestedUsers);

      // Apply final ranking and filtering
      const rankedFeed = await this.feedAlgorithm.rankFeed(mergedFeed, userProfile, userInteractions);

      // Add engagement predictions
      const feedWithPredictions = await this.addEngagementPredictions(rankedFeed, userId);

      // Track feed impression
      await this.trackFeedImpression(userId, feedWithPredictions.map(item => item._id), algorithm);

      const result = {
        posts: feedWithPredictions,
        algorithm,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          hasMore: feedWithPredictions.length === parseInt(limit)
        },
        metadata: {
          totalPosts: feedWithPredictions.filter(item => item.type === 'post').length,
          sponsoredCount: feedWithPredictions.filter(item => item.isSponsored).length,
          suggestedUsersCount: feedWithPredictions.filter(item => item.type === 'suggested_user').length,
          generatedAt: new Date().toISOString()
        }
      };

      // Cache the result
      await this.cacheManager.set(cacheKey, result, 300); // 5 minutes

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Get home feed error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get explore feed
  async getExploreFeed(req, res) {
    try {
      const userId = req.user.id;
      const { 
        page = 1, 
        limit = 20,
        category = 'for_you', // 'for_you', 'trending', 'recent', 'popular'
        interests = []
      } = req.query;

      const cacheKey = `explore:${userId}:${category}:${page}:${limit}:${interests.join(',')}`;
      const cachedFeed = await this.cacheManager.get(cacheKey);
      
      if (cachedFeed) {
        return res.json({
          success: true,
          data: cachedFeed,
          cached: true
        });
      }

      const userProfile = await this.getUserProfile(userId);
      const userInteractions = await this.getUserInteractions(userId);

      let explorePosts = [];

      switch (category) {
        case 'trending':
          explorePosts = await this.getTrendingExplorePosts(userId, page, limit);
          break;
        case 'recent':
          explorePosts = await this.getRecentExplorePosts(userId, page, limit);
          break;
        case 'popular':
          explorePosts = await this.getPopularExplorePosts(userId, page, limit);
          break;
        case 'for_you':
        default:
          explorePosts = await this.getPersonalizedExplorePosts(userId, userProfile, userInteractions, interests, page, limit);
          break;
      }

      // Apply diversity and freshness filters
      const diversifiedFeed = await this.diversifyFeed(explorePosts, userProfile);

      // Add engagement predictions
      const feedWithPredictions = await this.addEngagementPredictions(diversifiedFeed, userId);

      const result = {
        posts: feedWithPredictions,
        category,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          hasMore: feedWithPredictions.length === parseInt(limit)
        },
        metadata: {
          totalPosts: feedWithPredictions.length,
          generatedAt: new Date().toISOString()
        }
      };

      // Cache the result
      await this.cacheManager.set(cacheKey, result, 600); // 10 minutes

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Get explore feed error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get reels feed
  async getReelsFeed(req, res) {
    try {
      const userId = req.user.id;
      const { 
        page = 1, 
        limit = 10,
        algorithm = 'personalized'
      } = req.query;

      const cacheKey = `reels:${userId}:${algorithm}:${page}:${limit}`;
      const cachedFeed = await this.cacheManager.get(cacheKey);
      
      if (cachedFeed) {
        return res.json({
          success: true,
          data: cachedFeed,
          cached: true
        });
      }

      const userProfile = await this.getUserProfile(userId);
      const userInteractions = await this.getUserInteractions(userId);

      // Get reels based on algorithm
      let reels = [];
      if (algorithm === 'personalized') {
        reels = await this.getPersonalizedReels(userId, userProfile, userInteractions, page, limit);
      } else {
        reels = await this.getTrendingReels(userId, page, limit);
      }

      // Apply reels-specific ranking
      const rankedReels = await this.feedAlgorithm.rankReels(reels, userProfile, userInteractions);

      // Add engagement predictions and watch time estimates
      const reelsWithPredictions = await this.addReelsMetadata(rankedReels, userId);

      const result = {
        reels: reelsWithPredictions,
        algorithm,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          hasMore: reelsWithPredictions.length === parseInt(limit)
        },
        metadata: {
          totalReels: reelsWithPredictions.length,
          generatedAt: new Date().toISOString()
        }
      };

      // Cache the result
      await this.cacheManager.set(cacheKey, result, 300); // 5 minutes

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Get reels feed error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Update feed preferences
  async updateFeedPreferences(req, res) {
    try {
      const userId = req.user.id;
      const { error, value } = validateInput.updateFeedPreferences(req.body);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const {
        interests = [],
        preferredContentTypes = [],
        showSponsoredContent = true,
        showSuggestedUsers = true,
        feedAlgorithm = 'personalized',
        contentLanguages = ['en'],
        sensitiveContentFilter = 'medium'
      } = value;

      // Update user preferences
      await this.updateUserPreferences(userId, {
        interests,
        preferredContentTypes,
        showSponsoredContent,
        showSuggestedUsers,
        feedAlgorithm,
        contentLanguages,
        sensitiveContentFilter
      });

      // Clear user's feed cache
      await this.cacheManager.clearPattern(`feed:${userId}:*`);
      await this.cacheManager.clearPattern(`explore:${userId}:*`);
      await this.cacheManager.clearPattern(`reels:${userId}:*`);

      logger.info(`Feed preferences updated for user: ${userId}`);

      res.json({
        success: true,
        message: 'Feed preferences updated successfully'
      });
    } catch (error) {
      logger.error('Update feed preferences error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Hide post from feed
  async hidePost(req, res) {
    try {
      const userId = req.user.id;
      const { postId } = req.params;
      const { reason = 'not_interested' } = req.body;

      // Record the hide action
      await this.recordUserAction(userId, 'hide_post', {
        postId,
        reason,
        timestamp: new Date()
      });

      // Update recommendation model
      await this.recommendationEngine.recordNegativeFeedback(userId, postId, reason);

      // Clear relevant caches
      await this.cacheManager.clearPattern(`feed:${userId}:*`);

      logger.info(`Post hidden by user: ${userId}`, { postId, reason });

      res.json({
        success: true,
        message: 'Post hidden from feed'
      });
    } catch (error) {
      logger.error('Hide post error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Report feed issue
  async reportFeedIssue(req, res) {
    try {
      const userId = req.user.id;
      const { error, value } = validateInput.reportFeedIssue(req.body);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const { issueType, description, postId } = value;

      // Record the issue
      await this.recordFeedIssue(userId, {
        issueType,
        description,
        postId,
        timestamp: new Date(),
        userAgent: req.get('User-Agent'),
        ipAddress: req.ip
      });

      logger.info(`Feed issue reported by user: ${userId}`, { issueType, postId });

      res.json({
        success: true,
        message: 'Thank you for your feedback. We will investigate this issue.'
      });
    } catch (error) {
      logger.error('Report feed issue error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper methods
  async getPersonalizedFeed(userId, userProfile, userInteractions, followingUsers, page, limit) {
    try {
      // Get posts from content service
      const response = await axios.get(`${process.env.CONTENT_SERVICE_URL}/api/posts/feed`, {
        params: {
          userId,
          following: followingUsers.join(','),
          page,
          limit: limit * 2, // Get more to allow for filtering
          includeInteractions: true
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });

      const posts = response.data.data.posts || [];

      // Apply personalization
      const personalizedPosts = await this.recommendationEngine.personalizeContent(
        posts,
        userProfile,
        userInteractions
      );

      return personalizedPosts.slice(0, limit);
    } catch (error) {
      logger.error('Get personalized feed error:', error);
      return [];
    }
  }

  async getChronologicalFeed(userId, followingUsers, page, limit) {
    try {
      const response = await axios.get(`${process.env.CONTENT_SERVICE_URL}/api/posts/feed`, {
        params: {
          userId,
          following: followingUsers.join(','),
          page,
          limit,
          sort: 'chronological'
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });

      return response.data.data.posts || [];
    } catch (error) {
      logger.error('Get chronological feed error:', error);
      return [];
    }
  }

  async getTrendingFeed(userId, page, limit) {
    try {
      const response = await axios.get(`${process.env.CONTENT_SERVICE_URL}/api/posts/trending`, {
        params: {
          userId,
          page,
          limit,
          timeframe: '24h'
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });

      return response.data.data.posts || [];
    } catch (error) {
      logger.error('Get trending feed error:', error);
      return [];
    }
  }

  async getSponsoredContent(userId, userProfile, limit) {
    try {
      const response = await axios.get(`${process.env.CONTENT_SERVICE_URL}/api/posts/sponsored`, {
        params: {
          userId,
          limit,
          interests: userProfile.interests?.join(','),
          demographics: JSON.stringify(userProfile.demographics)
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });

      return response.data.data.posts || [];
    } catch (error) {
      logger.error('Get sponsored content error:', error);
      return [];
    }
  }

  async getSuggestedUsers(userId, userProfile, userInteractions, limit) {
    try {
      const response = await axios.get(`${process.env.AUTH_SERVICE_URL}/api/users/suggestions`, {
        params: {
          userId,
          limit,
          interests: userProfile.interests?.join(','),
          mutualConnections: true
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });

      return response.data.data.users || [];
    } catch (error) {
      logger.error('Get suggested users error:', error);
      return [];
    }
  }

  mergeFeedContent(posts, sponsoredPosts, suggestedUsers) {
    const mergedContent = [...posts];

    // Insert sponsored posts every 5th position
    sponsoredPosts.forEach((sponsoredPost, index) => {
      const insertPosition = (index + 1) * 5;
      if (insertPosition < mergedContent.length) {
        mergedContent.splice(insertPosition, 0, { ...sponsoredPost, isSponsored: true });
      } else {
        mergedContent.push({ ...sponsoredPost, isSponsored: true });
      }
    });

    // Insert suggested users at position 3
    if (suggestedUsers.length > 0 && mergedContent.length > 3) {
      mergedContent.splice(3, 0, {
        type: 'suggested_users',
        users: suggestedUsers,
        _id: `suggested_users_${Date.now()}`
      });
    }

    return mergedContent;
  }

  async addEngagementPredictions(posts, userId) {
    return Promise.all(posts.map(async (post) => {
      if (post.type === 'suggested_users') return post;

      const prediction = await this.recommendationEngine.predictEngagement(userId, post._id);
      
      return {
        ...post,
        engagementPrediction: {
          likesProbability: prediction.likesProbability,
          commentsProbability: prediction.commentsProbability,
          sharesProbability: prediction.sharesProbability,
          watchTimePrediction: prediction.watchTimePrediction,
          overallScore: prediction.overallScore
        }
      };
    }));
  }

  async diversifyFeed(posts, userProfile) {
    // Implement content diversity algorithm
    const diversifiedPosts = [];
    const seenCreators = new Set();
    const seenTopics = new Set();

    for (const post of posts) {
      const creatorId = post.userId._id || post.userId;
      const topics = post.hashtags || [];

      // Limit posts from same creator
      if (seenCreators.has(creatorId) && seenCreators.size > 3) {
        continue;
      }

      // Ensure topic diversity
      const hasNewTopic = topics.some(topic => !seenTopics.has(topic));
      if (!hasNewTopic && seenTopics.size > 5) {
        continue;
      }

      diversifiedPosts.push(post);
      seenCreators.add(creatorId);
      topics.forEach(topic => seenTopics.add(topic));

      if (diversifiedPosts.length >= 20) break;
    }

    return diversifiedPosts;
  }

  async getUserProfile(userId) {
    try {
      const response = await axios.get(`${process.env.AUTH_SERVICE_URL}/api/users/${userId}/profile`, {
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });
      return response.data.data.user || {};
    } catch (error) {
      logger.error('Get user profile error:', error);
      return {};
    }
  }

  async getUserInteractions(userId) {
    try {
      const response = await axios.get(`${process.env.ANALYTICS_SERVICE_URL}/api/interactions/${userId}`, {
        params: {
          timeframe: '30d',
          includeEngagement: true
        },
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });
      return response.data.data.interactions || {};
    } catch (error) {
      logger.error('Get user interactions error:', error);
      return {};
    }
  }

  async getFollowingUsers(userId) {
    try {
      const response = await axios.get(`${process.env.AUTH_SERVICE_URL}/api/users/${userId}/following`, {
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });
      return response.data.data.following || [];
    } catch (error) {
      logger.error('Get following users error:', error);
      return [];
    }
  }

  async trackFeedImpression(userId, postIds, algorithm) {
    try {
      await axios.post(`${process.env.ANALYTICS_SERVICE_URL}/api/impressions`, {
        userId,
        postIds,
        algorithm,
        timestamp: new Date(),
        source: 'feed'
      }, {
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });
    } catch (error) {
      logger.error('Track feed impression error:', error);
    }
  }

  async recordUserAction(userId, action, data) {
    try {
      await axios.post(`${process.env.ANALYTICS_SERVICE_URL}/api/actions`, {
        userId,
        action,
        data,
        timestamp: new Date()
      }, {
        headers: {
          'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
        }
      });
    } catch (error) {
      logger.error('Record user action error:', error);
    }
  }
}

module.exports = new FeedController();