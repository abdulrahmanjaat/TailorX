import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('Settings', 'ترتیبات')),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            languageProvider.getText('App Settings', 'ایپ کی ترتیبات'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Card(
            child: SwitchListTile(
              title: Text(
                languageProvider.getText('Urdu Language', 'اردو زبان'),
              ),
              subtitle: Text(
                languageProvider.getText(
                  'Toggle between English and Urdu',
                  'انگریزی اور اردو کے درمیان سوئچ کریں',
                ),
              ),
              value: languageProvider.isUrdu,
              onChanged: (value) => languageProvider.setLanguage(value),
            ),
          ),
          SizedBox(height: 8.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(languageProvider.getText('Theme', 'تھیم')),
              subtitle: Text(languageProvider.getText('Light', 'ہلکا')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.getText(
                        'Theme customization coming soon.',
                        'تھیم کی تخصیص جلد دستیاب ہوگی۔',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            languageProvider.getText('About', 'متعلق'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(languageProvider.getText('App Version', 'ایپ ورژن')),
              subtitle: const Text('1.0.0'),
            ),
          ),
          SizedBox(height: 8.h),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(
                languageProvider.getText('Privacy Policy', 'رازداری کی پالیسی'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
          ),
        ],
      ),
    );
  }
}
