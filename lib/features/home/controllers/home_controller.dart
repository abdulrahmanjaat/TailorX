import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeWelcomeProvider = Provider<String>(
  (ref) => 'Design flow crafted for contemporary ateliers',
);

class OverviewMetric {
  const OverviewMetric({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
}

class GoalMetric {
  const GoalMetric({
    required this.title,
    required this.progress,
    required this.status,
  });

  final String title;
  final double progress;
  final String status;
}

class HomeState {
  const HomeState({
    required this.utilization,
    required this.metrics,
    required this.goals,
  });

  final double utilization;
  final List<OverviewMetric> metrics;
  final List<GoalMetric> goals;
}

class HomeController extends StateNotifier<HomeState> {
  HomeController()
    : super(
        HomeState(
          utilization: 0.72,
          metrics: const [
            OverviewMetric(
              label: 'Active orders',
              value: '24',
              caption: '4 awaiting approval',
              icon: Icons.assignment,
            ),
            OverviewMetric(
              label: 'Premium clients',
              value: '18',
              caption: '+3 this week',
              icon: Icons.person_rounded,
            ),
            OverviewMetric(
              label: 'Fittings today',
              value: '9',
              caption: '3 virtual',
              icon: Icons.watch_later,
            ),
          ],
          goals: const [
            GoalMetric(
              title: 'Launch couture capsule',
              progress: 0.82,
              status: 'Due in 4 days',
            ),
            GoalMetric(
              title: 'Expand bridal pipeline',
              progress: 0.58,
              status: 'Tracking ahead',
            ),
            GoalMetric(
              title: 'Digitize measurements',
              progress: 0.36,
              status: 'Sync with atelier',
            ),
          ],
        ),
      );
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(),
);
