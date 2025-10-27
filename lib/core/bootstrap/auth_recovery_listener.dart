import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/auth_reset/view/screens/reset_screen.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool _recoveryHandled = false;

void setupAuthRecoveryListener(GlobalKey<NavigatorState> navigatorKey) {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    final hasRecoveryFragment = Uri.base.fragment.contains('type=recovery');
    final hasPkceCode = Uri.base.queryParameters.containsKey('code');
    final isRecoveryFlow = hasRecoveryFragment ||
        hasPkceCode ||
        event == AuthChangeEvent.passwordRecovery;

    if (!isRecoveryFlow || _recoveryHandled) return;
    _recoveryHandled = true;

    final ctx = navigatorKey.currentState?.context;
    if (ctx == null || !ctx.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctx.mounted) return;

      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => ResetBloc(auth: ServiceRegistry.auth),
            child: const ResetScreen(),
          ),
        ),
        (route) => false,
      );
    });
  });
}
