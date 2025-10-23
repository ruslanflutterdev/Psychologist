import 'package:flutter/material.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';

class PsychologistHeader extends StatelessWidget {
  const PsychologistHeader({
    required this.psychologist,
    super.key,
  });

  final PsychologistModel psychologist;

  Widget avatar(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (psychologist.avatarUrl != null && psychologist.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(psychologist.avatarUrl!),
        backgroundColor: cs.surfaceContainerHighest,
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: cs.primary.withValues(alpha: 0.12),
      child: Text(
        psychologist.initials,
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            avatar(context),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Психолог', style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  psychologist.fullName,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ваши подопечные:',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
