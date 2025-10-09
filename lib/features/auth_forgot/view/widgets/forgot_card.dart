import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_forgot/model/forgot_state.dart';
import 'package:heros_journey/features/auth_forgot/view/widgets/forgot_form.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/services/forgot_bloc.dart';

class ForgotCard extends StatelessWidget {
  const ForgotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<ForgotBloc, ForgotState>(
          listenWhen: (p, c) => p.isSuccess != c.isSuccess,
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пароль изменён')),
              );
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          builder: (context, state) => ForgotForm(state: state),
        ),
      ),
    );
  }
}
