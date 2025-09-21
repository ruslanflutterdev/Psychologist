import 'package:heros_journey/core/models/user_session.dart';

abstract class AuthService {
  Future<UserSession> registerPsychologist({
    required String email,
    required String password,
  });

  Future<UserSession> loginPsychologist({
    required String email,
    required String password,
  });
}
