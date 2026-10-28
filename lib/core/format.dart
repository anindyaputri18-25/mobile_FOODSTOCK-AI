/// Format tanggal dan angka tanpa paket tambahan (locale Indonesia).
class Fmt {
  Fmt._();

  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _bulanPendek = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// "2026-10-27" atau ISO-8601 -> "27 Okt 2026".
  static String tanggal(String? iso) {
    final d = _parse(iso);
    if (d == null) return '-';
    return '${d.day} ${_bulanPendek[d.month - 1]} ${d.year}';
  }

  /// "2026-10-27" -> "Oktober 2026" (untuk periode bulanan forecast).
  static String periode(String? iso) {
    final d = _parse(iso);
    if (d == null) return '-';
    return '${_bulan[d.month - 1]} ${d.year}';
  }

  /// ISO-8601 -> "27 Okt 2026, 14.05" (waktu setempat perangkat).
  static String waktu(String? iso) {
    final d = _parse(iso, local: true);
    if (d == null) return '-';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_bulanPendek[d.month - 1]} ${d.year}, $h.$m';
  }

  /// Tanggal untuk dikirim ke API: yyyy-MM-dd.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 12345.6 -> "12.345,6" (pemisah ribuan titik, desimal koma, maks 2 digit).
  static String angka(num? v) {
    if (v == null) return '-';
    final neg = v < 0;
    final fixed = v.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    var intPart = parts[0];
    var dec = parts[1].replaceAll(RegExp(r'0+$'), '');
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    final res = dec.isEmpty ? buf.toString() : '${buf.toString()},$dec';
    return neg ? '-$res' : res;
  }

  static String jumlah(num? v, String? unit) => v == null
      ? '-'
      : '${angka(v)}${unit == null || unit.isEmpty ? '' : ' $unit'}';

  static String persen(num? v) => v == null ? '-' : '${angka(v)}%';

  /// Mengurai angka yang diketik pengguna: "1.500,5", "1500,5", "1500.5" -> 1500.5.
  /// Titik tunggal diperlakukan sebagai desimal; negatif ditolak (null).
  static double? parseAngka(String input) {
    var t = input.trim().replaceAll(' ', '');
    if (t.isEmpty) return null;
    if (t.contains(',') && t.contains('.')) {
      t = t.replaceAll('.', '').replaceAll(',', '.');
    } else if (t.contains(',')) {
      t = t.replaceAll(',', '.');
    }
    final v = double.tryParse(t);
    if (v == null || v.isNaN || v.isInfinite || v < 0) return null;
    return v;
  }

  static DateTime? _parse(String? iso, {bool local = false}) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return null;
    return local ? d.toLocal() : d;
  }
}
