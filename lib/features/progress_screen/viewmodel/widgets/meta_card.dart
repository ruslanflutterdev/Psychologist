import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';

class MetaCard extends StatelessWidget {
  final ChildProgressModel data;

  const MetaCard({super.key, required this.data});

  String _twoDigits(int v) => v.toString().padLeft(2, '0');

  String _formatUpdatedAt(DateTime dt) {
    return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
        '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
  }

  Widget _metricItem({
    required BuildContext context,
    required String name,
    required int value,
    required int max,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: theme.textTheme.bodyMedium),
        Text(
          '$value / $max',
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = _formatUpdatedAt(data.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Сводка по сферам', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _metricItem(
              context: context,
              name: 'PQ (Physical)',
              value: data.pq,
              max: data.max,
            ),
            const SizedBox(height: 6),
            _metricItem(
              context: context,
              name: 'EQ (Emotional)',
              value: data.eq,
              max: data.max,
            ),
            const SizedBox(height: 6),
            _metricItem(
              context: context,
              name: 'IQ (Cognitive)',
              value: data.iq,
              max: data.max,
            ),
            const SizedBox(height: 6),
            _metricItem(
              context: context,
              name: 'SoQ (Social)',
              value: data.soq,
              max: data.max,
            ),
            const SizedBox(height: 6),
            _metricItem(
              context: context,
              name: 'SQ (Spiritual)',
              value: data.sq,
              max: data.max,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Max', style: theme.textTheme.bodyMedium),
                Text('${data.max}', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text('Обновлено: $updated', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
