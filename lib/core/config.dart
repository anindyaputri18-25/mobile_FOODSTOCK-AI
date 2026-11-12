/// Konfigurasi aplikasi.
class AppConfig {
  AppConfig._();

  static const int pageSize = 20;

  /// true = data contoh, false = pakai backend Docker.
  /// Biarkan true dulu sampai kode pemanggil API siap.
  static const bool demoMode = true;

  /// Windows / Chrome:      http://localhost:3000
  /// Emulator Android:      http://10.0.2.2:3000
  /// HP fisik (satu WiFi):  http://10.80.158.220:3000
  static const String baseUrl = 'http://localhost:3000';
}