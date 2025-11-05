import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:intl/intl.dart';

class CompletedQuestDetailsDialog extends StatelessWidget {
  final ChildQuest item;

  const CompletedQuestDetailsDialog({super.key, required this.item});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Дата выполнения не указана';
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return fmt.format(dt);
  }

  Widget _buildImage(BuildContext context) {
    if (item.photoUrl == null || item.photoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          item.photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: Text('Не удалось загрузить фото')),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quest = item.quest;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                _buildImage(context),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сфера: ${quest.type.uiLabel} | Опыт: ${quest.xp} XP',
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Описание квеста',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description.isNotEmpty
                        ? quest.description
                        : 'Описание не предоставлено.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Divider(height: 24),
                  Text(
                    'Отчет о выполнении',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Дата выполнения: ${_formatDate(item.completedAt)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (item.childComment != null && item.childComment!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Комментарий ребёнка: ${item.childComment!}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
