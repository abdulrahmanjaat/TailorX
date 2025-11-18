import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_spacing.dart';

class TailorHomeScreen extends StatefulWidget {
  const TailorHomeScreen({super.key});

  @override
  State<TailorHomeScreen> createState() => _TailorHomeScreenState();
}

class _TailorHomeScreenState extends State<TailorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final maxContentWidth = AppSpacing.responsiveMaxWidth(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 720;
    final horizontalPadding = isTablet ? AppSpacing.lg : AppSpacing.md;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.getText('Tailor Dashboard', 'درزی ڈیش بورڈ'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: languageProvider.getText('Profile', 'پروفائل'),
            onPressed: () => Navigator.pushNamed(context, '/tailor-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: languageProvider.getText('Logout', 'لاگ آؤٹ'),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(context, languageProvider),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    languageProvider.getText('Quick Actions', 'فوری عمل'),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 520;
                        return GridView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: isWide ? 3.2 : 2.6,
                              ),
                          children: [
                            _buildActionCard(
                              context,
                              icon: Icons.person_add_alt_1,
                              title: languageProvider.getText(
                                'Add New Customer',
                                'نیا گاہک شامل کریں',
                              ),
                              subtitle: languageProvider.getText(
                                'Create profile and measurements',
                                'پروفائل اور پیمائش بنائیں',
                              ),
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/customer-details',
                                  ),
                            ),
                            _buildActionCard(
                              context,
                              icon: Icons.people_alt_outlined,
                              title: languageProvider.getText(
                                'View All Customers',
                                'تمام گاہکوں کو دیکھیں',
                              ),
                              subtitle: languageProvider.getText(
                                'Browse and manage records',
                                'ریکارڈ دیکھیں اور منظم کریں',
                              ),
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/customers-list',
                                  ),
                            ),
                            _buildActionCard(
                              context,
                              icon: Icons.checkroom_outlined,
                              title: languageProvider.getText(
                                'Start Measurement',
                                'پیمائش شروع کریں',
                              ),
                              subtitle: languageProvider.getText(
                                'Select garment and details',
                                'لباس اور تفصیل منتخب کریں',
                              ),
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/garment-selection',
                                  ),
                            ),
                            _buildActionCard(
                              context,
                              icon: Icons.settings,
                              title: languageProvider.getText(
                                'Settings',
                                'ترتیبات',
                              ),
                              subtitle: languageProvider.getText(
                                'Preferences & language',
                                'ترجیحات اور زبان',
                              ),
                              onPressed:
                                  () =>
                                      Navigator.pushNamed(context, '/settings'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getText('Welcome Back,', 'خوش آمدید،'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            languageProvider.getText(
              'Ready to create some masterpieces today?',
              'آج کچھ شاہکار بنانے کے لیے تیار ہیں؟',
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.secondary.withValues(alpha: 0.12),
                child: Icon(icon, size: 28, color: colorScheme.secondary),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs * 0.75),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    final currentContext = context;
    final currentLanguageProvider =
        Provider.of<LanguageProvider>(currentContext, listen: false);
    final currentColorScheme = Theme.of(currentContext).colorScheme;

    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.of(currentContext).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text(
            currentLanguageProvider.getText(
              'Unable to logout. Please try again.',
              'لاگ آؤٹ نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
            ),
          ),
          backgroundColor: currentColorScheme.error,
        ),
      );
    }
  }
}
