import 'package:flutter/material.dart';
import '../models/creator_models.dart';

class PerformanceChart extends StatelessWidget {
  final List<DailyFollowerData> data;

  const PerformanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: ChartPainter(data),
                size: const Size(double.infinity, 200),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Followers', Colors.blue),
        _buildLegendItem('Gained', Colors.green),
        _buildLegendItem('Lost', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<DailyFollowerData> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    
    // Mock data for demonstration
    final mockData = List.generate(7, (index) => 
      DailyFollowerData(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        followers: 15000 + (index * 50) + (index % 2 == 0 ? 20 : -10),
        gained: 20 + (index * 5),
        lost: 5 + (index % 3),
      )
    );

    final maxFollowers = mockData.map((d) => d.followers).reduce((a, b) => a > b ? a : b);
    final minFollowers = mockData.map((d) => d.followers).reduce((a, b) => a < b ? a : b);
    final range = maxFollowers - minFollowers;

    for (int i = 0; i < mockData.length; i++) {
      final x = i * stepX;
      final y = size.height - ((mockData[i].followers - minFollowers) / range * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < mockData.length; i++) {
      final x = i * stepX;
      final y = size.height - ((mockData[i].followers - minFollowers) / range * size.height);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}