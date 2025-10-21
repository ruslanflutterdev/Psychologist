import 'package:heros_journey/core/models/user_session_model.dart';

abstract class AuthService {
  Future<UserSessionModel> registerPsychologist({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<UserSessionModel> loginPsychologist({
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> applyNewPassword({required String newPassword});

  Future<void> logout();
  Future<void> clearAllLocalData();
}
