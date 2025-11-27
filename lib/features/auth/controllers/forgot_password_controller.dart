import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/validators.dart';

enum ForgotPasswordStep { email, verify, reset }

class ForgotPasswordState {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.email = '',
    this.code = '',
    this.password = '',
    this.isLoading = false,
    this.completed = false,
  });

  final ForgotPasswordStep step;
  final String email;
  final String code;
  final String password;
  final bool isLoading;
  final bool completed;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? email,
    String? code,
    String? password,
    bool? isLoading,
    bool? completed,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      code: code ?? this.code,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      completed: completed ?? this.completed,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController() : super(const ForgotPasswordState());

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  Future<String?> next() async {
    switch (state.step) {
      case ForgotPasswordStep.email:
        final emailError = Validators.email(state.email);
        if (emailError != null) return emailError;
        break;
      case ForgotPasswordStep.verify:
        if (state.code.length != 6) return 'Enter 6-digit code';
        break;
      case ForgotPasswordStep.reset:
        if (state.password.length < 6) {
          return 'Password must be at least 6 characters';
        }
        break;
    }

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false);

    if (state.step == ForgotPasswordStep.reset) {
      state = state.copyWith(completed: true);
      return null;
    }

    final nextStep = ForgotPasswordStep.values[state.step.index + 1];
    state = state.copyWith(step: nextStep);
    return null;
  }

  void previous() {
    if (state.step == ForgotPasswordStep.email) return;
    final prevStep = ForgotPasswordStep.values[state.step.index - 1];
    state = state.copyWith(step: prevStep);
  }

  void resetFlow() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordControllerProvider =
    StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      (ref) => ForgotPasswordController(),
    );
