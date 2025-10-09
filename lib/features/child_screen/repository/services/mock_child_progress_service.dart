import 'dart:async';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_progress_service.dart';



class MockProgressService implements ProgressService {
  Duration latency = const Duration(milliseconds: 450);
  bool failNetwork = false;

  @override
  Future<ChildProgressModel> getChildProgress(String childId) async {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw Exception('NETWORK: Сеть недоступна. Повторите позже.');
    }

    const max = 100;
    final seed = childId.hashCode.abs() % 20;
    return ChildProgressModel(
      childId: childId,
      pq: 55 + (seed % 10),
      eq: 68 - (seed % 7),
      iq: 72 - (seed % 5),
      soq: 60 + (seed % 12),
      sq: 50 + (seed % 8),
      max: max,
      updatedAt: DateTime.now(),
    );
  }
}
