import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';
import 'repository.dart';

export 'api.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Cache master data (wilayah & komoditas) agar daftar menampilkan nama.
class MasterData extends ChangeNotifier {
  MasterData(this._repo);
  final FoodstockRepository _repo;

  List<Wilayah> wilayah = const [];
  List<Komoditas> komoditas = const [];
  bool loaded = false;
  String? error;

  final Map<int, Wilayah> _w = {};
  final Map<int, Komoditas> _k = {};

  Future<void> load() async {
    final results = await Future.wait([_repo.wilayah(), _repo.komoditas()]);
    wilayah = results[0] as List<Wilayah>;
    komoditas = results[1] as List<Komoditas>;
    _w
      ..clear()
      ..addEntries(wilayah.map((e) => MapEntry(e.id, e)));
    _k
      ..clear()
      ..addEntries(komoditas.map((e) => MapEntry(e.id, e)));
    loaded = true;
    error = null;
    notifyListeners();
  }

  void clear() {
    loaded = false;
    notifyListeners();
  }

  String wilayahName(int id) => _w[id]?.name ?? 'Wilayah #$id';
  String komoditasName(int id) => _k[id]?.name ?? 'Komoditas #$id';
  String unitOf(int komoditasId) => _k[komoditasId]?.unit ?? '';
  Komoditas? komoditasById(int id) => _k[id];
}

/// Sesi login ke backend Laravel (token Sanctum). Role diambil dari server.
class SessionController extends ChangeNotifier {
  SessionController({required this.repo, required this.master});

  final FoodstockRepository repo;
  final MasterData master;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? notice;

  /// Landing page tampil lebih dulu sebelum layar masuk.
  bool showLanding = true;
  void enterAuth() {
    showLanding = false;
    notifyListeners();
  }

  void backToLanding() {
    showLanding = true;
    notifyListeners();
  }

  /// Dipakai tab untuk memuat ulang data setelah ada perubahan.
  int dataVersion = 0;
  void bumpData() {
    dataVersion++;
    notifyListeners();
  }

  Future<void> restore() async {
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  AppUser _userFromJson(Map<String, dynamic> u) => AppUser(
        id: u['id'] as int,
        name: u['name'] as String,
        email: u['email'] as String,
        role: u['role'] as String,
        status: (u['status'] ?? 'aktif') as String,
        instansi: u['instansi'] as String?,
        wilayahId: u['wilayah_id'] as int?,
      );

  /// Parameter [role] dipertahankan agar layar login lama tidak error,
  /// tetapi tidak dipakai: role ditentukan oleh server.
  Future<void> login(String email, String password, {String? role}) async {
    final res = await ApiClient.post('/api/v1/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    ApiClient.token = res['token'] as String;
    user = _userFromJson(res['user'] as Map<String, dynamic>);
    notice = null;
    status = AuthStatus.signedIn;
    await master.load();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String instansi,
    required String password,
    required String confirmation,
  }) async {
    // Belum ada endpoint register di backend.
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> refreshUser() async {
    if (ApiClient.token == null) return;
    final res = await ApiClient.get('/api/v1/auth/me');
    user = _userFromJson(res as Map<String, dynamic>);
    notifyListeners();
  }

  void updateUser(AppUser u) {
    user = u;
    notifyListeners();
  }

  Future<void> logout() async {
    ApiClient.token = null;
    user = null;
    status = AuthStatus.signedOut;
    showLanding = true;
    master.clear();
    notifyListeners();
  }
}