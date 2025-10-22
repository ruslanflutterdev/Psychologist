import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/find_child_by_id.dart';
import 'package:heros_journey/features/child_screen/repository/services/mock_child_quests_service.dart';
import 'package:heros_journey/features/child_screen/view/widgets/child_error_text.dart';
import 'package:heros_journey/features/child_screen/view/widgets/child_info_card.dart';
import 'package:heros_journey/features/child_screen/view_model/parents_widgets/parent_contact_card.dart';
import 'package:heros_journey/features/child_screen/view_model/widgets/assign_quest_dialog.dart';
import 'package:heros_journey/features/child_screen/view_model/widgets/child_quests_section.dart';
import 'package:heros_journey/features/progress_screen/view/progress_screen.dart';

class ChildScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  bool _isAssigning = false;
  String? _error;

  ChildModel? _child;
  bool _loadingChild = true;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    try {
      final c = await findChildById(widget.childId);
      if (!mounted) return;
      setState(() {
        _loadingChild = false;

        if (c != null) {
          _child = ChildModel(
            id: c.id,
            firstName: c.firstName,
            lastName: c.lastName,
            age: c.age,
            gender: c.gender,
            archetype: 'Герой',
            updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          );
        } else {
          _child = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _child = null;
        _loadingChild = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _assignQuestFlow() async {
    final session = context.read<SessionCubit>().state;
    final currentUserId = session?.token ?? 'MOCK_PSYCH_ID';

    setState(() => _isAssigning = true);
    try {
      final quest = await showDialog<Quest>(
        context: context,
        builder: (_) =>
            AssignQuestDialog(catalog: ServiceRegistry.questCatalog),
      );
      if (!mounted) return;

      if (quest != null) {
        await ServiceRegistry.childQuests.assignQuest(
          childId: widget.childId,
          quest: quest,
          assignedBy: currentUserId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Квест "${quest.title}" назначен ребёнку.')),
        );
      }
    } on DuplicateQuestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Ошибка назначения квеста: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  void _openProgress() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgressScreen(
          childId: widget.childId,
          childName: _child?.name ?? widget.childName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _child?.name ?? widget.childName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Карточка ребёнка — $title'),
        actions: [
          IconButton(
            onPressed: _openProgress,
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Прогресс',
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: _isAssigning ? null : _assignQuestFlow,
            icon: const Icon(Icons.add),
            label: const Text('Добавить квест'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ChildInfoCard(isLoading: _loadingChild, child: _child),
              ParentContactCard(
                childId: widget.childId,
                service: ServiceRegistry.parentContact,
              ),
              const SizedBox(height: 8),
              ChildErrorText(error: _error),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ChildQuestsSection(
                    childId: widget.childId,
                    service: ServiceRegistry.childQuests,
                    onRefreshAfterChange: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
