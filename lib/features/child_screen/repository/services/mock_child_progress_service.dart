import 'dart:async';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_progress_service.dart';

class MockProgressService implements ProgressService {
  Duration latency = const Duration(milliseconds: 450);
  bool failNetwork = false;

  final Map<String, ChildProgressModel> _progressCache = {};

  MockProgressService() {
    _setupInitialData();
  }

  void _setupInitialData() {
    const max = 100;

    _progressCache['1'] =  ChildProgressModel(
      childId: '1',
      pq: 55, eq: 68, iq: 72, soq: 60, sq: 50,
      max: max,
      updatedAt: DateTime(2025, 10, 19, 9, 30),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (_progressCache.containsKey('1')) {
        final updated = _progressCache['1']!.copyWith(
          pq: 80,
          updatedAt: DateTime.now(),
        );
        _progressCache['1'] = updated;
      }
    });
  }

  @override
  Stream<ChildProgressModel?> getChildProgress(String childId) async* {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw Exception('NETWORK: Сеть недоступна. Повторите позже.');
    }
    yield _progressCache[childId];
    final updateStream = Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(100);
    await for (final _ in updateStream) {
      final latestData = _progressCache[childId];
      if (latestData != null) {
        yield latestData;
      }
    }
  }
}
