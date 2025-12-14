import 'package:flutter/material.dart';
import '../models/live_models.dart';

class LiveCommentsWidget extends StatefulWidget {
  final List<LiveComment> comments;
  final Function(String) onSendComment;
  final TextEditingController controller;

  const LiveCommentsWidget({
    super.key,
    required this.comments,
    required this.onSendComment,
    required this.controller,
  });

  @override
  State<LiveCommentsWidget> createState() => _LiveCommentsWidgetState();
}

class _LiveCommentsWidgetState extends State<LiveCommentsWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showInput = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return _buildComment(comment);
              },
            ),
          ),
        ),
        if (_showInput) _buildCommentInput(),
        _buildCommentButton(),
      ],
    );
  }

  Widget _buildComment(LiveComment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: comment.isPinned ? Colors.yellow.withOpacity(0.3) : Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (comment.isPinned)
            const Icon(Icons.push_pin, size: 12, color: Colors.yellow),
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${comment.username} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: comment.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onSubmitted: _sendComment,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _sendComment(widget.controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: () => setState(() => _showInput = !_showInput),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Comment',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _sendComment(String text) {
    if (text.trim().isNotEmpty) {
      widget.onSendComment(text.trim());
      widget.controller.clear();
      setState(() => _showInput = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}