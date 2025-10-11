abstract class ResetEvent {}

class ResetSubmitted extends ResetEvent {
  final String password;
  final String confirm;

  ResetSubmitted({required this.password, required this.confirm});
}
