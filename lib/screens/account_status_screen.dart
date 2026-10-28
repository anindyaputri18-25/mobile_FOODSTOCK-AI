import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

/// Ditampilkan bila akun sudah punya token tetapi belum berstatus aktif
/// (mis. `pending`: menunggu verifikasi Administrator).
class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  bool _checking = false;

  Future<void> _refresh() async {
    setState(() => _checking = true);
    try {
      await context.read<SessionController>().refreshUser();
      if (!mounted) return;
      final active = context.read<SessionController>().user?.isActive ?? false;
      if (!active) showSnack(context, 'Status akun belum berubah.');
    } catch (e) {
      if (mounted) showSnack(context, errorText(e), error: true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (icon, title, message) = switch (user.status) {
      'pending' => (
          Icons.hourglass_top_rounded,
          'Menunggu verifikasi',
          'Akun Anda sudah terdaftar dan sedang menunggu persetujuan Administrator. '
              'Role Anda akan ditetapkan saat akun diverifikasi.',
        ),
      'ditolak' => (
          Icons.block_rounded,
          'Registrasi ditolak',
          'Registrasi akun Anda ditolak. Hubungi Administrator untuk informasi lebih lanjut.',
        ),
      'terkunci' => (
          Icons.lock_rounded,
          'Akun terkunci',
          'Akun terkunci. Hubungi Administrator untuk membukanya.',
        ),
      _ => (
          Icons.person_off_rounded,
          'Akun tidak aktif',
          'Akun Anda tidak aktif. Hubungi Administrator.',
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('FOODSTOCK AI')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.15),
                          AppColors.tealGlow.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatusChip.akun(user.status),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _checking ? null : _refresh,
                    icon: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: const Text('Periksa status akun'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<SessionController>().logout(),
                    child: Text(
                      'Keluar',
                      style: TextStyle(
                        color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}