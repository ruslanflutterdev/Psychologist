import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/router/app_router.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceRegistry.initMocks();
  runApp(const PsychWebApp());
}

class PsychWebApp extends StatelessWidget {
  const PsychWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionCubit(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'PsyWell – Psychologist Web',
            theme: AppTheme.light,
            initialRoute: '/register',
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
