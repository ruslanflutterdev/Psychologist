import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_bloc.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_event.dart';
import 'package:heros_journey/features/auth_login/viewmodel/widgets/login_form.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<LoginBloc, LoginState>(
          listenWhen: (p, c) => p.isSuccess != c.isSuccess,
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.of(
                context,
              ).pushReplacementNamed('/psychologist_screen');
            }
          },
          builder: (context, state) => LoginForm(state: state),
        ),
      ),
    );
  }
}
