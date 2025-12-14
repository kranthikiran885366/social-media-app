import 'package:flutter/material.dart';

class LiveControlsWidget extends StatelessWidget {
  final bool isHost;
  final bool isLive;
  final bool isMuted;
  final bool isFrontCamera;
  final VoidCallback onStartLive;
  final VoidCallback onEndLive;
  final VoidCallback onToggleMute;
  final VoidCallback onSwitchCamera;
  final VoidCallback onAddGuest;
  final VoidCallback onToggleComments;

  const LiveControlsWidget({
    super.key,
    required this.isHost,
    required this.isLive,
    required this.isMuted,
    required this.isFrontCamera,
    required this.onStartLive,
    required this.onEndLive,
    required this.onToggleMute,
    required this.onSwitchCamera,
    required this.onAddGuest,
    required this.onToggleComments,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHost) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            onTap: onToggleMute,
            color: isMuted ? Colors.red : Colors.white,
          ),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            onTap: onSwitchCamera,
          ),
          if (!isLive)
            _buildStartButton()
          else
            _buildControlButton(
              icon: Icons.call_end,
              onTap: onEndLive,
              color: Colors.red,
            ),
          _buildControlButton(
            icon: Icons.person_add,
            onTap: onAddGuest,
          ),
          _buildControlButton(
            icon: Icons.comment,
            onTap: onToggleComments,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: onStartLive,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          'Go Live',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}