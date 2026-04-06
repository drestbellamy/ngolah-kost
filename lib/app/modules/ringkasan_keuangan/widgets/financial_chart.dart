import 'package:flutter/material.dart';

class FinancialChart extends StatelessWidget {
  final List<double> pemasukanData;
  final List<double> pengeluaranData;
  final List<String> labels;

  const FinancialChart({
    super.key,
    required this.pemasukanData,
    required this.pengeluaranData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate max value for Y-axis labels
    final maxValue = [
      ...pemasukanData,
      ...pengeluaranData,
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Y-axis labels
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildYLabel('${maxValue.toStringAsFixed(0)}Jt'),
                    _buildYLabel('${(maxValue * 0.75).toStringAsFixed(0)}Jt'),
                    _buildYLabel('${(maxValue * 0.5).toStringAsFixed(0)}Jt'),
                    _buildYLabel('${(maxValue * 0.25).toStringAsFixed(0)}Jt'),
                    _buildYLabel('0Jt'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: ChartPainter(
                      pemasukanData: pemasukanData,
                      pengeluaranData: pengeluaranData,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: labels.map((label) {
              return Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildYLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600]));
  }
}

class ChartPainter extends CustomPainter {
  final List<double> pemasukanData;
  final List<double> pengeluaranData;

  ChartPainter({required this.pemasukanData, required this.pengeluaranData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Find max value for scaling
    final maxValue = [
      ...pemasukanData,
      ...pengeluaranData,
    ].reduce((a, b) => a > b ? a : b);

    final spacing = size.width / (pemasukanData.length - 1);
    final heightScale = (size.height - 40) / maxValue;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height - 20) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Pemasukan line (green)
    paint.color = const Color(0xFF10B981);
    _drawLine(canvas, pemasukanData, spacing, heightScale, size.height, paint);
    _drawPoints(
      canvas,
      pemasukanData,
      spacing,
      heightScale,
      size.height,
      paint,
    );

    // Draw Pengeluaran line (red)
    paint.color = const Color(0xFFEF4444);
    _drawLine(
      canvas,
      pengeluaranData,
      spacing,
      heightScale,
      size.height,
      paint,
    );
    _drawPoints(
      canvas,
      pengeluaranData,
      spacing,
      heightScale,
      size.height,
      paint,
    );
  }

  void _drawLine(
    Canvas canvas,
    List<double> data,
    double spacing,
    double heightScale,
    double height,
    Paint paint,
  ) {
    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final y = height - 20 - (data[i] * heightScale);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawPoints(
    Canvas canvas,
    List<double> data,
    double spacing,
    double heightScale,
    double height,
    Paint paint,
  ) {
    paint.style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final y = height - 20 - (data[i] * heightScale);

      canvas.drawCircle(Offset(x, y), 4, paint);
    }

    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
