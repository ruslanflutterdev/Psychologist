String? validateFullName(String? v) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Введите ФИО родителя';
  if (val.length < 2) return 'Минимум 2 символа';
  if (val.length > 100) return 'Максимум 100 символов';
  return null;
}

String? validatePhoneRK(String? v) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Введите номер телефона';
  final phoneRegex = RegExp(r'^\+?[0-9\s-()]{10,20}$');
  final stripped = val.replaceAll(RegExp(r'[^\d]'), '');
  if (!phoneRegex.hasMatch(val) || stripped.length < 10) {
    return 'Некорректный формат телефона (мин. 10 цифр)';
  }
  return null;
}
