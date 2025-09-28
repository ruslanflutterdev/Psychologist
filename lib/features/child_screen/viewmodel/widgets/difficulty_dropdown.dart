import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest.dart';

class DifficultyDropdown extends StatelessWidget {
  final QuestDifficulty value;
  final ValueChanged<QuestDifficulty?>? onChanged;

  const DifficultyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<QuestDifficulty>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Сложность/Уровень',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: QuestDifficulty.low,    child: Text('Low')),
        DropdownMenuItem(value: QuestDifficulty.medium, child: Text('Medium')),
        DropdownMenuItem(value: QuestDifficulty.high,   child: Text('High')),
      ],
      onChanged: onChanged,
    );
  }
}
