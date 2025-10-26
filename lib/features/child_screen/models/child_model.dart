class ChildModel {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final ChildGender gender;
  final String? archetype;
  final DateTime? updatedAt;

  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    this.archetype,
    this.updatedAt,
  });

  String get name => '$firstName $lastName';
}

enum ChildGender { male, female }

extension ChildGenderX on ChildGender {
  String get uiLabel {
    switch (this) {
      case ChildGender.male:
        return 'Мальчик';
      case ChildGender.female:
        return 'Девочка';
    }
  }
}
