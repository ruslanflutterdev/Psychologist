import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/router/app_router.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gaelyvhlqvqgjyiqkrqf.supabase.co',
    anonKey: '<prefer publishable key instead of anon key for mobile and desktop apps>',
  );

  ServiceRegistry.initSupabaseAuth();

  runApp(const PsychWebApp());
}

class PsychWebApp extends StatelessWidget {
  const PsychWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionCubit(),
      child: MaterialApp(
        title: 'PsyWell – Psychologist Web',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/login',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
