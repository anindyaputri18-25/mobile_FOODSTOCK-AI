import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'monitoring_screens.dart';
import 'recommendation_screens.dart';
import 'warning_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final session = context.watch<SessionController>();
    final user = session.user!;
    final version = session.dataVersion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.accentMint, AppColors.tealGlow]
                      : [AppColors.emeraldDark, AppColors.emeraldDeep],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_rounded,
                size: 20,
                color: isDark ? AppColors.emeraldDark : Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text('FOODSTOCK AI'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => session.bumpData(),
          ),
        ],
      ),
      body: AsyncView<DashboardData>(
        load: repo.dashboard,
        reloadToken: version,
        builder: (context, data) {
          return [
            // KARTU SAMBUTAN & RINGKASAN UTAMA 3D
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.emeraldDark]
                      : [AppColors.emeraldDark, AppColors.emeraldDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.emeraldDark).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.accentMint : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.roleLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricSubTile(
                          label: 'Wilayah Pangan',
                          value: '${master.wilayah.length} Area',
                          icon: Icons.place_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricSubTile(
                          label: 'Komoditas',
                          value: '${master.komoditas.length} Jenis',
                          icon: Icons.grass_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // STATISTIK UTAMA (METRIC CARDS)
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Total Stok',
                    value: Fmt.angka(data.totalStok),
                    color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    label: 'Peringatan Aktif',
                    value: '${data.totalPeringatan}',
                    color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                    icon: Icons.warning_amber_rounded,
                    alert: data.totalPeringatan > 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BAGIAN NAVIGASI CEPAT (QUICK ACTIONS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Akses Cepat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _QuickActionItem(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Monitoring',
                  onTap: () => pushPage(context, const MonitoringScreen()),
                ),
                _QuickActionItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Peringatan',
                  onTap: () => pushPage(context, const WarningsScreen(standalone: true)),
                ),
                _QuickActionItem(
                  icon: Icons.swap_horizontal_circle_rounded,
                  label: 'Rekomendasi',
                  onTap: () => pushPage(context, const RecommendationsScreen()),
                ),
                _QuickActionItem(
                  icon: Icons.analytics_rounded,
                  label: 'Forecast',
                  onTap: () => pushPage(context, const ForecastListScreen(standalone: true)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // RINGKASAN STOK KOMODITAS UTAMA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stok Komoditas Utama',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
                TextButton(
                  onPressed: () => pushPage(context, const StokListScreen(standalone: true)),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (data.komoditasUtama.isEmpty)
              const StateMessage(
                icon: Icons.inventory_2_outlined,
                title: 'Belum ada data stok utama',
                message: 'Data stok akan muncul setelah disinkronkan dari sistem.',
              )
            else
              for (final k in data.komoditasUtama)
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.grass_rounded,
                          color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              k.nama,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              k.wilayah,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Fmt.jumlah(k.jumlah, k.satuan),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Fmt.tanggal(k.tanggal),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ];
        },
      ),
    );
  }
}

class _MetricSubTile extends StatelessWidget {
  const _MetricSubTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentMint, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}