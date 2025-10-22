import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/mock_child_quests_service.dart'; // Import for DuplicateQuestException

class AssignQuestDialog extends StatefulWidget {
  final Quest quest;

  const AssignQuestDialog({super.key, required this.quest});

  @override
  State<AssignQuestDialog> createState() => _AssignQuestDialogState();
}

class _AssignQuestDialogState extends State<AssignQuestDialog> {
  ChildModel? _selectedChild;
  late final Stream<List<ChildModel>> _childrenStream;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _childrenStream = ServiceRegistry.child.getChildren();
  }

  Future<void> _submitAssignment(BuildContext context) async {
    if (_selectedChild == null || _isAssigning) return;

    setState(() => _isAssigning = true);

    final session = context.read<SessionCubit>().state;
    final currentUserId = session?.token ?? 'MOCK_PSYCH_ID';

    try {
      await ServiceRegistry.childQuests.assignQuest(
        childId: _selectedChild!.id,
        quest: widget.quest,
        assignedBy: currentUserId,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Квест "${widget.quest.title}" назначен ребёнку ${_selectedChild!.firstName}.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on DuplicateQuestException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка назначения квеста: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Назначить квест "${widget.quest.title}"'),
      content: SizedBox(
        width: 300,
        child: StreamBuilder<List<ChildModel>>(
          stream: _childrenStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }

            final children = snapshot.data ?? [];

            if (children.isEmpty) {
              return const Text('У вас нет зарегистрированных детей.');
            }

            return DropdownButtonFormField<ChildModel>(
              initialValue: _selectedChild,
              hint: const Text('Выберите ребенка'),
              items: children.map((child) {
                return DropdownMenuItem(value: child, child: Text(child.name));
              }).toList(),
              onChanged: (ChildModel? newValue) {
                setState(() {
                  _selectedChild = newValue;
                });
              },
              validator: (value) => value == null ? 'Выберите ребенка' : null,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isAssigning ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: (_selectedChild != null && !_isAssigning)
              ? () => _submitAssignment(context)
              : null,
          child: _isAssigning
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Назначить'),
        ),
      ],
    );
  }
}
