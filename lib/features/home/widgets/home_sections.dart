import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TailorX', style: AppTextStyles.titleLarge),
              Text('Studio onboarding', style: AppTextStyles.caption),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.push(AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      gradient: const LinearGradient(
        colors: [Color.fromARGB(255, 107, 214, 230), Color(0xFF63E0C9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, TailorX',
            style: AppTextStyles.headlineMedium.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'You have 4 orders today',
            style: AppTextStyles.bodyLarge.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'First fitting starts at 10:00 AM',
                style: AppTextStyles.bodyRegular.copyWith(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButtonsGrid extends StatelessWidget {
  const ActionButtonsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem('Create Customer', Icons.person_add, AppRoutes.addCustomer),
      _ActionItem(
        'Add Measurement',
        Icons.straighten,
        AppRoutes.addMeasurement,
      ),
      _ActionItem('Create New Order', Icons.content_cut, AppRoutes.addOrder),
      _ActionItem(
        'All Orders',
        Icons.library_books_outlined,
        AppRoutes.ordersList,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final crossAxisCount = constraints.maxWidth > 520 ? 4 : 2;
        final childAspectRatio = isCompact ? 0.85 : 1.05;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return CustomCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              onTap: () => context.push(item.route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.icon,
                      size: AppSizes.iconLg,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    item.label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

class TodayStatsRow extends StatelessWidget {
  const TodayStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Today Orders', '08', Icons.assignment_turned_in),
      ('Pending', '03', Icons.timer),
      ('Completed', '05', Icons.check_circle_outline),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final cards = stats
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: CustomCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFEFF6F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: _StatTile(label: s.$1, value: s.$2, icon: s.$3),
                ),
              ),
            )
            .toList();
        if (isNarrow) {
          return Column(children: cards);
        }
        return Row(
          children: List.generate(cards.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == cards.length - 1 ? 0 : AppSizes.sm,
                ),
                child: cards[index],
              ),
            );
          }),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.titleLarge),
          ],
        ),
      ],
    );
  }
}

class LatestOrdersList extends StatelessWidget {
  const LatestOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      ('Alina Khan', 'Bridal Dress', 'Dec 12'),
      ('Rahul Mehta', 'Sherwani', 'Dec 14'),
      ('Sara Iqbal', 'Party Gown', 'Dec 16'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest orders', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSizes.md),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFEFF5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    order.$1.substring(0, 1),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(order.$1, style: AppTextStyles.bodyLarge),
                subtitle: Wrap(
                  spacing: AppSizes.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      label: Text(order.$2),
                      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Text('Delivery ${order.$3}', style: AppTextStyles.caption),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
