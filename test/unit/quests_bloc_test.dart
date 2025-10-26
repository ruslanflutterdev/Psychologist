import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../test/mocks/mock_repos.dart';
import '../fixtures/quest_fixtures.dart';

class QuestsState {
  final List<Quest> available;
  final List<Quest> visible;
  final List<ChildQuest> assigned;
  final String? filterType;
  final bool loading;
  QuestsState({
    required this.available,
    required this.visible,
    required this.assigned,
    this.filterType,
    this.loading = false,
  });
  QuestsState copyWith({
    List<Quest>? available,
    List<Quest>? visible,
    List<ChildQuest>? assigned,
    String? filterType,
    bool? loading,
  }) {
    return QuestsState(
      available: available ?? this.available,
      visible: visible ?? this.visible,
      assigned: assigned ?? this.assigned,
      filterType: filterType ?? this.filterType,
      loading: loading ?? this.loading,
    );
  }
}

abstract class QuestsEvent {}

class LoadQuests extends QuestsEvent {
  final String childId;
  LoadQuests(this.childId);
}

class ApplyFilter extends QuestsEvent {
  final String? type;
  ApplyFilter(this.type);
}

class AssignQuest extends QuestsEvent {
  final Quest quest;
  final String childId;
  AssignQuest(this.childId, this.quest);
}

class QuestsBloc extends Bloc<QuestsEvent, QuestsState> {
  final QuestsRepository repo;
  QuestsBloc(this.repo)
      : super(QuestsState(available: [], visible: [], assigned: [])) {
    on<LoadQuests>(_onLoad);
    on<ApplyFilter>(_onFilter);
    on<AssignQuest>(_onAssign);
  }
  Future<void> _onLoad(LoadQuests e, Emitter<QuestsState> emit) async {
    emit(state.copyWith(loading: true));
    final avail = await repo.getAvailableQuests();
    final assigned = await repo.getAssignedQuests(e.childId);
    emit(
      state.copyWith(
        loading: false,
        available: avail,
        visible: avail,
        assigned: assigned,
      ),
    );
  }

  void _onFilter(ApplyFilter e, Emitter<QuestsState> emit) {
    if (e.type == null) {
      emit(state.copyWith(visible: state.available));
    } else {
      final filtered = state.available.where((q) => q.type == e.type).toList();
      emit(state.copyWith(visible: filtered, filterType: e.type));
    }
  }

  Future<void> _onAssign(AssignQuest e, Emitter<QuestsState> emit) async {
    final added = await repo.assignQuest(e.childId, e.quest);
    emit(state.copyWith(assigned: [...state.assigned, added]));
  }
}

void main() {
  late MockQuestsRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeQuest());
    registerFallbackValue(FakeChildQuest());
  });

  setUp(() {
    repo = MockQuestsRepository();
  });

  blocTest<QuestsBloc, QuestsState>(
    'loads available & assigned quests',
    build: () {
      when(
        () => repo.getAvailableQuests(),
      ).thenAnswer((_) async => availableQuests);
      when(
        () => repo.getAssignedQuests(childId),
      ).thenAnswer((_) async => initiallyAssigned);
      return QuestsBloc(repo);
    },
    act: (b) => b.add(LoadQuests(childId)),
    expect: () => [
      isA<QuestsState>().having((s) => s.loading, 'loading', true),
      isA<QuestsState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.available.length, 'avail', 3)
          .having((s) => s.visible.length, 'visible', 3)
          .having((s) => s.assigned.length, 'assigned', 1),
    ],
  );

  blocTest<QuestsBloc, QuestsState>(
    'applies filter by type (strength)',
    build: () {
      when(
        () => repo.getAvailableQuests(),
      ).thenAnswer((_) async => availableQuests);
      when(
        () => repo.getAssignedQuests(childId),
      ).thenAnswer((_) async => initiallyAssigned);
      return QuestsBloc(repo);
    },
    act: (b) async {
      b.add(LoadQuests(childId));
      await Future<void>.delayed(Duration.zero);
      b.add(ApplyFilter('strength'));
    },
    expect: () => [
      isA<QuestsState>().having((s) => s.loading, 'loading', true),
      isA<QuestsState>().having((s) => s.visible.length, 'visible', 3),
      isA<QuestsState>()
          .having((s) => s.filterType, 'filter', 'strength')
          .having((s) => s.visible.length, 'filtered', 2),
    ],
  );

  blocTest<QuestsBloc, QuestsState>(
    'assigns quest adds to assigned list',
    build: () {
      when(
        () => repo.getAvailableQuests(),
      ).thenAnswer((_) async => availableQuests);
      when(
        () => repo.getAssignedQuests(childId),
      ).thenAnswer((_) async => initiallyAssigned);
      when(() => repo.assignQuest(childId, availableQuests.first)).thenAnswer(
        (_) async => ChildQuest(
          id: 'a2',
          questId: availableQuests.first.id,
          title: availableQuests.first.title,
        ),
      );
      return QuestsBloc(repo);
    },
    act: (b) async {
      b.add(LoadQuests(childId));
      await Future<void>.delayed(Duration.zero);
      b.add(AssignQuest(childId, availableQuests.first));
    },
    expect: () => [
      isA<QuestsState>(),
      isA<QuestsState>(),
      isA<QuestsState>().having((s) => s.assigned.length, 'assigned', 2),
    ],
  );
}
