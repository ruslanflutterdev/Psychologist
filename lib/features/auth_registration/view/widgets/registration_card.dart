import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_form.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';

class RegistrationCard extends StatelessWidget {
  const RegistrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<RegistrationBloc, RegistrationState>(
          listenWhen: (p, c) => p.isSuccess != c.isSuccess,
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.of(
                context,
              ).pushReplacementNamed('/psychologist_screen');
            }
          },
          builder: (context, state) => RegistrationForm(state: state),
        ),
      ),
    );
  }
}
