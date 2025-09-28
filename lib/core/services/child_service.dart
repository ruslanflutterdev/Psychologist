import 'package:heros_journey/core/models/child_model.dart';

abstract class ChildService {
  Future<List<ChildModel>> getChildren();
}
