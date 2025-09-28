import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  final String childId;
  final String childName;

  const ProgressScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Прогресс: $childName')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ID ребёнка: $childId',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Экран прогресса (заглушка)',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Здесь позже появятся графики/метрики по сферам PQ/EQ/IQ/SoQ/SQ, '
                    'история квестов и достижения.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
