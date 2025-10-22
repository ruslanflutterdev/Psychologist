import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';

enum TimeFilterOption { all, today, week, month, year, custom }

extension TimeFilterOptionX on TimeFilterOption {
  String get uiLabel {
    switch (this) {
      case TimeFilterOption.all:
        return 'Весь период';
      case TimeFilterOption.today:
        return 'Сегодня';
      case TimeFilterOption.week:
        return 'Неделя';
      case TimeFilterOption.month:
        return 'Месяц';
      case TimeFilterOption.year:
        return 'Год';
      case TimeFilterOption.custom:
        return 'Произвольный период...';
    }
  }

  QuestTimeFilter toFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case TimeFilterOption.all:
        return QuestTimeFilter.inactive;
      case TimeFilterOption.today:
        return QuestTimeFilter(dateFrom: today, dateTo: today);
      case TimeFilterOption.week:
        final dateFrom = today.subtract(const Duration(days: 7));
        return QuestTimeFilter(dateFrom: dateFrom, dateTo: today);
      case TimeFilterOption.month:
        final dateFrom = today.subtract(const Duration(days: 30));
        return QuestTimeFilter(dateFrom: dateFrom, dateTo: today);
      case TimeFilterOption.year:
        final dateFrom = today.subtract(const Duration(days: 365));
        return QuestTimeFilter(dateFrom: dateFrom, dateTo: today);
      case TimeFilterOption.custom:
        return QuestTimeFilter.inactive;
    }
  }
}
