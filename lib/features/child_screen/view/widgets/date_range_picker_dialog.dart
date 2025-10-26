import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';

class DateRangePickerDialog extends StatefulWidget {
  final QuestTimeFilter? initialFilter;

  const DateRangePickerDialog({super.key, this.initialFilter});

  @override
  State<DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<DateRangePickerDialog> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter?.dateFrom;
    _dateTo = widget.initialFilter?.dateTo;
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initialDate = isFrom ? _dateFrom : _dateTo;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
        _validate();
      });
    }
  }

  bool _validate() {
    if (_dateFrom != null && _dateTo != null && _dateFrom!.isAfter(_dateTo!)) {
      setState(() => _error = 'Дата "от" не может быть позже даты "до".');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  void _apply() {
    if (!_validate()) return;
    final result = QuestTimeFilter(dateFrom: _dateFrom, dateTo: _dateTo);
    Navigator.of(context).pop(result);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Дата от';
    return date.toLocal().toIso8601String().substring(0, 10);
  }

  Widget _buildDateButton(bool isFrom) {
    final text = isFrom ? _formatDate(_dateFrom) : _formatDate(_dateTo);
    final label = isFrom ? 'Дата от' : 'Дата до';
    final currentText = text == 'Дата от' || text == 'Дата до' ? label : text;

    return Expanded(
      child: OutlinedButton(
        onPressed: () => _pickDate(isFrom),
        child: Text(currentText),
      ),
    );
  }

  Widget _buildDateRangeSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDateButton(true),
        const SizedBox(width: 16),
        _buildDateButton(false),
      ],
    );
  }

  Widget _buildErrorDisplay(ThemeData theme) {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _error!,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    return SizedBox(
      width: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildDateRangeSelectors(), _buildErrorDisplay(theme)],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: _error == null && (_dateFrom != null || _dateTo != null)
            ? _apply
            : null,
        child: const Text('Применить'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Произвольный период'),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }
}
