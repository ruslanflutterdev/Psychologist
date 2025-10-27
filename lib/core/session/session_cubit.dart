import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/models/user_session_model.dart';

class SessionCubit extends Cubit<UserSessionModel?> {
  SessionCubit() : super(null);

  void save(UserSessionModel s) => emit(s);

  void clear() => emit(null);

  bool get isAuthorized => state != null;

  String? get role => state?.role;
}
