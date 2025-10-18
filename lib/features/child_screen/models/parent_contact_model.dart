class ParentContactModel {
  final String fullName;
  final String phone;

  const ParentContactModel({required this.fullName, required this.phone});

  ParentContactModel copyWith({String? fullName, String? phone}) {
    return ParentContactModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
    );
  }
}
