import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/router/app_router.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/core/theme/app_theme.dart';
import 'package:heros_journey/features/auth_login/view/screens/login_screen.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_bloc.dart';
import 'package:heros_journey/features/auth_reset/view/screens/reset_screen.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_bloc.dart';

class PsychWebApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool startAtReset;
  final SessionCubit? sessionCubit;

  const PsychWebApp({
    super.key,
    required this.navigatorKey,
    required this.startAtReset,
    this.sessionCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>(
      create: (_) => sessionCubit ?? SessionCubit(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'PsyWell – Psychologist Web',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: startAtReset
            ? BlocProvider(
                create: (_) => ResetBloc(auth: ServiceRegistry.auth),
                child: const ResetScreen(),
              )
            : BlocProvider(
                create: (ctx) => LoginBloc(
                  auth: ServiceRegistry.auth,
                  sessionCubit: ctx.read<SessionCubit>(),
                ),
                child: const LoginScreen(),
              ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
