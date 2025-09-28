import 'package:heros_journey/core/models/child_model.dart';
import 'package:heros_journey/core/services/child_service.dart';

class MockChildService implements ChildService {
  final List<ChildModel> _children = const [
    ChildModel(id: '1', name: 'Иван'),
    ChildModel(id: '2', name: 'Алина'),
    ChildModel(id: '3', name: 'Марат'),
    ChildModel(id: '4', name: 'Саша'),
    ChildModel(id: '5', name: 'Диана'),
  ];

  @override
  Future<List<ChildModel>> getChildren() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _children;
  }
}
