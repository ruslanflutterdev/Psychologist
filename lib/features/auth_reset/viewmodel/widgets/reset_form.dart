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
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!_emailFormKey.currentState!.validate()) return;
    context.read<ResetBloc>().add(ResetEmailSubmitted(email: _emailCtrl.text));
  }

  void _submitOtp() {
    if (!_otpFormKey.currentState!.validate()) return;
    context.read<ResetBloc>().add(ResetOtpSubmitted(otpCode: _otpCtrl.text));
  }

  void _submitPassword() {
    if (!_passFormKey.currentState!.validate()) return;
    context.read<ResetBloc>().add(
      ResetPasswordSubmitted(
          password: _passCtrl.text, confirm: _confirmCtrl.text),
    );
  }

  Widget _buildStepForm(ResetState state, ThemeData theme) {
    switch (state.currentStep) {
      case ResetStep.enterEmail:
        return Form(
          key: _emailFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Сброс пароля', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Введите Email, чтобы получить одноразовый код для сброса.', style: theme.textTheme.bodyMedium),
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
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.isLoading ? null : _submitEmail,
                child: state.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Отправить код'),
              ),
            ],
          ),
        );
      case ResetStep.enterOtp:
        return Form(
          key: _otpFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Подтверждение кода', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('На Email ${state.email} отправлен код. Введите его ниже.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP-код'),
                validator: (v) => (v?.trim().length == 6) ? null : 'Код должен содержать 6 цифр',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.isLoading ? null : _submitOtp,
                child: state.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Проверить код'),
              ),
            ],
          ),
        );
      case ResetStep.enterNewPassword:
        return Form(
          key: _passFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Новый пароль', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Новый пароль (мин. 6 симв)'),
                validator: validateNewPassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Повторите пароль'),
                validator: (v) => validateConfirmPassword(v, _passCtrl.text),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.isLoading ? null : _submitPassword,
                child: state.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Сохранить и войти'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ResetBloc, ResetState>(
      listenWhen: (p, c) => p.isSuccess != c.isSuccess,
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пароль успешно сброшен. Вы вошли.')),
          );
          Navigator.of(context).pushReplacementNamed('/psychologist_screen');
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepForm(state, theme),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () => Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text('Вернуться ко входу'),
            ),
          ],
        );
      },
    );
  }
}