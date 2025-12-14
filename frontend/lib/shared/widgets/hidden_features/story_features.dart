import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DraggableTextWidget extends StatefulWidget {
  final String text;
  final Function(Offset) onPositionChanged;

  const DraggableTextWidget({super.key, required this.text, required this.onPositionChanged});

  @override
  State<DraggableTextWidget> createState() => _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends State<DraggableTextWidget> {
  Offset _position = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _position = details.offset;
          });
          widget.onPositionChanged(_position);
        },
        child: GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryRingAnimation extends StatefulWidget {
  final Widget child;
  final bool hasUnseenStory;

  const StoryRingAnimation({super.key, required this.child, this.hasUnseenStory = false});

  @override
  State<StoryRingAnimation> createState() => _StoryRingAnimationState();
}

class _StoryRingAnimationState extends State<StoryRingAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    if (widget.hasUnseenStory) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.hasUnseenStory
                ? SweepGradient(
                    colors: const [Colors.purple, Colors.pink, Colors.orange, Colors.purple],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 6.28),
                  )
                : null,
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2),
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShakeForFeedbackWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;

  const ShakeForFeedbackWidget({super.key, required this.child, required this.onShake});

  @override
  State<ShakeForFeedbackWidget> createState() => _ShakeForFeedbackWidgetState();
}

class _ShakeForFeedbackWidgetState extends State<ShakeForFeedbackWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _shakeIntensity = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: -1, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _shakeIntensity += details.delta.dx.abs();
        });
        
        if (_shakeIntensity > 100) {
          _triggerShake();
          _shakeIntensity = 0;
        }
      },
      onPanEnd: (_) => setState(() => _shakeIntensity = 0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value * 5, 0),
            child: widget.child,
          );
        },
      ),
    );
  }

  void _triggerShake() {
    HapticFeedback.heavyImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onShake();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}