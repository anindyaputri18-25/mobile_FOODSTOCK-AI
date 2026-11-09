import 'package:flutter/material.dart';

/// Pengatur mode tampilan aplikasi: terang, gelap, atau mengikuti sistem.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode m) {
    if (m == _mode) return;
    _mode = m;
    notifyListeners();
  }

  /// Beralih cepat terang <-> gelap berdasarkan tampilan yang sedang aktif.
  void toggle(Brightness current) {
    setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
