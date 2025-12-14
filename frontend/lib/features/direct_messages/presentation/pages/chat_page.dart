import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Column(
            children: [
              _buildAppBar(isTablet),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient.scale(0.02),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator(isTablet);
                      }
                      return _buildMessageBubble(_messages[index], isTablet);
                    },
                  ),
                ),
              ),
              _buildMessageInput(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (isTablet ? 16 : 8),
        left: isTablet ? 24 : 16,
        right: isTablet ? 24 : 16,
        bottom: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isTablet ? 22 : 18,
                  backgroundImage: const CachedNetworkImageProvider(
                    'https://example.com/avatar.jpg',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: isTablet ? 16 : 12,
                  height: isTablet ? 16 : 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Active now',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.videocam,
                color: AppColors.primary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _startVideoCall,
            ),
          ),
          SizedBox(width: isTablet ? 8 : 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.call,
                color: AppColors.secondary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _startVoiceCall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isTablet) {
    final isMe = message.senderId == 'me';
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: isTablet ? 16 : 12,
                backgroundImage: const CachedNetworkImageProvider(
                  'https://example.com/avatar.jpg',
                ),
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 14 : 10,
              ),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.primaryGradient : null,
                color: isMe ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                border: isMe ? null : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: isTablet ? 8 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(message, isMe, isTablet),
            ),
          ),
          SizedBox(width: isTablet ? 60 : 40),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message, bool isMe, bool isTablet) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text!,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textPrimary,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
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

  Widget _buildTypingIndicator(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: CircleAvatar(
              radius: isTablet ? 16 : 12,
              backgroundImage: const CachedNetworkImageProvider(
                'https://example.com/avatar.jpg',
              ),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 14 : 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              border: Border.all(color: AppColors.border),
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

  Widget _buildMessageInput(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: AppColors.primary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _openCamera,
            ),
          ),
          SizedBox(width: isTablet ? 8 : 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.photo,
                color: AppColors.secondary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _pickImage,
            ),
          ),
          SizedBox(width: isTablet ? 8 : 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.gif_box,
                color: AppColors.info,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _pickGif,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                onChanged: _onMessageChanged,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          GestureDetector(
            onTap: _messageController.text.isNotEmpty ? () => _sendMessage(_messageController.text) : null,
            onLongPressStart: _startVoiceRecording,
            onLongPressEnd: _stopVoiceRecording,
            child: Container(
              width: isTablet ? 52 : 44,
              height: isTablet ? 52 : 44,
              decoration: BoxDecoration(
                gradient: _messageController.text.isNotEmpty ? AppColors.primaryGradient : null,
                color: _messageController.text.isEmpty ? AppColors.textTertiary : null,
                shape: BoxShape.circle,
                boxShadow: _messageController.text.isNotEmpty ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: isTablet ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Icon(
                _messageController.text.isNotEmpty ? Icons.send : Icons.mic,
                color: Colors.white,
                size: isTablet ? 24 : 20,
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