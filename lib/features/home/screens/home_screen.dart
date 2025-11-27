import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/home_sections.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: const EdgeInsets.all(AppSizes.lg),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeader(),
            SizedBox(height: AppSizes.lg),
            WelcomeCard(),
            SizedBox(height: AppSizes.lg),
            ActionButtonsGrid(),
            SizedBox(height: AppSizes.lg),
            TodayStatsRow(),
            SizedBox(height: AppSizes.lg),
            LatestOrdersList(),
          ],
        ),
      ),
      bottomNavigationBar: const TailorBottomNav(),
    );
  }
}
