# FoodStock AI Mobile (Flutter) - Prototipe UI

Bagian front end saja. Seluruh data berasal dari **data contoh** di
`lib/core/repository.dart` (tanpa backend/internet; hanya gambar latar login yang
diambil dari internet). Perubahan (tambah stok, ubah status, dll) tersimpan selama
aplikasi terbuka.

## Menjalankan

```bash
flutter pub get
flutter run
```

Di layar login, isi email/kata sandi apa saja (email harus berformat valid), lalu
pilih **Masuk sebagai** Dinas / Bulog / Distributor / Admin untuk mencoba tampilan tiap role.

## Halaman per role

| Role | Tab |
|---|---|
| Dinas | Beranda, Monitoring (stok, konsumsi, forecast), Peringatan, Rekomendasi, Profil |
| Bulog | Beranda, Stok, Input stok, Rekomendasi & Peringatan, Profil |
| Distributor | Beranda, Distribusi, Tambah, Riwayat, Profil |
| Admin | Beranda, Monitoring, Pengguna, Aktivitas, Profil |

## Struktur

- `lib/screens` - layar per fitur
- `lib/widgets/common.dart` - komponen bersama
- `lib/core/models.dart` - bentuk data
- `lib/core/repository.dart` - **satu-satunya titik data**; saat backend siap, isi ulang
  method-nya dengan pemanggilan API (bentuk model sudah mengikuti API Laravel FoodStock AI)
- `lib/core/session.dart` - sesi login contoh
