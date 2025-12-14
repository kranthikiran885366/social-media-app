import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EnhancedPostCard extends StatefulWidget {
  final dynamic post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const EnhancedPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<EnhancedPostCard> createState() => _EnhancedPostCardState();
}

class _EnhancedPostCardState extends State<EnhancedPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _heartController;
  late Animation<double> _likeAnimation;
  late Animation<double> _heartAnimation;
  
  bool _isLiked = false;
  bool _isSaved = false;
  int _currentMediaIndex = 0;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildProfilePicture(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.username ?? 'user',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: _getQualityGradient(widget.post.qualityScore ?? 7.0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(widget.post.qualityScore ?? 7.0).toStringAsFixed(1)}★',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.post.location != null)
                  Text(
                    widget.post.location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          _buildMoreButton(),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.post.userAvatar ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _showMoreOptions,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.more_horiz,
            size: 20,
            color: Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    final mediaUrls = widget.post.mediaUrls ?? [];
    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: CarouselSlider.builder(
              itemCount: mediaUrls.length,
              itemBuilder: (context, index, realIndex) {
                return _buildMediaItem(mediaUrls[index]);
              },
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentMediaIndex = index);
                },
              ),
            ),
          ),
          if (mediaUrls.length > 1) _buildMediaIndicators(mediaUrls.length),
          _buildHeartAnimation(),
        ],
      ),
    );
  }

  Widget _buildMediaItem(String mediaUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(0),
      ),
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C5CE7),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildMediaIndicators(int count) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${_currentMediaIndex + 1}/$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeartAnimation() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _heartAnimation,
        builder: (context, child) {
          return _showHeart
              ? Center(
                  child: Transform.scale(
                    scale: _heartAnimation.value,
                    child: Opacity(
                      opacity: 1.0 - _heartAnimation.value,
                      child: const Icon(
                        Icons.favorite,
                        size: 100,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : const Color(0xFF2D3436),
            onTap: _handleLike,
            animation: _likeAnimation,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFF2D3436),
            onTap: widget.onComment,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.send_outlined,
            color: const Color(0xFF2D3436),
            onTap: widget.onShare,
          ),
          const Spacer(),
          _buildActionButton(
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved ? const Color(0xFF6C5CE7) : const Color(0xFF2D3436),
            onTap: _handleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    Animation<double>? animation,
  }) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 26, color: color),
        ),
      ),
    );

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(scale: animation.value, child: button);
        },
      );
    }

    return button;
  }

  Widget _buildLikesAndCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((widget.post.likes ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${widget.post.likes} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
          if ((widget.post.content ?? '').isNotEmpty)
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF2D3436),
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: widget.post.username ?? 'user',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: widget.post.content ?? ''),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    final commentCount = widget.post.comments ?? 0;
    if (commentCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: widget.onComment,
        child: Text(
          'View all $commentCount comments',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStamp() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Text(
        _formatTimestamp(widget.post.timestamp ?? DateTime.now()),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  LinearGradient _getQualityGradient(double score) {
    if (score >= 8.0) {
      return const LinearGradient(colors: [Color(0xFF00b894), Color(0xFF00cec9)]);
    } else if (score >= 6.0) {
      return const LinearGradient(colors: [Color(0xFFfdcb6e), Color(0xFFe17055)]);
    } else {
      return const LinearGradient(colors: [Color(0xFFd63031), Color(0xFF74b9ff)]);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _handleLike();
      _showHeartAnimation();
    }
  }

  void _handleLike() {
    setState(() => _isLiked = !_isLiked);
    
    if (_isLiked) {
      _likeController.forward().then((_) => _likeController.reverse());
    }
    
    widget.onLike?.call();
  }

  void _handleSave() {
    setState(() => _isSaved = !_isSaved);
    widget.onSave?.call();
  }

  void _showHeartAnimation() {
    setState(() => _showHeart = true);
    _heartController.forward().then((_) {
      _heartController.reset();
      setState(() => _showHeart = false);
    });
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildBottomSheetOption(Icons.bookmark_border, 'Save', () {}),
            _buildBottomSheetOption(Icons.share_outlined, 'Share', () {}),
            _buildBottomSheetOption(Icons.report_outlined, 'Report', () {}),
            _buildBottomSheetOption(Icons.visibility_off_outlined, 'Hide', () {}),
            _buildBottomSheetOption(Icons.person_remove_outlined, 'Unfollow', () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D3436)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3436),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}