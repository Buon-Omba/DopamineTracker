import 'package:flutter/material.dart';

class LineChartData {
  final List<LineChartEntry> entries;
  final Color color;
  final double? minValue;
  final double? maxValue;

  LineChartData({
    required this.entries,
    required this.color,
    this.minValue,
    this.maxValue,
  });
}

class LineChart extends StatelessWidget {
  final List<LineChartData> datasets;
  final String emptyLabel;

  const LineChart({
    super.key,
    required this.datasets,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty || datasets.every((d) => d.entries.isEmpty)) {
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
        
        final referenceDataset = datasets.firstWhere(
          (d) => d.entries.isNotEmpty,
          orElse: () => datasets.first,
        );
        final referenceEntries = referenceDataset.entries;

        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(width, height - 32),
                painter: _MultiLineChartPainter(
                  datasets: datasets,
                ),
              ),
            ),
            SizedBox(
              height: 24,
              child: _buildLabelsRow(referenceEntries, width),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelsRow(List<LineChartEntry> entries, double totalWidth) {
    final count = entries.length;
    if (count == 0) return const SizedBox.shrink();

    final labelledIndices = <int>[];
    for (int i = 0; i < count; i++) {
      if (entries[i].label.isNotEmpty) {
        labelledIndices.add(i);
      }
    }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final dx = count == 1 ? 0.0 : w / (count - 1);

        return Stack(
          clipBehavior: Clip.none,
          children: labelledIndices.map((i) {
            final x = count == 1 ? w / 2 : dx * i;
            return Positioned(
              left: x - 20,
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
  final double value;

  LineChartEntry({required this.label, required this.value});
}

class _MultiLineChartPainter extends CustomPainter {
  final List<LineChartData> datasets;

  _MultiLineChartPainter({
    required this.datasets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var dataset in datasets) {
      if (dataset.entries.isEmpty) continue;

      double min = dataset.minValue ?? 0;
      double max = dataset.maxValue ?? 1;

      // If limits are not provided, calculate them from data
      if (dataset.minValue == null || dataset.maxValue == null) {
        double dataMin = dataset.entries.first.value;
        double dataMax = dataset.entries.first.value;
        for (var e in dataset.entries) {
          if (e.value < dataMin) dataMin = e.value;
          if (e.value > dataMax) dataMax = e.value;
        }
        
        if (dataset.minValue == null) min = dataMin;
        if (dataset.maxValue == null) max = dataMax;
      }

      // Handle cases where min == max to avoid division by zero
      if (min == max) {
        if (min > 0) min = 0;
        else if (min < 0) max = 0;
        else max = 1;
      }

      final range = max - min;

      final linePaint = Paint()
        ..color = dataset.color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final count = dataset.entries.length;
      final dx = count == 1 ? size.width : size.width / (count - 1);

      for (int i = 0; i < count; i++) {
        final entry = dataset.entries[i];
        final x = count == 1 ? size.width / 2 : dx * i;
        
        final normalized = (entry.value - min) / range;
        final y = size.height - (normalized * size.height).clamp(0.0, size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLineChartPainter oldDelegate) {
    return oldDelegate.datasets != datasets;
  }
}
