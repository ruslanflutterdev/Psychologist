import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/view_model/widgets/assign_quest_dialog.dart';

class QuestListTile extends StatelessWidget {
  final Quest quest;
  final bool isEditable;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final String currentUserId;

  const QuestListTile({
    super.key,
    required this.quest,
    required this.isEditable,
    required this.onEdit,
    required this.onToggleActive,
    required this.currentUserId,
  });

  String _formatUpdatedAt(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute}';
  }

  void _openAssignDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AssignQuestDialog(quest: quest),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isActive = quest.active;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: isActive ? null : cs.surfaceContainerLowest,
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle_outline : Icons.disabled_visible,
          color: isActive ? cs.primary : cs.outline,
        ),
        title: Text(
          quest.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('XP: ${quest.xp} | Сфера: ${quest.type.uiLabel}'),
            Text(
              quest.description.isNotEmpty ? quest.description : 'Нет описания',
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _openAssignDialog(context),
              child: const Text('НАЗНАЧИТЬ'),
            ),
            Text(
              'Обновлено: ${_formatUpdatedAt(quest.updatedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 12),
            if (isEditable)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Редактировать',
                onPressed: onEdit,
              ),
            if (isEditable)
              IconButton(
                icon: Icon(
                  isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: isActive ? cs.primary : cs.outline,
                  size: 28,
                ),
                tooltip: isActive ? 'Деактивировать' : 'Активировать',
                onPressed: onToggleActive,
              ),
            if (quest.createdBy != 'SYSTEM')
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  quest.createdBy == currentUserId ? 'Мой' : 'Чужой',
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
