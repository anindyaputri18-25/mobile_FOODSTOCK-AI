/// Model data sesuai bentuk JSON dari Laravel API (`App\Http\Presenter`).

double? _d(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _i(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

String? _s(dynamic v) => v?.toString();

/// Hasil daftar berpaginasi: `{ data: [...], meta: {page, per_page, total, last_page} }`.
class Paged<T> {
  Paged(this.items, {this.page = 1, this.lastPage = 1, this.total = 0});

  final List<T> items;
  final int page;
  final int lastPage;
  final int total;

  bool get hasMore => page < lastPage;

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) map,
  ) {
    final list = (json['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(map)
        .toList();
    final meta = (json['meta'] as Map?) ?? const {};
    return Paged(
      list,
      page: _i(meta['page'] ?? 1),
      lastPage: _i(meta['last_page'] ?? 1),
      total: _i(meta['total'] ?? list.length),
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.instansi,
    this.wilayahId,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String role; // admin | dinas | bulog | distributor
  final String status; // aktif | pending | ditolak | terkunci | nonaktif
  final String? instansi;
  final int? wilayahId;
  final String? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: _i(j['id']),
    name: _s(j['name']) ?? '',
    email: _s(j['email']) ?? '',
    role: _s(j['role']) ?? '',
    status: _s(j['status']) ?? '',
    instansi: _s(j['instansi']),
    wilayahId: j['wilayah_id'] == null ? null : _i(j['wilayah_id']),
    createdAt: _s(j['created_at']),
  );

  bool get isAdmin => role == 'admin';
  bool get isDinas => role == 'dinas';
  bool get isBulog => role == 'bulog';
  bool get isDistributor => role == 'distributor';
  bool get isActive => status == 'aktif';
  bool get isPending => status == 'pending';

  // Izin mengikuti middleware route di backend (routes/api.php). Backend tetap
  // menjadi penentu akhir; ini hanya untuk menyembunyikan menu/tombol.
  bool get canFollowUp => isAdmin || isDinas || isBulog;
  bool get canInputStok => isAdmin || isDinas || isBulog;
  bool get canUpdateRekomendasi => isAdmin || isDinas || isBulog;
  bool get canSeeRekomendasi => isAdmin || isDinas || isBulog;
  bool get canSeeNotifikasi => isAdmin || isDinas || isBulog;
  bool get canInputDistribusi => isAdmin || isDistributor;
  bool get canSeeWarnings => !isDistributor;

  String get roleLabel => switch (role) {
    'admin' => 'Administrator',
    'dinas' => 'Petugas Dinas Ketahanan Pangan',
    'bulog' => 'Petugas Bulog',
    'distributor' => 'Distributor / Pelaku Usaha Pangan',
    _ => role,
  };
}

class Wilayah {
  Wilayah({required this.id, required this.name, this.province});
  final int id;
  final String name;
  final String? province;
  factory Wilayah.fromJson(Map<String, dynamic> j) => Wilayah(
    id: _i(j['id']),
    name: _s(j['name']) ?? '-',
    province: _s(j['province']),
  );
}

class Komoditas {
  Komoditas({
    required this.id,
    required this.name,
    required this.unit,
    this.safeStock,
  });
  final int id;
  final String name;
  final String unit;
  final double? safeStock;
  factory Komoditas.fromJson(Map<String, dynamic> j) => Komoditas(
    id: _i(j['id']),
    name: _s(j['name']) ?? '-',
    unit: _s(j['unit']) ?? '',
    safeStock: _d(j['safe_stock']),
  );
}

class StokItem {
  StokItem({
    required this.id,
    required this.wilayahId,
    required this.komoditasId,
    required this.quantity,
    required this.recordedAt,
    this.source,
    this.recordedBy,
  });
  final int id;
  final int wilayahId;
  final int komoditasId;
  final double quantity;
  final String recordedAt;
  final String? source;
  final String? recordedBy;

  factory StokItem.fromJson(Map<String, dynamic> j) => StokItem(
    id: _i(j['id']),
    wilayahId: _i(j['wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    quantity: _d(j['quantity']) ?? 0,
    recordedAt: _s(j['recorded_at']) ?? '',
    source: _s(j['source']),
    recordedBy: _s(j['recorded_by']),
  );

  String get sourceLabel => switch (source) {
    'bps_bapanas' => 'BPS/Bapanas',
    'manual' => 'Input manual',
    'simulasi' => 'Simulasi',
    'gudang_bulog' => 'Gudang Bulog',
    _ => source ?? '-',
  };
}

class KonsumsiItem {
  KonsumsiItem({
    required this.id,
    required this.wilayahId,
    required this.komoditasId,
    required this.quantity,
    required this.recordedAt,
    this.source,
  });
  final int id;
  final int wilayahId;
  final int komoditasId;
  final double quantity;
  final String recordedAt;
  final String? source;

  factory KonsumsiItem.fromJson(Map<String, dynamic> j) => KonsumsiItem(
    id: _i(j['id']),
    wilayahId: _i(j['wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    quantity: _d(j['quantity']) ?? 0,
    recordedAt: _s(j['recorded_at']) ?? '',
    source: _s(j['source']),
  );
}

class DistribusiItem {
  DistribusiItem({
    required this.id,
    required this.originId,
    required this.destinationId,
    required this.komoditasId,
    required this.quantity,
    required this.distributedAt,
    required this.status,
    this.recordedBy,
  });
  final int id;
  final int originId;
  final int destinationId;
  final int komoditasId;
  final double quantity;
  final String distributedAt;
  final String status; // rencana | dikirim | selesai
  final String? recordedBy;

  factory DistribusiItem.fromJson(Map<String, dynamic> j) => DistribusiItem(
    id: _i(j['id']),
    originId: _i(j['origin_wilayah_id']),
    destinationId: _i(j['destination_wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    quantity: _d(j['quantity']) ?? 0,
    distributedAt: _s(j['distributed_at']) ?? '',
    status: _s(j['status']) ?? 'rencana',
    recordedBy: _s(j['recorded_by']),
  );

  /// Alur status yang dikenal backend: rencana -> dikirim -> selesai.
  String? get nextStatus => switch (status) {
    'rencana' => 'dikirim',
    'dikirim' => 'selesai',
    _ => null,
  };
}

class ForecastSummary {
  ForecastSummary({
    required this.id,
    required this.wilayahId,
    required this.komoditasId,
    required this.periode,
    required this.predicted,
    required this.stock,
    required this.status,
    this.daysToEvent,
    this.mape,
    this.modelVersion,
    this.createdAt,
  });
  final int id;
  final int wilayahId;
  final int komoditasId;
  final String periode;
  final double? predicted; // prediksi kebutuhan
  final double? stock; // stok yang dibandingkan
  final String status; // aman | shortage | surplus
  final int? daysToEvent;
  final double? mape;
  final String? modelVersion;
  final String? createdAt;

  factory ForecastSummary.fromJson(Map<String, dynamic> j) => ForecastSummary(
    id: _i(j['id']),
    wilayahId: _i(j['wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    periode: _s(j['periode']) ?? '',
    predicted: _d(j['predicted_value']),
    stock: _d(j['stock_value']),
    status: _s(j['status']) ?? 'aman',
    daysToEvent: j['days_to_event'] == null ? null : _i(j['days_to_event']),
    mape: _d(j['mape']),
    modelVersion: _s(j['model_version']),
    createdAt: _s(j['created_at']),
  );
}

class ForecastPoint {
  ForecastPoint({
    required this.periode,
    required this.predicted,
    required this.stock,
    required this.status,
  });
  final String periode;
  final double? predicted;
  final double? stock;
  final String status;
  factory ForecastPoint.fromJson(Map<String, dynamic> j) => ForecastPoint(
    periode: _s(j['periode']) ?? '',
    predicted: _d(j['predicted_value']),
    stock: _d(j['stock_value']),
    status: _s(j['status']) ?? 'aman',
  );
}

class ForecastAccuracy {
  ForecastAccuracy({
    this.modelVersion,
    this.mapeAverage,
    this.lastRunAt,
    this.combinations = 0,
  });
  final String? modelVersion;
  final double? mapeAverage;
  final String? lastRunAt;
  final int combinations;
  factory ForecastAccuracy.fromJson(Map<String, dynamic> j) => ForecastAccuracy(
    modelVersion: _s(j['model_version']),
    mapeAverage: _d(j['mape_average']),
    lastRunAt: _s(j['last_run_at']),
    combinations: _i(j['combinations']),
  );
}

class DashboardSummary {
  DashboardSummary({
    required this.hasForecast,
    this.lastForecastAt,
    this.lastStockUpdate,
    this.aman = 0,
    this.shortage = 0,
    this.surplus = 0,
    this.usesSimulatedStock = false,
  });
  final bool hasForecast;
  final String? lastForecastAt;
  final String? lastStockUpdate;
  final int aman;
  final int shortage;
  final int surplus;
  final bool usesSimulatedStock;

  int get peringatanAktif => shortage + surplus;

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    final c = (j['counts'] as Map?) ?? const {};
    return DashboardSummary(
      hasForecast: j['has_forecast'] == true,
      lastForecastAt: _s(j['last_forecast_at']),
      lastStockUpdate: _s(j['last_stock_update']),
      aman: _i(c['aman']),
      shortage: _i(c['shortage']),
      surplus: _i(c['surplus']),
      usesSimulatedStock: j['uses_simulated_stock'] == true,
    );
  }
}

/// Satu baris "komoditas utama" untuk kartu di Beranda.
class KomoditasUtama {
  KomoditasUtama({
    required this.nama,
    required this.wilayah,
    required this.jumlah,
    required this.satuan,
    required this.tanggal,
  });
  final String nama;
  final String wilayah;
  final double jumlah;
  final String satuan;
  final String tanggal;
}

/// Data yang ditampilkan Beranda: ringkasan forecast + total stok + komoditas utama.
class DashboardData {
  DashboardData({
    required this.summary,
    required this.totalStok,
    required this.totalPeringatan,
    required this.komoditasUtama,
  });
  final DashboardSummary summary;
  final double totalStok;
  final int totalPeringatan;
  final List<KomoditasUtama> komoditasUtama;
}

class WarningItem {
  WarningItem({
    required this.forecastId,
    required this.wilayahId,
    required this.komoditasId,
    required this.periode,
    required this.status,
    required this.message,
    required this.recommendationText,
    this.predicted,
    this.stock,
    this.daysToEvent,
    this.deliveryStatus,
    this.followedUp = false,
    this.followupNote,
    this.followupResult,
    this.followedUpBy,
    this.createdAt,
  });
  final int forecastId;
  final int wilayahId;
  final int komoditasId;
  final String periode;
  final String status; // shortage | surplus
  final String message;
  final String recommendationText;
  final double? predicted;
  final double? stock;
  final int? daysToEvent;
  final String? deliveryStatus; // terkirim | gagal | menunggu
  final bool followedUp;
  final String? followupNote;
  final String? followupResult;
  final String? followedUpBy;
  final String? createdAt;

  factory WarningItem.fromJson(Map<String, dynamic> j) => WarningItem(
    forecastId: _i(j['forecast_id'] ?? j['id']),
    wilayahId: _i(j['wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    periode: _s(j['periode']) ?? '',
    status: _s(j['status']) ?? '',
    message: _s(j['message']) ?? '',
    recommendationText: _s(j['recommendation_text']) ?? '',
    predicted: _d(j['predicted_value']),
    stock: _d(j['stock_value']),
    daysToEvent: j['days_to_event'] == null ? null : _i(j['days_to_event']),
    deliveryStatus: _s(j['delivery_status']),
    followedUp: j['followed_up'] == true,
    followupNote: _s(j['followup_note']),
    followupResult: _s(j['followup_result']),
    followedUpBy: _s(j['followed_up_by']),
    createdAt: _s(j['created_at']),
  );
}

class Recommendation {
  Recommendation({
    required this.id,
    required this.komoditasId,
    required this.sourceName,
    required this.targetName,
    required this.quantity,
    required this.distance,
    required this.status,
    this.forecastId,
    this.createdAt,
  });
  final int id;
  final int? forecastId;
  final int komoditasId;
  final String sourceName;
  final String targetName;
  final double quantity;
  final double? distance;
  final String status; // menunggu | disetujui | eskalasi | selesai
  final String? createdAt;

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    id: _i(j['id']),
    forecastId: j['forecast_id'] == null ? null : _i(j['forecast_id']),
    komoditasId: _i(j['komoditas_id']),
    sourceName: _s((j['source_wilayah'] as Map?)?['name']) ?? '-',
    targetName: _s((j['target_wilayah'] as Map?)?['name']) ?? '-',
    quantity: _d(j['quantity']) ?? 0,
    distance: _d(j['distance']),
    status: _s(j['status']) ?? 'menunggu',
    createdAt: _s(j['created_at']),
  );
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.wilayahId,
    required this.komoditasId,
    required this.forecastStatus,
    required this.channel,
    required this.status,
    this.recipient,
    this.errorMessage,
    this.sentAt,
    this.createdAt,
  });
  final int id;
  final int wilayahId;
  final int komoditasId;
  final String forecastStatus;
  final String channel;
  final String status; // SENT | FAILED | ...
  final String? recipient;
  final String? errorMessage;
  final String? sentAt;
  final String? createdAt;

  /// Judul untuk tampilan: diturunkan dari status forecast pemicu notifikasi.
  String get title => switch (forecastStatus) {
    'shortage' => 'Peringatan potensi kekurangan',
    'surplus' => 'Peringatan potensi surplus',
    _ => 'Notifikasi sistem',
  };

  /// Isi untuk tampilan: kanal dan status pengiriman (plus alasan bila gagal).
  String get body {
    final kanal = channel.isEmpty ? 'Notifikasi' : (channel == 'email' ? 'Email' : channel);
    final st = switch (status.toUpperCase()) {
      'SENT' => 'terkirim',
      'FAILED' => 'gagal terkirim',
      _ => 'menunggu pengiriman',
    };
    final err = (errorMessage == null || errorMessage!.isEmpty) ? '' : ' ($errorMessage)';
    return '$kanal $st$err';
  }

  /// Backend tidak punya status "dibaca"; notifikasi yang berhasil terkirim dianggap sudah tuntas.
  bool get isRead => status.toUpperCase() == 'SENT';

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: _i(j['id']),
    wilayahId: _i(j['wilayah_id']),
    komoditasId: _i(j['komoditas_id']),
    forecastStatus: _s(j['forecast_status']) ?? '',
    channel: _s(j['channel']) ?? '',
    status: _s(j['status']) ?? '',
    recipient: _s(j['recipient']),
    errorMessage: _s(j['error_message']),
    sentAt: _s(j['sent_at']),
    createdAt: _s(j['created_at']),
  );
}

class AuditLogItem {
  AuditLogItem({
    required this.id,
    required this.actorName,
    required this.action,
    this.actorRole,
    this.entity,
    this.createdAt,
  });
  final int id;
  final String actorName;
  final String? actorRole;
  final String action;
  final String? entity;
  final String? createdAt;

  factory AuditLogItem.fromJson(Map<String, dynamic> j) => AuditLogItem(
    id: _i(j['id']),
    actorName: _s(j['actor_name']) ?? 'Sistem',
    actorRole: _s(j['actor_role']),
    action: _s(j['action']) ?? '',
    entity: _s(j['entity']),
    createdAt: _s(j['created_at']),
  );
}

class HealthDetails {
  HealthDetails({
    required this.database,
    this.lastForecastAt,
    this.stokCount = 0,
    this.konsumsiCount = 0,
    this.emailSent = 0,
    this.emailFailed = 0,
    this.usersPending = 0,
    this.serverTime,
  });
  final String database;
  final String? lastForecastAt;
  final int stokCount;
  final int konsumsiCount;
  final int emailSent;
  final int emailFailed;
  final int usersPending;
  final String? serverTime;

  factory HealthDetails.fromJson(Map<String, dynamic> j) {
    final e = (j['email'] as Map?) ?? const {};
    return HealthDetails(
      database: _s(j['database']) ?? 'unknown',
      lastForecastAt: _s(j['last_forecast_at']),
      stokCount: _i(j['stok_count']),
      konsumsiCount: _i(j['konsumsi_count']),
      emailSent: _i(e['sent']),
      emailFailed: _i(e['failed']),
      usersPending: _i(j['users_pending']),
      serverTime: _s(j['server_time']),
    );
  }
}
