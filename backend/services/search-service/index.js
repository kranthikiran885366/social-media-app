const express = require('express');
const mongoose = require('mongoose');
const { Client } = require('@elastic/elasticsearch');
const redis = require('redis');

const app = express();
const esClient = new Client({ node: process.env.ELASTICSEARCH_URL || 'http://localhost:9200' });
const redisClient = redis.createClient();

app.use(express.json());

// Advanced Search Index Schemas
const SearchIndexSchema = new mongoose.Schema({
  entityType: { type: String, enum: ['user', 'post', 'hashtag', 'location', 'audio'], required: true },
  entityId: { type: mongoose.Schema.Types.ObjectId, required: true },
  
  searchableContent: {
    primary: String,      // Main searchable text
    secondary: [String],  // Additional searchable fields
    keywords: [String],   // Extracted keywords
    hashtags: [String],   // Associated hashtags
    mentions: [String]    // User mentions
  },
  
  metadata: {
    author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdAt: Date,
    location: {
      type: { type: String, default: 'Point' },
      coordinates: [Number],
      name: String,
      city: String,
      country: String
    },
    language: String,
    contentType: String,
    mediaType: [String]
  },
  
  popularity: {
    searchCount: { type: Number, default: 0 },
    clickCount: { type: Number, default: 0 },
    engagementScore: { type: Number, default: 0 },
    trendingScore: { type: Number, default: 0 },
    qualityScore: { type: Number, default: 0 }
  },
  
  targeting: {
    demographics: {
      ageGroups: [String],
      genders: [String],
      interests: [String]
    },
    geographic: {
      countries: [String],
      cities: [String],
      radius: Number
    }
  }
}, { timestamps: true });

// Search Analytics Schema
const SearchAnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  query: String,
  filters: Object,
  results: {
    count: Number,
    topResults: [mongoose.Schema.Types.ObjectId],
    clickedResults: [mongoose.Schema.Types.ObjectId],
    searchTime: Number
  },
  context: {
    location: { type: { type: String }, coordinates: [Number] },
    device: String,
    platform: String,
    sessionId: String
  },
  timestamp: { type: Date, default: Date.now }
});

const SearchIndex = mongoose.model('SearchIndex', SearchIndexSchema);
const SearchAnalytics = mongoose.model('SearchAnalytics', SearchAnalyticsSchema);

// Advanced Search Service
class SearchService {
  static async initializeElasticsearch() {
    try {
      // Create indices with advanced mappings
      await this.createUserIndex();
      await this.createContentIndex();
      await this.createHashtagIndex();
      await this.createLocationIndex();
      console.log('Elasticsearch indices initialized');
    } catch (error) {
      console.error('Elasticsearch initialization error:', error);
    }
  }

  static async universalSearch(query, options = {}) {
    const {
      userId,
      filters = {},
      page = 1,
      limit = 20,
      sortBy = 'relevance',
      searchType = 'all'
    } = options;

    // Multi-index search with boosting
    const searchBody = {
      query: {
        bool: {
          should: [
            // User search with personalization boost
            {
              multi_match: {
                query,
                fields: ['username^3', 'fullName^2', 'bio'],
                type: 'best_fields',
                boost: await this.getUserPersonalizationBoost(userId, 'user')
              }
            },
            // Content search with engagement boost
            {
              multi_match: {
                query,
                fields: ['caption^2', 'hashtags^1.5', 'location.name'],
                type: 'cross_fields',
                boost: await this.getEngagementBoost('content')
              }
            },
            // Hashtag search with trending boost
            {
              match: {
                'hashtag': {
                  query,
                  boost: await this.getTrendingBoost('hashtag')
                }
              }
            },
            // Location search with proximity boost
            {
              match: {
                'location.name': {
                  query,
                  boost: await this.getProximityBoost(userId, 'location')
                }
              }
            }
          ],
          filter: this.buildFilters(filters),
          minimum_should_match: 1
        }
      },
      sort: this.buildSort(sortBy, userId),
      from: (page - 1) * limit,
      size: limit,
      highlight: {
        fields: {
          '*': {}
        }
      },
      aggs: {
        types: {
          terms: { field: 'entityType' }
        },
        locations: {
          terms: { field: 'location.city' }
        },
        timeRanges: {
          date_range: {
            field: 'createdAt',
            ranges: [
              { key: 'last_hour', from: 'now-1h' },
              { key: 'last_day', from: 'now-1d' },
              { key: 'last_week', from: 'now-7d' },
              { key: 'last_month', from: 'now-30d' }
            ]
          }
        }
      }
    };

    const response = await esClient.search({
      index: ['users', 'content', 'hashtags', 'locations'],
      body: searchBody
    });

    // Track search analytics
    await this.trackSearchAnalytics(userId, query, filters, response);

    return this.formatSearchResults(response, query);
  }

  static async smartAutoComplete(query, userId, options = {}) {
    const { limit = 10, types = ['user', 'hashtag', 'location'] } = options;

    // Get user's search history for personalization
    const searchHistory = await this.getUserSearchHistory(userId);
    
    // Multi-source autocomplete
    const suggestions = await Promise.all([
      this.getTypedSuggestions(query, 'user', limit / 3),
      this.getTypedSuggestions(query, 'hashtag', limit / 3),
      this.getTypedSuggestions(query, 'location', limit / 3),
      this.getPersonalizedSuggestions(query, userId, searchHistory)
    ]);

    const combined = suggestions.flat();
    
    // Rank suggestions with ML scoring
    const rankedSuggestions = await this.rankSuggestions(combined, userId, query);
    
    return rankedSuggestions.slice(0, limit);
  }

  static async getTrendingSearches(options = {}) {
    const { timeRange = '24h', location, category, limit = 20 } = options;

    const trendingQuery = {
      query: {
        bool: {
          filter: [
            {
              range: {
                timestamp: {
                  gte: `now-${timeRange}`
                }
              }
            }
          ]
        }
      },
      aggs: {
        trending_queries: {
          terms: {
            field: 'query.keyword',
            size: limit,
            order: { search_volume: 'desc' }
          },
          aggs: {
            search_volume: {
              sum: { field: 'searchCount' }
            },
            growth_rate: {
              derivative: {
                buckets_path: 'search_volume'
              }
            }
          }
        }
      }
    };

    if (location) {
      trendingQuery.query.bool.filter.push({
        geo_distance: {
          distance: '50km',
          'context.location': location
        }
      });
    }

    const response = await esClient.search({
      index: 'search_analytics',
      body: trendingQuery
    });

    return this.formatTrendingResults(response);
  }

  static async getSearchInsights(userId, timeRange = '30d') {
    const insights = await Promise.all([
      this.getUserSearchPatterns(userId, timeRange),
      this.getPopularSearches(userId, timeRange),
      this.getSearchPerformanceMetrics(userId, timeRange),
      this.getSearchRecommendations(userId)
    ]);

    return {
      patterns: insights[0],
      popular: insights[1],
      performance: insights[2],
      recommendations: insights[3]
    };
  }

  // Advanced ML-powered search ranking
  static async rankSearchResults(results, userId, query, context = {}) {
    const rankingFactors = {
      relevance: 0.35,      // Text relevance score
      popularity: 0.25,     // Global popularity
      personalization: 0.20, // User personalization
      recency: 0.15,        // Content freshness
      quality: 0.05         // Content quality score
    };

    const rankedResults = [];

    for (const result of results) {
      const scores = {
        relevance: this.calculateRelevanceScore(result, query),
        popularity: this.calculatePopularityScore(result),
        personalization: await this.calculatePersonalizationScore(result, userId),
        recency: this.calculateRecencyScore(result),
        quality: this.calculateQualityScore(result)
      };

      const finalScore = Object.entries(scores).reduce((total, [factor, score]) => {
        return total + (score * rankingFactors[factor]);
      }, 0);

      rankedResults.push({ ...result, searchScore: finalScore, scores });
    }

    return rankedResults.sort((a, b) => b.searchScore - a.searchScore);
  }

  // Real-time search suggestions
  static async getRealtimeSuggestions(query, userId) {
    const cacheKey = `suggestions:${userId}:${query}`;
    const cached = await redisClient.get(cacheKey);
    
    if (cached) {
      return JSON.parse(cached);
    }

    const suggestions = await this.generateRealtimeSuggestions(query, userId);
    await redisClient.setex(cacheKey, 300, JSON.stringify(suggestions)); // 5 min cache
    
    return suggestions;
  }

  // Business search analytics
  static async getBusinessSearchMetrics(businessId) {
    const metrics = await SearchAnalytics.aggregate([
      {
        $match: {
          'results.clickedResults': mongoose.Types.ObjectId(businessId),
          timestamp: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
        }
      },
      {
        $group: {
          _id: null,
          totalSearches: { $sum: 1 },
          uniqueUsers: { $addToSet: '$userId' },
          avgPosition: { $avg: { $indexOfArray: ['$results.topResults', mongoose.Types.ObjectId(businessId)] } },
          topQueries: { $push: '$query' }
        }
      }
    ]);

    return metrics[0] || {};
  }

  // Advanced filtering and faceting
  static buildAdvancedFilters(filters, userId) {
    const esFilters = [];

    // Content type filter
    if (filters.contentType) {
      esFilters.push({ term: { contentType: filters.contentType } });
    }

    // Date range filter
    if (filters.dateRange) {
      esFilters.push({
        range: {
          createdAt: {
            gte: filters.dateRange.start,
            lte: filters.dateRange.end
          }
        }
      });
    }

    // Location filter with radius
    if (filters.location && filters.radius) {
      esFilters.push({
        geo_distance: {
          distance: `${filters.radius}km`,
          location: filters.location
        }
      });
    }

    // Engagement filter
    if (filters.minEngagement) {
      esFilters.push({
        range: {
          engagementScore: { gte: filters.minEngagement }
        }
      });
    }

    // Personalization filter
    if (filters.personalized && userId) {
      esFilters.push({
        terms: {
          'targeting.demographics.interests': await this.getUserInterests(userId)
        }
      });
    }

    return esFilters;
  }
}

// Initialize Elasticsearch on startup
SearchService.initializeElasticsearch();

// API Routes
app.get('/api/search', async (req, res) => {
  try {
    const { q: query, ...options } = req.query;
    const results = await SearchService.universalSearch(query, options);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/search/autocomplete', async (req, res) => {
  try {
    const { q: query, userId } = req.query;
    const suggestions = await SearchService.smartAutoComplete(query, userId, req.query);
    res.json(suggestions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/search/trending', async (req, res) => {
  try {
    const trending = await SearchService.getTrendingSearches(req.query);
    res.json(trending);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/search/:userId/insights', async (req, res) => {
  try {
    const { timeRange } = req.query;
    const insights = await SearchService.getSearchInsights(req.params.userId, timeRange);
    res.json(insights);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/search/index', async (req, res) => {
  try {
    const { entityType, entityId, data } = req.body;
    await SearchService.indexEntity(entityType, entityId, data);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3009;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_search')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Search service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));