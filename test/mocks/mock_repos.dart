import 'package:mocktail/mocktail.dart';
import '../fixtures/quest_fixtures.dart';

abstract class QuestsRepository {
  Future<List<Quest>> getAvailableQuests();
  Future<List<ChildQuest>> getAssignedQuests(String childId);
  Future<ChildQuest> assignQuest(String childId, Quest quest);
}

class MockQuestsRepository extends Mock implements QuestsRepository {}

class FakeQuest extends Fake implements Quest {}

class FakeChildQuest extends Fake implements ChildQuest {}
