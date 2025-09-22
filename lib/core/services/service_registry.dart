import 'package:heros_journey/core/services/auth_service.dart';
import 'package:heros_journey/core/services/mock_auth_service.dart';

class ServiceRegistry {
  static late AuthService auth;
  static void initMocks() {
    auth = MockAuthService();
  }
}
