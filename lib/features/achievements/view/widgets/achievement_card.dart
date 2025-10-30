import 'package:flutter/material.dart';
import 'package:heros_journey/features/achievements/models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final ValueChanged<AchievementModel> onToggleAttachment;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.onToggleAttachment,
  });

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'bolt':
        return Icons.bolt;
      case 'school':
        return Icons.school;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'verified':
        return Icons.verified;
      case 'psychology':
        return Icons.psychology;
      case 'favorite':
        return Icons.favorite;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isAttached = achievement.isAttached;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          _getIconData(achievement.iconPath),
          size: 48,
          color: cs.primary,
        ),
        title: Text(achievement.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isAttached ? Icons.link : Icons.link_off,
                  size: 14,
                  color: isAttached ? cs.primary : cs.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  isAttached
                      ? 'Привязана (Quest ID: ${achievement.questId?.substring(0, 4)}...)'
                      : 'Не привязана к квесту',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isAttached ? cs.primary : cs.outline,
                    fontWeight:
                        isAttached ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: FilledButton(
          onPressed: () => onToggleAttachment(achievement),
          style: isAttached
              ? FilledButton.styleFrom(backgroundColor: cs.error)
              : null,
          child: Text(isAttached ? 'Отвязать' : 'Привязать к квесту'),
        ),
      ),
    );
  }
}
