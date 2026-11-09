import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models.dart';
import '../core/session.dart';
import '../core/theme.dart';
import 'admin_screens.dart';
import 'dashboard_screen.dart';
import 'distribusi_screens.dart';
import 'monitoring_screens.dart';
import 'profile_screen.dart';
import 'recommendation_screens.dart';
import 'warning_screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionController, AppUser>((s) => s.user!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menentukan daftar tab navigasi sesuai role pengguna
    final tabs = switch (user.role) {
      'admin' => const [
          (DashboardScreen(), 'Beranda', Icons.dashboard_rounded),
          (UsersScreen(), 'Pengguna', Icons.people_rounded),
          (ActivityScreen(), 'Aktivitas', Icons.history_rounded),
          (ProfileScreen(), 'Profil', Icons.person_rounded),
        ],
      'bulog' => const [
          (DashboardScreen(), 'Beranda', Icons.dashboard_rounded),
          (BulogAlertsScreen(), 'Rekomendasi', Icons.swap_horizontal_circle_rounded),
          (DistribusiListScreen(riwayat: false), 'Distribusi', Icons.local_shipping_rounded),
          (ProfileScreen(), 'Profil', Icons.person_rounded),
        ],
      'distributor' => const [
          (DashboardScreen(), 'Beranda', Icons.dashboard_rounded),
          (DistribusiListScreen(riwayat: false), 'Distribusi', Icons.local_shipping_rounded),
          (DistribusiListScreen(riwayat: true), 'Riwayat', Icons.history_rounded),
          (ProfileScreen(), 'Profil', Icons.person_rounded),
        ],
      _ => const [
          (DashboardScreen(), 'Beranda', Icons.dashboard_rounded),
          (MonitoringScreen(), 'Monitoring', Icons.monitor_heart_rounded),
          (WarningsScreen(standalone: true), 'Peringatan', Icons.warning_amber_rounded),
          (RecommendationsScreen(), 'Realokasi', Icons.swap_horizontal_circle_rounded),
          (ProfileScreen(), 'Profil', Icons.person_rounded),
        ],
    };

    if (_index >= tabs.length) {
      _index = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final t in tabs) t.$1],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1.2,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          indicatorColor: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.15),
          elevation: 0,
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: Icon(
                  t.$3,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
                selectedIcon: Icon(
                  t.$3,
                  color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                ),
                label: t.$2,
              ),
          ],
        ),
      ),
    );
  }
}