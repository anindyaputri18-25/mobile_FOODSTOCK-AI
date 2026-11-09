/// Konfigurasi aplikasi (versi UI-only dengan data contoh).
class AppConfig {
  AppConfig._();

  /// Jumlah item per halaman untuk daftar panjang.
  static const int pageSize = 20;

  /// Penanda bahwa aplikasi memakai data contoh, bukan backend.
  static const bool demoMode = true;
}
