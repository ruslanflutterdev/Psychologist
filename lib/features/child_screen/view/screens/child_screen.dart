import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/view/models/child_model.dart';
import 'package:heros_journey/features/child_screen/view/models/find_child_by_id.dart';
import 'package:heros_journey/features/child_screen/viewmodel/widgets/child_actions.dart';
import 'package:heros_journey/features/child_screen/viewmodel/widgets/child_error_text.dart';
import 'package:heros_journey/features/child_screen/viewmodel/widgets/child_info_card.dart';
import 'package:heros_journey/features/child_screen/viewmodel/widgets/difficulty_dropdown.dart';
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
  QuestDifficulty _difficulty = QuestDifficulty.medium;
  bool _isLoading = false;
  String? _error;

  ChildModel? _child;
  bool _loadingChild = true;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    final c = await findChildById(widget.childId);
    if (!mounted) return;
    setState(() {
      _child = c;
      _loadingChild = false;
    });
  }

  Future<void> _assignQuest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ServiceRegistry.quest.assignQuest(
        childId: widget.childId,
        difficulty: _difficulty,
      );
      if (!mounted) return;
      final displayName = _child?.name ?? widget.childName;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Квест назначен (${_difficulty.uiLabel}) для $displayName',
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      appBar: AppBar(title: Text('Карточка ребёнка — $title')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChildInfoCard(isLoading: _loadingChild, child: _child),
                  DifficultyDropdown(
                    value: _difficulty,
                    onChanged: _isLoading
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => _difficulty = v);
                          },
                  ),
                  const SizedBox(height: 16),
                  ChildErrorText(error: _error),
                  ChildActions(
                    isLoading: _isLoading,
                    onAssignQuest: _assignQuest,
                    onOpenProgress: _openProgress,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
