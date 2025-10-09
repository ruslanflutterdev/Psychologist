import 'package:flutter/material.dart';
import 'package:heros_journey/features/auth_login/view/widgets/login_card.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const LoginCard(),
        ),
      ),
    );
  }
}
