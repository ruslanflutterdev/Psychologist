import 'package:flutter/material.dart';

class PsychologistModel {
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  const PsychologistModel({
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName.characters.first : '';
    final l = lastName.isNotEmpty ? lastName.characters.first : '';
    return (f + l).toUpperCase();
  }
}
