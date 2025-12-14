const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const ffmpeg = require('fluent-ffmpeg');
const AWS = require('aws-sdk');
const redis = require('redis');

const app = express();
const redisClient = redis.createClient();

// AWS S3 Configuration
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// CloudFront Configuration
const cloudfront = new AWS.CloudFront({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
});

const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 100 * 1024 * 1024 } // 100MB limit
});

// Media Compression Service
class MediaProcessor {
  static async compressImage(buffer, options = {}) {
    const { width = 1080, height = 1080, quality = 80 } = options;
    
    return await sharp(buffer)
      .resize(width, height, { 
        fit: 'inside',
        withoutEnlargement: true 
      })
      .jpeg({ quality, progressive: true })
      .toBuffer();
  }

  static async generateImageVariants(buffer) {
    const variants = {};
    
    // Thumbnail
    variants.thumbnail = await sharp(buffer)
      .resize(150, 150, { fit: 'cover' })
      .jpeg({ quality: 70 })
      .toBuffer();
    
    // Medium
    variants.medium = await sharp(buffer)
      .resize(640, 640, { fit: 'inside' })
      .jpeg({ quality: 75 })
      .toBuffer();
    
    // Large
    variants.large = await sharp(buffer)
      .resize(1080, 1080, { fit: 'inside' })
      .jpeg({ quality: 85 })
      .toBuffer();
    
    return variants;
  }

  static async compressVideo(inputPath, outputPath, options = {}) {
    const { bitrate = '1000k', resolution = '720p' } = options;
    
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .videoBitrate(bitrate)
        .size(resolution)
        .format('mp4')
        .videoCodec('libx264')
        .audioCodec('aac')
        .on('end', resolve)
        .on('error', reject)
        .save(outputPath);
    });
  }
}

// CDN Management
class CDNManager {
  static async uploadToS3(buffer, key, contentType) {
    const params = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
      Body: buffer,
      ContentType: contentType,
      CacheControl: 'max-age=31536000', // 1 year
      ACL: 'public-read'
    };
    
    const result = await s3.upload(params).promise();
    return result.Location;
  }

  static async invalidateCache(paths) {
    const params = {
      DistributionId: process.env.CLOUDFRONT_DISTRIBUTION_ID,
      InvalidationBatch: {
        CallerReference: Date.now().toString(),
        Paths: {
          Quantity: paths.length,
          Items: paths
        }
      }
    };
    
    return await cloudfront.createInvalidation(params).promise();
  }

  static getCDNUrl(key) {
    return `https://${process.env.CLOUDFRONT_DOMAIN}/${key}`;
  }
}

// Background Upload Queue
class UploadQueue {
  constructor() {
    this.queue = [];
    this.processing = false;
  }

  add(task) {
    this.queue.push(task);
    if (!this.processing) {
      this.process();
    }
  }

  async process() {
    this.processing = true;
    
    while (this.queue.length > 0) {
      const task = this.queue.shift();
      try {
        await this.executeTask(task);
      } catch (error) {
        console.error('Upload task failed:', error);
      }
    }
    
    this.processing = false;
  }

  async executeTask(task) {
    const { buffer, key, contentType, variants } = task;
    
    if (variants) {
      // Upload all variants
      for (const [variant, variantBuffer] of Object.entries(variants)) {
        const variantKey = `${key}_${variant}`;
        await CDNManager.uploadToS3(variantBuffer, variantKey, contentType);
      }
    } else {
      await CDNManager.uploadToS3(buffer, key, contentType);
    }
  }
}

const uploadQueue = new UploadQueue();

// Routes
app.post('/api/media/upload/image', upload.single('image'), async (req, res) => {
  try {
    const { buffer, mimetype } = req.file;
    const userId = req.body.userId;
    const timestamp = Date.now();
    
    // Generate variants
    const variants = await MediaProcessor.generateImageVariants(buffer);
    
    // Create unique key
    const key = `images/${userId}/${timestamp}`;
    
    // Add to background upload queue
    uploadQueue.add({
      buffer,
      key,
      contentType: mimetype,
      variants
    });
    
    // Return immediate response with CDN URLs
    const urls = {
      original: CDNManager.getCDNUrl(key),
      thumbnail: CDNManager.getCDNUrl(`${key}_thumbnail`),
      medium: CDNManager.getCDNUrl(`${key}_medium`),
      large: CDNManager.getCDNUrl(`${key}_large`)
    };
    
    res.json({ urls, uploadId: timestamp });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/media/upload/video', upload.single('video'), async (req, res) => {
  try {
    const { buffer, mimetype } = req.file;
    const userId = req.body.userId;
    const timestamp = Date.now();
    
    const key = `videos/${userId}/${timestamp}.mp4`;
    
    // Add to background processing queue
    uploadQueue.add({
      buffer,
      key,
      contentType: mimetype
    });
    
    const url = CDNManager.getCDNUrl(key);
    res.json({ url, uploadId: timestamp });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/media/status/:uploadId', async (req, res) => {
  try {
    const { uploadId } = req.params;
    
    // Check upload status (mock implementation)
    const status = Math.random() > 0.3 ? 'completed' : 'processing';
    
    res.json({ 
      uploadId, 
      status,
      progress: status === 'completed' ? 100 : Math.floor(Math.random() * 90) + 10
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Differential Loading
app.get('/api/media/adaptive/:contentId', async (req, res) => {
  try {
    const { contentId } = req.params;
    const { quality = 'auto', bandwidth } = req.query;
    
    let selectedQuality = quality;
    
    if (quality === 'auto' && bandwidth) {
      const bw = parseInt(bandwidth);
      if (bw < 500000) selectedQuality = 'low';
      else if (bw < 2000000) selectedQuality = 'medium';
      else selectedQuality = 'high';
    }
    
    const urls = {
      low: CDNManager.getCDNUrl(`${contentId}_thumbnail`),
      medium: CDNManager.getCDNUrl(`${contentId}_medium`),
      high: CDNManager.getCDNUrl(`${contentId}_large`)
    };
    
    res.json({ 
      url: urls[selectedQuality] || urls.medium,
      quality: selectedQuality,
      alternatives: urls
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Offline Caching Support
app.get('/api/media/cache-manifest/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get user's recent content for offline caching
    const cacheManifest = {
      version: Date.now(),
      assets: [
        { url: '/images/profile.jpg', priority: 'high' },
        { url: '/images/recent_posts.jpg', priority: 'medium' },
        { url: '/videos/recent_reels.mp4', priority: 'low' }
      ]
    };
    
    res.json(cacheManifest);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3014;

app.listen(PORT, () => {
  console.log(`Media service running on port ${PORT}`);
});