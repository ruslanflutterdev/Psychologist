import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/models/user_session.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/bloc/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/view/registration_screen.dart';
import 'package:heros_journey/features/dashboard/view/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case '/dashboard':
        final session = _findSession(settings);
        if (session?.role != 'psych') {
          return _redirect('/register');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );
      default:
        return _redirect('/register');
    }
  }

  static UserSession? _findSession(RouteSettings s) {
    return null;
  }

  static Route<dynamic> _redirect(String path) => MaterialPageRoute(
    builder: (_) => const _Redirector(path: '/register'),
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
