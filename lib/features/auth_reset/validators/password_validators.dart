String? validateNewPassword(String? v) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Введите пароль';
  if (val.length < 6) return 'Минимум 6 символов';
  return null;
}

String? validateConfirmPassword(String? v, String original) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Повторите пароль';
  if (val != original.trim()) return 'Пароли не совпадают';
  return null;
}
