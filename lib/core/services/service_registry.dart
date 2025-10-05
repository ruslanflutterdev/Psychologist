import 'package:heros_journey/core/services/agreement_service.dart';
import 'package:heros_journey/core/services/mock_agreement_service.dart';
import 'package:heros_journey/core/services/mock_quest_service.dart';
import 'package:heros_journey/core/services/quest_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/mock_auth_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/child_progress_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/child_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/mock_child_progress_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/mock_child_service.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/services/mock_psychologist_service.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/services/psychologist_service.dart';

class ServiceRegistry {
  static late AuthService auth;
  static late ChildService child;
  static late QuestService quest;
  static late ProgressService progress;
  static late PsychologistService psychologist;
  static late AgreementService agreement;

  static void initMocks() {
    auth = MockAuthService();
    child = MockChildService();
    quest = MockQuestService();
    progress = MockProgressService();
    psychologist = MockPsychologistService();
    agreement = const MockAgreementService();
  }
}
