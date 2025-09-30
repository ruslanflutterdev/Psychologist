import 'package:heros_journey/features/psychologist_screen/view/models/psychologist_model.dart';

abstract class PsychologistService {
  Future<PsychologistModel> getProfile();
}
