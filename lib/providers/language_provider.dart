import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;
  Locale get locale => _isUrdu ? const Locale('ur') : const Locale('en');
  TextDirection get textDirection =>
      _isUrdu ? TextDirection.rtl : TextDirection.ltr;

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    notifyListeners();
  }

  void setLanguage(bool isUrdu) {
    if (_isUrdu == isUrdu) return;
    _isUrdu = isUrdu;
    notifyListeners();
  }

  String getText(String englishText, String urduText) {
    return _isUrdu ? urduText : englishText;
  }

  static const Map<String, Map<String, String>> _translations = {
    'common': {
      'save': 'Save',
      'save_urdu': 'محفوظ کریں',
      'cancel': 'Cancel',
      'cancel_urdu': 'منسوخ کریں',
      'next': 'Next',
      'next_urdu': 'اگلا',
      'back': 'Back',
      'back_urdu': 'پیچھے',
      'proceed': 'Proceed',
      'proceed_urdu': 'آگے بڑھیں',
      'edit': 'Edit',
      'edit_urdu': 'ترمیم کریں',
      'delete': 'Delete',
      'delete_urdu': 'حذف کریں',
      'confirm': 'Confirm',
      'confirm_urdu': 'تصدیق کریں',
      'logout': 'Logout',
      'logout_urdu': 'لاگ آؤٹ',
      'profile': 'Profile',
      'profile_urdu': 'پروفائل',
      'settings': 'Settings',
      'settings_urdu': 'ترتیبات',
    },
    'garments': {
      'sherwani': 'Sherwani',
      'sherwani_urdu': 'شیروانی',
      'waistcoat': 'Waistcoat',
      'waistcoat_urdu': 'ویسٹ کوٹ',
      'shirt': 'Shirt',
      'shirt_urdu': 'قمیض',
      'kameez_shalwar': 'Kameez Shalwar',
      'kameez_shalwar_urdu': 'قمیض شلوار',
      'coat': 'Coat',
      'coat_urdu': 'کوٹ',
      'coat_pent': 'Coat Pant',
      'coat_pent_urdu': 'کوٹ پینٹ',
    },
    'screens': {
      'tailor_dashboard': 'Tailor Dashboard',
      'tailor_dashboard_urdu': 'درزی ڈیش بورڈ',
      'tailor_profile': 'Tailor Profile',
      'tailor_profile_urdu': 'درزی پروفائل',
      'customers_list': 'All Customers',
      'customers_list_urdu': 'تمام گاہک',
      'add_measurement': 'Add New Measurement',
      'add_measurement_urdu': 'نئی پیمائش شامل کریں',
      'view_customers': 'View All Customers',
      'view_customers_urdu': 'تمام گاہکوں کو دیکھیں',
    },
  };

  String getTranslation(String category, String key) {
    final categoryMap = _translations[category];
    if (categoryMap == null) {
      return key;
    }
    if (_isUrdu) {
      return categoryMap['${key}_urdu'] ?? key;
    }
    return categoryMap[key] ?? key;
  }
}

