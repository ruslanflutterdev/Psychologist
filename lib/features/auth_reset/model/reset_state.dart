class ResetState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ResetState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ResetState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) =>
      ResetState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
      );
  static const initial = ResetState();
}
