/// Service for managing currency symbols based on country codes
class CurrencyService {
  CurrencyService._();

  static final CurrencyService instance = CurrencyService._();

  /// Map of international dialing codes to ISO country codes (best-effort)
  /// This is intentionally small and focused on common markets for the app.
  static const Map<String, String> _dialCodeToCountry = {
    '1': 'US', // +1 North America (default to US)
    '44': 'GB',
    '49': 'DE',
    '33': 'FR',
    '39': 'IT',
    '34': 'ES',
    '351': 'PT',
    '353': 'IE',
    '41': 'CH',
    '46': 'SE',
    '47': 'NO',
    '45': 'DK',
    '48': 'PL',
    '30': 'GR',
    '31': 'NL',
    '32': 'BE',
    '36': 'HU',
    '420': 'CZ',
    '43': 'AT',
    '91': 'IN',
    '92': 'PK',
    '93': 'AF',
    '94': 'LK',
    '95': 'MM',
    '60': 'MY',
    '61': 'AU',
    '62': 'ID',
    '63': 'PH',
    '65': 'SG',
    '66': 'TH',
    '81': 'JP',
    '82': 'KR',
    '84': 'VN',
    '86': 'CN',
    '90': 'TR',
    '971': 'AE',
    '966': 'SA',
    '974': 'QA',
    '968': 'OM',
    '973': 'BH',
    '965': 'KW',
    '20': 'EG',
    '27': 'ZA',
    '234': 'NG',
    '255': 'TZ',
    '256': 'UG',
    '254': 'KE',
    '233': 'GH',
    '598': 'UY',
    '55': 'BR',
    '52': 'MX',
    '57': 'CO',
    '58': 'VE',
    '51': 'PE',
    '56': 'CL',
  };

  /// Map of ISO country codes to currency symbols
  /// This covers major countries and their currencies
  static const Map<String, String> _countryToCurrency = {
    // North America
    'US': '\$', // United States Dollar
    'CA': '\$', // Canadian Dollar
    'MX': '\$', // Mexican Peso
    // Europe
    'GB': '£', // British Pound
    'IE': '€', // Euro (Ireland)
    'FR': '€', // Euro (France)
    'DE': '€', // Euro (Germany)
    'IT': '€', // Euro (Italy)
    'ES': '€', // Euro (Spain)
    'PT': '€', // Euro (Portugal)
    'NL': '€', // Euro (Netherlands)
    'BE': '€', // Euro (Belgium)
    'AT': '€', // Euro (Austria)
    'FI': '€', // Euro (Finland)
    'GR': '€', // Euro (Greece)
    'LU': '€', // Euro (Luxembourg)
    'MT': '€', // Euro (Malta)
    'CY': '€', // Euro (Cyprus)
    'SK': '€', // Euro (Slovakia)
    'SI': '€', // Euro (Slovenia)
    'EE': '€', // Euro (Estonia)
    'LV': '€', // Euro (Latvia)
    'LT': '€', // Euro (Lithuania)
    'CH': 'CHF', // Swiss Franc
    'NO': 'kr', // Norwegian Krone
    'SE': 'kr', // Swedish Krona
    'DK': 'kr', // Danish Krone
    'PL': 'zł', // Polish Zloty
    'CZ': 'Kč', // Czech Koruna
    'HU': 'Ft', // Hungarian Forint
    'RO': 'lei', // Romanian Leu
    'BG': 'лв', // Bulgarian Lev
    'HR': 'kn', // Croatian Kuna
    // Asia
    'PK': 'Rs', // Pakistani Rupee
    'IN': '₹', // Indian Rupee
    'BD': '৳', // Bangladeshi Taka
    'LK': 'Rs', // Sri Lankan Rupee
    'NP': 'Rs', // Nepalese Rupee
    'AF': '؋', // Afghan Afghani
    'CN': '¥', // Chinese Yuan
    'JP': '¥', // Japanese Yen
    'KR': '₩', // South Korean Won
    'TH': '฿', // Thai Baht
    'VN': '₫', // Vietnamese Dong
    'ID': 'Rp', // Indonesian Rupiah
    'MY': 'RM', // Malaysian Ringgit
    'SG': 'S\$', // Singapore Dollar
    'PH': '₱', // Philippine Peso
    'MM': 'K', // Myanmar Kyat
    'KH': '៛', // Cambodian Riel
    'LA': '₭', // Lao Kip
    // Middle East
    'SA': '﷼', // Saudi Riyal
    'AE': 'د.إ', // UAE Dirham
    'QA': '﷼', // Qatari Riyal
    'KW': 'د.ك', // Kuwaiti Dinar
    'BH': 'د.ب', // Bahraini Dinar
    'OM': 'ر.ع', // Omani Rial
    'JO': 'د.ا', // Jordanian Dinar
    'LB': 'ل.ل', // Lebanese Pound
    'IL': '₪', // Israeli Shekel
    'TR': '₺', // Turkish Lira
    'IR': '﷼', // Iranian Rial
    'IQ': 'ع.د', // Iraqi Dinar
    // Africa
    'ZA': 'R', // South African Rand
    'EG': 'ج.م', // Egyptian Pound
    'NG': '₦', // Nigerian Naira
    'KE': 'KSh', // Kenyan Shilling
    'GH': '₵', // Ghanaian Cedi
    'ET': 'Br', // Ethiopian Birr
    'TZ': 'TSh', // Tanzanian Shilling
    'UG': 'USh', // Ugandan Shilling
    // Oceania
    'AU': 'A\$', // Australian Dollar
    'NZ': 'NZ\$', // New Zealand Dollar
    'FJ': 'FJ\$', // Fijian Dollar
    'PG': 'K', // Papua New Guinean Kina
    // South America
    'BR': 'R\$', // Brazilian Real
    'AR': '\$', // Argentine Peso
    'CL': '\$', // Chilean Peso
    'CO': '\$', // Colombian Peso
    'PE': 'S/', // Peruvian Sol
    'VE': 'Bs', // Venezuelan Bolivar
    'UY': '\$', // Uruguayan Peso
    'PY': '₲', // Paraguayan Guaraní
    'BO': 'Bs', // Bolivian Boliviano
    'EC': '\$', // US Dollar (Ecuador)
    'GY': '\$', // Guyanese Dollar
    'SR': 'Sr\$', // Surinamese Dollar
    // Central America & Caribbean
    'CR': '₡', // Costa Rican Colon
    'PA': 'B/.', // Panamanian Balboa
    'GT': 'Q', // Guatemalan Quetzal
    'HN': 'L', // Honduran Lempira
    'NI': 'C\$', // Nicaraguan Cordoba
    'SV': '\$', // US Dollar (El Salvador)
    'BZ': 'BZ\$', // Belize Dollar
    'JM': 'J\$', // Jamaican Dollar
    'TT': 'TT\$', // Trinidad and Tobago Dollar
    'BB': 'Bds\$', // Barbadian Dollar
    'BS': 'B\$', // Bahamian Dollar
    // Other
    'RU': '₽', // Russian Ruble
    'UA': '₴', // Ukrainian Hryvnia
    'KZ': '₸', // Kazakhstani Tenge
    'UZ': 'so\'m', // Uzbekistani Som
    'BY': 'Br', // Belarusian Ruble
    'MD': 'L', // Moldovan Leu
    'GE': '₾', // Georgian Lari
    'AM': '֏', // Armenian Dram
    'AZ': '₼', // Azerbaijani Manat
  };

  /// Get currency symbol for a given country code
  /// Returns the currency symbol or '$' as default
  String getCurrencySymbol(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return '\$'; // Default to USD
    }

    final upperCode = countryCode.toUpperCase();
    return _countryToCurrency[upperCode] ?? '\$';
  }

  /// Get currency symbol with country code fallback
  /// If country code is not found, returns default currency
  String getCurrencySymbolWithFallback(
    String? countryCode, {
    String? defaultCurrency,
  }) {
    if (countryCode == null || countryCode.isEmpty) {
      return defaultCurrency ?? '\$';
    }

    final upperCode = countryCode.toUpperCase();
    return _countryToCurrency[upperCode] ?? (defaultCurrency ?? '\$');
  }

  /// Format amount with currency symbol
  /// Example: formatAmount(100, 'US') returns "$100"
  String formatAmount(double amount, String? countryCode, {int decimals = 2}) {
    final symbol = getCurrencySymbol(countryCode);
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// Format amount with custom currency symbol
  String formatAmountWithSymbol(
    double amount,
    String symbol, {
    int decimals = 2,
  }) {
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// Get all supported country codes
  List<String> getSupportedCountries() {
    return _countryToCurrency.keys.toList()..sort();
  }

  /// Check if a country code is supported
  bool isCountrySupported(String countryCode) {
    return _countryToCurrency.containsKey(countryCode.toUpperCase());
  }

  /// Infer ISO country code from a phone number (best-effort).
  /// Returns null if unable to infer.
  String? inferCountryCodeFromPhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    // Keep digits only, strip leading +
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final normalized = digits.startsWith('+') ? digits.substring(1) : digits;

    // Try to match the longest possible dialing code
    // Check 3, then 2, then 1 digit prefixes
    for (final len in [3, 2, 1]) {
      if (normalized.length >= len) {
        final prefix = normalized.substring(0, len);
        if (_dialCodeToCountry.containsKey(prefix)) {
          return _dialCodeToCountry[prefix];
        }
      }
    }
    return null;
  }
}
