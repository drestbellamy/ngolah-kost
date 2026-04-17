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

  // Format label sumbu Y - selalu bilangan bulat
  String _formatYAxisLabel(double value) {
    return '${value.round()}Jt';
  }

  // Hitung nice max value untuk sumbu Y - bulatkan ke atas
  double _calculateNiceMaxValue(double maxValue) {
    if (maxValue == 0) return 4.0; // Default minimal 4 untuk spacing yang baik

    // Bulatkan ke atas
    final rounded = maxValue.ceil().toDouble();

    // Pastikan minimal 4 untuk spacing yang baik
    if (rounded < 4) return 4.0;

    // Jika lebih dari 4, bulatkan ke kelipatan yang bagus
    if (rounded <= 5) return 5.0;
    if (rounded <= 10) return 10.0;

    // Untuk nilai lebih besar, bulatkan ke kelipatan 5
    return ((rounded / 5).ceil() * 5).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max value for Y-axis labels
    final allValues = [...pemasukanData, ...pengeluaranData];
    final maxValue = allValues.isEmpty
        ? 1.0
        : allValues.reduce((a, b) => a > b ? a : b);

    // Gunakan nice max value untuk sumbu Y
    final displayMaxValue = _calculateNiceMaxValue(maxValue);

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
                    _buildYLabel(_formatYAxisLabel(displayMaxValue)),
                    _buildYLabel(_formatYAxisLabel(displayMaxValue * 0.75)),
                    _buildYLabel(_formatYAxisLabel(displayMaxValue * 0.5)),
                    _buildYLabel(_formatYAxisLabel(displayMaxValue * 0.25)),
                    _buildYLabel('0Jt'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart dengan shadow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: ChartPainter(
                        pemasukanData: pemasukanData,
                        pengeluaranData: pengeluaranData,
                        maxValue: displayMaxValue,
                      ),
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
  final double maxValue;

  ChartPainter({
    required this.pemasukanData,
    required this.pengeluaranData,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Validasi data
    if (pemasukanData.isEmpty || pengeluaranData.isEmpty) {
      return; // Tidak menggambar apa-apa jika data kosong
    }

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Perbaiki perhitungan spacing untuk menghindari division by zero
    final dataLength = pemasukanData.length;
    final spacing = dataLength > 1
        ? size.width / (dataLength - 1)
        : size.width / 2;
    final heightScale = maxValue > 0 ? (size.height - 40) / maxValue : 1.0;

    // Draw grid lines (horizontal - lebih jelas)
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height - 20) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines untuk setiap bulan
    final verticalGridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i < dataLength; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 20),
        verticalGridPaint,
      );
    }

    // Draw Pemasukan line (green) dengan garis yang lebih tebal
    paint.color = const Color(0xFF10B981);
    paint.strokeWidth = 3;
    _drawLine(canvas, pemasukanData, spacing, heightScale, size.height, paint);
    _drawPoints(
      canvas,
      pemasukanData,
      spacing,
      heightScale,
      size.height,
      paint,
    );

    // Draw Pengeluaran line (red) dengan garis yang lebih tebal
    paint.color = const Color(0xFFEF4444);
    paint.strokeWidth = 3;
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
    if (data.isEmpty) return;

    final path = Path();
    bool hasValidPoint = false;

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final dataValue = data[i].isFinite ? data[i] : 0.0; // Handle NaN/Infinity
      final y = height - 20 - (dataValue * heightScale);

      // Validasi koordinat
      if (!x.isFinite || !y.isFinite) continue;

      if (!hasValidPoint) {
        path.moveTo(x, y);
        hasValidPoint = true;
      } else {
        path.lineTo(x, y);
      }
    }

    if (hasValidPoint) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawPoints(
    Canvas canvas,
    List<double> data,
    double spacing,
    double heightScale,
    double height,
    Paint paint,
  ) {
    if (data.isEmpty) return;

    final originalColor = paint.color;

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final dataValue = data[i].isFinite ? data[i] : 0.0; // Handle NaN/Infinity
      final y = height - 20 - (dataValue * heightScale);

      // Validasi koordinat sebelum menggambar
      if (x.isFinite && y.isFinite) {
        // Draw white border circle
        paint.style = PaintingStyle.fill;
        paint.color = Colors.white;
        canvas.drawCircle(Offset(x, y), 6, paint);

        // Draw colored inner circle
        paint.color = originalColor;
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }

    paint.style = PaintingStyle.stroke;
    paint.color = originalColor;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
