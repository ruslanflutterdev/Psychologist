import 'package:flutter/material.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';

class PsychologistHeader extends StatelessWidget {
  final PsychologistModel profile;

  const PsychologistHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget avatar() {
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        return CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(profile.avatarUrl!),
          backgroundColor: cs.surfaceContainerHighest,
        );
      }
      return CircleAvatar(
        radius: 28,
        backgroundColor: cs.primary.withValues(alpha: 0.12),
        child: Text(
          profile.initials,
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            avatar(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Психолог', style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  profile.fullName,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
