import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/features/auth_forgot/model/forgot_state.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/services/forgot_bloc.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/services/forgot_event.dart';

class ForgotForm extends StatefulWidget {
  final ForgotState state;

  const ForgotForm({super.key, required this.state});

  @override
  State<ForgotForm> createState() => _ForgotFormState();
}

class _ForgotFormState extends State<ForgotForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotBloc>().add(ForgotSubmitted(email: _emailCtrl.text));
  }

  void _goBack() {
    context.read<ForgotBloc>().add(ForgotBackPressed());
    Navigator.of(context).pushReplacementNamed('/login');
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
                : const Text('Отправить ссылку для сброса'),
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
