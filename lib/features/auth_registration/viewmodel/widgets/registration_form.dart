import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_registration/validators/password_validators.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/consent_checkbox.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/consent_row.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_back_button.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_email_field.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_password_field.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_submit_button.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';

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
  late final TextEditingController _confirmCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  bool _consentChecked = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegistrationBloc>().add(
          RegistrationSubmitted(
            email: _emailCtrl.text,
            password: _passCtrl.text,
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
          ),
        );
  }

  bool get _canSubmit => _consentChecked && !widget.state.isLoading;

  void _openAgreement() => Navigator.of(context).pushNamed('/agreement');

  String? _validateNamePart(String? v, String fieldName) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return 'Введите $fieldName';
    if (val.length < 2) return 'Минимум 2 символа';
    return null;
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
          TextFormField(
            controller: _firstNameCtrl,
            decoration: const InputDecoration(labelText: 'Имя'),
            validator: (v) => _validateNamePart(v, 'имя'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastNameCtrl,
            decoration: const InputDecoration(labelText: 'Фамилия'),
            validator: (v) => _validateNamePart(v, 'фамилию'),
          ),
          const SizedBox(height: 12),
          RegistrationEmailField(controller: _emailCtrl),
          const SizedBox(height: 12),
          RegistrationPasswordField(controller: _passCtrl),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Подтверждение пароля',
            ),
            validator: (v) {
              final securityError = validateSecurePassword(v);
              if (securityError != null) return securityError;
              final val = v?.trim() ?? '';
              if (val != _passCtrl.text.trim()) return 'Пароли не совпадают';
              return null;
            },
          ),
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
