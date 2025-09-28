import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _goBack() {
    Navigator.of(context).pushReplacementNamed('/login');
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
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return 'Введите E-mail';
              if (!val.contains('@')) return 'Некорректный E-mail';
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль'),
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return 'Введите пароль';
              if (val.length < 6) return 'Минимум 6 символов';
              return null;
            },
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
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Зарегистрироваться'),
          ),
          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: state.isLoading ? null : _goBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Назад'),
          ),
        ],
      ),
    );
  }
}
