import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/validators.dart';

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
  });

  final String email;
  final String password;
  final bool isLoading;

  LoginState copyWith({String? email, String? password, bool? isLoading}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  Future<String?> submit() async {
    final emailError = Validators.email(state.email);
    if (emailError != null) return emailError;
    if (state.password.isEmpty) return 'Password is required';

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
    return null;
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(),
    );
