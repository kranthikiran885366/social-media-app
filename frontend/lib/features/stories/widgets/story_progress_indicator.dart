import 'package:flutter/material.dart';

class StoryProgressIndicator extends StatelessWidget {
  final int storyCount;
  final int currentIndex;
  final double progress;

  const StoryProgressIndicator({
    Key? key,
    required this.storyCount,
    required this.currentIndex,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(storyCount, (index) {
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            child: LinearProgressIndicator(
              value: index < currentIndex 
                  ? 1.0 
                  : index == currentIndex 
                      ? progress 
                      : 0.0,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      }),
    );
  }
}

class StoryInteractionOverlay extends StatelessWidget {
  final dynamic story;
  final Function(String) onReply;
  final VoidCallback onShare;
  final VoidCallback onViewProfile;

  const StoryInteractionOverlay({
    Key? key,
    required this.story,
    required this.onReply,
    required this.onShare,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showReplyDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Send message',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: Colors.white),
        ),
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.send, color: Colors.white),
        ),
      ],
    );
  }

  void _showReplyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 16),
                  const SizedBox(width: 8),
                  const Text('Reply to story...'),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Send message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      onReply('Sample reply');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}