import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_models.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final VoidCallback onReply;
  final Function(String) onReact;
  final VoidCallback onForward;
  final VoidCallback onDelete;
  final bool isVanishMode;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReply,
    required this.onReact,
    required this.onForward,
    required this.onDelete,
    this.isVanishMode = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showReactions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showMessageOptions,
      onDoubleTap: () => widget.onReact('❤️'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isMe) _buildAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(),
                  if (widget.message.reactions.isNotEmpty) _buildReactions(),
                  _buildMessageInfo(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isMe) _buildMessageStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 12,
      child: Text(widget.message.senderId[0].toUpperCase()),
    );
  }

  Widget _buildMessageContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe 
          ? (widget.isVanishMode ? Colors.purple : Theme.of(context).primaryColor)
          : (widget.isVanishMode ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.replyToId != null) _buildReplyContent(),
          if (widget.message.isForwarded) _buildForwardedLabel(),
          _buildMainContent(),
          if (widget.message.isEdited) _buildEditedLabel(),
        ],
      ),
    );
  }

  Widget _buildReplyContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Replied message content...',
        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildForwardedLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forward,
            size: 12,
            color: widget.isMe ? Colors.white70 : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            'Forwarded',
            style: TextStyle(
              fontSize: 10,
              color: widget.isMe ? Colors.white70 : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: widget.isMe 
              ? Colors.white 
              : (widget.isVanishMode ? Colors.white : Colors.black),
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.message.content,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image),
            ),
          ),
        );
      case MessageType.voice:
        return _buildVoiceMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.gif:
        return _buildGifMessage();
      case MessageType.sticker:
        return _buildStickerMessage();
      default:
        return Text(widget.message.content);
    }
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {},
        ),
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        const Text('0:15'),
      ],
    );
  }

  Widget _buildVideoMessage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            height: 150,
            color: Colors.black,
            child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
          ),
        ),
      ],
    );
  }

  Widget _buildGifMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 150,
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: Text('GIF')),
      ),
    );
  }

  Widget _buildStickerMessage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.emoji_emotions, size: 80),
    );
  }

  Widget _buildEditedLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'edited',
        style: TextStyle(
          fontSize: 10,
          color: widget.isMe ? Colors.white70 : Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildReactions() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        children: widget.message.reactions.map((reaction) => Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${reaction.emoji} 1',
            style: const TextStyle(fontSize: 12),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        _formatTime(widget.message.timestamp),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color = Colors.grey;

    switch (widget.message.status) {
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

    return Icon(icon, size: 12, color: color);
  }

  void _showMessageOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              widget.onReply();
            },
          ),
          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text('Forward'),
            onTap: () {
              Navigator.pop(context);
              widget.onForward();
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: widget.message.content));
            },
          ),
          if (widget.isMe) ...[
            const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}