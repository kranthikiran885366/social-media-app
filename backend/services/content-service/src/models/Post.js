const mongoose = require('mongoose');

const mediaSchema = new mongoose.Schema({
  type: { type: String, enum: ['image', 'video', 'audio'], required: true },
  url: { type: String, required: true },
  thumbnailUrl: String,
  duration: Number, // for video/audio in seconds
  dimensions: {
    width: Number,
    height: Number
  },
  size: Number, // file size in bytes
  format: String,
  altText: String,
  blurHash: String, // for progressive image loading
  processingStatus: { type: String, enum: ['pending', 'processing', 'completed', 'failed'], default: 'pending' }
});

const locationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  address: String,
  coordinates: {
    type: [Number], // [longitude, latitude]
    index: '2dsphere'
  },
  placeId: String, // Google Places ID
  category: String
});

const hashtagSchema = new mongoose.Schema({
  tag: { type: String, required: true, lowercase: true },
  count: { type: Number, default: 1 }
});

const mentionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  username: { type: String, required: true },
  position: {
    x: Number, // percentage from left
    y: Number  // percentage from top
  }
});

const commentSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true, maxlength: 2200 },
  media: [mediaSchema],
  mentions: [mentionSchema],
  hashtags: [String],
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  likesCount: { type: Number, default: 0 },
  replies: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    content: { type: String, required: true, maxlength: 2200 },
    mentions: [mentionSchema],
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    likesCount: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
    isEdited: { type: Boolean, default: false },
    editedAt: Date
  }],
  repliesCount: { type: Number, default: 0 },
  isPinned: { type: Boolean, default: false },
  isEdited: { type: Boolean, default: false },
  editedAt: Date,
  createdAt: { type: Date, default: Date.now }
});

const pollSchema = new mongoose.Schema({
  question: { type: String, required: true, maxlength: 280 },
  options: [{
    text: { type: String, required: true, maxlength: 100 },
    votes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    votesCount: { type: Number, default: 0 }
  }],
  totalVotes: { type: Number, default: 0 },
  expiresAt: Date,
  allowMultipleChoices: { type: Boolean, default: false }
});

const productTagSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  position: {
    x: Number, // percentage from left
    y: Number  // percentage from top
  },
  mediaIndex: { type: Number, default: 0 } // which media item this tag is on
});

const collaboratorSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  role: { type: String, enum: ['co-author', 'featured'], default: 'featured' },
  confirmed: { type: Boolean, default: false }
});

const postSchema = new mongoose.Schema({
  // Basic Info
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['post', 'reel', 'story', 'live'], default: 'post' },
  content: { type: String, maxlength: 2200 },
  media: [mediaSchema],
  
  // Engagement
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  likesCount: { type: Number, default: 0 },
  comments: [commentSchema],
  commentsCount: { type: Number, default: 0 },
  shares: [{ 
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    sharedAt: { type: Date, default: Date.now },
    platform: String // 'instagram', 'facebook', 'twitter', etc.
  }],
  sharesCount: { type: Number, default: 0 },
  saves: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  savesCount: { type: Number, default: 0 },
  views: [{ 
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    viewedAt: { type: Date, default: Date.now },
    duration: Number, // viewing duration in seconds
    source: String // 'feed', 'profile', 'explore', 'hashtag', etc.
  }],
  viewsCount: { type: Number, default: 0 },
  
  // Social Features
  hashtags: [String],
  mentions: [mentionSchema],
  location: locationSchema,
  collaborators: [collaboratorSchema],
  
  // Interactive Features
  poll: pollSchema,
  productTags: [productTagSchema],
  
  // Privacy & Visibility
  visibility: { type: String, enum: ['public', 'private', 'friends', 'close_friends'], default: 'public' },
  allowComments: { type: Boolean, default: true },
  allowSharing: { type: Boolean, default: true },
  allowDownload: { type: Boolean, default: true },
  hideLikesCount: { type: Boolean, default: false },
  
  // Moderation & Safety
  isReported: { type: Boolean, default: false },
  reportCount: { type: Number, default: 0 },
  reports: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: { type: String, enum: ['spam', 'harassment', 'hate_speech', 'violence', 'nudity', 'copyright', 'other'] },
    description: String,
    reportedAt: { type: Date, default: Date.now }
  }],
  moderationStatus: { type: String, enum: ['pending', 'approved', 'rejected', 'under_review'], default: 'pending' },
  moderationNotes: String,
  
  // AI Analysis
  aiAnalysis: {
    contentScore: { type: Number, min: 0, max: 10 }, // Overall content quality
    sentimentScore: { type: Number, min: -1, max: 1 }, // Sentiment analysis
    toxicityScore: { type: Number, min: 0, max: 1 }, // Toxicity detection
    spamScore: { type: Number, min: 0, max: 1 }, // Spam detection
    adultContentScore: { type: Number, min: 0, max: 1 }, // Adult content detection
    violenceScore: { type: Number, min: 0, max: 1 }, // Violence detection
    tags: [String], // AI-generated tags
    objects: [String], // Detected objects in images/videos
    faces: Number, // Number of faces detected
    text: String, // Extracted text from images
    language: String, // Detected language
    emotions: [{ emotion: String, confidence: Number }],
    lastAnalyzed: Date
  },
  
  // Performance Metrics
  engagement: {
    rate: { type: Number, default: 0 }, // (likes + comments + shares) / views
    reach: { type: Number, default: 0 }, // unique users who saw the post
    impressions: { type: Number, default: 0 }, // total times post was displayed
    clickThroughRate: { type: Number, default: 0 },
    averageWatchTime: { type: Number, default: 0 }, // for videos
    completionRate: { type: Number, default: 0 }, // for videos
    peakViewers: { type: Number, default: 0 }, // for live content
    demographics: {
      ageGroups: [{
        range: String, // "18-24", "25-34", etc.
        percentage: Number
      }],
      genders: [{
        gender: String,
        percentage: Number
      }],
      locations: [{
        country: String,
        percentage: Number
      }]
    }
  },
  
  // Monetization
  isSponsored: { type: Boolean, default: false },
  sponsorInfo: {
    brandId: { type: mongoose.Schema.Types.ObjectId, ref: 'Brand' },
    campaignId: { type: mongoose.Schema.Types.ObjectId, ref: 'Campaign' },
    disclosureText: String,
    paymentAmount: Number,
    currency: String
  },
  isBoosted: { type: Boolean, default: false },
  boostInfo: {
    budget: Number,
    currency: String,
    targetAudience: {
      ageRange: { min: Number, max: Number },
      genders: [String],
      locations: [String],
      interests: [String]
    },
    startDate: Date,
    endDate: Date,
    status: { type: String, enum: ['active', 'paused', 'completed', 'cancelled'] }
  },
  
  // Scheduling
  isScheduled: { type: Boolean, default: false },
  scheduledFor: Date,
  publishedAt: Date,
  
  // Cross-posting
  crossPosts: [{
    platform: String, // 'facebook', 'twitter', 'tiktok', etc.
    postId: String,
    url: String,
    status: { type: String, enum: ['pending', 'published', 'failed'] }
  }],
  
  // Archive & Deletion
  isArchived: { type: Boolean, default: false },
  archivedAt: Date,
  isDeleted: { type: Boolean, default: false },
  deletedAt: Date,
  
  // Edit History
  isEdited: { type: Boolean, default: false },
  editHistory: [{
    content: String,
    editedAt: { type: Date, default: Date.now },
    reason: String
  }],
  
  // Trending & Algorithm
  trendingScore: { type: Number, default: 0 },
  algorithmBoost: { type: Number, default: 1 }, // multiplier for algorithm ranking
  lastEngagement: Date,
  
  // Collections & Series
  collections: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Collection' }],
  series: { type: mongoose.Schema.Types.ObjectId, ref: 'Series' },
  episodeNumber: Number
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
postSchema.index({ userId: 1, createdAt: -1 });
postSchema.index({ hashtags: 1 });
postSchema.index({ 'location.coordinates': '2dsphere' });
postSchema.index({ visibility: 1, createdAt: -1 });
postSchema.index({ trendingScore: -1, createdAt: -1 });
postSchema.index({ 'aiAnalysis.contentScore': -1 });
postSchema.index({ type: 1, createdAt: -1 });
postSchema.index({ isDeleted: 1, isArchived: 1 });

// Virtual for engagement rate calculation
postSchema.virtual('engagementRate').get(function() {
  if (this.viewsCount === 0) return 0;
  return ((this.likesCount + this.commentsCount + this.sharesCount) / this.viewsCount) * 100;
});

// Virtual for time since posted
postSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const posted = this.publishedAt || this.createdAt;
  const diffMs = now - posted;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m`;
  if (diffHours < 24) return `${diffHours}h`;
  if (diffDays < 7) return `${diffDays}d`;
  return posted.toLocaleDateString();
});

// Pre-save middleware
postSchema.pre('save', function(next) {
  // Update counts
  this.likesCount = this.likes.length;
  this.commentsCount = this.comments.length;
  this.sharesCount = this.shares.length;
  this.savesCount = this.saves.length;
  this.viewsCount = this.views.length;
  
  // Update engagement metrics
  this.engagement.rate = this.engagementRate;
  this.lastEngagement = new Date();
  
  // Calculate trending score
  this.calculateTrendingScore();
  
  next();
});

// Methods
postSchema.methods.calculateTrendingScore = function() {
  const now = new Date();
  const ageHours = (now - this.createdAt) / (1000 * 60 * 60);
  const engagementWeight = this.likesCount + (this.commentsCount * 2) + (this.sharesCount * 3);
  const timeDecay = Math.exp(-ageHours / 24); // Decay over 24 hours
  
  this.trendingScore = engagementWeight * timeDecay * this.algorithmBoost;
};

postSchema.methods.addView = function(userId, source = 'feed', duration = 0) {
  // Avoid duplicate views from same user within 1 hour
  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
  const recentView = this.views.find(view => 
    view.userId.toString() === userId.toString() && 
    view.viewedAt > oneHourAgo
  );
  
  if (!recentView) {
    this.views.push({
      userId,
      viewedAt: new Date(),
      duration,
      source
    });
    this.engagement.impressions += 1;
  }
};

postSchema.methods.addLike = function(userId) {
  if (!this.likes.includes(userId)) {
    this.likes.push(userId);
    return true;
  }
  return false;
};

postSchema.methods.removeLike = function(userId) {
  const index = this.likes.indexOf(userId);
  if (index > -1) {
    this.likes.splice(index, 1);
    return true;
  }
  return false;
};

postSchema.methods.addComment = function(commentData) {
  const comment = {
    ...commentData,
    createdAt: new Date()
  };
  this.comments.push(comment);
  return comment;
};

postSchema.methods.addShare = function(userId, platform = 'instagram') {
  this.shares.push({
    userId,
    sharedAt: new Date(),
    platform
  });
};

postSchema.methods.addSave = function(userId) {
  if (!this.saves.includes(userId)) {
    this.saves.push(userId);
    return true;
  }
  return false;
};

postSchema.methods.removeSave = function(userId) {
  const index = this.saves.indexOf(userId);
  if (index > -1) {
    this.saves.splice(index, 1);
    return true;
  }
  return false;
};

postSchema.methods.addReport = function(reportData) {
  this.reports.push({
    ...reportData,
    reportedAt: new Date()
  });
  this.reportCount = this.reports.length;
  this.isReported = true;
};

postSchema.methods.toSafeObject = function(currentUserId = null) {
  const postObject = this.toObject();
  
  // Remove sensitive data
  delete postObject.reports;
  delete postObject.aiAnalysis;
  delete postObject.sponsorInfo;
  delete postObject.boostInfo;
  
  // Add user-specific data
  if (currentUserId) {
    postObject.isLiked = this.likes.includes(currentUserId);
    postObject.isSaved = this.saves.includes(currentUserId);
  }
  
  return postObject;
};

module.exports = mongoose.model('Post', postSchema);