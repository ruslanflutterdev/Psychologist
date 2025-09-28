import 'package:heros_journey/features/auth_registration/viewmodel/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/mock_auth_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/child_service.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/mock_child_service.dart';

class ServiceRegistry {
  static late AuthService auth;
  static late ChildService child;

  static void initMocks() {
    auth = MockAuthService();
    child = MockChildService();
  }
}
