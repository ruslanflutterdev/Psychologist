import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_bloc.dart';
import 'package:heros_journey/features/auth_login/viewmodel/services/login_event.dart';

class LoginForm extends StatefulWidget {
  final LoginState state;

  const LoginForm({super.key, required this.state});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
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
    context.read<LoginBloc>().add(
          LoginSubmitted(email: _emailCtrl.text, password: _passCtrl.text),
        );
  }

  void _goRegister() {
    context.read<LoginBloc>().add(LoginGoRegister());
    Navigator.of(context).pushReplacementNamed('/register');
  }

  void _goForgot() {
    context.read<LoginBloc>().add(LoginForgotPassword());
    Navigator.of(context).pushReplacementNamed('/forgot');
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Вход (Психолог)', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
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
            autofillHints: const [AutofillHints.password],
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.errorMessage!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Войти'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: state.isLoading ? null : _goRegister,
                child: const Text('Регистрация'),
              ),
              TextButton(
                onPressed: state.isLoading ? null : _goForgot,
                child: const Text('Забыли пароль'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
