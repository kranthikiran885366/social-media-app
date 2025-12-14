import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/notification_models.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(context),
                    const SizedBox(height: 4),
                    _buildTimestamp(context),
                  ],
                ),
              ),
              if (notification.contentThumbnail != null) ...[
                const SizedBox(width: 12),
                _buildContentThumbnail(),
              ],
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: notification.actionUserAvatar != null
              ? NetworkImage(notification.actionUserAvatar!)
              : null,
          child: notification.actionUserAvatar == null
              ? Icon(_getNotificationIcon())
              : null,
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(),
              size: 12,
              color: _getNotificationColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
        ),
        children: [
          if (notification.actionUserName != null)
            TextSpan(
              text: notification.actionUserName!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          TextSpan(text: ' ${notification.message}'),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);
    String timeText;
    
    if (difference.inMinutes < 1) {
      timeText = 'Just now';
    } else if (difference.inHours < 1) {
      timeText = '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      timeText = '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      timeText = '${difference.inDays}d ago';
    } else {
      timeText = '${(difference.inDays / 7).floor()}w ago';
    }
    
    return Text(
      timeText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildContentThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        notification.contentThumbnail!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.storyMention:
      case NotificationType.storyReply:
        return Icons.auto_stories;
      case NotificationType.liveVideo:
        return Icons.videocam;
      case NotificationType.igtvAlert:
        return Icons.tv;
      case NotificationType.reelsNotification:
        return Icons.movie;
      case NotificationType.taggedInPhoto:
      case NotificationType.taggedInReel:
        return Icons.local_offer;
      case NotificationType.suggestedAccount:
      case NotificationType.friendSuggestion:
        return Icons.people;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.securityAlert:
      case NotificationType.loginAlert:
        return Icons.security;
      case NotificationType.verificationUpdate:
        return Icons.verified;
      case NotificationType.shopping:
        return Icons.shopping_bag;
      case NotificationType.newFeature:
        return Icons.new_releases;
      case NotificationType.creatorUpdate:
        return Icons.star;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.follow:
        return Colors.green;
      case NotificationType.storyMention:
      case NotificationType.storyReply:
        return Colors.purple;
      case NotificationType.liveVideo:
        return Colors.red;
      case NotificationType.igtvAlert:
        return Colors.indigo;
      case NotificationType.reelsNotification:
        return Colors.pink;
      case NotificationType.taggedInPhoto:
      case NotificationType.taggedInReel:
        return Colors.teal;
      case NotificationType.suggestedAccount:
      case NotificationType.friendSuggestion:
        return Colors.cyan;
      case NotificationType.newMessage:
        return Colors.blue;
      case NotificationType.securityAlert:
      case NotificationType.loginAlert:
        return Colors.amber;
      case NotificationType.verificationUpdate:
        return Colors.blue;
      case NotificationType.shopping:
        return Colors.green;
      case NotificationType.newFeature:
        return Colors.orange;
      case NotificationType.creatorUpdate:
        return Colors.yellow;
    }
  }
}