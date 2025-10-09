import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';

class AssignQuestDialog extends StatefulWidget {
  final QuestCatalogService catalog;

  const AssignQuestDialog({super.key, required this.catalog});

  @override
  State<AssignQuestDialog> createState() => _AssignQuestDialogState();
}

class _AssignQuestDialogState extends State<AssignQuestDialog> {
  QuestType? _filter;
  List<Quest> _all = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.catalog.getAll();
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == null
        ? _all
        : _all.where((q) => q.type == _filter).toList();
    return AlertDialog(
      title: const Text('+ Добавить квест'),
      content: SizedBox(
        width: 520,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Все'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                      ...QuestType.values.map(
                        (t) => FilterChip(
                          label: Text(t.uiLabel),
                          selected: _filter == t,
                          onSelected: (_) => setState(() => _filter = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final q = filtered[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(q.title),
                            subtitle: Text(q.type.uiLabel),
                            trailing: const Icon(Icons.add),
                            onTap: () => Navigator.of(context).pop<Quest>(q),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<Quest>(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}
