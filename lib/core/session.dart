import 'package:flutter/foundation.dart';

import 'models.dart';
import 'repository.dart';

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

/// Sesi login **contoh** (tanpa server): role dipilih di layar login agar
/// setiap tampilan per-role bisa dicoba.
class SessionController extends ChangeNotifier {
  SessionController({required this.repo, required this.master});

  final FoodstockRepository repo;
  final MasterData master;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? notice;

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

  static const _demo = {
    'dinas': ('Siti Rahma', 'Dinas Ketahanan Pangan', 1),
    'bulog': ('Rina Kartika', 'Perum Bulog', 1),
    'distributor': ('Agus Pratama', 'CV Tani Makmur', null),
    'admin': ('Administrator Utama', 'Administrator Sistem', null),
  };

  Future<void> login(String email, String password, {required String role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final d = _demo[role]!;
    user = AppUser(
      id: 1,
      name: d.$1,
      email: email.trim().toLowerCase(),
      role: role,
      status: 'aktif',
      instansi: d.$2,
      wilayahId: d.$3,
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> refreshUser() async {}

  void updateUser(AppUser u) {
    user = u;
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    status = AuthStatus.signedOut;
    master.clear();
    notifyListeners();
  }
}
