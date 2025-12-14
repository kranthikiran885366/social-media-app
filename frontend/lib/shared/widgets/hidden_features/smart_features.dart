import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefreshWidget({super.key, required this.child, required this.onRefresh});

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        _controller.forward();
        await widget.onRefresh();
        _controller.reverse();
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SaveDraftReminderWidget extends StatefulWidget {
  final String content;
  final VoidCallback onSave;

  const SaveDraftReminderWidget({super.key, required this.content, required this.onSave});

  @override
  State<SaveDraftReminderWidget> createState() => _SaveDraftReminderWidgetState();
}

class _SaveDraftReminderWidgetState extends State<SaveDraftReminderWidget> {
  bool _showReminder = false;

  @override
  void initState() {
    super.initState();
    _checkForUnsavedContent();
  }

  void _checkForUnsavedContent() {
    if (widget.content.isNotEmpty) {
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && widget.content.isNotEmpty) {
          setState(() => _showReminder = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showReminder) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.save, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Save as draft?',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onSave();
              setState(() => _showReminder = false);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () => setState(() => _showReminder = false),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class QuietModeWidget extends StatefulWidget {
  final Widget child;

  const QuietModeWidget({super.key, required this.child});

  @override
  State<QuietModeWidget> createState() => _QuietModeWidgetState();
}

class _QuietModeWidgetState extends State<QuietModeWidget> {
  bool _isQuietMode = false;

  @override
  void initState() {
    super.initState();
    _loadQuietModeState();
  }

  void _loadQuietModeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isQuietMode = prefs.getBool('quiet_mode') ?? false;
    });
  }

  void _toggleQuietMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isQuietMode = !_isQuietMode;
    });
    await prefs.setBool('quiet_mode', _isQuietMode);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isQuietMode)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_off, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text('Quiet', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: _toggleQuietMode,
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class TakeBreakReminderWidget extends StatefulWidget {
  final int usageMinutes;

  const TakeBreakReminderWidget({super.key, required this.usageMinutes});

  @override
  State<TakeBreakReminderWidget> createState() => _TakeBreakReminderWidgetState();
}

class _TakeBreakReminderWidgetState extends State<TakeBreakReminderWidget> {
  bool _showReminder = false;

  @override
  void initState() {
    super.initState();
    _checkUsageTime();
  }

  void _checkUsageTime() {
    if (widget.usageMinutes > 15 && widget.usageMinutes % 15 == 0) {
      setState(() => _showReminder = true);
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showReminder = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showReminder) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.self_improvement, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Time for a break?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve been scrolling for ${widget.usageMinutes} minutes',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => setState(() => _showReminder = false),
                child: const Text('Later', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _showReminder = false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Take Break', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AutoBrightnessWidget extends StatefulWidget {
  final Widget child;

  const AutoBrightnessWidget({super.key, required this.child});

  @override
  State<AutoBrightnessWidget> createState() => _AutoBrightnessWidgetState();
}

class _AutoBrightnessWidgetState extends State<AutoBrightnessWidget> {
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _adjustBrightness();
  }

  void _adjustBrightness() {
    // Simulate ambient light detection
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour <= 6) {
      _brightness = 0.3; // Night mode
    } else {
      _brightness = 1.0; // Day mode
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(1 - _brightness),
      child: widget.child,
    );
  }
}