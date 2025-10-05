import 'dart:async';
import 'package:heros_journey/core/services/quest_service.dart';

class MockQuestService implements QuestService {
  Duration latency = const Duration(milliseconds: 600);
  bool failNetwork = false;

  @override
  Future<void> assignQuest({required String childId}) async {
    await Future<void>.delayed(latency);

    if (failNetwork) {
      throw Exception('NETWORK: Сеть недоступна. Повторите позже.');
    }

    final payload = <String, dynamic>{
      'childId': childId,
      'assignedAt': DateTime.now().toIso8601String(),
    };
    print('MOCK POST /assign-quest payload=$payload');
  }
}
