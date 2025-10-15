import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_login/view/screens/login_screen.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_bloc.dart';

void goToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (ctx) => BlocProvider(
        create: (ctx) => LoginBloc(
          auth: ServiceRegistry.auth,
          sessionCubit: ctx.read<SessionCubit>(),
        ),
        child: const LoginScreen(),
      ),
    ),
    (route) => false,
  );
}
