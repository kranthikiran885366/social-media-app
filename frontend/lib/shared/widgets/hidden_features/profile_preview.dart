import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePreviewWidget extends StatefulWidget {
  final String userId;
  final Widget child;

  const ProfilePreviewWidget({super.key, required this.userId, required this.child});

  @override
  State<ProfilePreviewWidget> createState() => _ProfilePreviewWidgetState();
}

class _ProfilePreviewWidgetState extends State<ProfilePreviewWidget> {
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _showPreview,
      onLongPressEnd: (_) => _hidePreview(),
      child: widget.child,
    );
  }

  void _showPreview(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalPosition.dy - 200,
        left: details.globalPosition.dx - 150,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 300,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person)),
                const SizedBox(height: 12),
                const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Bio text here...'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Posts', '123'),
                    _buildStat('Followers', '1.2K'),
                    _buildStat('Following', '456'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Follow')),
              ],
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePreview() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}