import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Terms & Privacy',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Service',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Last updated: December 2024',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Welcome to TailorX. By using our app, you agree to these terms. '
                    'Please read them carefully.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('1. Account Registration'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'You must provide accurate information when creating an account. '
                    'You are responsible for maintaining the security of your account.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('2. Use of Service'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'TailorX is designed for professional tailors to manage their business. '
                    'You agree to use the service only for lawful purposes and in accordance '
                    'with these terms.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('3. Data Privacy'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'We respect your privacy and handle your data according to our Privacy Policy. '
                    'Your customer data is stored securely and only accessible to you.',
                    style: AppTextStyles.bodyRegular,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _SectionTitle('Information We Collect'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'We collect information you provide directly, including your name, '
                    'email, phone number, and business details. We also collect customer '
                    'data you enter into the app.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('How We Use Your Information'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'We use your information to provide and improve our services, '
                    'process transactions, and communicate with you. We do not sell '
                    'your data to third parties.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('Data Security'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'We implement appropriate security measures to protect your data. '
                    'However, no method of transmission over the internet is 100% secure.',
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _SectionTitle('Contact Us'),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'If you have questions about these terms or our privacy practices, '
                    'please contact us at support@tailorx.com',
                    style: AppTextStyles.bodyRegular,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}
