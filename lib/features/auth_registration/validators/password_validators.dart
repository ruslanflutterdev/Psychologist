String? validateSecurePassword(String? v) {
  final val = v?.trim() ?? '';

  if (val.isEmpty) {
    return 'Введите пароль';
  }

  if (val.length < 8) {
    return 'Минимум 8 символов';
  }

  final hasUppercase = RegExp(r'[A-Z]').hasMatch(val);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(val);
  final hasDigit = RegExp(r'[0-9]').hasMatch(val);
  final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val);

  if (!hasUppercase) {
    return 'Добавьте заглавную букву';
  }
  if (!hasLowercase) {
    return 'Добавьте строчную букву';
  }
  if (!hasDigit) {
    return 'Добавьте цифру';
  }
  if (!hasSpecialChar) {
    return 'Добавьте спецсимвол (!@#\$...)';
  }

  return null;
}
