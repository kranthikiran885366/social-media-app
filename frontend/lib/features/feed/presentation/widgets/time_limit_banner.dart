import 'package:flutter/material.dart';

class TimeLimitBanner extends StatefulWidget {
  const TimeLimitBanner({super.key});

  @override
  State<TimeLimitBanner> createState() => _TimeLimitBannerState();
}

class _TimeLimitBannerState extends State<TimeLimitBanner> {
  int remainingMinutes = 12; // Mock remaining time
  
  @override
  Widget build(BuildContext context) {
    if (remainingMinutes <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade100,
        child: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Daily limit reached. Take a break! 🧘‍♀️',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View Stats'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            '$remainingMinutes minutes left today',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.grey.shade300,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: remainingMinutes / 15, // 15 minutes total
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: remainingMinutes > 5 ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}