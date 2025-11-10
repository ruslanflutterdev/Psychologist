enum ResetStep { enterEmail, enterOtp, enterNewPassword }

class ResetState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final ResetStep currentStep;
  final String email;

  const ResetState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.currentStep = ResetStep.enterEmail,
    this.email = '',
  });

  ResetState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    ResetStep? currentStep,
    String? email,
  }) =>
      ResetState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
        currentStep: currentStep ?? this.currentStep,
        email: email ?? this.email,
      );
  static const initial = ResetState();
}