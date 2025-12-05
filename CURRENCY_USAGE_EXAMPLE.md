# Currency Symbol Implementation Guide

## Overview
The app now automatically detects the user's country from their location and displays the appropriate currency symbol (e.g., $ for USA, € for Europe, Rs for Pakistan, etc.).

## How It Works

1. **Location Detection**: When the app starts, it detects the user's location and gets the country code (e.g., 'US', 'PK', 'GB').

2. **Currency Mapping**: The country code is mapped to the appropriate currency symbol using `CurrencyService`.

3. **Storage**: Both the country code and currency symbol are stored in secure storage for quick access.

4. **Automatic Updates**: When location is detected, the currency symbol is automatically updated.

## Files Created

1. **`lib/shared/services/currency_service.dart`**
   - Maps country codes to currency symbols
   - Supports 100+ countries
   - Provides currency formatting methods

2. **`lib/core/helpers/currency_formatter.dart`**
   - Helper class for easy currency formatting
   - Main interface for formatting amounts throughout the app

3. **Updated `lib/shared/services/location_service.dart`**
   - Now automatically stores currency symbol when country is detected

4. **Updated `lib/shared/services/secure_storage_service.dart`**
   - Added methods to store and retrieve currency symbol

## Usage Examples

### Example 1: Format Amount (Recommended - Async)
```dart
import 'package:tailorx/core/helpers/currency_formatter.dart';

// Format amount with currency symbol
final formatted = await CurrencyFormatter.formatAmount(100.50);
// Returns: "$100.50" (if in USA), "Rs100.50" (if in Pakistan), "€100.50" (if in Europe)

// Format whole number (no decimals)
final formattedWhole = await CurrencyFormatter.formatAmountWhole(100);
// Returns: "$100", "Rs100", "€100"
```

### Example 2: Get Currency Symbol
```dart
import 'package:tailorx/core/helpers/currency_formatter.dart';

// Get currency symbol
final symbol = await CurrencyFormatter.getCurrencySymbol();
// Returns: "$", "Rs", "€", "£", etc.
```

### Example 3: In Widgets (Using FutureBuilder)
```dart
import 'package:tailorx/core/helpers/currency_formatter.dart';

FutureBuilder<String>(
  future: CurrencyFormatter.formatAmount(order.totalAmount),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(snapshot.data!); // "$100.50"
    }
    return Text('\$${order.totalAmount.toStringAsFixed(2)}'); // Fallback
  },
)
```

### Example 4: In StatefulWidget (Cache the Symbol)
```dart
class OrderCard extends StatefulWidget {
  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String _currencySymbol = '\$'; // Default fallback

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyFormatter.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_currencySymbol${order.amount.toStringAsFixed(2)}');
  }
}
```

### Example 5: Direct Service Usage
```dart
import 'package:tailorx/shared/services/currency_service.dart';
import 'package:tailorx/shared/services/secure_storage_service.dart';

// Get country code
final countryCode = await SecureStorageService.instance.getCountryCode();

// Get currency symbol
final symbol = CurrencyService.instance.getCurrencySymbol(countryCode);

// Format amount
final formatted = CurrencyService.instance.formatAmount(100.50, countryCode);
```

## Migration Guide

### Replace Hardcoded Dollar Signs

**Before:**
```dart
Text('\$${order.amount.toStringAsFixed(2)}')
```

**After:**
```dart
FutureBuilder<String>(
  future: CurrencyFormatter.formatAmount(order.amount),
  builder: (context, snapshot) => Text(snapshot.data ?? '\$${order.amount.toStringAsFixed(2)}'),
)
```

### Or Use Cached Symbol (Better Performance)

**Before:**
```dart
Text('\$${order.amount.toStringAsFixed(2)}')
```

**After:**
```dart
// In initState or build method
final symbol = await CurrencyFormatter.getCurrencySymbol();
Text('$symbol${order.amount.toStringAsFixed(2)}')
```

## Supported Countries

The currency service supports 100+ countries including:
- **North America**: USA ($), Canada ($), Mexico ($)
- **Europe**: UK (£), Germany (€), France (€), Italy (€), Spain (€), etc.
- **Asia**: Pakistan (Rs), India (₹), Bangladesh (৳), China (¥), Japan (¥), etc.
- **Middle East**: Saudi Arabia (﷼), UAE (د.إ), Qatar (﷼), etc.
- **Africa**: South Africa (R), Egypt (ج.م), Nigeria (₦), etc.
- **Oceania**: Australia (A$), New Zealand (NZ$)
- **South America**: Brazil (R$), Argentina ($), Chile ($), etc.

## Default Behavior

- If location cannot be detected, defaults to **$** (USD)
- If country code is not in the mapping, defaults to **$** (USD)
- Currency symbol is cached in secure storage for quick access

## Testing

1. **Test in different locations**: Use a VPN or change device location to test different currencies
2. **Test without location**: Disable location permission to see default behavior
3. **Test currency formatting**: Verify amounts are formatted correctly with appropriate symbols

## Notes

- Currency symbol is automatically updated when location is detected
- The symbol is cached, so it doesn't need to be fetched every time
- For better performance, cache the currency symbol in your widget's state
- The currency service uses ISO country codes (e.g., 'US', 'PK', 'GB')

