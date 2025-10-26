import 'package:heros_journey/features/child_screen/models/parent_contact_model.dart';

abstract class ParentContactService {
  Future<ParentContactModel?> getContact(String childId);
  Future<void> saveContact(String childId, ParentContactModel contact);
  Future<void> deleteContact(String childId);
}
