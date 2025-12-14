import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message_models.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, MessageType) onSend;
  final Function(bool) onTyping;
  final Message? replyingTo;
  final VoidCallback? onCancelReply;
  final bool isVanishMode;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
    this.replyingTo,
    this.onCancelReply,
    this.isVanishMode = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isRecording = false;
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isVanishMode ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          if (_showEmojiPicker) _buildEmojiPicker(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: widget.isVanishMode ? Colors.white : null,
                ),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isVanishMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: widget.isVanishMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            hintStyle: TextStyle(
                              color: widget.isVanishMode ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onChanged: _onTextChanged,
                          maxLines: 5,
                          minLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                          color: widget.isVanishMode ? Colors.white70 : Colors.grey,
                        ),
                        onPressed: _toggleEmojiPicker,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.controller.text.trim().isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: widget.isVanishMode ? Colors.purple : Theme.of(context).primaryColor,
                  ),
                  onPressed: _sendTextMessage,
                )
              else
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isVanishMode ? Colors.purple : Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 250,
      color: widget.isVanishMode ? Colors.grey[900] : Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        itemCount: _getEmojis().length,
        itemBuilder: (context, index) {
          final emoji = _getEmojis()[index];
          return GestureDetector(
            onTap: () => _insertEmoji(emoji),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.photo_library,
                  'Gallery',
                  () => _pickImage(ImageSource.gallery),
                ),
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Camera',
                  () => _pickImage(ImageSource.camera),
                ),
                _buildAttachmentOption(
                  Icons.videocam,
                  'Video',
                  () => _pickVideo(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.gif,
                  'GIF',
                  () => _pickGif(),
                ),
                _buildAttachmentOption(
                  Icons.emoji_emotions,
                  'Sticker',
                  () => _pickSticker(),
                ),
                _buildAttachmentOption(
                  Icons.location_on,
                  'Location',
                  () => _shareLocation(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _onTextChanged(String text) {
    widget.onTyping(text.isNotEmpty);
  }

  void _sendTextMessage() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text, MessageType.text);
      widget.controller.clear();
      widget.onTyping(false);
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        _focusNode.unfocus();
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  void _insertEmoji(String emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );
  }

  void _startRecording() {
    setState(() => _isRecording = true);
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    widget.onSend('Voice message', MessageType.voice);
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      widget.onSend(image.path, MessageType.image);
    }
  }

  void _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      widget.onSend(video.path, MessageType.video);
    }
  }

  void _pickGif() {
    widget.onSend('gif_url', MessageType.gif);
  }

  void _pickSticker() {
    widget.onSend('sticker_id', MessageType.sticker);
  }

  void _shareLocation() {
    widget.onSend('location_data', MessageType.location);
  }

  List<String> _getEmojis() {
    return [
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
      '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
      '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
      '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
      '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
      '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
      '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
    ];
  }
}