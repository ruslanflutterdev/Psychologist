import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_reset/model/reset_state.dart';
import 'package:heros_journey/features/auth_reset/navigation/reset_navigator.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetListener extends StatefulWidget {
  const ResetListener({super.key});

  @override
  State<ResetListener> createState() => _ResetListenerState();
}

class _ResetListenerState extends State<ResetListener> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetBloc, ResetState>(
      listenWhen: (prev, curr) =>
          prev.isSuccess != curr.isSuccess ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) async {
        if (!mounted) return;
        if (state.isSuccess) {
          await Supabase.instance.client.auth.signOut();
          if (!context.mounted) return;
          goToLogin(context);
        }

        if (state.errorMessage != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
