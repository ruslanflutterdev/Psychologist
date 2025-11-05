import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/view/widgets/assigned_quest_details_dialog.dart';

class AssignedQuestTile extends StatelessWidget {
  final ChildQuest item;

  const AssignedQuestTile({super.key, required this.item});

  void _openDetailsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AssignedQuestDetailsDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _openDetailsDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(item.quest.title),
          subtitle: Text(item.quest.type.uiLabel),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
