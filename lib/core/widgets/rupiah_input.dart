import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats number input to Rupiah display format while typing.
/// 
/// Displays "Rp 5.000.000" as user types, but internally stores
/// the raw integer value. Use [getRawValue] to get the unformatted number.
class RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strip all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(digitsOnly) ?? 0;
    final formatted = 'Rp ${_formatter.format(number)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Parse the displayed text back to an integer value.
  static int? parse(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }
}

/// Budget preset chips for quick selection in mobile.
class BudgetPreset {
  final String label;
  final int? minValue;
  final int? maxValue;
  final String displayText;

  const BudgetPreset({
    required this.label,
    this.minValue,
    this.maxValue,
    required this.displayText,
  });

  /// Standard presets for UMKM budget ranges
  static const List<BudgetPreset> defaults = [
    BudgetPreset(
      label: '< Rp 1 jt',
      maxValue: 1000000,
      displayText: 'Rp 1.000.000',
    ),
    BudgetPreset(
      label: 'Rp 1–5 jt',
      minValue: 1000000,
      maxValue: 5000000,
      displayText: 'Rp 5.000.000',
    ),
    BudgetPreset(
      label: 'Rp 5–20 jt',
      minValue: 5000000,
      maxValue: 20000000,
      displayText: 'Rp 20.000.000',
    ),
    BudgetPreset(
      label: '> Rp 20 jt',
      minValue: 20000000,
      displayText: 'Rp 50.000.000',
    ),
  ];

  /// Returns the representative value to use when this preset is selected.
  /// Uses maxValue if available, otherwise minValue * 2.5 as a reasonable default.
  int get representativeValue {
    if (maxValue != null) return maxValue!;
    if (minValue != null) return (minValue! * 2.5).toInt();
    return 0;
  }
}
