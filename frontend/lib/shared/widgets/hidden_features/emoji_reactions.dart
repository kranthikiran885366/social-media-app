import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmojiReactionWidget extends StatefulWidget {
  final Widget child;
  final Function(String) onReaction;

  const EmojiReactionWidget({super.key, required this.child, required this.onReaction});

  @override
  State<EmojiReactionWidget> createState() => _EmojiReactionWidgetState();
}

class _EmojiReactionWidgetState extends State<EmojiReactionWidget> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<String> _emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _showEmojiReactions,
      onLongPressEnd: (_) => _hideEmojiReactions(),
      onTap: () => widget.onReaction('❤️'),
      child: widget.child,
    );
  }

  void _showEmojiReactions(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalPosition.dy - 60,
        left: details.globalPosition.dx - 150,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _emojis.map((emoji) => 
                      GestureDetector(
                        onTap: () {
                          widget.onReaction(emoji);
                          _hideEmojiReactions();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _hideEmojiReactions() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}