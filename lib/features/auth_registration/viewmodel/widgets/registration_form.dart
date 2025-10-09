import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/consent_checkbox.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/consent_row.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/registration_back_button.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/registration_email_field.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/registration_password_field.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/widgets/registration_submit_button.dart';

class RegistrationForm extends StatefulWidget {
  final RegistrationState state;

  const RegistrationForm({super.key, required this.state});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  bool _consentChecked = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegistrationBloc>().add(
      RegistrationSubmitted(email: _emailCtrl.text, password: _passCtrl.text),
    );
  }

  bool get _canSubmit => _consentChecked && !widget.state.isLoading;

  void _openAgreement() {
    Navigator.of(context).pushNamed('/agreement');
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Регистрация (Психолог)', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          RegistrationEmailField(controller: _emailCtrl),
          const SizedBox(height: 12),
          RegistrationPasswordField(controller: _passCtrl),
          const SizedBox(height: 12),
          ConsentRow(
            checkbox: ConsentCheckbox(
              value: _consentChecked,
              onChanged: (v) => setState(() => _consentChecked = v),
            ),
            onOpenAgreement: _openAgreement,
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            Text(
              state.errorMessage!,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
            ),

          const SizedBox(height: 8),
          RegistrationSubmitButton(
            enabled: _canSubmit,
            isLoading: state.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 8),
          const RegistrationBackButton(),
        ],
      ),
    );
  }
}
