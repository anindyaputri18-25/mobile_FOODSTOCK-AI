import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

// ---------------------------------------------------------------------------
// Pengguna: daftar + verifikasi (ADM-05, ADM-06). Pengelolaan lengkap tetap di web.
// ---------------------------------------------------------------------------

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _status = 'pending';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengguna')),
      body: PagedList<AppUser>(
        fetch: (page) => repo.users(page: page, status: _status == 'semua' ? null : _status),
        reloadToken: Object.hash(_status, version),
        emptyTitle: _status == 'pending' ? 'Tidak ada akun menunggu verifikasi' : 'Tidak ada pengguna',
        header: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final s in const [
                ('pending', 'Menunggu'),
                ('aktif', 'Aktif'),
                ('terkunci', 'Terkunci'),
                ('ditolak', 'Ditolak'),
                ('semua', 'Semua'),
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
        ),
        itemBuilder: (context, u) => _UserCard(user: u),
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  const _UserCard({required this.user});
  final AppUser user;

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _busy = false;

  static const _roles = {
    'dinas': 'Petugas Dinas',
    'bulog': 'Petugas Bulog',
    'distributor': 'Distributor',
    'admin': 'Administrator',
  };

  /// Menyetujui akun pending: Admin menetapkan role lebih dulu.
  Future<void> _approve() async {
    final role = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tetapkan role pengguna', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.emeraldDark)),
        children: [
          for (final e in _roles.entries)
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, e.key), child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (role == null || !mounted) return;
    final ok = await confirmAction(
      context,
      title: 'Setujui akun?',
      message: '${widget.user.name} akan diaktifkan sebagai ${_roles[role]}.',
      confirmLabel: 'Setujui',
    );
    if (!ok || !mounted) return;
    await _run(() async {
      final repo = context.read<FoodstockRepository>();
      await repo.updateUser(widget.user.id, {'role': role});
      await repo.verifyUser(widget.user.id, approve: true);
    }, 'Akun disetujui.');
  }

  Future<void> _reject() async {
    final ok = await confirmAction(
      context,
      title: 'Tolak registrasi?',
      message: 'Registrasi ${widget.user.name} akan ditolak dan dicatat di audit log.',
      confirmLabel: 'Tolak',
    );
    if (!ok || !mounted) return;
    await _run(() => context.read<FoodstockRepository>().verifyUser(widget.user.id, approve: false), 'Registrasi ditolak.');
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    final session = context.read<SessionController>();
    try {
      await action();
      if (!mounted) return;
      showSnack(context, success);
      session.bumpData();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.detail, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final me = context.select<SessionController, int?>((s) => s.user?.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  u.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ),
              StatusChip.akun(u.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            u.email,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_roles[u.role] ?? u.role} · ${(u.instansi ?? '').isEmpty ? 'instansi belum diisi' : u.instansi}',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Mendaftar ${Fmt.tanggal(u.createdAt)}',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          if (u.isPending && u.id != me) ...[
            const SizedBox(height: 12),
            if (_busy)
              const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                        foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
                      ),
                      onPressed: _approve,
                      child: const Text('Setujui'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tealGlow,
                        minimumSize: const Size.fromHeight(42),
                        side: const BorderSide(color: AppColors.tealGlow),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                      ),
                      onPressed: _reject,
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aktivitas: audit log ringkas + kesehatan sistem (ADM-07, ADM-08)
// ---------------------------------------------------------------------------

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aktivitas'),
          bottom: TabBar(
            labelColor: isDark ? AppColors.accentMint : Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.tealGlow,
            tabs: const [Tab(text: 'Audit log'), Tab(text: 'Kesehatan sistem')],
          ),
        ),
        body: const TabBarView(children: [_AuditBody(), _HealthBody()]),
      ),
    );
  }
}

class _AuditBody extends StatelessWidget {
  const _AuditBody();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PagedList<AuditLogItem>(
      fetch: (page) => repo.auditLogs(page: page),
      reloadToken: version,
      emptyTitle: 'Belum ada aktivitas tercatat',
      header: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Ringkasan aktivitas terbaru. Laporan audit lengkap dan ekspor tersedia di web.',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      itemBuilder: (context, a) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.action,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${a.actorName}${a.actorRole == null ? '' : ' (${a.actorRole})'} · ${Fmt.waktu(a.createdAt)}',
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

class _HealthBody extends StatelessWidget {
  const _HealthBody();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AsyncView<HealthDetails>(
      load: repo.healthDetails,
      reloadToken: version,
      builder: (context, h) {
        final dbOk = h.database == 'up';
        return [
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (dbOk ? AppColors.tealGlow : AppColors.tealGlow).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    dbOk ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: dbOk ? AppColors.tealGlow : AppColors.tealGlow,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Database',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                        ),
                      ),
                      Text(
                        dbOk ? 'Tersambung' : 'Tidak dapat dijangkau',
                        style: TextStyle(
                          color: dbOk ? AppColors.tealGlow : AppColors.tealGlow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              children: [
                InfoRow('Forecast terakhir', Fmt.waktu(h.lastForecastAt)),
                InfoRow('Catatan stok', Fmt.angka(h.stokCount)),
                InfoRow('Catatan konsumsi', Fmt.angka(h.konsumsiCount)),
                InfoRow('Email terkirim', '${h.emailSent} dari ${h.emailSent + h.emailFailed}'),
                InfoRow('Email gagal', '${h.emailFailed}'),
                InfoRow('Akun menunggu', '${h.usersPending}'),
                InfoRow('Waktu server', Fmt.waktu(h.serverTime)),
              ],
            ),
          ),
          Text(
            'Indikator berasal dari pemeriksaan backend. Layanan lain (antrean, push) belum dimonitor.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ];
      },
    );
  }
}