import 'package:flutter/material.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_card.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const SingleChildScrollView(child: RegistrationCard()),
        ),
      ),
    );
  }
}
