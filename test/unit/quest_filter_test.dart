import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/models/time_filter_option.dart';
import 'package:heros_journey/features/child_screen/repository/services/mock_child_quests_service.dart';

// Вспомогательный класс для доступа к не-приватным полям в тестах (super.fieldName)
class TestableMockChildQuestsService extends MockChildQuestsService {
  // Доступ к полям теперь не требует "super." или "dynamic"
  Map<String, List<ChildQuest>> get completedMap => completedQuests;
  Map<String, List<ChildQuest>> get assignedMap => assignedQuests;

  TestableMockChildQuestsService({super.latency});
}


void main() {
  group('Quest Filter Logic Unit Tests', () {
    // Используем фиксированную дату для тестирования пресетов и фильтрации
    final fixedNow = DateTime(2025, 10, 19); // 19 Октября 2025
    final today = DateTime(2025, 10, 19);
    final yesterday = DateTime(2025, 10, 18);
    final lastWeek = DateTime(2025, 10, 12);
    final lastMonth = DateTime(2025, 9, 19);
    final nextDay = DateTime(2025, 10, 20);

    // Создаем экземпляр тестового сервиса
    final testableService = TestableMockChildQuestsService(latency: Duration.zero);
    const childId = 'c1';
    final baseQuest = Quest(id: 'q1', title: 'Test', type: QuestType.cognitive);

    // Вспомогательный метод для тестирования TimeFilterOptionX.toFilter() относительно фиксированной даты
    QuestTimeFilter testToFilter(TimeFilterOption option, DateTime now) {
      final today = DateTime(now.year, now.month, now.day);
      switch (option) {
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

    // Helper to manually set mock state
    void setMockCompleted(List<ChildQuest> completed) {
      testableService.completedMap[childId] = completed;
    }
    void setMockAssigned(List<ChildQuest> assigned) {
      testableService.assignedMap[childId] = assigned;
    }

    // --- Тесты валидации диапазона дат (логика DateRangePickerDialog) ---
    group('Date Range Validation', () {
      bool isDateRangeValid(DateTime? dateFrom, DateTime? dateTo) {
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
          return false;
        }
        return true;
      }

      test('Корректный диапазон проходит валидацию', () {
        expect(isDateRangeValid(yesterday, today), isTrue);
      });

      test('Одинаковые даты проходят валидацию', () {
        expect(isDateRangeValid(today, today), isTrue);
      });

      test('"Дата до" < "Дата от" возвращает ошибку валидации', () {
        expect(isDateRangeValid(today, yesterday), isFalse);
      });

      test('Пустые даты проходят валидацию', () {
        expect(isDateRangeValid(null, null), isTrue);
      });
    });

    // --- Тесты пресетов TimeFilterOption ---
    group('TimeFilterOption Presets', () {
      test('Пресет "Сегодня" возвращает правильный диапазон', () {
        final filter = testToFilter(TimeFilterOption.today, fixedNow);
        expect(filter.dateFrom, today);
        expect(filter.dateTo, today);
      });

      test('Пресет "Неделя" возвращает правильный диапазон', () {
        final filter = testToFilter(TimeFilterOption.week, fixedNow);
        expect(filter.dateFrom, lastWeek);
        expect(filter.dateTo, today);
      });

      test('Пресет "Месяц" возвращает правильный диапазон', () {
        final filter = testToFilter(TimeFilterOption.month, fixedNow);
        expect(filter.dateFrom, lastMonth);
        expect(filter.dateTo, today);
      });

      test('Пресет "Весь период" возвращает неактивный фильтр', () {
        final filter = testToFilter(TimeFilterOption.all, fixedNow);
        expect(filter.isActive, isFalse);
        expect(filter.dateFrom, isNull);
        expect(filter.dateTo, isNull);
      });
    });

    // --- Тесты логики фильтрации MockChildQuestsService ---
    group('MockChildQuestsService Filtering', () {

      test('Unfiltered load возвращает все квесты', () async {
        // Добавляем квесты
        final completedQuest = ChildQuest(id: 'c1', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: today);
        final assignedQuest = ChildQuest(id: 'a1', childId: childId, quest: baseQuest, status: ChildQuestStatus.assigned);

        setMockCompleted([completedQuest]);
        setMockAssigned([assignedQuest]);

        final completed = await testableService.getCompleted(childId);
        final assigned = await testableService.getAssigned(childId);

        expect(completed.length, 1, reason: 'Completed count should be 1');
        expect(assigned.length, 1, reason: 'Assigned count should be 1');
      });

      test('Фильтр "Сегодня" включает квесты сегодня и исключает завтра', () async {
        // Имитируем квесты с разными датами
        final completedToday = ChildQuest(id: 'c1', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: today);
        final completedYesterday = ChildQuest(id: 'c2', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: yesterday);
        final completedNextDay = ChildQuest(id: 'c3', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: nextDay);

        setMockCompleted([completedToday, completedYesterday, completedNextDay]);

        // Определяем фильтр (Сегодня: 2025-10-19)
        final filter = testToFilter(TimeFilterOption.today, fixedNow);

        final filteredCompleted = await testableService.getCompleted(childId, filter: filter);

        expect(filteredCompleted.length, 1, reason: 'Только завершенный сегодня квест должен быть включен');
        expect(filteredCompleted.first.id, completedToday.id);
      });

      test('Фильтр "Неделя" исключает квесты старше 7 дней', () async {
        final sevenDaysAgo = lastWeek; // 2025-10-12
        final eightDaysAgo = sevenDaysAgo.subtract(const Duration(days: 1)); // 2025-10-11

        final completedSevenDaysAgo = ChildQuest(id: 'c1', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: sevenDaysAgo);
        final completedEightDaysAgo = ChildQuest(id: 'c2', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: eightDaysAgo);

        setMockCompleted([completedSevenDaysAgo, completedEightDaysAgo]);

        // Определяем фильтр (Неделя: 2025-10-12 to 2025-10-19)
        final filter = testToFilter(TimeFilterOption.week, fixedNow);

        final filteredCompleted = await testableService.getCompleted(childId, filter: filter);

        expect(filteredCompleted.length, 1, reason: 'Квест старше 7 дней должен быть исключен');
        expect(filteredCompleted.first.id, completedSevenDaysAgo.id);
      });

      test('Неактивный фильтр возвращает все квесты (сброс фильтра)', () async {
        // Имитируем квесты
        final completedQuest = ChildQuest(id: 'c1', childId: childId, quest: baseQuest, status: ChildQuestStatus.completed, completedAt: today);
        final assignedQuest = ChildQuest(id: 'a1', childId: childId, quest: baseQuest, status: ChildQuestStatus.assigned);

        setMockCompleted([completedQuest]);
        setMockAssigned([assignedQuest]);

        // Определяем неактивный фильтр
        final filter = QuestTimeFilter.inactive;

        final filteredCompleted = await testableService.getCompleted(childId, filter: filter);
        final filteredAssigned = await testableService.getAssigned(childId, filter: filter);

        expect(filteredCompleted.length, 1);
        expect(filteredAssigned.length, 1);
      });
    });
  });
}
