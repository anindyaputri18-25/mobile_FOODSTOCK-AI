import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'warning_screens.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Realokasi')),
      body: const RecommendationsBody(),
    );
  }
}

/// Bulog: Peringatan + Rekomendasi dalam satu tab (sesuai rancangan navigasi bagian 7.2).
class BulogAlertsScreen extends StatelessWidget {
  const BulogAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rekomendasi & Peringatan'),
          bottom: TabBar(
            labelColor: isDark ? AppColors.accentMint : Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.tealGlow,
            tabs: const [Tab(text: 'Rekomendasi'), Tab(text: 'Peringatan')],
          ),
        ),
        body: const TabBarView(children: [RecommendationsBody(), WarningsBody()]),
      ),
    );
  }
}

class RecommendationsBody extends StatefulWidget {
  const RecommendationsBody({super.key});

  @override
  State<RecommendationsBody> createState() => _RecommendationsBodyState();
}

class _RecommendationsBodyState extends State<RecommendationsBody> {
  String _status = 'semua';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AsyncView<List<Recommendation>>(
      load: repo.recommendations,
      reloadToken: version,
      builder: (context, all) {
        final list = _status == 'semua' ? all : all.where((r) => r.status == _status).toList();
        return [
          Wrap(
            spacing: 8,
            children: [
              for (final s in const [
                ('semua', 'Semua'),
                ('menunggu', 'Menunggu'),
                ('disetujui', 'Disetujui'),
                ('eskalasi', 'Eskalasi'),
                ('selesai', 'Selesai'),
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
          if (all.isEmpty)
            const StateMessage(
              icon: Icons.swap_horiz_rounded,
              title: 'Belum ada rekomendasi',
              message: 'Rekomendasi realokasi dibuat otomatis saat ada wilayah surplus yang dapat menutup kekurangan.',
            )
          else if (list.isEmpty)
            const StateMessage(icon: Icons.search_off_rounded, title: 'Tidak ada rekomendasi dengan status ini')
          else
            for (final r in list) _RecommendationCard(item: r, master: master),
        ];
      },
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  const _RecommendationCard({required this.item, required this.master});
  final Recommendation item;
  final MasterData master;

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  bool _busy = false;

  /// Aksi yang ditawarkan menurut status saat ini. Status valid di backend:
  /// menunggu, disetujui, eskalasi, selesai.
  List<(String status, String label)> _actions(String current) => switch (current) {
        'menunggu' => const [('disetujui', 'Setujui'), ('eskalasi', 'Eskalasi')],
        'disetujui' => const [('selesai', 'Tandai selesai'), ('eskalasi', 'Eskalasi')],
        'eskalasi' => const [('disetujui', 'Setujui')],
        _ => const [],
      };

  Future<void> _change(String status, String label) async {
    if (_busy) return;
    final ok = await confirmAction(
      context,
      title: '$label rekomendasi?',
      message: 'Status rekomendasi akan diubah menjadi "$status" dan dicatat di audit log.',
      confirmLabel: label,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final repo = context.read<FoodstockRepository>();
    final session = context.read<SessionController>();
    try {
      await repo.updateRecommendation(widget.item.id, status);
      if (!mounted) return;
      showSnack(context, 'Status rekomendasi diperbarui.');
      session.bumpData();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.detail, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.item;
    final unit = widget.master.unitOf(r.komoditasId);
    final user = context.select<SessionController, AppUser>((s) => s.user!);
    final actions = user.canUpdateRekomendasi ? _actions(r.status) : const <(String, String)>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.master.komoditasName(r.komoditasId),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ),
              StatusChip.rekomendasi(r.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _place('Asal', r.sourceName, isDark)),
              Padding(
                padding: const EdgeInsets.only(top: 14, left: 6, right: 6),
                child: Icon(Icons.arrow_forward_rounded, color: isDark ? AppColors.accentMint : AppColors.emeraldDark),
              ),
              Expanded(child: _place('Tujuan', r.targetName, isDark)),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow('Jumlah usulan', Fmt.jumlah(r.quantity, unit)),
          InfoRow('Jarak', r.distance == null ? '-' : '${Fmt.angka(r.distance!.roundToDouble())} km'),
          InfoRow('Dibuat', Fmt.waktu(r.createdAt)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_busy)
              const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Wrap(
                spacing: 8,
                children: [
                  for (final a in actions)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: a.$1 == 'eskalasi' ? AppColors.tealGlow : (isDark ? AppColors.accentMint : AppColors.emeraldDark),
                        side: BorderSide(color: a.$1 == 'eskalasi' ? AppColors.tealGlow : (isDark ? AppColors.accentMint : AppColors.emeraldDark)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _change(a.$1, a.$2),
                      child: Text(a.$2),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _place(String k, String v, bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
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