import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/view/widgets/photo_viewer_dialog.dart';
import 'package:intl/intl.dart';

class CompletedQuestTile extends StatelessWidget {
  final ChildQuest item;

  const CompletedQuestTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final dateStr = item.completedAt != null
        ? fmt.format(item.completedAt!)
        : '';

    Widget? thumb() {
      if (item.photoUrl == null || item.photoUrl!.isEmpty) return null;
      return InkWell(
        onTap: () => showPhotoViewer(context, item.photoUrl!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.photoUrl!,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumb() != null) thumb()!,
            if (thumb() != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.quest.title,
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
                  if (item.childComment != null &&
                      item.childComment!.isNotEmpty)
                    Text(
                      'Комментарий: ${item.childComment!}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),
                  if (dateStr.isNotEmpty)
                    Text(
                      'Выполнено: $dateStr',
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
