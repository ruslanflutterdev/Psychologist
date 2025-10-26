import 'dart:async';
import 'package:heros_journey/features/child_screen/models/parent_contact_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/parent_contact_service.dart';

class MockParentContactService implements ParentContactService {
  final Duration latency = const Duration(milliseconds: 200);
  final Map<String, ParentContactModel> _contacts = {};

  @override
  Future<ParentContactModel?> getContact(String childId) async {
    await Future<void>.delayed(latency);
    if (childId == '2') {
      _contacts.putIfAbsent(
        '2',
        () => const ParentContactModel(
          fullName: 'Садыкова Анна Игоревна',
          phone: '+7 705 123 4567',
        ),
      );
    }
    return _contacts[childId];
  }

  @override
  Future<void> saveContact(String childId, ParentContactModel contact) async {
    await Future<void>.delayed(latency);
    _contacts[childId] = contact;
  }

  @override
  Future<void> deleteContact(String childId) async {
    await Future<void>.delayed(latency);
    _contacts.remove(childId);
  }
}
