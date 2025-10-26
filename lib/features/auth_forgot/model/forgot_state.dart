class ForgotState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ForgotState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ForgotState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) =>
      ForgotState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
      );

  static const initial = ForgotState();
}
