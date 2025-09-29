import 'package:flutter/material.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/widgets/forgot_card.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const ForgotCard(),
        ),
      ),
    );
  }
}
