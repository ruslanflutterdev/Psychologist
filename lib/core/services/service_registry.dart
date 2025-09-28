import 'package:heros_journey/core/services/mock_quest_service.dart';
import 'package:heros_journey/core/services/quest_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/mock_auth_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/child_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/mock_child_service.dart';

class ServiceRegistry {
  static late AuthService auth;
  static late ChildService child;
  static late QuestService quest;

  static void initMocks() {
    auth = MockAuthService();
    child = MockChildService();
    quest = MockQuestService();
  }
}
