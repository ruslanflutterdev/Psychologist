import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_reset/model/reset_state.dart';
import 'package:heros_journey/features/auth_reset/validators/password_validators.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_bloc.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_event.dart';

class ResetForm extends StatefulWidget {
  const ResetForm({super.key});

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ResetBloc>().add(
      ResetSubmitted(password: _passCtrl.text, confirm: _confirmCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ResetBloc, ResetState>(
      buildWhen: (p, c) =>
          p.isLoading != c.isLoading || p.errorMessage != c.errorMessage,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Сброс пароля', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Новый пароль'),
                validator: validateNewPassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
                ),
                validator: (v) => validateConfirmPassword(v, _passCtrl.text),
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
                onPressed: state.isLoading ? null : () => _submit(context),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить новый пароль'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Вернуться ко входу'),
              ),
            ],
          ),
        );
      },
    );
  }
}
