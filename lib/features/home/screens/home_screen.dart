import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/services/session_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/home_sections.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start session when home screen opens (if not already started)
    SessionService.instance.startSession();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.lg,
              AppSizes.md,
              150,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(),
                SizedBox(height: AppSizes.lg),
                WelcomeCard(),
                SizedBox(height: AppSizes.lg),
                ActionButtonsGrid(),
                SizedBox(height: AppSizes.lg),
                TodayStatsRow(),
                SizedBox(height: AppSizes.lg),
                LatestOrdersList(),
                SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
          const Positioned(
            left: AppSizes.md,
            right: AppSizes.md,
            bottom: AppSizes.lg,
            child: TailorBottomNav(),
          ),
        ],
      ),
    );
  }
}
