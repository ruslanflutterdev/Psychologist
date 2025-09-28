import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest.dart';
import 'package:heros_journey/core/services/service_registry.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Квест назначен (${_difficulty.uiLabel}) для ${widget.childName}',
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openProgress() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgressScreen(
          childId: widget.childId,
          childName: widget.childName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка ребёнка')),
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
                  Text(
                    'Ребёнок: ${widget.childName} (ID: ${widget.childId})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<QuestDifficulty>(
                    value: _difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Сложность/Уровень',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: QuestDifficulty.low,
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: QuestDifficulty.medium,
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: QuestDifficulty.high,
                        child: Text('High'),
                      ),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (v) {
                            if (v != null) {
                              setState(() => _difficulty = v);
                            }
                          },
                  ),

                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),

                  FilledButton(
                    onPressed: _isLoading ? null : _assignQuest,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Назначить квест'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _openProgress,
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Посмотреть прогресс'),
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
