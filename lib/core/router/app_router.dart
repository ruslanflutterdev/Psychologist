import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/agreement/view/agreement_screen.dart';
import 'package:heros_journey/features/auth_forgot/view/screens/forgot_screen.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/services/forgot_bloc.dart';
import 'package:heros_journey/features/auth_login/view/screens/login_screen.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_bloc.dart';
import 'package:heros_journey/features/auth_registration/view/screens/registration_screen.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_reset/view/screens/reset_screen.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_bloc.dart';
import 'package:heros_journey/features/psychologist_screen/view/screens/psychologist_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (ctx) => BlocProvider(
            create: (ctx) => LoginBloc(
              auth: ServiceRegistry.auth,
              sessionCubit: ctx.read<SessionCubit>(),
            ),
            child: const LoginScreen(),
          ),
        );
      case '/register':
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => RegistrationBloc(
              auth: ServiceRegistry.auth,
              sessionCubit: ctx.read<SessionCubit>(),
            ),
            child: const RegistrationScreen(),
          ),
        );
      case '/psychologist_screen':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PsychologistScreen(),
        );
      case '/forgot':
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => ForgotBloc(auth: ServiceRegistry.auth),
            child: const ForgotScreen(),
          ),
        );
      case '/agreement':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgreementScreen(),
        );
      case '/reset':
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => ResetBloc(auth: ServiceRegistry.auth),
            child: const ResetScreen(),
          ),
        );
      default:
        return _redirect('/login');
    }
  }

  static Route<dynamic> _redirect(String path) => MaterialPageRoute(
    builder: (_) => _Redirector(path: path),
    settings: const RouteSettings(name: '/redirect'),
  );
}

class _Redirector extends StatelessWidget {
  final String path;

  const _Redirector({required this.path});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(path);
    });
    return const SizedBox.shrink();
  }
}
