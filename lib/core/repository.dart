import 'config.dart';
import 'models.dart';

/// Sumber data **contoh** (in-memory) untuk prototipe UI.
///
/// Nama method dan bentuk model sengaja sama dengan yang dibutuhkan layar,
/// sehingga saat backend siap cukup isi ulang class ini dengan pemanggilan
/// API tanpa mengubah layar. Perubahan (tambah stok, ubah status, dll) hanya
/// tersimpan selama aplikasi terbuka.
class FoodstockRepository {
  FoodstockRepository() {
    _seed();
  }

  static const _delay = Duration(milliseconds: 350);
  Future<T> _wait<T>(T v) async {
    await Future<void>.delayed(_delay);
    return v;
  }

  Paged<T> _page<T>(List<T> all, int page, int perPage) {
    final last = all.isEmpty ? 1 : ((all.length + perPage - 1) ~/ perPage);
    final start = (page - 1) * perPage;
    final items = start >= all.length ? <T>[] : all.sublist(start, (start + perPage).clamp(0, all.length));
    return Paged(items, page: page, lastPage: last, total: all.length);
  }

  // ---------------- data contoh ----------------
  final List<Wilayah> _wilayah = [
    Wilayah(id: 1, name: 'Jawa Timur', province: 'Jawa Timur'),
    Wilayah(id: 2, name: 'Jawa Tengah', province: 'Jawa Tengah'),
    Wilayah(id: 3, name: 'Jawa Barat', province: 'Jawa Barat'),
    Wilayah(id: 4, name: 'DI Yogyakarta', province: 'DI Yogyakarta'),
    Wilayah(id: 5, name: 'Bali', province: 'Bali'),
    Wilayah(id: 6, name: 'Banten', province: 'Banten'),
  ];
  final List<Komoditas> _komoditas = [
    Komoditas(id: 1, name: 'Beras Medium', unit: 'ton', safeStock: 500),
    Komoditas(id: 2, name: 'Cabai Rawit Merah', unit: 'ton', safeStock: 20),
    Komoditas(id: 3, name: 'Bawang Merah', unit: 'ton', safeStock: 40),
    Komoditas(id: 4, name: 'Minyak Goreng', unit: 'kg', safeStock: 8000),
  ];

  final List<StokItem> _stok = [];
  final List<KonsumsiItem> _konsumsi = [];
  final List<DistribusiItem> _distribusi = [];
  final List<ForecastSummary> _forecasts = [];
  final Map<int, List<ForecastPoint>> _series = {};
  final List<WarningItem> _warnings = [];
  final List<Recommendation> _recs = [];
  final List<NotificationItem> _notifs = [];
  final List<AppUser> _users = [];
  final List<AuditLogItem> _audit = [];
  int _nextId = 1000;

  static const _base = {1: 900.0, 2: 30.0, 3: 60.0, 4: 12000.0};
  static const _nama = ['Rina Kartika', 'Budi Santoso', 'Dewi Lestari', 'Agus Pratama'];
  static const _sumber = ['gudang_bulog', 'manual', 'bps_bapanas', 'simulasi'];

  String _iso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _seed() {
    final today = DateTime(2026, 10, 27);

    // Stok: 36 catatan, terbaru dulu.
    for (var i = 0; i < 36; i++) {
      final w = (i % 6) + 1;
      final k = (i % 4) + 1;
      _stok.add(StokItem(
        id: i + 1,
        wilayahId: w,
        komoditasId: k,
        quantity: (_base[k]! * (0.55 + (i % 7) * 0.12)).roundToDouble(),
        recordedAt: _iso(today.subtract(Duration(days: i * 3))),
        source: _sumber[i % 4],
        recordedBy: _nama[i % 4],
      ));
    }

    // Konsumsi bulanan.
    for (var i = 0; i < 24; i++) {
      final w = (i % 6) + 1;
      final k = (i % 4) + 1;
      _konsumsi.add(KonsumsiItem(
        id: i + 1,
        wilayahId: w,
        komoditasId: k,
        quantity: (_base[k]! * (0.6 + 0.05 * w)).roundToDouble(),
        recordedAt: _iso(DateTime(2026, 10 - (i ~/ 6), 1)),
        source: 'bps_bapanas',
      ));
    }

    // Distribusi.
    const st = ['rencana', 'dikirim', 'selesai', 'selesai', 'dikirim', 'rencana', 'selesai', 'selesai'];
    for (var i = 0; i < 8; i++) {
      _distribusi.add(DistribusiItem(
        id: i + 1,
        originId: (i % 6) + 1,
        destinationId: ((i + 2) % 6) + 1,
        komoditasId: (i % 4) + 1,
        quantity: (_base[(i % 4) + 1]! * 0.12).roundToDouble(),
        distributedAt: _iso(today.subtract(Duration(days: i * 4))),
        status: st[i],
        recordedBy: 'Agus Pratama',
      ));
    }

    // Forecast: 6 wilayah x 4 komoditas, 3 bulan ke depan.
    var fid = 1;
    for (var w = 1; w <= 6; w++) {
      for (var k = 1; k <= 4; k++) {
        final pred = _base[k]! * (0.6 + 0.1 * w);
        final pattern = (w + k) % 5;
        final stock = pattern == 0 ? pred * 0.6 : (pattern == 1 ? pred * 1.8 : pred * 1.15);
        final points = <ForecastPoint>[];
        for (var m = 0; m < 3; m++) {
          final p = pred * (1 + 0.04 * m);
          final s = stock * (1 - 0.08 * m);
          final status = s < p ? 'shortage' : (s > p * 1.5 ? 'surplus' : 'aman');
          points.add(ForecastPoint(
            periode: _iso(DateTime(2026, 11 + m, 1)),
            predicted: p.roundToDouble(),
            stock: s.roundToDouble(),
            status: status,
          ));
        }
        final first = points.first;
        final days = DateTime.parse(first.periode).difference(today).inDays;
        _forecasts.add(ForecastSummary(
          id: fid,
          wilayahId: w,
          komoditasId: k,
          periode: first.periode,
          predicted: first.predicted,
          stock: first.stock,
          status: first.status,
          daysToEvent: first.status == 'aman' ? null : days,
          mape: 6 + ((w * k) % 9) + 0.4,
          modelVersion: 'holt-winters-additive-v1',
          createdAt: '2026-10-26T08:00:00Z',
        ));
        _series[w * 100 + k] = points;
        fid++;
      }
    }

    // Peringatan dari forecast non-aman.
    for (final f in _forecasts.where((f) => f.status != 'aman')) {
      final kn = _komoditas.firstWhere((e) => e.id == f.komoditasId).name;
      final wn = _wilayah.firstWhere((e) => e.id == f.wilayahId).name;
      final kind = f.status == 'shortage' ? 'kekurangan (shortage)' : 'kelebihan (surplus)';
      _warnings.add(WarningItem(
        forecastId: f.id,
        wilayahId: f.wilayahId,
        komoditasId: f.komoditasId,
        periode: f.periode,
        status: f.status,
        message: 'Potensi $kind $kn di $wn pada November 2026.',
        recommendationText: f.status == 'shortage'
            ? 'Koordinasikan pengadaan tambahan dari wilayah surplus terdekat.'
            : 'Pertimbangkan realokasi surplus ke wilayah dengan proyeksi kekurangan.',
        predicted: f.predicted,
        stock: f.stock,
        daysToEvent: f.daysToEvent,
        deliveryStatus: f.id % 3 == 0 ? 'gagal' : 'terkirim',
        followedUp: f.id % 4 == 0,
        followupNote: f.id % 4 == 0 ? 'Koordinasi dengan gudang wilayah terdekat.' : null,
        followedUpBy: f.id % 4 == 0 ? 'Siti Rahma' : null,
        createdAt: f.createdAt,
      ));
      _notifs.add(NotificationItem(
        id: f.id,
        wilayahId: f.wilayahId,
        komoditasId: f.komoditasId,
        forecastStatus: f.status,
        channel: 'email',
        status: f.id % 3 == 0 ? 'FAILED' : 'SENT',
        recipient: 'petugas@foodstock.id',
        errorMessage: f.id % 3 == 0 ? 'Server email tidak merespons' : null,
        sentAt: '2026-10-26T08:05:00Z',
        createdAt: '2026-10-26T08:05:00Z',
      ));
    }

    // Rekomendasi realokasi.
    const rs = ['menunggu', 'disetujui', 'eskalasi', 'selesai', 'menunggu'];
    final shortages = _forecasts.where((f) => f.status == 'shortage').toList();
    for (var i = 0; i < shortages.length && i < 5; i++) {
      final f = shortages[i];
      final src = _wilayah[(f.wilayahId + 1) % 6];
      final tgt = _wilayah.firstWhere((e) => e.id == f.wilayahId);
      _recs.add(Recommendation(
        id: i + 1,
        forecastId: f.id,
        komoditasId: f.komoditasId,
        sourceName: src.name,
        targetName: tgt.name,
        quantity: ((f.predicted ?? 100) * 0.3).roundToDouble(),
        distance: 120.0 + i * 85,
        status: rs[i % 5],
        createdAt: '2026-10-26T08:10:00Z',
      ));
    }

    // Pengguna & audit log.
    _users.addAll([
      AppUser(id: 1, name: 'Administrator Utama', email: 'admin@foodstock.id', role: 'admin', status: 'aktif', instansi: 'Administrator Sistem', createdAt: '2026-08-01T00:00:00Z'),
      AppUser(id: 2, name: 'Siti Rahma', email: 'siti@dinas.go.id', role: 'dinas', status: 'aktif', instansi: 'Dinas Ketahanan Pangan', createdAt: '2026-08-05T00:00:00Z'),
      AppUser(id: 3, name: 'Rina Kartika', email: 'rina@bulog.co.id', role: 'bulog', status: 'aktif', instansi: 'Perum Bulog', createdAt: '2026-08-07T00:00:00Z'),
      AppUser(id: 4, name: 'Agus Pratama', email: 'agus@distribusi.id', role: 'distributor', status: 'aktif', instansi: 'CV Tani Makmur', createdAt: '2026-08-10T00:00:00Z'),
      AppUser(id: 5, name: 'Dewi Lestari', email: 'dewi@mitra.id', role: 'distributor', status: 'pending', instansi: 'UD Sumber Pangan', createdAt: '2026-10-25T00:00:00Z'),
      AppUser(id: 6, name: 'Hendra Wijaya', email: 'hendra@pangan.id', role: 'distributor', status: 'pending', instansi: 'PT Nusantara Pangan', createdAt: '2026-10-26T00:00:00Z'),
      AppUser(id: 7, name: 'Maya Putri', email: 'maya@lama.id', role: 'bulog', status: 'terkunci', instansi: 'Perum Bulog', createdAt: '2026-08-12T00:00:00Z'),
    ]);
    const acts = [
      'Login ke sistem',
      'Menjalankan forecast',
      'Mencatat tindak lanjut peringatan',
      'Menyetujui registrasi dewi@mitra.id',
      'Mengubah data stok',
      'Rekomendasi realokasi #1: menunggu → disetujui',
    ];
    for (var i = 0; i < 18; i++) {
      _audit.add(AuditLogItem(
        id: i + 1,
        actorName: _users[i % 4].name,
        actorRole: _users[i % 4].role,
        action: acts[i % acts.length],
        entity: 'sistem',
        createdAt: '2026-10-${(27 - i ~/ 3).toString().padLeft(2, '0')}T${(8 + i % 9).toString().padLeft(2, '0')}:15:00Z',
      ));
    }
  }

  // ---------------- profil ----------------
  Future<AppUser> updateProfile({required String name, required String instansi, required AppUser current}) =>
      _wait(AppUser(
        id: current.id,
        name: name,
        email: current.email,
        role: current.role,
        status: current.status,
        instansi: instansi,
        wilayahId: current.wilayahId,
        createdAt: current.createdAt,
      ));

  Future<void> changePassword({required String current, required String next, required String confirmation}) =>
      _wait(null);

  // ---------------- master ----------------
  Future<List<Wilayah>> wilayah() => _wait(List.of(_wilayah));
  Future<List<Komoditas>> komoditas() => _wait(List.of(_komoditas));

  // ---------------- dashboard & forecast ----------------
  Future<DashboardData> dashboard() {
    int c(String s) => _forecasts.where((f) => f.status == s).length;
    final summary = DashboardSummary(
      hasForecast: true,
      lastForecastAt: '2026-10-26T08:00:00Z',
      lastStockUpdate: _stok.first.recordedAt,
      aman: c('aman'),
      shortage: c('shortage'),
      surplus: c('surplus'),
      usesSimulatedStock: true,
    );

    final namaWilayah = {for (final w in _wilayah) w.id: w.name};
    final infoKomoditas = {for (final k in _komoditas) k.id: k};
    final terbaru = List.of(_stok)..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    // Stok terbaru untuk tiap kombinasi wilayah x komoditas.
    final perKombinasi = <String, StokItem>{};
    for (final s in terbaru) {
      perKombinasi.putIfAbsent('${s.wilayahId}-${s.komoditasId}', () => s);
    }
    final totalStok = perKombinasi.values.fold<double>(0, (a, s) => a + s.quantity);

    // Komoditas utama: stok terbaru per komoditas, maksimal 5.
    final perKomoditas = <int, StokItem>{};
    for (final s in terbaru) {
      perKomoditas.putIfAbsent(s.komoditasId, () => s);
    }
    final utama = perKomoditas.values.take(5).map((s) {
      final k = infoKomoditas[s.komoditasId];
      return KomoditasUtama(
        nama: k?.name ?? 'Komoditas #${s.komoditasId}',
        wilayah: namaWilayah[s.wilayahId] ?? 'Wilayah #${s.wilayahId}',
        jumlah: s.quantity,
        satuan: k?.unit ?? '',
        tanggal: s.recordedAt,
      );
    }).toList();

    return _wait(DashboardData(
      summary: summary,
      totalStok: totalStok,
      totalPeringatan: summary.peringatanAktif,
      komoditasUtama: utama,
    ));
  }

  Future<List<ForecastSummary>> forecasts() => _wait(List.of(_forecasts));

  Future<List<ForecastPoint>> forecastSeries(int wilayahId, int komoditasId) =>
      _wait(List.of(_series[wilayahId * 100 + komoditasId] ?? const []));

  Future<ForecastAccuracy> forecastAccuracy() => _wait(ForecastAccuracy(
        modelVersion: 'holt-winters-additive-v1',
        mapeAverage: 9.8,
        lastRunAt: '2026-10-26T08:00:00Z',
        combinations: _forecasts.length,
      ));

  // ---------------- peringatan ----------------
  Future<List<WarningItem>> warnings() => _wait(List.of(_warnings));

  Future<void> followUp(int forecastId, {String? note, String? result}) async {
    final i = _warnings.indexWhere((w) => w.forecastId == forecastId);
    if (i >= 0) {
      final w = _warnings[i];
      _warnings[i] = WarningItem(
        forecastId: w.forecastId,
        wilayahId: w.wilayahId,
        komoditasId: w.komoditasId,
        periode: w.periode,
        status: w.status,
        message: w.message,
        recommendationText: w.recommendationText,
        predicted: w.predicted,
        stock: w.stock,
        daysToEvent: w.daysToEvent,
        deliveryStatus: w.deliveryStatus,
        followedUp: true,
        followupNote: (note ?? '').trim().isEmpty ? w.followupNote : note!.trim(),
        followupResult: (result ?? '').trim().isEmpty ? w.followupResult : result!.trim(),
        followedUpBy: 'Anda (contoh)',
        createdAt: w.createdAt,
      );
    }
    await _wait(null);
  }

  // ---------------- rekomendasi & notifikasi ----------------
  Future<List<Recommendation>> recommendations() => _wait(List.of(_recs));

  Future<Recommendation> updateRecommendation(int id, String status) async {
    final i = _recs.indexWhere((r) => r.id == id);
    final r = _recs[i];
    _recs[i] = Recommendation(
      id: r.id,
      forecastId: r.forecastId,
      komoditasId: r.komoditasId,
      sourceName: r.sourceName,
      targetName: r.targetName,
      quantity: r.quantity,
      distance: r.distance,
      status: status,
      createdAt: r.createdAt,
    );
    return _wait(_recs[i]);
  }

  Future<Paged<NotificationItem>> notifications({int page = 1}) =>
      _wait(_page(_notifs, page, AppConfig.pageSize));

  // ---------------- stok & konsumsi ----------------
  Future<Paged<StokItem>> stok({int page = 1, int? wilayahId, int? komoditasId}) {
    final list = _stok
        .where((s) => (wilayahId == null || s.wilayahId == wilayahId) && (komoditasId == null || s.komoditasId == komoditasId))
        .toList();
    return _wait(_page(list, page, AppConfig.pageSize));
  }

  Future<StokItem> createStok({
    required int wilayahId,
    required int komoditasId,
    required double quantity,
    required DateTime recordedAt,
    String recordedBy = 'Anda (contoh)',
  }) async {
    final s = StokItem(
      id: _nextId++,
      wilayahId: wilayahId,
      komoditasId: komoditasId,
      quantity: quantity,
      recordedAt: _iso(recordedAt),
      source: 'manual',
      recordedBy: recordedBy,
    );
    _stok.insert(0, s);
    return _wait(s);
  }

  Future<Paged<KonsumsiItem>> konsumsi({int page = 1, int? wilayahId, int? komoditasId}) {
    final list = _konsumsi
        .where((s) => (wilayahId == null || s.wilayahId == wilayahId) && (komoditasId == null || s.komoditasId == komoditasId))
        .toList();
    return _wait(_page(list, page, AppConfig.pageSize));
  }

  // ---------------- distribusi ----------------
  Future<Paged<DistribusiItem>> distribusi({int page = 1, int perPage = AppConfig.pageSize}) =>
      _wait(_page(_distribusi, page, perPage));

  Future<DistribusiItem> createDistribusi({
    required int originId,
    required int destinationId,
    required int komoditasId,
    required double quantity,
    required DateTime date,
  }) async {
    final d = DistribusiItem(
      id: _nextId++,
      originId: originId,
      destinationId: destinationId,
      komoditasId: komoditasId,
      quantity: quantity,
      distributedAt: _iso(date),
      status: 'rencana',
      recordedBy: 'Anda (contoh)',
    );
    _distribusi.insert(0, d);
    return _wait(d);
  }

  Future<DistribusiItem> updateDistribusiStatus(int id, String status) async {
    final i = _distribusi.indexWhere((d) => d.id == id);
    final d = _distribusi[i];
    _distribusi[i] = DistribusiItem(
      id: d.id,
      originId: d.originId,
      destinationId: d.destinationId,
      komoditasId: d.komoditasId,
      quantity: d.quantity,
      distributedAt: d.distributedAt,
      status: status,
      recordedBy: d.recordedBy,
    );
    return _wait(_distribusi[i]);
  }

  // ---------------- admin ----------------
  Future<Paged<AppUser>> users({int page = 1, String? status}) {
    final list = _users.where((u) => status == null || u.status == status).toList();
    return _wait(_page(list, page, AppConfig.pageSize));
  }

  Future<AppUser> updateUser(int id, Map<String, dynamic> body) async {
    final i = _users.indexWhere((u) => u.id == id);
    final u = _users[i];
    _users[i] = AppUser(
      id: u.id,
      name: u.name,
      email: u.email,
      role: (body['role'] as String?) ?? u.role,
      status: (body['status'] as String?) ?? u.status,
      instansi: u.instansi,
      wilayahId: u.wilayahId,
      createdAt: u.createdAt,
    );
    return _wait(_users[i]);
  }

  Future<AppUser> verifyUser(int id, {required bool approve}) =>
      updateUser(id, {'status': approve ? 'aktif' : 'ditolak'});

  Future<Paged<AuditLogItem>> auditLogs({int page = 1}) =>
      _wait(_page(_audit, page, AppConfig.pageSize));

  Future<HealthDetails> healthDetails() => _wait(HealthDetails(
        database: 'up',
        lastForecastAt: '2026-10-26T08:00:00Z',
        stokCount: _stok.length,
        konsumsiCount: _konsumsi.length,
        emailSent: _notifs.where((n) => n.status == 'SENT').length,
        emailFailed: _notifs.where((n) => n.status == 'FAILED').length,
        usersPending: _users.where((u) => u.status == 'pending').length,
        serverTime: '2026-10-27T12:00:00Z',
      ));
}
