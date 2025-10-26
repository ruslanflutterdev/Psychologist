import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/quest_catalog/models/quest_catalog_filter.dart';

class CatalogFilterRow extends StatelessWidget {
  final QuestCatalogFilter filter;
  final ValueChanged<String?> onSearchChanged;
  final ValueChanged<QuestType?> onTypeChanged;
  final ValueChanged<bool> onActiveToggled;

  const CatalogFilterRow({
    super.key,
    required this.filter,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onActiveToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск по названию',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<QuestType>(
            value: filter.type,
            hint: const Text('Сфера'),
            items: QuestType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.uiLabel)))
                .toList(),
            onChanged: onTypeChanged,
          ),
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Активные'),
            selected: filter.onlyActive ?? false,
            onSelected: onActiveToggled,
          ),
        ],
      ),
    );
  }
}
