import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.accentMint, AppColors.tealGlow]
                              : [AppColors.emeraldDark, AppColors.emeraldDeep],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InfoRow('Role', user.roleLabel),
                InfoRow('Instansi', (user.instansi ?? '').isEmpty ? '-' : user.instansi!),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 124,
                        child: Text(
                          'Status akun',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      StatusChip.akun(user.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _tile(context, Icons.edit_outlined, 'Ubah nama & instansi', () => _editProfile(context, user), isDark),
          _tile(context, Icons.lock_outline_rounded, 'Ganti kata sandi', () => _changePassword(context), isDark),
          _tile(context, Icons.info_outline_rounded, 'Tentang aplikasi', () {
            showAboutDialog(
              context: context,
              applicationName: 'FoodStock AI Mobile',
              applicationVersion: '1.0.0',
              children: [
                const Text('Monitoring stok pangan, forecasting, Early Warning, dan distribusi.'),
                const SizedBox(height: 8),
                const Text('Mode prototipe UI: data contoh, belum terhubung ke backend.', style: TextStyle(fontSize: 11)),
              ],
            );
          }, isDark),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tealGlow,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.tealGlow, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Keluar dari akun?',
                message: 'Anda perlu masuk kembali untuk mengakses data.',
                confirmLabel: 'Keluar',
              );
              if (ok && context.mounted) await context.read<SessionController>().logout();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap, bool isDark) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white54 : AppColors.neutral,
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, AppUser user) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(user: user),
    );
  }

  Future<void> _changePassword(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});
  final AppUser user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.user.name);
  late final TextEditingController _instansi = TextEditingController(text: widget.user.instansi ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _instansi.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_name.text.trim().length < 3 || _instansi.text.trim().length < 2) {
      setState(() => _error = 'Nama minimal 3 karakter dan instansi minimal 2 karakter.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = context.read<FoodstockRepository>();
    final session = context.read<SessionController>();
    final navigator = Navigator.of(context);
    try {
      final u = await repo.updateProfile(name: _name.text.trim(), instansi: _instansi.text.trim(), current: widget.user);
      session.updateUser(u);
      navigator.pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ubah profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama lengkap')),
            const SizedBox(height: 14),
            TextField(controller: _instansi, decoration: const InputDecoration(labelText: 'Instansi')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.tealGlow, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.emeraldDark : Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_current.text.isEmpty) {
      setState(() => _error = 'Kata sandi saat ini wajib diisi.');
      return;
    }
    if (_next.text.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter.');
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'Konfirmasi kata sandi baru tidak sama.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = context.read<FoodstockRepository>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.changePassword(current: _current.text, next: _next.text, confirmation: _confirm.text);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah.')));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ganti kata sandi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _current, obscureText: true, decoration: const InputDecoration(labelText: 'Kata sandi saat ini')),
            const SizedBox(height: 14),
            TextField(controller: _next, obscureText: true, decoration: const InputDecoration(labelText: 'Kata sandi baru (min. 8 karakter)')),
            const SizedBox(height: 14),
            TextField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Ulangi kata sandi baru')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.tealGlow, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? AppColors.emeraldDark : Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}