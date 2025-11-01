import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/testing/test_keys.dart';
import 'package:heros_journey/features/child_screen/view/widgets/photo_viewer_dialog.dart';
import 'package:intl/intl.dart';

class CompletedQuestTile extends StatelessWidget {
  final ChildQuest item;

  const CompletedQuestTile({super.key, required this.item});

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
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final dateStr =
        item.completedAt != null ? fmt.format(item.completedAt!) : '';

    Widget? thumb() {
      if (item.photoUrl == null || item.photoUrl!.isEmpty) return null;
      return InkWell(
        onTap: () => showPhotoViewer(context, item.photoUrl!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.photoUrl!,
            key: Tk.completedPhoto(item.id),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final thumbWidget = thumb();

    return Card(
      key: Tk.completedItem(item.id),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbWidget != null) thumbWidget,
            if (thumbWidget != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.quest.title,
                    key: Tk.completedTitle(item.id),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.quest.type.uiLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.achievement != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(item.achievement!.iconPath),
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Получена ачивка: ${item.achievement!.title}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (item.childComment != null &&
                      item.childComment!.isNotEmpty)
                    Text(
                      'Комментарий: ${item.childComment!}',
                      key: Tk.completedComment(item.id),
                      style: theme.textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),
                  if (dateStr.isNotEmpty)
                    Text(
                      'Выполнено: $dateStr',
                      key: Tk.completedDate(item.id),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
