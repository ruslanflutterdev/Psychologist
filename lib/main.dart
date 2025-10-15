import 'package:flutter/material.dart';
import 'package:heros_journey/core/app/psych_web_app.dart';
import 'package:heros_journey/core/bootstrap/auth_recovery_listener.dart';
import 'package:heros_journey/core/bootstrap/start_mode.dart';
import 'package:heros_journey/core/bootstrap/supabase_bootstrap.dart';
import 'package:heros_journey/core/services/service_registry.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrapSupabase(
    url: 'https://gaelyvhlqvqgjyiqkrqf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhZWx5dmhscXZxZ2p5aXFrcnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzE0NjIsImV4cCI6MjA3NTAwNzQ2Mn0.MFgs_m0K7MWtRw_TaWufWqYK4Bu_cTDwArWEcFxrrNE',
  );

  ServiceRegistry.initSupabase();

  setupAuthRecoveryListener(navigatorKey);

  final startAtReset = shouldStartAtReset();

  runApp(PsychWebApp(navigatorKey: navigatorKey, startAtReset: startAtReset));
}

