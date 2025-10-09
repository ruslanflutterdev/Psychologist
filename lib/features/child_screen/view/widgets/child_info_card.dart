import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';

class ChildInfoCard extends StatelessWidget {
  final bool isLoading;
  final ChildModel? child;

  const ChildInfoCard({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (child == null) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Данные ребёнка не найдены'),
        ),
      );
    }

    Widget row(String label, String value) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Информация о ребёнке', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            row('Имя ребёнка', child!.firstName),
            const SizedBox(height: 6),
            row('Фамилия ребёнка', child!.lastName),
            const SizedBox(height: 6),
            row('Возраст ребёнка', '${child!.age}'),
            const SizedBox(height: 6),
            row('Пол ребёнка', child!.gender.uiLabel),
          ],
        ),
      ),
    );
  }
}
