import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';
import 'package:heros_journey/core/testing/test_keys.dart';

class QuestPickerDialog extends StatefulWidget {
  final QuestCatalogService catalog;

  const QuestPickerDialog({super.key, required this.catalog});

  @override
  State<QuestPickerDialog> createState() => _QuestPickerDialogState();
}

class _QuestPickerDialogState extends State<QuestPickerDialog> {
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
    // В каталоге для выбора показываем только активные квесты
    final filtered = _filter == null
        ? _all.where((q) => q.active).toList()
        : _all.where((q) => q.type == _filter && q.active).toList();

    return AlertDialog(
      title: const Text('+ Выбрать квест'),
      content: SizedBox(
        width: 520,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                key: Tk.questPicker,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        key: Tk.filterChip('all'),
                        label: const Text('Все'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                      ...QuestType.values.map(
                        (t) => FilterChip(
                          key: Tk.filterChip(t.name),
                          label: Text(t.uiLabel),
                          selected: _filter == t,
                          onSelected: (_) => setState(() => _filter = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('Квесты не найдены или не активны.'),
                    ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final q = filtered[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            key: Tk.questTile(q.id),
                            title: Text(q.title),
                            subtitle: Text(q.type.uiLabel),
                            trailing: TextButton(
                              key: Tk.assignBtn(q.id),
                              onPressed: () =>
                                  Navigator.of(context).pop<Quest>(q),
                              child: const Text('Выбрать'),
                            ),
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
