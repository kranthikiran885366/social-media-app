import 'package:flutter/material.dart';
import '../models/message_models.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: chat.avatar != null ? NetworkImage(chat.avatar!) : null,
            child: chat.avatar == null ? Text(_getInitials()) : null,
          ),
          if (_isOnline())
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          if (chat.isPinned) const Icon(Icons.push_pin, size: 16, color: Colors.grey),
          Expanded(
            child: Text(
              _getChatName(),
              style: TextStyle(
                fontWeight: _hasUnreadMessages() ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.isMuted) const Icon(Icons.volume_off, size: 16, color: Colors.grey),
          if (chat.isVanishMode) const Icon(Icons.visibility_off, size: 16, color: Colors.purple),
        ],
      ),
      subtitle: Row(
        children: [
          if (chat.lastMessage?.senderId == 'current_user') _buildMessageStatus(),
          Expanded(
            child: Text(
              _getLastMessagePreview(),
              style: TextStyle(
                color: _hasUnreadMessages() ? Colors.black : Colors.grey[600],
                fontWeight: _hasUnreadMessages() ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(),
            style: TextStyle(
              fontSize: 12,
              color: _hasUnreadMessages() ? Theme.of(context).primaryColor : Colors.grey[600],
              fontWeight: _hasUnreadMessages() ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (_getUnreadCount() > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: chat.isMuted ? Colors.grey : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getUnreadCount() > 99 ? '99+' : _getUnreadCount().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    if (chat.lastMessage == null) return const SizedBox.shrink();

    IconData icon;
    Color color = Colors.grey;

    switch (chat.lastMessage!.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, size: 14, color: color),
    );
  }

  String _getInitials() {
    if (chat.name != null && chat.name!.isNotEmpty) {
      return chat.name![0].toUpperCase();
    }
    return 'U';
  }

  String _getChatName() {
    if (chat.name != null) return chat.name!;
    if (chat.type == ChatType.group) return 'Group Chat';
    return 'User';
  }

  String _getLastMessagePreview() {
    if (chat.lastMessage == null) return 'No messages yet';

    switch (chat.lastMessage!.type) {
      case MessageType.text:
        return chat.lastMessage!.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.gif:
        return 'GIF';
      case MessageType.sticker:
        return '😊 Sticker';
      case MessageType.location:
        return '📍 Location';
      case MessageType.post:
        return '📝 Shared a post';
      case MessageType.story:
        return '📖 Shared a story';
      default:
        return 'Message';
    }
  }

  String _formatTime() {
    if (chat.lastActivity == null) return '';

    final now = DateTime.now();
    final difference = now.difference(chat.lastActivity!);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${chat.lastActivity!.day}/${chat.lastActivity!.month}';
    }
  }

  bool _hasUnreadMessages() {
    return _getUnreadCount() > 0;
  }

  int _getUnreadCount() {
    return chat.unreadCount['current_user'] ?? 0;
  }

  bool _isOnline() {
    if (chat.type == ChatType.group) return false;
    
    final lastSeen = chat.lastSeen.values.isNotEmpty 
        ? chat.lastSeen.values.first 
        : null;
    
    if (lastSeen == null) return false;
    
    final difference = DateTime.now().difference(lastSeen);
    return difference.inMinutes < 5;
  }
}