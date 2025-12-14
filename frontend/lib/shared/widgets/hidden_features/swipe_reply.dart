import 'package:flutter/material.dart';

class SwipeReplyWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeReplyWidget({super.key, required this.child, required this.onReply});

  @override
  State<SwipeReplyWidget> createState() => _SwipeReplyWidgetState();
}

class _SwipeReplyWidgetState extends State<SwipeReplyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, 0)).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDistance = details.primaryDelta ?? 0;
          if (_dragDistance > 0) {
            _controller.value = (_dragDistance / 100).clamp(0.0, 1.0);
          }
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragDistance > 50) {
          widget.onReply();
        }
        _controller.reverse();
        _dragDistance = 0;
      },
      child: Stack(
        children: [
          if (_controller.value > 0.1)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.reply,
                  color: Colors.grey.withOpacity(_controller.value),
                  size: 24 * _controller.value,
                ),
              ),
            ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value * 100,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: widget.child,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}