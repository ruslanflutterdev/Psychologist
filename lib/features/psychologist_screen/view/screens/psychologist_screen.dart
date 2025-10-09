import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/view/screens/child_screen.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/widgets/psychologist_body.dart';

class PsychologistScreen extends StatelessWidget {
  const PsychologistScreen({super.key});

  void _logout(BuildContext context) {
    context.read<SessionCubit>().clear();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _openChild(BuildContext context, ChildModel child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChildScreen(childId: child.id, childName: child.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _logout(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Панель психолога'),
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        body: PsychologistBody(onOpenChild: (c) => _openChild(context, c)),
      ),
    );
  }
}
