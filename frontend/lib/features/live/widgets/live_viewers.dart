import 'package:flutter/material.dart';

class LiveViewersWidget extends StatelessWidget {
  final int count;
  final List<String>? avatars;

  const LiveViewersWidget({
    super.key,
    required this.count,
    this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (avatars != null && avatars!.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildAvatarStack(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 60,
      height: 20,
      child: Stack(
        children: List.generate(
          (avatars!.length > 3 ? 3 : avatars!.length),
          (index) => Positioned(
            left: index * 15.0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: CircleAvatar(
                radius: 8,
                backgroundImage: NetworkImage(avatars![index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}