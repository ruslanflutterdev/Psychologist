class RegistrationState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  const RegistrationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
  RegistrationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) => RegistrationState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    errorMessage: errorMessage,
  );
  static const initial = RegistrationState();
}
