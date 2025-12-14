import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/feed_bloc.dart';

class SponsoredPostCard extends StatefulWidget {
  final Post post;

  const SponsoredPostCard({super.key, required this.post});

  @override
  State<SponsoredPostCard> createState() => _SponsoredPostCardState();
}

class _SponsoredPostCardState extends State<SponsoredPostCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildSponsoredLabel(),
          _buildMediaContent(),
          _buildActionButtons(),
          _buildCTAButton(),
          _buildCaption(),
          _buildTimeStamp(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
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
                      ),
                    ),
                    if (widget.post.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 14),
                    ],
                  ],
                ),
                if (widget.post.location != null)
                  Text(
                    widget.post.location!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'hide_ad':
                  _showHideAdDialog(context);
                  break;
                case 'report_ad':
                  _showReportAdDialog(context);
                  break;
                case 'why_ad':
                  _showWhyAdDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hide_ad', child: Text('Hide ad')),
              const PopupMenuItem(value: 'report_ad', child: Text('Report ad')),
              const PopupMenuItem(value: 'why_ad', child: Text('Why am I seeing this?')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'Sponsored',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.info_outline,
            size: 12,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.post.mediaUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CachedNetworkImage(
        imageUrl: widget.post.mediaUrls.first,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.post.isLiked ? Colors.red : Colors.black87,
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 28),
            onPressed: () {},
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Handle CTA action (e.g., visit website, download app)
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Learn More',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.post.hideLikeCount && widget.post.likes > 0)
            Text(
              '${widget.post.likes} likes',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 4),
          if (widget.post.content.isNotEmpty)
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
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

  Widget _buildTimeStamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        _formatTimestamp(widget.post.timestamp),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  void _showHideAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide this ad?'),
        content: const Text('We\'ll try to show you fewer ads like this.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle hide ad
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  void _showReportAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Ad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Inappropriate'),
              onTap: () => Navigator.pop(context, 'inappropriate'),
            ),
            ListTile(
              title: const Text('Spam'),
              onTap: () => Navigator.pop(context, 'spam'),
            ),
            ListTile(
              title: const Text('Misleading'),
              onTap: () => Navigator.pop(context, 'misleading'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWhyAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why am I seeing this ad?'),
        content: const Text(
          'You\'re seeing this ad based on your activity on our platform and other websites. '
          'Advertisers can reach people based on their interests, demographics, and other factors.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
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