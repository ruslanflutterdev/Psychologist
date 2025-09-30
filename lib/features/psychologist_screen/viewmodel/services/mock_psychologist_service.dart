import 'dart:async';
import 'package:heros_journey/features/psychologist_screen/view/models/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/services/psychologist_service.dart';

class MockPsychologistService implements PsychologistService {
  Duration latency = const Duration(milliseconds: 350);
  bool failNetwork = false;

  @override
  Future<PsychologistModel> getProfile() async {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw Exception('NETWORK: Сеть недоступна');
    }

    return const PsychologistModel(firstName: 'Руслан', lastName: 'Тютюнников');
  }
}
