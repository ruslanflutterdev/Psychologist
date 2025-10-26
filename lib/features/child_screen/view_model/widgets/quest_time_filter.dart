import 'package:flutter/material.dart' hide DateRangePickerDialog;
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/models/time_filter_option.dart';
import 'package:heros_journey/features/child_screen/view/widgets/date_range_picker_dialog.dart';

class QuestTimeFilterDropdown extends StatefulWidget {
  final QuestTimeFilter currentFilter;
  final ValueChanged<QuestTimeFilter> onFilterChanged;

  const QuestTimeFilterDropdown({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<QuestTimeFilterDropdown> createState() =>
      _QuestTimeFilterDropdownState();
}

class _QuestTimeFilterDropdownState extends State<QuestTimeFilterDropdown> {
  TimeFilterOption _selectedOption = TimeFilterOption.all;

  @override
  void initState() {
    super.initState();
    if (widget.currentFilter.isActive) {
      _selectedOption = TimeFilterOption.custom;
    } else {
      _selectedOption = TimeFilterOption.all;
    }
  }

  String _displayLabel() {
    if (_selectedOption == TimeFilterOption.custom &&
        widget.currentFilter.isActive) {
      final from =
          widget.currentFilter.dateFrom?.toIso8601String().substring(5, 10) ??
              '?';
      final to =
          widget.currentFilter.dateTo?.toIso8601String().substring(5, 10) ??
              '?';
      return 'С $from по $to';
    }
    return _selectedOption.uiLabel;
  }

  void _handleOptionSelected(TimeFilterOption? option) async {
    if (option == null) return;

    if (option == TimeFilterOption.custom) {
      final customFilter = await showDialog<QuestTimeFilter>(
        context: context,
        builder: (ctx) =>
            DateRangePickerDialog(initialFilter: widget.currentFilter),
      );

      if (customFilter != null) {
        setState(() => _selectedOption = option);
        widget.onFilterChanged(customFilter);
      }
    } else {
      setState(() => _selectedOption = option);
      widget.onFilterChanged(option.toFilter());
    }
  }

  List<DropdownMenuItem<TimeFilterOption>> _buildDropdownItems() {
    return TimeFilterOption.values.map((option) {
      return DropdownMenuItem<TimeFilterOption>(
        value: option,
        child: Text(option.uiLabel),
      );
    }).toList();
  }

  List<Widget> _buildSelectedItemBuilder() {
    return TimeFilterOption.values.map((option) {
      return Center(
        child: Text(
          _displayLabel(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeFilterOption>(
      value: _selectedOption,
      items: _buildDropdownItems(),
      onChanged: _handleOptionSelected,
      selectedItemBuilder: (context) => _buildSelectedItemBuilder(),
    );
  }
}
