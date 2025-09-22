import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_forgot/bloc/forgot_bloc.dart';
import 'package:heros_journey/features/auth_forgot/bloc/forgot_event.dart';
import 'package:heros_journey/features/auth_forgot/bloc/forgot_state.dart';


class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotBloc>().add(
      ForgotSubmitted(email: _emailCtrl.text, newPassword: _passCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
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
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Восстановление пароля', style: theme.textTheme.headlineSmall),
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
                          decoration: const InputDecoration(labelText: 'Новый пароль'),
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
                            child: Text(state.errorMessage!, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.error)),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: state.isLoading ? null : () => _submit(context),
                                child: state.isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Сохранить новый пароль'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () {
                            context.read<ForgotBloc>().add(ForgotBackPressed());
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Назад'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
