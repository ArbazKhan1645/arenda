/// Currency formatting and conversion utilities for West African markets.
abstract final class CurrencyUtils {
  static const Map<String, _CurrencyMeta> _meta = {
    'GHS': _CurrencyMeta(symbol: '₵',   name: 'Ghana Cedi',          ratePerUSD: 15.5,  decimals: 0),
    'NGN': _CurrencyMeta(symbol: '₦',   name: 'Nigerian Naira',      ratePerUSD: 1600,  decimals: 0),
    'XOF': _CurrencyMeta(symbol: 'CFA', name: 'West African CFA',    ratePerUSD: 600,   decimals: 0),
    'XAF': _CurrencyMeta(symbol: 'CFA', name: 'Central African CFA', ratePerUSD: 600,   decimals: 0),
    'USD': _CurrencyMeta(symbol: '\$',  name: 'US Dollar',           ratePerUSD: 1,     decimals: 0),
    'EUR': _CurrencyMeta(symbol: '€',   name: 'Euro',                ratePerUSD: 0.93,  decimals: 0),
    'GBP': _CurrencyMeta(symbol: '£',   name: 'British Pound',       ratePerUSD: 0.79,  decimals: 0),
  };

  /// All supported currencies as label → code pairs for dropdowns.
  static const List<(String label, String code)> supportedCurrencies = [
    ('🇬🇭 Ghana Cedi (GHS)', 'GHS'),
    ('🇳🇬 Nigerian Naira (NGN)', 'NGN'),
    ('🌍 West African CFA (XOF)', 'XOF'),
    ('🇺🇸 US Dollar (USD)', 'USD'),
    ('🇪🇺 Euro (EUR)', 'EUR'),
    ('🇬🇧 Pound Sterling (GBP)', 'GBP'),
  ];

  /// Symbol for the given currency code. Falls back to '\$'.
  static String symbol(String code) => _meta[code]?.symbol ?? '\$';

  /// Full name of the currency.
  static String name(String code) => _meta[code]?.name ?? code;

  /// Convert USD amount to target currency.
  static double fromUSD(double usdAmount, String toCurrency) {
    final rate = _meta[toCurrency]?.ratePerUSD ?? 1.0;
    return usdAmount * rate;
  }

  /// Format an amount already in [currencyCode] as a display string.
  /// e.g. format(1800, 'GHS') → '₵1,800'
  static String format(double amount, String currencyCode) {
    final meta = _meta[currencyCode] ?? _meta['USD']!;
    final sym = meta.symbol;
    final rounded = amount.round();
    // thousands separator
    final formatted = _thousands(rounded);
    return '$sym$formatted';
  }

  /// Format a USD amount into local currency automatically.
  static String formatFromUSD(double usdAmount, String toCurrency) {
    return format(fromUSD(usdAmount, toCurrency), toCurrency);
  }

  static String _thousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

class _CurrencyMeta {
  const _CurrencyMeta({
    required this.symbol,
    required this.name,
    required this.ratePerUSD,
    required this.decimals,
  });

  final String symbol;
  final String name;
  final double ratePerUSD;
  final int decimals;
}
