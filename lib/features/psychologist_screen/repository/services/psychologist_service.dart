import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';

abstract class PsychologistService {
  Future<PsychologistModel> getProfile();
}
