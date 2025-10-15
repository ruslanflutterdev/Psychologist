bool shouldStartAtReset() {
  final hasRecoveryFragment = Uri.base.fragment.contains('type=recovery');
  final hasPkceCode = Uri.base.queryParameters.containsKey('code');
  return hasRecoveryFragment || hasPkceCode;
}
