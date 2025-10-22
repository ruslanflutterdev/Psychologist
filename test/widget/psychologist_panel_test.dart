import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/repository/services/psychologist_service.dart';
import 'package:heros_journey/features/psychologist_screen/view/widgets/child_tile.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/widgets/psychologist_body.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/widgets/psychologist_header.dart';
import 'package:mocktail/mocktail.dart';

// --- MOCKS ---
class MockPsychologistService extends Mock implements PsychologistService {}

class MockChildService extends Mock implements ChildService {}

// --- TEST DATA ---
final testProfile = const PsychologistModel(
  firstName: 'Тест',
  lastName: 'Психолог',
);

final initialChildren = [
  const ChildModel(
    id: '1',
    firstName: 'Иван',
    lastName: 'Иванов',
    age: 10,
    gender: ChildGender.male,
  ),
  const ChildModel(
    id: '2',
    firstName: 'Мария',
    lastName: 'Петрова',
    age: 9,
    gender: ChildGender.female,
  ),
];

void main() {
  late MockPsychologistService mockPsychologistService;
  late MockChildService mockChildService;

  setUp(() {
    mockPsychologistService = MockPsychologistService();
    mockChildService = MockChildService(); // Корректная инициализация

    // Инициализация ServiceRegistry моками
    ServiceRegistry.psychologist = mockPsychologistService;
    ServiceRegistry.child = mockChildService;
  });

  // Вспомогательный виджет для монтирования PsychologistBody
  Widget createWidgetUnderTest({
    required Stream<List<ChildModel>> childStream,
  }) {
    // Временно мокаем getChildren для потока
    when(() => mockChildService.getChildren()).thenAnswer((_) => childStream);

    return MaterialApp(
      home: Scaffold(body: PsychologistBody(onOpenChild: (_) {})),
    );
  }

  group('PsychologistBody Data Loading and Realtime', () {
    testWidgets('Проверка успешной загрузки ФИО психолога и списка детей', (
      tester,
    ) async {
      // Подготовка: Мокаем успешные ответы
      when(
        () => mockPsychologistService.getProfile(),
      ).thenAnswer((_) async => testProfile);
      // Мокаем Stream с немедленной эмиссией начального списка
      final childStream = Stream.value(initialChildren);

      await tester.pumpWidget(createWidgetUnderTest(childStream: childStream));

      // 1. Проверяем загрузку профиля
      await tester.pumpAndSettle();
      expect(find.byType(PsychologistHeader), findsOneWidget);
      expect(find.text('Тест Психолог'), findsOneWidget);

      // 2. Проверяем загрузку списка детей
      expect(find.byType(ChildTile), findsNWidgets(2));
      expect(find.text('Иван Иванов'), findsOneWidget);
    });

    testWidgets(
      'Проверка Realtime-обновлений: список детей обновляется при эмиссии нового элемента',
      (tester) async {
        // Подготовка: Используем StreamController для имитации Realtime
        final controller = StreamController<List<ChildModel>>();
        when(
          () => mockPsychologistService.getProfile(),
        ).thenAnswer((_) async => testProfile);

        await tester.pumpWidget(
          createWidgetUnderTest(childStream: controller.stream),
        );
        await tester.pump(); // Запускаем FutureBuilder для профиля

        // 1. Эмиссия начальных данных
        controller.add(initialChildren);
        await tester.pumpAndSettle();

        // Проверяем начальный список
        expect(find.byType(ChildTile), findsNWidgets(2));

        // 2. Эмиссия обновленных данных (Realtime)
        final updatedChildren = [
          ...initialChildren,
          const ChildModel(
            id: '3',
            firstName: 'Новый',
            lastName: 'Клиент',
            age: 8,
            gender: ChildGender.male,
          ),
        ];
        controller.add(updatedChildren);
        await tester.pumpAndSettle();

        // Проверяем обновленный список
        expect(find.byType(ChildTile), findsNWidgets(3));
        expect(find.text('Новый Клиент'), findsOneWidget);

        await controller.close();
      },
    );

    testWidgets(
      'Проверка перехода: При нажатии на ребенка открывается его карточка',
      (tester) async {
        final childToOpen = initialChildren.first;
        bool wasChildOpened = false;

        // Mock the profile loading
        when(
          () => mockPsychologistService.getProfile(),
        ).thenAnswer((_) async => testProfile);

        // Mock the children stream (ИСПРАВЛЕНИЕ: Добавлен мок перед pumpWidget)
        final childStream = Stream.value(initialChildren);
        when(
          () => mockChildService.getChildren(),
        ).thenAnswer((_) => childStream);

        // Создаем функцию теста, которая захватывает попытку навигации
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PsychologistBody(
                onOpenChild: (c) {
                  // Проверяем, что был передан нужный объект ChildModel
                  if (c.id == childToOpen.id) {
                    wasChildOpened = true;
                  }
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Находим карточку первого ребенка и нажимаем
        final childTileFinder = find.text(childToOpen.name);
        expect(childTileFinder, findsOneWidget);
        await tester.tap(childTileFinder);
        await tester.pump();

        // Проверяем, что обработчик навигации был вызван
        expect(
          wasChildOpened,
          isTrue,
          reason: 'onOpenChild callback должен быть вызван.',
        );
      },
    );

    testWidgets(
      'Проверка пустого состояния: Если список детей пуст, виджеты списка отсутствуют',
      (tester) async {
        when(
          () => mockPsychologistService.getProfile(),
        ).thenAnswer((_) async => testProfile);
        final emptyStream = Stream.value(const <ChildModel>[]);

        await tester.pumpWidget(
          createWidgetUnderTest(childStream: emptyStream),
        );
        await tester.pumpAndSettle();

        // Проверяем, что отображается сообщение "Детей пока нет"
        expect(find.text('Детей пока нет'), findsOneWidget);
        expect(find.byType(ChildTile), findsNothing);
      },
    );

    testWidgets('Проверка обработки ошибки загрузки профиля', (tester) async {
      // Подготовка: Мокаем ошибку для профиля
      when(
        () => mockPsychologistService.getProfile(),
      ).thenAnswer((_) => Future.error(Exception('Профиль не найден')));

      when(
        () => mockChildService.getChildren(),
      ).thenAnswer((_) => Stream.value(initialChildren));

      await tester.pumpWidget(
        createWidgetUnderTest(childStream: Stream.value(initialChildren)),
      );
      await tester.pumpAndSettle();

      // Заголовок (PsychologistHeader) должен быть скрыт (заменен на SizedBox.shrink())
      expect(find.byType(PsychologistHeader), findsNothing);
      // Список детей должен загрузиться корректно
      expect(
        find.byType(ChildTile),
        findsNWidgets(2),
        reason: 'Список детей должен загрузиться, несмотря на ошибку профиля',
      );
    });

    testWidgets('Проверка обработки ошибки Stream для детей', (tester) async {
      // Подготовка: Мокаем ошибку в Stream
      when(
        () => mockPsychologistService.getProfile(),
      ).thenAnswer((_) async => testProfile);
      final errorStream = Stream<List<ChildModel>>.error('Ошибка Realtime');

      await tester.pumpWidget(createWidgetUnderTest(childStream: errorStream));

      await tester.pump();

      // Ожидаем ошибку от StreamBuilder
      await tester.pumpAndSettle();

      // Проверяем, что отображается сообщение об ошибке
      expect(
        find.textContaining('Ошибка загрузки: Ошибка Realtime'),
        findsOneWidget,
      );
      // Проверяем, что заголовок загружен
      expect(find.text('Тест Психолог'), findsOneWidget);
    });
  });
}
