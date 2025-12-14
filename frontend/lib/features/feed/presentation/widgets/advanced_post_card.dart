import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import '../bloc/feed_bloc.dart';

class AdvancedPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const AdvancedPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<AdvancedPostCard> createState() => _AdvancedPostCardState();
}

class _AdvancedPostCardState extends State<AdvancedPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  VideoPlayerController? _videoController;
  bool _isLiked = false;
  bool _isSaved = false;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.elasticOut),
    );
    
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.post.mediaUrls.isNotEmpty && 
        widget.post.mediaUrls.first.contains('.mp4')) {
      _videoController = VideoPlayerController.network(widget.post.mediaUrls.first)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMediaContent(),
          _buildActionButtons(),
          _buildLikesAndCaption(),
          _buildComments(),
          _buildTimeStamp(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: CachedNetworkImageProvider(widget.post.userAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.post.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF0095F6),
                        size: 12,
                      ),
                    ],
                  ],
                ),
                if (widget.post.location != null)
                  Text(
                    widget.post.location!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 16,
            ),
            onPressed: () => _handleMenuAction('more'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.post.mediaUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: widget.post.mediaUrls.length,
            itemBuilder: (context, index, realIndex) {
              final mediaUrl = widget.post.mediaUrls[index];
              
              if (mediaUrl.contains('.mp4')) {
                return _buildVideoPlayer(mediaUrl);
              } else {
                return _buildImageViewer(mediaUrl);
              }
            },
            options: CarouselOptions(
              height: 400,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentMediaIndex = index;
                });
              },
            ),
          ),
          if (widget.post.mediaUrls.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentMediaIndex + 1}/${widget.post.mediaUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (widget.post.mediaUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.post.mediaUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentMediaIndex == entry.key
                          ? Colors.white
                          : Colors.white54,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    if (_videoController == null) return const Center(child: CircularProgressIndicator());

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
          } else {
            _videoController!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController!),
          if (!_videoController!.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleLike,
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.black,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: widget.onComment,
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: widget.onShare,
            child: const Icon(
              Icons.send,
              color: Colors.black,
              size: 24,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _handleSave,
            child: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesAndCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.likes > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${widget.post.likes} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          if (widget.post.content.isNotEmpty)
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: widget.post.username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: widget.post.content),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    if (widget.post.comments == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: GestureDetector(
        onTap: widget.onComment,
        child: Text(
          'View all ${widget.post.comments} comments',
          style: const TextStyle(
            color: Color(0xFF8E8E8E),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStamp() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Text(
        _formatTimestamp(widget.post.timestamp).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _handleLike();
    }
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
    
    widget.onLike?.call();
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave?.call();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        _handleSave();
        break;
      case 'share':
        widget.onShare?.call();
        break;
      case 'report':
        _showReportDialog();
        break;
      case 'hide':
        _showHideDialog();
        break;
      case 'unfollow':
        _showUnfollowDialog();
        break;
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () => Navigator.pop(context, 'spam'),
            ),
            ListTile(
              title: const Text('Inappropriate Content'),
              onTap: () => Navigator.pop(context, 'inappropriate'),
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () => Navigator.pop(context, 'harassment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide Post'),
        content: const Text('This post will be hidden from your feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle hide post
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  void _showUnfollowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unfollow ${widget.post.username}?'),
        content: const Text('You will no longer see their posts in your feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle unfollow
            },
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(double score) {
    if (score >= 8.0) return const Color(0xFF00b894);
    if (score >= 6.0) return const Color(0xFFfdcb6e);
    return const Color(0xFFd63031);
  }

  LinearGradient _getQualityGradient(double score) {
    if (score >= 8.0) {
      return const LinearGradient(
        colors: [Color(0xFF00b894), Color(0xFF00cec9)],
      );
    } else if (score >= 6.0) {
      return const LinearGradient(
        colors: [Color(0xFFfdcb6e), Color(0xFFe17055)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFd63031), Color(0xFF74b9ff)],
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

// Extended Post model with all Instagram features
extension PostExtension on Post {
  bool get isVerified => false; // Add to Post model
  String? get location => null; // Add to Post model
}