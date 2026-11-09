/// Kesalahan yang ditampilkan ke pengguna.
///
/// Versi UI-only: tidak ada pemanggilan jaringan. Kelas ini dipertahankan agar
/// layar tidak perlu diubah saat nanti terhubung ke backend (buat ulang
/// ApiClient dan isi FoodstockRepository dengan pemanggilan API).
class ApiException implements Exception {
  ApiException({this.statusCode, this.code = 'ERROR', required this.message, this.errors = const {}});

  final int? statusCode;
  final String code;
  final String message;
  final Map<String, List<String>> errors;

  bool get isNetwork => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isPending => code == 'ACCOUNT_PENDING';

  String get detail {
    if (errors.isEmpty) return message;
    final lines = errors.values.expand((e) => e).toList();
    return lines.isEmpty ? message : lines.join('\n');
  }

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
