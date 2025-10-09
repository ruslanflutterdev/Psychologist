import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';

class RadarChartCard extends StatelessWidget {
  final ChildProgressModel data;

  const RadarChartCard({super.key, required this.data});

  List<double> _values() => [
    data.pq.toDouble(),
    data.eq.toDouble(),
    data.iq.toDouble(),
    data.soq.toDouble(),
    data.sq.toDouble(),
  ];

  List<String> _titles() => const ['PQ', 'EQ', 'IQ', 'SoQ', 'SQ'];

  RadarDataSet _currentDataSet(ColorScheme cs, List<double> values) {
    return RadarDataSet(
      dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
      borderColor: cs.primary,
      fillColor: cs.primary.withValues(alpha: 0.20),
      entryRadius: 2,
      borderWidth: 2,
    );
  }

  RadarDataSet _maxDataSet(ColorScheme cs, int len, double max) {
    return RadarDataSet(
      dataEntries: List.generate(len, (_) => RadarEntry(value: max)),
      borderColor: cs.secondary.withValues(alpha: .35),
      fillColor: Colors.transparent,
      borderWidth: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titles = _titles();
    final values = _values();

    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        radarBorderData: const BorderSide(color: Colors.transparent),
        tickCount: 4,
        ticksTextStyle: TextStyle(color: cs.outline),
        tickBorderData: BorderSide(color: cs.outline.withValues(alpha: .25)),
        gridBorderData: BorderSide(color: cs.outline.withValues(alpha: .25)),
        titleTextStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: .9),
          fontWeight: FontWeight.w600,
        ),
        getTitle: (index, angle) => RadarChartTitle(text: titles[index]),
        radarShape: RadarShape.polygon,
        dataSets: [
          _currentDataSet(cs, values),
          _maxDataSet(cs, values.length, data.max.toDouble()),
        ],
        radarTouchData: RadarTouchData(enabled: true),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
