import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/models/user_session.dart';

class SessionCubit extends Cubit<UserSession?> {
  SessionCubit() : super(null);

  void save(UserSession s) => emit(s);

  void clear() => emit(null);

  bool get isAuthorized => state != null;

  String? get role => state?.role;
}
