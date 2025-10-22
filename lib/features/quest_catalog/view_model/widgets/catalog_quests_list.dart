import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/quest_catalog/view/widgets/quest_list_tile.dart';

class CatalogQuestsList extends StatelessWidget {
  final List<Quest> quests;
  final bool isLoading;
  final String currentUserId;
  final ValueChanged<Quest> onEdit;
  final ValueChanged<Quest> onToggleActive;

  const CatalogQuestsList({
    super.key,
    required this.quests,
    required this.isLoading,
    required this.currentUserId,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty && !isLoading) {
      return const Expanded(child: Center(child: Text('Квестов не найдено.')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          final q = quests[index];
          final isOwner = q.createdBy == currentUserId;
          return QuestListTile(
            quest: q,
            isEditable: isOwner,
            onEdit: () => onEdit(q),
            onToggleActive: () => onToggleActive(q),
            currentUserId: currentUserId,
          );
        },
      ),
    );
  }
}
