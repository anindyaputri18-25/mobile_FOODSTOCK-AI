import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class WarningsScreen extends StatelessWidget {
  const WarningsScreen({super.key, this.standalone = false});
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Early Warning')),
      body: const WarningsBody(),
    );
  }
}

/// Daftar Early Warning dengan pencarian dan filter status/tindak lanjut.
class WarningsBody extends StatefulWidget {
  const WarningsBody({super.key});

  @override
  State<WarningsBody> createState() => _WarningsBodyState();
}

class _WarningsBodyState extends State<WarningsBody> {
  String _status = 'semua';
  String _tindak = 'semua'; // semua | belum | sudah
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AsyncView<List<WarningItem>>(
      load: repo.warnings,
      reloadToken: version,
      builder: (context, all) {
        final q = _query.trim().toLowerCase();
        final list = all.where((w) {
          if (_status != 'semua' && w.status != _status) return false;
          if (_tindak == 'belum' && w.followedUp) return false;
          if (_tindak == 'sudah' && !w.followedUp) return false;
          if (q.isEmpty) return true;
          return master.komoditasName(w.komoditasId).toLowerCase().contains(q) ||
              master.wilayahName(w.wilayahId).toLowerCase().contains(q);
        }).toList()
          ..sort((a, b) => (a.daysToEvent ?? 9999).compareTo(b.daysToEvent ?? 9999));

        return [
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
            runSpacing: 6,
            children: [
              for (final s in const [('semua', 'Semua'), ('shortage', 'Kekurangan'), ('surplus', 'Surplus')])
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
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final s in const [('semua', 'Semua tindak lanjut'), ('belum', 'Belum ditindaklanjuti'), ('sudah', 'Sudah')])
                FilterChip(
                  label: Text(s.$2),
                  selected: _tindak == s.$1,
                  selectedColor: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.2),
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _tindak == s.$1
                        ? (isDark ? AppColors.accentMint : AppColors.emeraldDark)
                        : (isDark ? Colors.white70 : Colors.grey.shade700),
                  ),
                  onSelected: (_) => setState(() => _tindak = s.$1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (all.isEmpty)
            const StateMessage(
              icon: Icons.verified_outlined,
              title: 'Tidak ada peringatan aktif',
              message: 'Peringatan muncul saat forecasting memprediksi kekurangan atau surplus.',
            )
          else if (list.isEmpty)
            const StateMessage(icon: Icons.search_off_rounded, title: 'Tidak ada hasil yang cocok')
          else
            for (final w in list) WarningCard(item: w, master: master),
        ];
      },
    );
  }
}

class WarningCard extends StatelessWidget {
  const WarningCard({super.key, required this.item, required this.master});
  final WarningItem item;
  final MasterData master;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () => pushPage(context, WarningDetailScreen(item: item)),
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
            item.message,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                item.followedUp ? Icons.task_alt_rounded : Icons.pending_actions_rounded,
                size: 16,
                color: item.followedUp ? AppColors.tealGlow : AppColors.accentMint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.followedUp ? 'Sudah ditindaklanjuti' : 'Belum ditindaklanjuti',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: item.followedUp ? AppColors.tealGlow : (isDark ? AppColors.accentMint : AppColors.emeraldDark),
                  ),
                ),
              ),
              if (item.daysToEvent != null)
                Text(
                  '${item.daysToEvent} hari lagi',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WarningDetailScreen extends StatelessWidget {
  const WarningDetailScreen({super.key, required this.item});
  final WarningItem item;

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterData>();
    final user = context.select<SessionController, AppUser>((s) => s.user!);
    final unit = master.unitOf(item.komoditasId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (deliveryLabel, deliveryColor) = switch (item.deliveryStatus) {
      'terkirim' => ('Notifikasi terkirim', AppColors.tealGlow),
      'gagal' => ('Notifikasi gagal terkirim', AppColors.tealGlow),
      _ => ('Notifikasi menunggu', AppColors.accentMint),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Peringatan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
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
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [StatusChip.forecast(item.status), StatusChip(label: deliveryLabel, color: deliveryColor)],
                ),
                const SizedBox(height: 12),
                Text(
                  item.message,
                  style: TextStyle(
                    height: 1.4,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Data pendukung'),
          AppCard(
            child: Column(
              children: [
                InfoRow('Periode prediksi', Fmt.periode(item.periode)),
                InfoRow('Perkiraan waktu', item.daysToEvent == null ? '-' : '${item.daysToEvent} hari lagi'),
                InfoRow('Prediksi kebutuhan', Fmt.jumlah(item.predicted, unit)),
                InfoRow('Stok', Fmt.jumlah(item.stock, unit)),
                InfoRow('Dibuat', Fmt.waktu(item.createdAt)),
              ],
            ),
          ),
          const ForecastDisclaimer(),
          const SectionTitle('Rekomendasi tindakan'),
          AppCard(
            child: Text(
              item.recommendationText,
              style: TextStyle(
                height: 1.4,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
            ),
          ),
          const SectionTitle('Tindak lanjut'),
          AppCard(
            child: item.followedUp
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.task_alt_rounded, color: AppColors.tealGlow, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Sudah ditindaklanjuti',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InfoRow('Penanggung jawab', item.followedUpBy ?? '-'),
                      InfoRow('Catatan tindakan', (item.followupNote ?? '').isEmpty ? '-' : item.followupNote!),
                      InfoRow('Hasil', (item.followupResult ?? '').isEmpty ? '-' : item.followupResult!),
                    ],
                  )
                : Text(
                    'Belum ada tindak lanjut untuk peringatan ini.',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                  ),
          ),
          if (user.canFollowUp) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
              ),
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(item.followedUp ? 'Perbarui tindak lanjut' : 'Tindak lanjuti'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FollowUpSheet(item: item),
    );
    if (saved == true && context.mounted) Navigator.of(context).pop(true);
  }
}

class _FollowUpSheet extends StatefulWidget {
  const _FollowUpSheet({required this.item});
  final WarningItem item;

  @override
  State<_FollowUpSheet> createState() => _FollowUpSheetState();
}

class _FollowUpSheetState extends State<_FollowUpSheet> {
  late final TextEditingController _note = TextEditingController(text: widget.item.followupNote ?? '');
  late final TextEditingController _result = TextEditingController(text: widget.item.followupResult ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    _result.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_note.text.trim().isEmpty && _result.text.trim().isEmpty && !widget.item.followedUp) {
      setState(() => _error = 'Isi catatan tindakan atau hasil terlebih dahulu.');
      return;
    }
    final ok = await confirmAction(
      context,
      title: 'Simpan tindak lanjut?',
      message: 'Peringatan akan ditandai sudah ditindaklanjuti atas nama Anda dan tercatat di audit log.',
      confirmLabel: 'Simpan',
    );
    if (!ok || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = context.read<FoodstockRepository>();
    final session = context.read<SessionController>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.followUp(widget.item.forecastId, note: _note.text, result: _result.text);
      session.bumpData();
      messenger.showSnackBar(const SnackBar(content: Text('Tindak lanjut tersimpan.')));
      if (mounted) Navigator.of(context).pop(true);
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
              'Tindak lanjut peringatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: 'Catatan tindakan'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _result,
              maxLines: 2,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: 'Hasil (opsional)'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_error!, style: const TextStyle(color: AppColors.tealGlow, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 16),
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