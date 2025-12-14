const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const AWS = require('aws-sdk');
const sharp = require('sharp');
const cors = require('cors');
const helmet = require('helmet');
const { v4: uuidv4 } = require('uuid');
const winston = require('winston');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3003;

// Logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
  transports: [new winston.transports.Console()]
});

// AWS S3 setup
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_content');

// Post Schema
const postSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  caption: { type: String, maxlength: 2200 },
  media: [{
    type: { type: String, enum: ['image', 'video'], required: true },
    url: { type: String, required: true },
    thumbnail: String,
    duration: Number,
    dimensions: { width: Number, height: Number }
  }],
  location: {
    name: String,
    coordinates: { lat: Number, lng: Number }
  },
  tags: [String],
  mentions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  comments: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    text: { type: String, required: true, maxlength: 500 },
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    replies: [{
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      text: { type: String, maxlength: 500 },
      createdAt: { type: Date, default: Date.now }
    }],
    createdAt: { type: Date, default: Date.now }
  }],
  aiScore: { type: Number, min: 1, max: 10, default: 5 },
  aiAnalysis: {
    qualityScore: Number,
    sentimentScore: Number,
    educationalValue: Number,
    originalityScore: Number,
    spamProbability: Number,
    topics: [String],
    isApproved: { type: Boolean, default: false }
  },
  visibility: { type: String, enum: ['public', 'followers', 'close_friends'], default: 'public' },
  isArchived: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const Post = mongoose.model('Post', postSchema);

// Story Schema
const storySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  media: {
    type: { type: String, enum: ['image', 'video'], required: true },
    url: { type: String, required: true },
    duration: Number
  },
  text: String,
  backgroundColor: String,
  music: {
    title: String,
    artist: String,
    url: String
  },
  viewers: [{ 
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    viewedAt: { type: Date, default: Date.now }
  }],
  visibility: { type: String, enum: ['public', 'followers', 'close_friends'], default: 'followers' },
  expiresAt: { type: Date, default: () => new Date(Date.now() + 24 * 60 * 60 * 1000) },
  createdAt: { type: Date, default: Date.now }
});

const Story = mongoose.model('Story', storySchema);

// Reel Schema
const reelSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  video: {
    url: { type: String, required: true },
    thumbnail: String,
    duration: { type: Number, required: true }
  },
  caption: { type: String, maxlength: 2200 },
  music: {
    title: String,
    artist: String,
    url: String,
    startTime: { type: Number, default: 0 }
  },
  effects: [String],
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  comments: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    text: { type: String, required: true, maxlength: 500 },
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    createdAt: { type: Date, default: Date.now }
  }],
  shares: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  views: [{ 
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    viewedAt: { type: Date, default: Date.now },
    watchTime: Number
  }],
  aiScore: { type: Number, min: 1, max: 10, default: 5 },
  aiAnalysis: {
    qualityScore: Number,
    engagementPrediction: Number,
    contentType: String,
    isApproved: { type: Boolean, default: false }
  },
  createdAt: { type: Date, default: Date.now }
});

const Reel = mongoose.model('Reel', reelSchema);

// Multer setup for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/quicktime'];
    cb(null, allowedTypes.includes(file.mimetype));
  }
});

// Upload media to S3
const uploadToS3 = async (buffer, filename, contentType) => {
  const params = {
    Bucket: process.env.AWS_S3_BUCKET || 'smart-social-media',
    Key: filename,
    Body: buffer,
    ContentType: contentType,
    ACL: 'public-read'
  };
  
  const result = await s3.upload(params).promise();
  return result.Location;
};

// Create post
app.post('/api/content/posts', upload.array('media', 10), async (req, res) => {
  try {
    const { userId, caption, location, tags, visibility } = req.body;
    const files = req.files;

    if (!files || files.length === 0) {
      return res.status(400).json({ error: 'At least one media file required' });
    }

    const mediaItems = [];

    for (const file of files) {
      const fileId = uuidv4();
      const isVideo = file.mimetype.startsWith('video/');
      
      let processedBuffer = file.buffer;
      let dimensions = {};

      if (!isVideo) {
        // Process image with Sharp
        const processed = sharp(file.buffer)
          .resize(1080, 1080, { fit: 'inside', withoutEnlargement: true })
          .jpeg({ quality: 85 });
        
        processedBuffer = await processed.toBuffer();
        const metadata = await sharp(processedBuffer).metadata();
        dimensions = { width: metadata.width, height: metadata.height };
      }

      const filename = `posts/${userId}/${fileId}.${isVideo ? 'mp4' : 'jpg'}`;
      const url = await uploadToS3(processedBuffer, filename, file.mimetype);

      mediaItems.push({
        type: isVideo ? 'video' : 'image',
        url,
        dimensions: isVideo ? undefined : dimensions,
        duration: isVideo ? undefined : undefined
      });
    }

    const post = new Post({
      userId,
      caption,
      media: mediaItems,
      location: location ? JSON.parse(location) : undefined,
      tags: tags ? JSON.parse(tags) : [],
      visibility: visibility || 'public'
    });

    await post.save();

    // Trigger AI analysis (async)
    analyzeContent(post._id, 'post');

    logger.info(`Post created: ${post._id}`);
    res.status(201).json({ message: 'Post created successfully', postId: post._id });
  } catch (error) {
    logger.error('Post creation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create story
app.post('/api/content/stories', upload.single('media'), async (req, res) => {
  try {
    const { userId, text, backgroundColor, visibility } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ error: 'Media file required' });
    }

    const fileId = uuidv4();
    const isVideo = file.mimetype.startsWith('video/');
    const filename = `stories/${userId}/${fileId}.${isVideo ? 'mp4' : 'jpg'}`;
    
    const url = await uploadToS3(file.buffer, filename, file.mimetype);

    const story = new Story({
      userId,
      media: {
        type: isVideo ? 'video' : 'image',
        url,
        duration: isVideo ? undefined : undefined
      },
      text,
      backgroundColor,
      visibility: visibility || 'followers'
    });

    await story.save();

    logger.info(`Story created: ${story._id}`);
    res.status(201).json({ message: 'Story created successfully', storyId: story._id });
  } catch (error) {
    logger.error('Story creation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create reel
app.post('/api/content/reels', upload.single('video'), async (req, res) => {
  try {
    const { userId, caption, music, effects } = req.body;
    const file = req.file;

    if (!file || !file.mimetype.startsWith('video/')) {
      return res.status(400).json({ error: 'Video file required' });
    }

    const fileId = uuidv4();
    const filename = `reels/${userId}/${fileId}.mp4`;
    
    const url = await uploadToS3(file.buffer, filename, file.mimetype);

    const reel = new Reel({
      userId,
      video: {
        url,
        duration: 30 // Default duration, should be extracted from video
      },
      caption,
      music: music ? JSON.parse(music) : undefined,
      effects: effects ? JSON.parse(effects) : []
    });

    await reel.save();

    // Trigger AI analysis
    analyzeContent(reel._id, 'reel');

    logger.info(`Reel created: ${reel._id}`);
    res.status(201).json({ message: 'Reel created successfully', reelId: reel._id });
  } catch (error) {
    logger.error('Reel creation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get posts
app.get('/api/content/posts', async (req, res) => {
  try {
    const { userId, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const query = userId ? { userId } : { 'aiAnalysis.isApproved': true };
    
    const posts = await Post.find(query)
      .populate('userId', 'username fullName profilePicture isVerified')
      .populate('comments.userId', 'username fullName profilePicture')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    res.json({ posts });
  } catch (error) {
    logger.error('Posts fetch error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Like/Unlike post
app.post('/api/content/posts/:postId/like', async (req, res) => {
  try {
    const { postId } = req.params;
    const { userId } = req.body;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const isLiked = post.likes.includes(userId);
    
    if (isLiked) {
      post.likes.pull(userId);
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.json({ 
      message: isLiked ? 'Post unliked' : 'Post liked',
      isLiked: !isLiked,
      likesCount: post.likes.length
    });
  } catch (error) {
    logger.error('Like/unlike error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add comment
app.post('/api/content/posts/:postId/comments', async (req, res) => {
  try {
    const { postId } = req.params;
    const { userId, text } = req.body;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    post.comments.push({ userId, text });
    await post.save();

    const populatedPost = await Post.findById(postId)
      .populate('comments.userId', 'username fullName profilePicture');

    const newComment = populatedPost.comments[populatedPost.comments.length - 1];

    res.status(201).json({ 
      message: 'Comment added successfully',
      comment: newComment
    });
  } catch (error) {
    logger.error('Comment creation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Async AI analysis function
const analyzeContent = async (contentId, type) => {
  try {
    // Call AI moderation service
    const response = await fetch(`http://localhost:3005/api/ai/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contentId, type })
    });

    if (response.ok) {
      const analysis = await response.json();
      
      const Model = type === 'post' ? Post : Reel;
      await Model.findByIdAndUpdate(contentId, {
        aiScore: analysis.overallScore,
        'aiAnalysis.qualityScore': analysis.qualityScore,
        'aiAnalysis.sentimentScore': analysis.sentimentScore,
        'aiAnalysis.educationalValue': analysis.educationalValue,
        'aiAnalysis.originalityScore': analysis.originalityScore,
        'aiAnalysis.spamProbability': analysis.spamProbability,
        'aiAnalysis.isApproved': analysis.overallScore >= 6,
        'aiAnalysis.topics': analysis.topics
      });
    }
  } catch (error) {
    logger.error('AI analysis error:', error);
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'content-service', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  logger.info(`Content Service running on port ${PORT}`);
});

module.exports = app;