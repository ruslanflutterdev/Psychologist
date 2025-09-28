import 'package:heros_journey/features/child_screen/view/models/child_progress_model.dart';

abstract class ProgressService {
  Future<ChildProgressModel> getChildProgress(String childId);
}
