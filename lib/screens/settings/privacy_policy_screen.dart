import 'package:flutter/material.dart';

import '../../utils/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = _policySections(theme.textTheme);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppSpacing.responsiveMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We value your privacy',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'This policy explains how Lahore Dulha Suiting collects, '
                    'uses, and protects your information.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ...sections,
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Last updated: ${DateTime.now().year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  List<Widget> _policySections(TextTheme textTheme) {
    final entries = <Map<String, String>>[
      {
        'title': 'Information we collect',
        'body':
            'Customer profile details, measurements, and authentication data '
            'stored securely in Firebase.',
      },
      {
        'title': 'How we use your data',
        'body':
            'To manage tailoring orders, personalize the experience, and '
            'improve app reliability. We never sell your data.',
      },
      {
        'title': 'Your controls',
        'body':
            'You can request data removal or amendments from the in-app '
            'support contact. Language and notification preferences are '
            'also adjustable in Settings.',
      },
      {
        'title': 'Security',
        'body':
            'We rely on Firebase Authentication & Firestore security rules to '
            'prevent unauthorized access. Devices should be protected by '
            'a passcode or biometrics.',
      },
    ];

    return entries
        .map(
          (section) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section['title']!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(section['body']!, style: textTheme.bodyMedium),
              ],
            ),
          ),
        )
        .toList();
  }
}
