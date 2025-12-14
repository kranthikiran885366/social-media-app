import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_models.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  Message? _replyingTo;
  bool _isTyping = false;
  bool _isVanishMode = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _isVanishMode = widget.chat.isVanishMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isVanishMode ? Colors.black : null,
      appBar: AppBar(
        backgroundColor: _isVanishMode ? Colors.black : null,
        foregroundColor: _isVanishMode ? Colors.white : null,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(widget.chat.name?[0] ?? 'U'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name ?? 'User',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _getOnlineStatus(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isVanishMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startAudioCall(),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startVideoCall(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(_isVanishMode ? Icons.visibility : Icons.visibility_off),
                  title: Text(_isVanishMode ? 'Turn off vanish mode' : 'Turn on vanish mode'),
                  onTap: () => _toggleVanishMode(),
                ),
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Search in conversation'),
                ),
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block'),
                ),
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isVanishMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
              child: const Text(
                'Vanish mode is on. Messages will disappear after being seen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          if (_replyingTo != null) _buildReplyPreview(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0 && _isTyping) {
                  return const TypingIndicatorWidget();
                }
                final messageIndex = _isTyping ? index - 1 : index;
                final message = _messages[messageIndex];
                return MessageBubble(
                  message: message,
                  isMe: message.senderId == 'current_user',
                  onReply: () => _replyToMessage(message),
                  onReact: (emoji) => _reactToMessage(message, emoji),
                  onForward: () => _forwardMessage(message),
                  onDelete: () => _deleteMessage(message),
                  isVanishMode: _isVanishMode,
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onTyping: _onTyping,
            replyingTo: _replyingTo,
            onCancelReply: () => setState(() => _replyingTo = null),
            isVanishMode: _isVanishMode,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingTo!.senderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  _replyingTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  void _loadMessages() {
    setState(() {
      _messages.addAll(List.generate(20, (index) => Message(
        id: 'msg_$index',
        chatId: widget.chat.id,
        senderId: index % 3 == 0 ? 'current_user' : 'other_user',
        type: MessageType.text,
        content: 'Message content $index',
        timestamp: DateTime.now().subtract(Duration(minutes: index * 5)),
        status: MessageStatus.read,
      )));
    });
  }

  void _sendMessage(String content, MessageType type) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'current_user',
      replyToId: _replyingTo?.id,
      type: type,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      isDisappearing: _isVanishMode,
      disappearAfter: _isVanishMode ? const Duration(seconds: 10) : null,
    );

    setState(() {
      _messages.insert(0, message);
      _replyingTo = null;
    });

    _scrollToBottom();
  }

  void _replyToMessage(Message message) {
    setState(() => _replyingTo = message);
  }

  void _reactToMessage(Message message, String emoji) {
    HapticFeedback.lightImpact();
  }

  void _forwardMessage(Message message) {}

  void _deleteMessage(Message message) {
    setState(() => _messages.remove(message));
  }

  void _onTyping(bool typing) {
    setState(() => _isTyping = typing);
  }

  void _toggleVanishMode() {
    setState(() => _isVanishMode = !_isVanishMode);
    Navigator.pop(context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getOnlineStatus() {
    return 'Active now';
  }

  void _startAudioCall() {}
  void _startVideoCall() {}
}