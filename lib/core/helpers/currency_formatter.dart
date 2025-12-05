import '../../shared/services/currency_service.dart';
import '../../shared/services/secure_storage_service.dart';

/// Helper class for formatting currency amounts
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount with currency symbol from stored country code
  /// This is the main method to use throughout the app
  static Future<String> formatAmount(double amount, {int decimals = 2}) async {
    final countryCode = await SecureStorageService.instance.getCountryCode();
    final currencySymbol = CurrencyService.instance.getCurrencySymbol(
      countryCode,
    );
    return '$currencySymbol${amount.toStringAsFixed(decimals)}';
  }

  /// Format amount with currency symbol synchronously (uses cached value)
  /// Use this when you already have the currency symbol
  static String formatAmountWithSymbol(
    double amount,
    String currencySymbol, {
    int decimals = 2,
  }) {
    return '$currencySymbol${amount.toStringAsFixed(decimals)}';
  }

  /// Get currency symbol for current location
  static Future<String> getCurrencySymbol() async {
    // First try to get from storage (cached)
    final cachedSymbol = await SecureStorageService.instance
        .getCurrencySymbol();
    if (cachedSymbol != null && cachedSymbol.isNotEmpty) {
      return cachedSymbol;
    }

    // If not cached, get from country code
    final countryCode = await SecureStorageService.instance.getCountryCode();
    return CurrencyService.instance.getCurrencySymbol(countryCode);
  }

  /// Format amount with zero decimals (for whole numbers)
  static Future<String> formatAmountWhole(double amount) async {
    return formatAmount(amount, decimals: 0);
  }

  /// Format amount with custom decimals
  static Future<String> formatAmountCustom(double amount, int decimals) async {
    return formatAmount(amount, decimals: decimals);
  }
}
