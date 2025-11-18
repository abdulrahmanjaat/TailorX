import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';

class TailorProfileScreen extends StatelessWidget {
  const TailorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'No Name';
    final email = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('Tailor Profile', 'درزی پروفائل')),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: const Color(0xFFD4AF37),
                child: const Icon(Icons.person, size: 60, color: Colors.black),
              ),
              SizedBox(height: 16.h),
              Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                email,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 32.h),
              _buildProfileOption(
                context,
                icon: Icons.settings,
                title: languageProvider.getText('Settings', 'ترتیبات'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const Divider(),
              _buildProfileOption(
                context,
                icon: Icons.help_outline,
                title: languageProvider.getText(
                  'Help & Support',
                  'مدد اور سپورٹ',
                ),
                onTap: () {},
              ),
              const Divider(),
              const Spacer(),
              FilledButton(
                onPressed: () => _confirmLogout(context, languageProvider),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Text(
                    languageProvider.getText('Logout', 'لاگ آؤٹ'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    LanguageProvider languageProvider,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(languageProvider.getText('Logout', 'لاگ آؤٹ')),
        content: Text(
          languageProvider.getText(
            'Are you sure you want to logout?',
            'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(languageProvider.getText('Cancel', 'منسوخ کریں')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(languageProvider.getText('Logout', 'لاگ آؤٹ')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
