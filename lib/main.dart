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
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhZWx5dmhscXZxZ2p5aXFrcnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzE0NjIsImV4cCI6MjA3NTAwNzQ2Mn0.MFgs_m0K7MWtRw_TaWufWqYK4Bu_cTDwArWEcFxrrNE',
  );

  ServiceRegistry.initSupabase();

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
