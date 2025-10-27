import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';

class AssignedQuestTile extends StatelessWidget {
  final ChildQuest item;
  const AssignedQuestTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(item.quest.title),
        subtitle: Text(item.quest.type.uiLabel),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
