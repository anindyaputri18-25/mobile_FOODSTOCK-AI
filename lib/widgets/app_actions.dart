import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../core/theme_controller.dart';
import '../screens/notification_screen.dart';

/// Ikon lonceng notifikasi (kanan atas AppBar) dengan lencana jumlah belum dibaca.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;
  int? _loadedVersion;

  Future<void> _load() async {
    try {
      final repo = context.read<FoodstockRepository>();
      final res = await repo.notifications();
      if (!mounted) return;
      setState(() => _unread = res.items.where((n) => !n.isRead).length);
    } catch (_) {
      // Lencana hanya pelengkap; abaikan galat.
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    if (_loadedVersion != version) {
      _loadedVersion = version;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }

    return IconButton(
      tooltip: 'Notifikasi',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
        );
        if (mounted) _load();
      },
      icon: Badge(
        isLabelVisible: _unread > 0,
        backgroundColor: AppColors.accentMint,
        textColor: AppColors.emeraldDark,
        label: Text(_unread > 9 ? '9+' : '$_unread'),
        child: const Icon(Icons.notifications_rounded),
      ),
    );
  }
}

/// Tombol cepat ganti terang/gelap (dipakai di landing page & layar masuk).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Mode terang' : 'Mode gelap',
      onPressed: () => context.read<ThemeController>().toggle(Theme.of(context).brightness),
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: color ?? Colors.white,
      ),
    );
  }
}

/// Kartu pengaturan tampilan (Terang / Gelap / Otomatis) untuk halaman Profil.
class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = context.watch<ThemeController>();
    final accent = isDark ? AppColors.accentMint : AppColors.emeraldDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.emeraldDark).withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: accent),
              const SizedBox(width: 14),
              Text(
                'Tampilan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded, size: 18), label: Text('Terang')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded, size: 18), label: Text('Gelap')),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded, size: 18), label: Text('Otomatis')),
              ],
              selected: {ctrl.mode},
              onSelectionChanged: (s) => ctrl.setMode(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? accent : Colors.transparent,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? (isDark ? AppColors.emeraldDark : Colors.white)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark),
                ),
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
