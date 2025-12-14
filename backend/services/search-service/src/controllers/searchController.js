const { Client } = require('@elastic/elasticsearch');
const Fuse = require('fuse.js');
const natural = require('natural');
const compromise = require('compromise');
const axios = require('axios');
const { validateInput } = require('../utils/validation');
const { SearchAnalytics } = require('../utils/searchAnalytics');
const { TrendingManager } = require('../utils/trendingManager');
const { CacheManager } = require('../utils/cacheManager');
const logger = require('../utils/logger');

class SearchController {
  constructor() {
    this.elasticClient = new Client({
      node: process.env.ELASTICSEARCH_URL || 'http://localhost:9200'
    });
    this.searchAnalytics = new SearchAnalytics();
    this.trendingManager = new TrendingManager();
    this.cacheManager = new CacheManager();
    this.stemmer = natural.PorterStemmer;
  }

  // Universal search
  async universalSearch(req, res) {
    try {
      const userId = req.user.id;
      const { error, value } = validateInput.universalSearch(req.query);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const {
        q: query,
        type = 'all', // 'all', 'users', 'posts', 'hashtags', 'locations', 'sounds'
        page = 1,
        limit = 20,
        filters = {},
        sort = 'relevance' // 'relevance', 'recent', 'popular'
      } = value;

      // Check cache first
      const cacheKey = `search:${query}:${type}:${page}:${limit}:${JSON.stringify(filters)}:${sort}`;
      const cachedResults = await this.cacheManager.get(cacheKey);
      
      if (cachedResults) {
        // Track search analytics
        await this.searchAnalytics.trackSearch(userId, query, type, 'cache_hit');
        
        return res.json({
          success: true,
          data: cachedResults,
          cached: true
        });
      }

      // Process and analyze query
      const processedQuery = this.processSearchQuery(query);
      
      let searchResults = {};

      if (type === 'all') {
        // Perform parallel searches across all types
        const [users, posts, hashtags, locations, sounds] = await Promise.all([
          this.searchUsers(processedQuery, userId, { page: 1, limit: 5 }, filters),
          this.searchPosts(processedQuery, userId, { page: 1, limit: 8 }, filters),
          this.searchHashtags(processedQuery, userId, { page: 1, limit: 5 }, filters),
          this.searchLocations(processedQuery, userId, { page: 1, limit: 3 }, filters),
          this.searchSounds(processedQuery, userId, { page: 1, limit: 3 }, filters)
        ]);

        searchResults = {
          users: users.results,
          posts: posts.results,
          hashtags: hashtags.results,
          locations: locations.results,
          sounds: sounds.results,
          totalResults: users.total + posts.total + hashtags.total + locations.total + sounds.total,
          suggestions: await this.getSearchSuggestions(query, userId),
          trending: await this.getTrendingSearches(userId)
        };
      } else {
        // Perform specific type search
        const searchMethod = this[`search${type.charAt(0).toUpperCase() + type.slice(1)}`];
        if (searchMethod) {
          const results = await searchMethod.call(this, processedQuery, userId, { page, limit }, filters, sort);
          searchResults = {
            [type]: results.results,
            totalResults: results.total,
            pagination: {
              page: parseInt(page),
              limit: parseInt(limit),
              hasMore: results.results.length === parseInt(limit)
            }
          };
        }
      }

      // Add personalized recommendations
      if (searchResults.totalResults === 0) {
        searchResults.recommendations = await this.getSearchRecommendations(query, userId);
      }

      // Cache results
      await this.cacheManager.set(cacheKey, searchResults, 300); // 5 minutes

      // Track search analytics
      await this.searchAnalytics.trackSearch(userId, query, type, 'success', searchResults.totalResults);

      // Update trending searches
      await this.trendingManager.updateSearchTrend(query, userId);

      res.json({
        success: true,
        data: searchResults
      });
    } catch (error) {
      logger.error('Universal search error:', error);
      
      // Track search error
      await this.searchAnalytics.trackSearch(req.user.id, req.query.q, req.query.type, 'error');
      
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Search users
  async searchUsers(processedQuery, userId, pagination, filters = {}, sort = 'relevance') {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      // Build Elasticsearch query
      const esQuery = {
        index: 'users',
        body: {
          query: {
            bool: {
              must: [
                {
                  multi_match: {
                    query: processedQuery.original,
                    fields: [
                      'username^3',
                      'fullName^2',
                      'bio',
                      'location.city',
                      'location.country'
                    ],
                    type: 'best_fields',
                    fuzziness: 'AUTO'
                  }
                }
              ],
              filter: []
            }
          },
          highlight: {
            fields: {
              username: {},
              fullName: {},
              bio: {}
            }
          },
          from: skip,
          size: limit
        }
      };

      // Apply filters
      if (filters.verified) {
        esQuery.body.query.bool.filter.push({ term: { isVerified: true } });
      }

      if (filters.accountType) {
        esQuery.body.query.bool.filter.push({ term: { accountType: filters.accountType } });
      }

      if (filters.location) {
        esQuery.body.query.bool.filter.push({
          geo_distance: {
            distance: filters.radius || '50km',
            'location.coordinates': filters.location
          }
        });
      }

      // Apply sorting
      if (sort === 'popular') {
        esQuery.body.sort = [{ followersCount: { order: 'desc' } }];
      } else if (sort === 'recent') {
        esQuery.body.sort = [{ createdAt: { order: 'desc' } }];
      }

      const response = await this.elasticClient.search(esQuery);
      
      const users = response.body.hits.hits.map(hit => ({
        ...hit._source,
        _id: hit._id,
        _score: hit._score,
        highlights: hit.highlight
      }));

      // Add relationship status for each user
      const usersWithRelationship = await this.addUserRelationships(users, userId);

      return {
        results: usersWithRelationship,
        total: response.body.hits.total.value
      };
    } catch (error) {
      logger.error('Search users error:', error);
      return { results: [], total: 0 };
    }
  }

  // Search posts
  async searchPosts(processedQuery, userId, pagination, filters = {}, sort = 'relevance') {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const esQuery = {
        index: 'posts',
        body: {
          query: {
            bool: {
              must: [
                {
                  multi_match: {
                    query: processedQuery.original,
                    fields: [
                      'content^2',
                      'hashtags^3',
                      'location.name',
                      'aiAnalysis.tags',
                      'aiAnalysis.objects'
                    ],
                    type: 'best_fields',
                    fuzziness: 'AUTO'
                  }
                }
              ],
              filter: [
                { term: { isDeleted: false } },
                { term: { isArchived: false } },
                { term: { visibility: 'public' } }
              ]
            }
          },
          highlight: {
            fields: {
              content: {},
              hashtags: {}
            }
          },
          from: skip,
          size: limit
        }
      };

      // Apply filters
      if (filters.mediaType) {
        esQuery.body.query.bool.filter.push({ term: { 'media.type': filters.mediaType } });
      }

      if (filters.dateRange) {
        esQuery.body.query.bool.filter.push({
          range: {
            createdAt: {
              gte: filters.dateRange.from,
              lte: filters.dateRange.to
            }
          }
        });
      }

      if (filters.minLikes) {
        esQuery.body.query.bool.filter.push({
          range: { likesCount: { gte: filters.minLikes } }
        });
      }

      // Apply sorting
      if (sort === 'popular') {
        esQuery.body.sort = [{ likesCount: { order: 'desc' } }];
      } else if (sort === 'recent') {
        esQuery.body.sort = [{ createdAt: { order: 'desc' } }];
      } else if (sort === 'trending') {
        esQuery.body.sort = [{ trendingScore: { order: 'desc' } }];
      }

      const response = await this.elasticClient.search(esQuery);
      
      const posts = response.body.hits.hits.map(hit => ({
        ...hit._source,
        _id: hit._id,
        _score: hit._score,
        highlights: hit.highlight
      }));

      // Add user interaction status
      const postsWithInteractions = await this.addPostInteractions(posts, userId);

      return {
        results: postsWithInteractions,
        total: response.body.hits.total.value
      };
    } catch (error) {
      logger.error('Search posts error:', error);
      return { results: [], total: 0 };
    }
  }

  // Search hashtags
  async searchHashtags(processedQuery, userId, pagination, filters = {}) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const esQuery = {
        index: 'hashtags',
        body: {
          query: {
            bool: {
              should: [
                {
                  prefix: {
                    tag: processedQuery.original.toLowerCase()
                  }
                },
                {
                  fuzzy: {
                    tag: {
                      value: processedQuery.original.toLowerCase(),
                      fuzziness: 'AUTO'
                    }
                  }
                }
              ]
            }
          },
          sort: [
            { postsCount: { order: 'desc' } },
            { trendingScore: { order: 'desc' } }
          ],
          from: skip,
          size: limit
        }
      };

      const response = await this.elasticClient.search(esQuery);
      
      const hashtags = response.body.hits.hits.map(hit => ({
        ...hit._source,
        _id: hit._id,
        _score: hit._score
      }));

      // Add user's usage history for each hashtag
      const hashtagsWithHistory = await this.addHashtagHistory(hashtags, userId);

      return {
        results: hashtagsWithHistory,
        total: response.body.hits.total.value
      };
    } catch (error) {
      logger.error('Search hashtags error:', error);
      return { results: [], total: 0 };
    }
  }

  // Search locations
  async searchLocations(processedQuery, userId, pagination, filters = {}) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const esQuery = {
        index: 'locations',
        body: {
          query: {
            multi_match: {
              query: processedQuery.original,
              fields: ['name^2', 'address', 'category'],
              type: 'best_fields',
              fuzziness: 'AUTO'
            }
          },
          sort: [{ postsCount: { order: 'desc' } }],
          from: skip,
          size: limit
        }
      };

      // Add geo-location filter if user location is available
      if (filters.nearMe && filters.userLocation) {
        esQuery.body.query = {
          bool: {
            must: [esQuery.body.query],
            filter: {
              geo_distance: {
                distance: '100km',
                coordinates: filters.userLocation
              }
            }
          }
        };
      }

      const response = await this.elasticClient.search(esQuery);
      
      const locations = response.body.hits.hits.map(hit => ({
        ...hit._source,
        _id: hit._id,
        _score: hit._score
      }));

      return {
        results: locations,
        total: response.body.hits.total.value
      };
    } catch (error) {
      logger.error('Search locations error:', error);
      return { results: [], total: 0 };
    }
  }

  // Search sounds/music
  async searchSounds(processedQuery, userId, pagination, filters = {}) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const esQuery = {
        index: 'sounds',
        body: {
          query: {
            multi_match: {
              query: processedQuery.original,
              fields: ['title^3', 'artist^2', 'album', 'genre', 'tags'],
              type: 'best_fields',
              fuzziness: 'AUTO'
            }
          },
          sort: [{ usageCount: { order: 'desc' } }],
          from: skip,
          size: limit
        }
      };

      // Apply filters
      if (filters.genre) {
        esQuery.body.query = {
          bool: {
            must: [esQuery.body.query],
            filter: { term: { genre: filters.genre } }
          }
        };
      }

      if (filters.duration) {
        esQuery.body.query.bool.filter.push({
          range: {
            duration: {
              gte: filters.duration.min,
              lte: filters.duration.max
            }
          }
        });
      }

      const response = await this.elasticClient.search(esQuery);
      
      const sounds = response.body.hits.hits.map(hit => ({
        ...hit._source,
        _id: hit._id,
        _score: hit._score
      }));

      return {
        results: sounds,
        total: response.body.hits.total.value
      };
    } catch (error) {
      logger.error('Search sounds error:', error);
      return { results: [], total: 0 };
    }
  }

  // Get search suggestions
  async getSearchSuggestions(req, res) {
    try {
      const userId = req.user.id;
      const { q: query, limit = 10 } = req.query;

      if (!query || query.length < 2) {
        return res.json({
          success: true,
          data: {
            suggestions: [],
            recent: await this.getRecentSearches(userId, 5),
            trending: await this.getTrendingSearches(userId, 5)
          }
        });
      }

      const cacheKey = `suggestions:${query}:${limit}`;
      const cachedSuggestions = await this.cacheManager.get(cacheKey);
      
      if (cachedSuggestions) {
        return res.json({
          success: true,
          data: cachedSuggestions,
          cached: true
        });
      }

      // Get suggestions from multiple sources
      const [
        userSuggestions,
        hashtagSuggestions,
        locationSuggestions,
        soundSuggestions
      ] = await Promise.all([
        this.getUserSuggestions(query, limit / 4),
        this.getHashtagSuggestions(query, limit / 4),
        this.getLocationSuggestions(query, limit / 4),
        this.getSoundSuggestions(query, limit / 4)
      ]);

      const suggestions = [
        ...userSuggestions,
        ...hashtagSuggestions,
        ...locationSuggestions,
        ...soundSuggestions
      ].slice(0, limit);

      const result = {
        suggestions,
        recent: await this.getRecentSearches(userId, 5),
        trending: await this.getTrendingSearches(userId, 5)
      };

      // Cache suggestions
      await this.cacheManager.set(cacheKey, result, 600); // 10 minutes

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Get search suggestions error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get trending searches
  async getTrendingSearches(req, res) {
    try {
      const userId = req.user.id;
      const { timeframe = '24h', limit = 20 } = req.query;

      const cacheKey = `trending:${timeframe}:${limit}`;
      const cachedTrending = await this.cacheManager.get(cacheKey);
      
      if (cachedTrending) {
        return res.json({
          success: true,
          data: cachedTrending,
          cached: true
        });
      }

      const trending = await this.trendingManager.getTrendingSearches(timeframe, limit);
      
      // Add context for each trending search
      const trendingWithContext = await Promise.all(
        trending.map(async (item) => {
          const context = await this.getSearchContext(item.query);
          return {
            ...item,
            context
          };
        })
      );

      const result = {
        trending: trendingWithContext,
        timeframe,
        generatedAt: new Date().toISOString()
      };

      // Cache trending searches
      await this.cacheManager.set(cacheKey, result, 300); // 5 minutes

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      logger.error('Get trending searches error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Save search to history
  async saveSearch(req, res) {
    try {
      const userId = req.user.id;
      const { query, type, resultCount } = req.body;

      await this.searchAnalytics.saveSearchHistory(userId, {
        query,
        type,
        resultCount,
        timestamp: new Date()
      });

      res.json({
        success: true,
        message: 'Search saved to history'
      });
    } catch (error) {
      logger.error('Save search error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Clear search history
  async clearSearchHistory(req, res) {
    try {
      const userId = req.user.id;

      await this.searchAnalytics.clearSearchHistory(userId);

      res.json({
        success: true,
        message: 'Search history cleared'
      });
    } catch (error) {
      logger.error('Clear search history error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper methods
  processSearchQuery(query) {
    const original = query.trim();
    const normalized = original.toLowerCase();
    const tokens = natural.WordTokenizer.tokenize(normalized);
    const stemmed = tokens.map(token => this.stemmer.stem(token));
    
    // Extract entities using compromise
    const doc = compromise(original);
    const people = doc.people().out('array');
    const places = doc.places().out('array');
    const hashtags = original.match(/#\w+/g) || [];
    const mentions = original.match(/@\w+/g) || [];

    return {
      original,
      normalized,
      tokens,
      stemmed,
      entities: {
        people,
        places,
        hashtags: hashtags.map(tag => tag.substring(1)),
        mentions: mentions.map(mention => mention.substring(1))
      }
    };
  }

  async addUserRelationships(users, userId) {
    // This would typically call the auth service to get relationship status
    return users.map(user => ({
      ...user,
      isFollowing: false, // Placeholder
      isFollower: false,  // Placeholder
      isMutualFollow: false // Placeholder
    }));
  }

  async addPostInteractions(posts, userId) {
    // This would typically call the content service to get interaction status
    return posts.map(post => ({
      ...post,
      isLiked: false, // Placeholder
      isSaved: false, // Placeholder
      isShared: false // Placeholder
    }));
  }

  async addHashtagHistory(hashtags, userId) {
    // Add user's usage history for hashtags
    return hashtags.map(hashtag => ({
      ...hashtag,
      userUsageCount: 0, // Placeholder
      lastUsed: null     // Placeholder
    }));
  }

  async getSearchRecommendations(query, userId) {
    // Generate personalized search recommendations
    return [];
  }

  async getRecentSearches(userId, limit) {
    return this.searchAnalytics.getRecentSearches(userId, limit);
  }

  async getTrendingSearches(userId, limit) {
    return this.trendingManager.getTrendingSearches('24h', limit);
  }

  async getUserSuggestions(query, limit) {
    // Get user suggestions based on query
    return [];
  }

  async getHashtagSuggestions(query, limit) {
    // Get hashtag suggestions based on query
    return [];
  }

  async getLocationSuggestions(query, limit) {
    // Get location suggestions based on query
    return [];
  }

  async getSoundSuggestions(query, limit) {
    // Get sound suggestions based on query
    return [];
  }

  async getSearchContext(query) {
    // Get context information for a search query
    return {
      category: 'general',
      relatedTopics: [],
      popularity: 0
    };
  }
}

module.exports = new SearchController();