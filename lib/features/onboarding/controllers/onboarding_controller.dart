import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class OnboardingState {
  const OnboardingState({this.index = 0, this.completed = false});

  final int index;
  final bool completed;

  OnboardingState copyWith({int? index, bool? completed}) {
    return OnboardingState(
      index: index ?? this.index,
      completed: completed ?? this.completed,
    );
  }
}

final onboardingPagesProvider = Provider<List<OnboardingPage>>(
  (ref) => const [
    OnboardingPage(
      title: 'Measure Smarter',
      description:
          'Augmented workflows that guide every measurement with live precision cues.',
      icon: Icons.architecture,
    ),
    OnboardingPage(
      title: 'Collaborate Anywhere',
      description:
          'Connect ateliers, clients, and production in one elegant workspace.',
      icon: Icons.devices_other,
    ),
    OnboardingPage(
      title: 'Deliver Perfection',
      description:
          'Track goals, approvals, and deliveries through immersive dashboards.',
      icon: Icons.check_circle,
    ),
  ],
);

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._pages) : super(const OnboardingState());

  final List<OnboardingPage> _pages;

  void updateIndex(int index) {
    state = state.copyWith(index: index.clamp(0, _pages.length - 1));
  }

  void skip() {
    state = state.copyWith(index: _pages.length - 1, completed: true);
  }

  void next() {
    if (state.index >= _pages.length - 1) {
      state = state.copyWith(completed: true);
    } else {
      updateIndex(state.index + 1);
    }
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
      (ref) => OnboardingController(ref.read(onboardingPagesProvider)),
    );
