// utils/language_utils.dart
import 'package:flutter/services.dart';

Future<void> toggleLanguage({
  required bool isCurrentlyArabic,
  required Function(bool) updateState,
}) async {
  final newValue = !isCurrentlyArabic;
  updateState(newValue); // Equivalent to setState(() => _isArabic = newValue)

  if (newValue) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}