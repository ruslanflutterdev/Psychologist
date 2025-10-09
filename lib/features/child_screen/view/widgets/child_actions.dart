import 'package:flutter/material.dart';

class ChildActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onAssignQuest;
  final VoidCallback onOpenProgress;

  const ChildActions({
    super.key,
    required this.isLoading,
    required this.onAssignQuest,
    required this.onOpenProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isLoading ? null : onAssignQuest,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Назначить квест'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onOpenProgress,
          icon: const Icon(Icons.bar_chart),
          label: const Text('Посмотреть прогресс'),
        ),
      ],
    );
  }
}
