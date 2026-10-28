import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'stok_form_screen.dart';
import 'warning_screens.dart';

// ---------------------------------------------------------------------------
// Monitoring (tab untuk Dinas & Admin)
// ---------------------------------------------------------------------------

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionController, AppUser>((s) => s.user!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = user.isAdmin
        ? const [('Stok', StokListBody()), ('Forecast', ForecastBody()), ('Peringatan', WarningsBody())]
        : const [('Stok', StokListBody()), ('Konsumsi', KonsumsiListBody()), ('Forecast', ForecastBody())];
    
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoring'),
          bottom: TabBar(
            labelColor: isDark ? AppColors.accentMint : Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.tealGlow,
            tabs: [for (final t in tabs) Tab(text: t.$1)],
          ),
        ),
        body: TabBarView(children: [for (final t in tabs) t.$2]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter wilayah & komoditas
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.master,
    required this.wilayahId,
    required this.komoditasId,
    required this.onChanged,
  });

  final MasterData master;
  final int? wilayahId;
  final int? komoditasId;
  final void Function(int? wilayahId, int? komoditasId) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: IdDropdown(
              label: 'Wilayah',
              allowAll: true,
              value: wilayahId,
              items: {for (final w in master.wilayah) w.id: w.name},
              onChanged: (v) => onChanged(v, komoditasId),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: IdDropdown(
              label: 'Komoditas',
              allowAll: true,
              value: komoditasId,
              items: {for (final k in master.komoditas) k.id: k.name},
              onChanged: (v) => onChanged(wilayahId, v),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stok
// ---------------------------------------------------------------------------

class StokListScreen extends StatelessWidget {
  const StokListScreen({super.key, this.standalone = false});
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(standalone ? 'Monitoring Stok' : 'Stok')),
      body: const StokListBody(),
    );
  }
}

class StokListBody extends StatefulWidget {
  const StokListBody({super.key});

  @override
  State<StokListBody> createState() => _StokListBodyState();
}

class _StokListBodyState extends State<StokListBody> {
  int? _wilayah;
  int? _komoditas;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final session = context.watch<SessionController>();
    final user = session.user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PagedList<StokItem>(
      fetch: (page) => repo.stok(page: page, wilayahId: _wilayah, komoditasId: _komoditas),
      reloadToken: Object.hash(_wilayah, _komoditas, session.dataVersion, master.loaded),
      emptyTitle: 'Belum ada data stok',
      emptyMessage: 'Coba ubah filter wilayah atau komoditas.',
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterBar(
            master: master,
            wilayahId: _wilayah,
            komoditasId: _komoditas,
            onChanged: (w, k) => setState(() {
              _wilayah = w;
              _komoditas = k;
            }),
          ),
          if (user.canInputStok && !user.isBulog)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  side: BorderSide(color: isDark ? AppColors.accentMint : AppColors.emeraldDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () => pushPage(context, const StokFormScreen()),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah catatan stok'),
              ),
            ),
        ],
      ),
      itemBuilder: (context, item) => StokCard(item: item, master: master),
    );
  }
}

class StokCard extends StatelessWidget {
  const StokCard({super.key, required this.item, required this.master});
  final StokItem item;
  final MasterData master;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  master.komoditasName(item.komoditasId),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ),
              Text(
                Fmt.jumlah(item.quantity, master.unitOf(item.komoditasId)),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 15, color: isDark ? AppColors.accentMint : AppColors.emeraldDark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  master.wilayahName(item.wilayahId),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal data ${Fmt.tanggal(item.recordedAt)} · ${item.sourceLabel}'
            '${item.recordedBy == null ? '' : ' · oleh ${item.recordedBy}'}',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Konsumsi
// ---------------------------------------------------------------------------

class KonsumsiListBody extends StatefulWidget {
  const KonsumsiListBody({super.key});

  @override
  State<KonsumsiListBody> createState() => _KonsumsiListBodyState();
}

class _KonsumsiListBodyState extends State<KonsumsiListBody> {
  int? _wilayah;
  int? _komoditas;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PagedList<KonsumsiItem>(
      fetch: (page) => repo.konsumsi(page: page, wilayahId: _wilayah, komoditasId: _komoditas),
      reloadToken: Object.hash(_wilayah, _komoditas, version, master.loaded),
      emptyTitle: 'Belum ada data konsumsi',
      header: _FilterBar(
        master: master,
        wilayahId: _wilayah,
        komoditasId: _komoditas,
        onChanged: (w, k) => setState(() {
          _wilayah = w;
          _komoditas = k;
        }),
      ),
      itemBuilder: (context, k) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    master.komoditasName(k.komoditasId),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                    ),
                  ),
                ),
                Text(
                  Fmt.jumlah(k.quantity, master.unitOf(k.komoditasId)),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              master.wilayahName(k.wilayahId),
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periode ${Fmt.periode(k.recordedAt)}${k.source == null ? '' : ' · ${k.source}'}',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Forecasting
// ---------------------------------------------------------------------------

class ForecastListScreen extends StatelessWidget {
  const ForecastListScreen({super.key, this.standalone = false});
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Forecasting')),
      body: const ForecastBody(),
    );
  }
}

class _ForecastData {
  _ForecastData(this.accuracy, this.items);
  final ForecastAccuracy accuracy;
  final List<ForecastSummary> items;
}

class ForecastBody extends StatefulWidget {
  const ForecastBody({super.key});

  @override
  State<ForecastBody> createState() => _ForecastBodyState();
}

class _ForecastBodyState extends State<ForecastBody> {
  String _status = 'semua';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AsyncView<_ForecastData>(
      load: () async {
        final accF = repo.forecastAccuracy();
        final listF = repo.forecasts();
        return _ForecastData(await accF, await listF);
      },
      reloadToken: version,
      builder: (context, data) {
        final q = _query.trim().toLowerCase();
        final list = data.items.where((f) {
          if (_status != 'semua' && f.status != _status) return false;
          if (q.isEmpty) return true;
          return master.komoditasName(f.komoditasId).toLowerCase().contains(q) ||
              master.wilayahName(f.wilayahId).toLowerCase().contains(q);
        }).toList()
          ..sort((a, b) {
            int rank(String s) => s == 'shortage' ? 0 : (s == 'surplus' ? 1 : 2);
            final r = rank(a.status).compareTo(rank(b.status));
            return r != 0 ? r : (a.daysToEvent ?? 9999).compareTo(b.daysToEvent ?? 9999);
          });

        return [
          const ForecastDisclaimer(),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow('Model', data.accuracy.modelVersion ?? '-'),
                InfoRow('Rata-rata MAPE', Fmt.persen(data.accuracy.mapeAverage)),
                InfoRow('Kombinasi dihitung', '${data.accuracy.combinations}'),
                InfoRow('Dijalankan', Fmt.waktu(data.accuracy.lastRunAt)),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari komoditas atau wilayah',
              prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.accentMint : AppColors.emeraldDark),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final s in const [
                ('semua', 'Semua'),
                ('shortage', 'Kekurangan'),
                ('surplus', 'Surplus'),
                ('aman', 'Aman'),
              ])
                ChoiceChip(
                  label: Text(s.$2),
                  selected: _status == s.$1,
                  selectedColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _status == s.$1
                        ? (isDark ? AppColors.emeraldDark : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark),
                  ),
                  onSelected: (_) => setState(() => _status = s.$1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.items.isEmpty)
            const StateMessage(
              icon: Icons.query_stats_rounded,
              title: 'Forecast belum tersedia',
              message: 'Hasil prediksi muncul setelah proses forecasting dijalankan dari web.',
            )
          else if (list.isEmpty)
            const StateMessage(icon: Icons.search_off_rounded, title: 'Tidak ada hasil yang cocok')
          else
            for (final f in list) _ForecastCard(item: f, master: master),
        ];
      },
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.item, required this.master});
  final ForecastSummary item;
  final MasterData master;

  @override
  Widget build(BuildContext context) {
    final unit = master.unitOf(item.komoditasId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () => pushPage(context, ForecastDetailScreen(item: item)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  master.komoditasName(item.komoditasId),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ),
              StatusChip.forecast(item.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            master.wilayahName(item.wilayahId),
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Periode ${Fmt.periode(item.periode)}'
            '${item.daysToEvent == null ? '' : ' · ${item.daysToEvent} hari lagi'}',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _kv('Prediksi kebutuhan', Fmt.jumlah(item.predicted, unit), isDark)),
              Expanded(child: _kv('Stok', Fmt.jumlah(item.stock, unit), isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : AppColors.tealGlow,
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
            ),
          ),
        ],
      );
}

class ForecastDetailScreen extends StatelessWidget {
  const ForecastDetailScreen({super.key, required this.item});
  final ForecastSummary item;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final unit = master.unitOf(item.komoditasId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Forecasting')),
      body: AsyncView<List<ForecastPoint>>(
        load: () => repo.forecastSeries(item.wilayahId, item.komoditasId),
        builder: (context, points) => [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  master.komoditasName(item.komoditasId),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  master.wilayahName(item.wilayahId),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                StatusChip.forecast(item.status),
                const SizedBox(height: 14),
                InfoRow('Periode utama', Fmt.periode(item.periode)),
                InfoRow('MAPE (historis)', Fmt.persen(item.mape)),
                InfoRow('Model', item.modelVersion ?? '-'),
                InfoRow('Dihitung', Fmt.waktu(item.createdAt)),
              ],
            ),
          ),
          const ForecastDisclaimer(),
          const SectionTitle('Prediksi kebutuhan vs stok'),
          AppCard(child: ForecastBars(points: points, unit: unit)),
          const SectionTitle('Rincian per periode'),
          for (final p in points)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Fmt.periode(p.periode),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                          ),
                        ),
                      ),
                      StatusChip.forecast(p.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InfoRow('Prediksi kebutuhan', Fmt.jumlah(p.predicted, unit)),
                  InfoRow('Stok', Fmt.jumlah(p.stock, unit)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}