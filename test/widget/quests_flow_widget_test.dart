import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/testing/test_keys.dart';
import 'package:mocktail/mocktail.dart';
import '../fixtures/quest_fixtures.dart';
import '../mocks/mock_repos.dart';

class QuestFake extends Fake implements Quest {}

class ChildQuestFake extends Fake implements ChildQuest {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(QuestFake());
    registerFallbackValue(ChildQuestFake());
  });

  testWidgets('Поток: открыть список → фильтр → назначить → квест в текущих', (
    tester,
  ) async {
    final repo = MockQuestsRepository();

    when(() => repo.assignQuest(childId, any<Quest>())).thenAnswer((
      invocation,
    ) async {
      final Quest q = invocation.positionalArguments[1] as Quest;
      return ChildQuest(id: 'assigned-${q.id}', questId: q.id, title: q.title);
    });

    await tester.pumpWidget(MaterialApp(home: ChildProfileHarness(repo: repo)));

    expect(find.byKey(Tk.questPicker), findsNothing);
    await tester.tap(find.byKey(Tk.addQuestBtn));
    await tester.pumpAndSettle();
    expect(find.byKey(Tk.questPicker), findsOneWidget);

    final listTilesInPickerBefore = find.descendant(
      of: find.byKey(Tk.questPicker),
      matching: find.byType(ListTile),
    );
    expect(listTilesInPickerBefore, findsNWidgets(availableQuests.length));

    await tester.tap(find.byKey(Tk.filterChip('strength')));
    await tester.pumpAndSettle();

    final listTilesInPickerAfter = find.descendant(
      of: find.byKey(Tk.questPicker),
      matching: find.byType(ListTile),
    );
    expect(
      listTilesInPickerAfter,
      findsNWidgets(availableQuests.where((q) => q.type == 'strength').length),
    );

    final strengthQuest = availableQuests.firstWhere(
      (q) => q.type == 'strength',
    );
    await tester.tap(find.byKey(Tk.assignBtn(strengthQuest.id)));
    await tester.pumpAndSettle();

    expect(find.byKey(Tk.assignedList), findsOneWidget);
    expect(find.text(strengthQuest.title), findsWidgets);

    final comp = initiallyAssigned.first;
    expect(find.byKey(Tk.completedItem(comp.id)), findsOneWidget);
    expect(find.byKey(Tk.completedTitle(comp.id)), findsOneWidget);
    expect(find.byKey(Tk.completedComment(comp.id)), findsOneWidget);
    expect(find.byKey(Tk.completedPhoto(comp.id)), findsOneWidget);
    expect(find.byKey(Tk.completedDate(comp.id)), findsOneWidget);
  });
}

class ChildProfileHarness extends StatefulWidget {
  final QuestsRepository repo;
  const ChildProfileHarness({super.key, required this.repo});

  @override
  State<ChildProfileHarness> createState() => _ChildProfileHarnessState();
}

class _ChildProfileHarnessState extends State<ChildProfileHarness> {
  List<ChildQuest> assigned = initiallyAssigned;

  Future<void> _openQuestPicker() async {
    final selected = await showModalBottomSheet<ChildQuest>(
      context: context,
      builder: (_) => QuestPickerSheet(repo: widget.repo),
    );
    if (selected != null) {
      setState(() => assigned = [...assigned, selected]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: Tk.addQuestBtn,
            onPressed: _openQuestPicker,
            child: const Text('+ Добавить квест'),
          ),
          Expanded(
            child: ListView(
              key: Tk.assignedList,
              children: [
                for (final a in assigned)
                  ListTile(
                    key: Tk.completedItem(a.id),
                    title: Text(a.title, key: Tk.completedTitle(a.id)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.comment != null)
                          Text(a.comment!, key: Tk.completedComment(a.id)),
                        if (a.completedAt != null)
                          Text(
                            a.completedAt!.toIso8601String(),
                            key: Tk.completedDate(a.id),
                          ),
                        if (a.previewUrl != null)
                          SizedBox(
                            height: 40,
                            child: Image.network(
                              a.previewUrl!,
                              key: Tk.completedPhoto(a.id),
                              errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(width: 40, height: 40),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestPickerSheet extends StatefulWidget {
  final QuestsRepository repo;
  const QuestPickerSheet({super.key, required this.repo});

  @override
  State<QuestPickerSheet> createState() => _QuestPickerSheetState();
}

class _QuestPickerSheetState extends State<QuestPickerSheet> {
  String? filter;
  List<Quest> visible = [];

  @override
  void initState() {
    super.initState();
    visible = availableQuests;
  }

  void _applyFilter(String? t) {
    setState(() {
      filter = t;
      visible = t == null
          ? availableQuests
          : availableQuests.where((q) => q.type == t).toList();
    });
  }

  Future<void> _assign(Quest q) async {
    final added = await widget.repo.assignQuest(childId, q);
    if (!mounted) return;
    Navigator.of(context).pop(added);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Tk.questPicker,
      child: Column(
        children: [
          Wrap(
            children: [
              FilterChip(
                key: Tk.filterChip('all'),
                label: const Text('все'),
                selected: filter == null,
                onSelected: (_) => _applyFilter(null),
              ),
              FilterChip(
                key: Tk.filterChip('strength'),
                label: const Text('сила'),
                selected: filter == 'strength',
                onSelected: (_) => _applyFilter('strength'),
              ),
              FilterChip(
                key: Tk.filterChip('wisdom'),
                label: const Text('мудрость'),
                selected: filter == 'wisdom',
                onSelected: (_) => _applyFilter('wisdom'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                for (final q in visible)
                  ListTile(
                    key: Tk.questTile(q.id),
                    title: Text(q.title),
                    trailing: TextButton(
                      key: Tk.assignBtn(q.id),
                      onPressed: () => _assign(q),
                      child: const Text('Назначить'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
