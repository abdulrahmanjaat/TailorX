import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashState {
  const SplashState({this.isReady = false});

  final bool isReady;

  SplashState copyWith({bool? isReady}) {
    return SplashState(isReady: isReady ?? this.isReady);
  }
}

class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(const SplashState()) {
    _load();
  }

  Future<void> _load() async {
    // Wait for splash screen animation
    // Note: Location permission is now requested from the splash screen widget
    // to ensure it has proper UI context
    await Future<void>.delayed(const Duration(seconds: 3));
    state = state.copyWith(isReady: true);
  }
}

final splashControllerProvider =
    StateNotifierProvider.autoDispose<SplashController, SplashState>(
      (ref) => SplashController(),
    );
