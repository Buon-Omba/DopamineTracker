import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  final List<LineChartEntry> entries;
  final String emptyLabel;
  final Color lineColor;

  const LineChart({
    super.key,
    required this.entries,
    required this.emptyLabel,
    this.lineColor = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = entries.isEmpty
        ? 0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return Center(
        child: Text(
          emptyLabel,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(width, height - 32),
                painter: _LineChartPainter(
                  entries: entries,
                  maxValue: maxValue,
                  color: lineColor,
                ),
              ),
            ),
            SizedBox(
              height: 24,
              child: _buildLabelsRow(entries, width),
            ),
          ],
        );
      },
    );
  }

  /// Builds the X-axis labels, positioning only non-empty labels
  /// at the exact X coordinate that matches the chart data point.
  Widget _buildLabelsRow(List<LineChartEntry> entries, double totalWidth) {
    final count = entries.length;
    if (count == 0) return const SizedBox.shrink();

    // Collect indices that have a visible label
    final labelledIndices = <int>[];
    for (int i = 0; i < count; i++) {
      if (entries[i].label.isNotEmpty) {
        labelledIndices.add(i);
      }
    }

    // If every entry has a label (e.g. 7-day / 14-day view), use simple Expanded row
    if (labelledIndices.length == count) {
      return Row(
        children: entries
            .map(
              (e) => Expanded(
                child: Text(
                  e.label,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      );
    }

    // For sparse labels (e.g. month view), position each label at the
    // exact X coordinate of its data point using a Stack.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final dx = count == 1 ? 0.0 : w / (count - 1);

        return Stack(
          clipBehavior: Clip.none,
          children: labelledIndices.map((i) {
            final x = count == 1 ? w / 2 : dx * i;
            return Positioned(
              left: x - 20, // center a 40dp-wide label on the point
              top: 0,
              child: SizedBox(
                width: 40,
                child: Text(
                  entries[i].label,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class LineChartEntry {
  final String label;
  final int value;

  LineChartEntry({required this.label, required this.value});
}

class _LineChartPainter extends CustomPainter {
  final List<LineChartEntry> entries;
  final int maxValue;
  final Color color;

  _LineChartPainter({
    required this.entries,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final count = entries.length;
    final dx = count == 1 ? size.width : size.width / (count - 1);

    for (int i = 0; i < count; i++) {
      final entry = entries[i];
      final x = count == 1 ? size.width / 2 : dx * i;
      final y = size.height -
          ((entry.value / maxValue) * size.height)
              .clamp(0.0, size.height); // invert axis

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.color != color;
  }
}
