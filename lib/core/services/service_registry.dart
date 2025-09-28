import 'package:heros_journey/core/services/auth_service.dart';
import 'package:heros_journey/core/services/child_service.dart';
import 'package:heros_journey/core/services/mock_auth_service.dart';
import 'package:heros_journey/core/services/mock_child_service.dart';

class ServiceRegistry {
  static late AuthService auth;
  static late ChildService child;

  static void initMocks() {
    auth = MockAuthService();
    child = MockChildService();
  }
}
