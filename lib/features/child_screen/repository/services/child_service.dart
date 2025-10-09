import 'package:heros_journey/features/child_screen/models/child_model.dart';

abstract class ChildService {
  Future<List<ChildModel>> getChildren();
}
