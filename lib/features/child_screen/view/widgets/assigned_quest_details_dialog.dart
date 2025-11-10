import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:intl/intl.dart';

class AssignedQuestDetailsDialog extends StatelessWidget {
  final ChildQuest item;

  const AssignedQuestDetailsDialog({super.key, required this.item});

  String _formatDate(DateTime dt) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return fmt.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quest = item.quest;
    final questDateStr = _formatDate(quest.updatedAt);

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Детали квеста: ${quest.title}',
              style: theme.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                'Информация',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Последнее обновление шаблона квеста: $questDateStr',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
          ),
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
