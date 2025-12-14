import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  bool _isTyping = false;
  bool _isRecording = false;

  final List<Message> _messages = [
    Message(
      id: '1',
      text: 'Hey! How are you doing?',
      senderId: 'other',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: MessageType.text,
    ),
    Message(
      id: '2',
      text: 'I\'m good! Just working on some new features',
      senderId: 'me',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      type: MessageType.text,
    ),
    Message(
      id: '3',
      mediaUrl: 'https://example.com/image.jpg',
      senderId: 'other',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      type: MessageType.image,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(
                  'https://example.com/avatar.jpg',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Active now',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: _startVideoCall,
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: _startVoiceCall,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'mute', child: Text('Mute')),
            const PopupMenuItem(value: 'disappearing', child: Text('Disappearing Messages')),
            const PopupMenuItem(value: 'block', child: Text('Block')),
            const PopupMenuItem(value: 'report', child: Text('Report')),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == 'me';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: CachedNetworkImageProvider(
                'https://example.com/avatar.jpg',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildMessageContent(message, isMe),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
          if (!isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text!,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      case MessageType.video:
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : Colors.blue,
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: isMe ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '0:15',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        );
      case MessageType.sticker:
        return Image.network(
          message.mediaUrl!,
          width: 100,
          height: 100,
        );
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: CachedNetworkImageProvider(
              'https://example.com/avatar.jpg',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue = (_typingController.value - delay).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, -10 * (1 - (animationValue * 2 - 1).abs())),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _openCamera,
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.gif_box),
            onPressed: _pickGif,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: _onMessageChanged,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _messageController.text.isNotEmpty ? () => _sendMessage(_messageController.text) : null,
            onLongPressStart: _startVoiceRecording,
            onLongPressEnd: _stopVoiceRecording,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _messageController.text.isNotEmpty ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _messageController.text.isNotEmpty ? Icons.send : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMessageChanged(String text) {
    setState(() {});
    // Implement typing indicator
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: 'me',
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
    });
    
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _openCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Send image message
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Send image message
    }
  }

  void _pickGif() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose GIF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('GIF')),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceRecording(LongPressStartDetails details) {
    setState(() => _isRecording = true);
    // Implement voice recording
  }

  void _stopVoiceRecording(LongPressEndDetails details) {
    setState(() => _isRecording = false);
    // Stop recording and send voice message
  }

  void _startVideoCall() {
    // Implement video call
  }

  void _startVoiceCall() {
    // Implement voice call
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mute':
        // Implement mute
        break;
      case 'disappearing':
        // Implement disappearing messages
        break;
      case 'block':
        // Implement block user
        break;
      case 'report':
        // Implement report user
        break;
    }
  }
}

class Message {
  final String id;
  final String? text;
  final String? mediaUrl;
  final String senderId;
  final DateTime timestamp;
  final MessageType type;

  Message({
    required this.id,
    this.text,
    this.mediaUrl,
    required this.senderId,
    required this.timestamp,
    required this.type,
  });
}

enum MessageType {
  text,
  image,
  video,
  voice,
  sticker,
}