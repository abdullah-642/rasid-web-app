import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Display Formatter
String formatCurrency(num amount) {
  final formatter = NumberFormat('#,##0.##', 'en_US');
  return formatter.format(amount);
}

// Input Formatter
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(',', '');

    // Handle decimals if entered
    if (newText.contains('.')) {
      // If user is typing decimals, don't interfere too much yet
      // or implement complex decimal logic.
      // For MVP of this request (1000 -> 1,000), let's stick to integer formatting part
      // and allow decimals pass through or split logic.
      return newValue;
    }

    // Integer only logic for thousands
    if (int.tryParse(newText) == null) {
      return oldValue; // Revert if invalid char
    }

    final intValue = int.parse(newText);
    final String newString = _formatter.format(intValue);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
