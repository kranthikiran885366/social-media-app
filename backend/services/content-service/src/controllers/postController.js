const Post = require('../models/Post');
const { uploadToS3, deleteFromS3 } = require('../utils/s3Utils');
const { processMedia } = require('../utils/mediaProcessor');
const { analyzeContent } = require('../utils/aiAnalyzer');
const { validateInput } = require('../utils/validation');
const { addToQueue } = require('../utils/queueManager');
const logger = require('../utils/logger');

class PostController {
  // Create new post
  async createPost(req, res) {
    try {
      const { error, value } = validateInput.createPost(req.body);
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const userId = req.user.id;
      const {
        content,
        type = 'post',
        visibility = 'public',
        allowComments = true,
        allowSharing = true,
        hashtags = [],
        mentions = [],
        location,
        productTags = [],
        poll,
        scheduledFor,
        crossPost = []
      } = value;

      // Process uploaded media files
      let mediaItems = [];
      if (req.files && req.files.length > 0) {
        for (const file of req.files) {
          try {
            // Upload to S3
            const uploadResult = await uploadToS3(file, `posts/${userId}`);
            
            // Process media (resize, compress, generate thumbnails)
            const processedMedia = await processMedia(file, uploadResult.url);
            
            mediaItems.push({
              type: file.mimetype.startsWith('image') ? 'image' : 
                    file.mimetype.startsWith('video') ? 'video' : 'audio',
              url: uploadResult.url,
              thumbnailUrl: processedMedia.thumbnailUrl,
              duration: processedMedia.duration,
              dimensions: processedMedia.dimensions,
              size: file.size,
              format: file.mimetype,
              blurHash: processedMedia.blurHash,
              processingStatus: 'completed'
            });
          } catch (error) {
            logger.error('Media processing error:', error);
            mediaItems.push({
              type: file.mimetype.startsWith('image') ? 'image' : 
                    file.mimetype.startsWith('video') ? 'video' : 'audio',
              url: '',
              processingStatus: 'failed'
            });
          }
        }
      }

      // Create post
      const post = new Post({
        userId,
        type,
        content,
        media: mediaItems,
        hashtags: hashtags.map(tag => tag.toLowerCase().replace('#', '')),
        mentions,
        location,
        productTags,
        poll,
        visibility,
        allowComments,
        allowSharing,
        isScheduled: !!scheduledFor,
        scheduledFor,
        publishedAt: scheduledFor ? null : new Date()
      });

      // Queue AI analysis
      if (content || mediaItems.length > 0) {
        addToQueue('ai-analysis', {
          postId: post._id,
          content,
          mediaUrls: mediaItems.map(m => m.url)
        });
      }

      // Queue cross-posting
      if (crossPost.length > 0) {
        addToQueue('cross-post', {
          postId: post._id,
          platforms: crossPost
        });
      }

      await post.save();

      // Update user's post count
      await this.updateUserPostCount(userId, 1);

      logger.info(`Post created: ${post._id}`, {
        userId,
        type,
        hasMedia: mediaItems.length > 0,
        isScheduled: !!scheduledFor
      });

      res.status(201).json({
        success: true,
        message: 'Post created successfully',
        data: {
          post: post.toSafeObject(userId)
        }
      });
    } catch (error) {
      logger.error('Create post error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get feed posts
  async getFeedPosts(req, res) {
    try {
      const userId = req.user.id;
      const { 
        page = 1, 
        limit = 20, 
        type = 'all',
        source = 'feed'
      } = req.query;

      const skip = (page - 1) * limit;
      
      // Build query based on user's following and preferences
      let query = {
        isDeleted: false,
        isArchived: false,
        $or: [
          { visibility: 'public' },
          { 
            visibility: 'friends',
            userId: { $in: await this.getUserFollowing(userId) }
          }
        ]
      };

      if (type !== 'all') {
        query.type = type;
      }

      // Add scheduled posts filter
      query.$and = [
        {
          $or: [
            { isScheduled: false },
            { 
              isScheduled: true, 
              scheduledFor: { $lte: new Date() },
              publishedAt: { $ne: null }
            }
          ]
        }
      ];

      const posts = await Post.find(query)
        .populate('userId', 'username fullName profilePicture isVerified')
        .populate('comments.userId', 'username fullName profilePicture')
        .populate('mentions.userId', 'username fullName')
        .sort({ 
          trendingScore: -1, 
          createdAt: -1 
        })
        .skip(skip)
        .limit(parseInt(limit))
        .lean();

      // Add view tracking for each post
      const postIds = posts.map(post => post._id);
      await this.trackPostViews(postIds, userId, source);

      // Process posts for response
      const processedPosts = posts.map(post => {
        const postObj = { ...post };
        postObj.isLiked = post.likes.includes(userId);
        postObj.isSaved = post.saves.includes(userId);
        postObj.timeAgo = this.calculateTimeAgo(post.createdAt);
        
        // Remove sensitive data
        delete postObj.reports;
        delete postObj.aiAnalysis;
        
        return postObj;
      });

      res.json({
        success: true,
        data: {
          posts: processedPosts,
          pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            hasMore: posts.length === parseInt(limit)
          }
        }
      });
    } catch (error) {
      logger.error('Get feed posts error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get explore posts
  async getExplorePosts(req, res) {
    try {
      const userId = req.user.id;
      const { 
        page = 1, 
        limit = 20,
        category = 'trending'
      } = req.query;

      const skip = (page - 1) * limit;
      
      let query = {
        isDeleted: false,
        isArchived: false,
        visibility: 'public',
        userId: { $ne: userId } // Exclude user's own posts
      };

      let sortOptions = {};

      switch (category) {
        case 'trending':
          sortOptions = { trendingScore: -1, createdAt: -1 };
          break;
        case 'recent':
          sortOptions = { createdAt: -1 };
          break;
        case 'popular':
          sortOptions = { likesCount: -1, createdAt: -1 };
          break;
        case 'videos':
          query['media.type'] = 'video';
          sortOptions = { viewsCount: -1, createdAt: -1 };
          break;
        case 'photos':
          query['media.type'] = 'image';
          sortOptions = { likesCount: -1, createdAt: -1 };
          break;
        default:
          sortOptions = { trendingScore: -1, createdAt: -1 };
      }

      const posts = await Post.find(query)
        .populate('userId', 'username fullName profilePicture isVerified')
        .sort(sortOptions)
        .skip(skip)
        .limit(parseInt(limit))
        .lean();

      // Track views
      const postIds = posts.map(post => post._id);
      await this.trackPostViews(postIds, userId, 'explore');

      // Process posts
      const processedPosts = posts.map(post => {
        const postObj = { ...post };
        postObj.isLiked = post.likes.includes(userId);
        postObj.isSaved = post.saves.includes(userId);
        postObj.timeAgo = this.calculateTimeAgo(post.createdAt);
        
        delete postObj.reports;
        delete postObj.aiAnalysis;
        
        return postObj;
      });

      res.json({
        success: true,
        data: {
          posts: processedPosts,
          pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            hasMore: posts.length === parseInt(limit)
          }
        }
      });
    } catch (error) {
      logger.error('Get explore posts error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Like/Unlike post
  async toggleLike(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      const isLiked = post.likes.includes(userId);
      let action;

      if (isLiked) {
        post.removeLike(userId);
        action = 'unliked';
      } else {
        post.addLike(userId);
        action = 'liked';
        
        // Queue notification
        if (post.userId.toString() !== userId) {
          addToQueue('notification', {
            type: 'like',
            fromUserId: userId,
            toUserId: post.userId,
            postId: post._id
          });
        }
      }

      await post.save();

      logger.info(`Post ${action}: ${postId}`, {
        userId,
        postUserId: post.userId
      });

      res.json({
        success: true,
        message: `Post ${action} successfully`,
        data: {
          isLiked: !isLiked,
          likesCount: post.likesCount
        }
      });
    } catch (error) {
      logger.error('Toggle like error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Add comment
  async addComment(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;
      const { error, value } = validateInput.addComment(req.body);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const { content, mentions = [], parentCommentId } = value;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      if (!post.allowComments) {
        return res.status(403).json({
          success: false,
          message: 'Comments are disabled for this post'
        });
      }

      let comment;
      
      if (parentCommentId) {
        // Reply to comment
        const parentComment = post.comments.id(parentCommentId);
        if (!parentComment) {
          return res.status(404).json({
            success: false,
            message: 'Parent comment not found'
          });
        }

        const reply = {
          userId,
          content,
          mentions,
          createdAt: new Date()
        };

        parentComment.replies.push(reply);
        parentComment.repliesCount = parentComment.replies.length;
        comment = reply;
      } else {
        // Top-level comment
        comment = post.addComment({
          userId,
          content,
          mentions
        });
      }

      await post.save();

      // Queue notifications
      if (post.userId.toString() !== userId) {
        addToQueue('notification', {
          type: 'comment',
          fromUserId: userId,
          toUserId: post.userId,
          postId: post._id,
          commentId: comment._id
        });
      }

      // Notify mentioned users
      mentions.forEach(mention => {
        if (mention.userId !== userId) {
          addToQueue('notification', {
            type: 'mention',
            fromUserId: userId,
            toUserId: mention.userId,
            postId: post._id,
            commentId: comment._id
          });
        }
      });

      // Populate comment user data
      await post.populate('comments.userId', 'username fullName profilePicture');

      logger.info(`Comment added to post: ${postId}`, {
        userId,
        commentId: comment._id,
        isReply: !!parentCommentId
      });

      res.status(201).json({
        success: true,
        message: 'Comment added successfully',
        data: {
          comment,
          commentsCount: post.commentsCount
        }
      });
    } catch (error) {
      logger.error('Add comment error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Save/Unsave post
  async toggleSave(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      const isSaved = post.saves.includes(userId);
      let action;

      if (isSaved) {
        post.removeSave(userId);
        action = 'unsaved';
      } else {
        post.addSave(userId);
        action = 'saved';
      }

      await post.save();

      logger.info(`Post ${action}: ${postId}`, {
        userId
      });

      res.json({
        success: true,
        message: `Post ${action} successfully`,
        data: {
          isSaved: !isSaved,
          savesCount: post.savesCount
        }
      });
    } catch (error) {
      logger.error('Toggle save error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Share post
  async sharePost(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;
      const { platform = 'instagram', message } = req.body;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      if (!post.allowSharing) {
        return res.status(403).json({
          success: false,
          message: 'Sharing is disabled for this post'
        });
      }

      post.addShare(userId, platform);
      await post.save();

      // Queue notification
      if (post.userId.toString() !== userId) {
        addToQueue('notification', {
          type: 'share',
          fromUserId: userId,
          toUserId: post.userId,
          postId: post._id
        });
      }

      logger.info(`Post shared: ${postId}`, {
        userId,
        platform,
        postUserId: post.userId
      });

      res.json({
        success: true,
        message: 'Post shared successfully',
        data: {
          sharesCount: post.sharesCount
        }
      });
    } catch (error) {
      logger.error('Share post error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Report post
  async reportPost(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;
      const { error, value } = validateInput.reportPost(req.body);
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const { reason, description } = value;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      // Check if user already reported this post
      const existingReport = post.reports.find(report => 
        report.userId.toString() === userId
      );

      if (existingReport) {
        return res.status(409).json({
          success: false,
          message: 'You have already reported this post'
        });
      }

      post.addReport({
        userId,
        reason,
        description
      });

      await post.save();

      // Queue moderation review if report count exceeds threshold
      if (post.reportCount >= 5) {
        addToQueue('moderation-review', {
          postId: post._id,
          priority: 'high'
        });
      }

      logger.info(`Post reported: ${postId}`, {
        userId,
        reason,
        reportCount: post.reportCount
      });

      res.json({
        success: true,
        message: 'Post reported successfully. We will review it shortly.'
      });
    } catch (error) {
      logger.error('Report post error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete post
  async deletePost(req, res) {
    try {
      const { postId } = req.params;
      const userId = req.user.id;

      const post = await Post.findById(postId);
      if (!post) {
        return res.status(404).json({
          success: false,
          message: 'Post not found'
        });
      }

      // Check ownership
      if (post.userId.toString() !== userId) {
        return res.status(403).json({
          success: false,
          message: 'You can only delete your own posts'
        });
      }

      // Soft delete
      post.isDeleted = true;
      post.deletedAt = new Date();
      await post.save();

      // Queue media cleanup
      if (post.media.length > 0) {
        addToQueue('cleanup-media', {
          mediaUrls: post.media.map(m => m.url)
        });
      }

      // Update user's post count
      await this.updateUserPostCount(userId, -1);

      logger.info(`Post deleted: ${postId}`, {
        userId
      });

      res.json({
        success: true,
        message: 'Post deleted successfully'
      });
    } catch (error) {
      logger.error('Delete post error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper methods
  async getUserFollowing(userId) {
    // This would typically fetch from a separate Follow model
    // For now, returning empty array
    return [];
  }

  async trackPostViews(postIds, userId, source) {
    try {
      await Post.updateMany(
        { 
          _id: { $in: postIds },
          'views.userId': { $ne: userId }
        },
        {
          $push: {
            views: {
              userId,
              viewedAt: new Date(),
              source
            }
          }
        }
      );
    } catch (error) {
      logger.error('Track post views error:', error);
    }
  }

  async updateUserPostCount(userId, increment) {
    try {
      // This would update the user's post count in the User model
      // Implementation depends on user service integration
    } catch (error) {
      logger.error('Update user post count error:', error);
    }
  }

  calculateTimeAgo(date) {
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m`;
    if (diffHours < 24) return `${diffHours}h`;
    if (diffDays < 7) return `${diffDays}d`;
    return date.toLocaleDateString();
  }
}

module.exports = new PostController();