import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/validators.dart';

class SignupState {
  const SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.organization = '',
    this.isLoading = false,
  });

  final String name;
  final String email;
  final String password;
  final String organization;
  final bool isLoading;

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    String? organization,
    bool? isLoading,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      organization: organization ?? this.organization,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SignupController extends StateNotifier<SignupState> {
  SignupController() : super(const SignupState());

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void updateOrganization(String value) {
    state = state.copyWith(organization: value);
  }

  Future<String?> submit() async {
    final nameError = Validators.requiredField(state.name, fieldName: 'Name');
    if (nameError != null) return nameError;
    final orgError = Validators.requiredField(
      state.organization,
      fieldName: 'Studio',
    );
    if (orgError != null) return orgError;
    final emailError = Validators.email(state.email);
    if (emailError != null) return emailError;
    if (state.password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isLoading: false);
    return null;
  }
}

final signupControllerProvider =
    StateNotifierProvider<SignupController, SignupState>(
      (ref) => SignupController(),
    );
