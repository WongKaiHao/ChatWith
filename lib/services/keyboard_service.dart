import 'package:flutter/widgets.dart';

class KeyboardService {
  // Private constructor to ensure a single instance of KeyboardService
  KeyboardService._privateConstructor();

  static final KeyboardService instance = KeyboardService._privateConstructor();

  // Method to hide the keyboard
  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}