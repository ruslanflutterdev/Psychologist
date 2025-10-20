import 'package:flutter/material.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/widgets/reset_form.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/widgets/reset_listener.dart';

class ResetScaffold extends StatelessWidget {
  const ResetScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Card(
            margin: EdgeInsets.all(24),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [ResetListener(), ResetForm()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
