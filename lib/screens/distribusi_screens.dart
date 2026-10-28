import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

String _statusAksi(String next) => next == 'dikirim' ? 'Tandai dikirim' : 'Tandai selesai';

/// Mengubah status distribusi mengikuti alur backend: rencana -> dikirim -> selesai.
/// Mengembalikan true bila berhasil.
Future<bool> changeDistribusiStatus(BuildContext context, DistribusiItem item) async {
  final next = item.nextStatus;
  if (next == null) return false;
  final master = context.read<MasterData>();
  final ok = await confirmAction(
    context,
    title: '${_statusAksi(next)}?',
    message: '${master.komoditasName(item.komoditasId)}: ${master.wilayahName(item.originId)} → '
        '${master.wilayahName(item.destinationId)}\nStatus akan berubah menjadi "$next".',
    confirmLabel: 'Ya, ubah',
  );
  if (!ok || !context.mounted) return false;
  final repo = context.read<FoodstockRepository>();
  final session = context.read<SessionController>();
  try {
    await repo.updateDistribusiStatus(item.id, next);
    session.bumpData();
    if (context.mounted) showSnack(context, 'Status distribusi diperbarui.');
    return true;
  } on ApiException catch (e) {
    if (context.mounted) showSnack(context, e.detail, error: true);
    return false;
  }
}

// ---------------------------------------------------------------------------
// Daftar: aktif (rencana/dikirim) dan riwayat (selesai)
// ---------------------------------------------------------------------------

class DistribusiListScreen extends StatefulWidget {
  const DistribusiListScreen({super.key, required this.riwayat});
  final bool riwayat;

  @override
  State<DistribusiListScreen> createState() => _DistribusiListScreenState();
}

class _DistribusiListScreenState extends State<DistribusiListScreen> {
  String _status = 'semua';
  int? _komoditas;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final master = context.watch<MasterData>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool where(DistribusiItem d) {
      if (widget.riwayat) {
        if (d.status != 'selesai') return false;
      } else {
        if (d.status == 'selesai') return false;
        if (_status != 'semua' && d.status != _status) return false;
      }
      if (_komoditas != null && d.komoditasId != _komoditas) return false;
      return true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.riwayat ? 'Riwayat Distribusi' : 'Distribusi')),
      body: PagedList<DistribusiItem>(
        fetch: (page) => repo.distribusi(page: page),
        reloadToken: version,
        where: where,
        emptyTitle: widget.riwayat ? 'Belum ada riwayat' : 'Tidak ada distribusi aktif',
        emptyMessage: widget.riwayat
            ? 'Distribusi yang berstatus selesai tampil di sini.'
            : 'Catat distribusi baru dari menu Tambah.',
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.riwayat)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final s in const [('semua', 'Semua'), ('rencana', 'Rencana'), ('dikirim', 'Dikirim')])
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IdDropdown(
                label: 'Komoditas',
                allowAll: true,
                value: _komoditas,
                items: {for (final k in master.komoditas) k.id: k.name},
                onChanged: (v) => setState(() => _komoditas = v),
              ),
            ),
          ],
        ),
        itemBuilder: (context, d) => DistribusiCard(item: d, master: master),
      ),
    );
  }
}

class DistribusiCard extends StatelessWidget {
  const DistribusiCard({super.key, required this.item, required this.master});
  final DistribusiItem item;
  final MasterData master;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () => pushPage(context, DistribusiDetailScreen(item: item)),
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
              StatusChip.distribusi(item.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${master.wilayahName(item.originId)} → ${master.wilayahName(item.destinationId)}',
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
            '${Fmt.jumlah(item.quantity, master.unitOf(item.komoditasId))} · ${Fmt.tanggal(item.distributedAt)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail + pembaruan status
// ---------------------------------------------------------------------------

class DistribusiDetailScreen extends StatefulWidget {
  const DistribusiDetailScreen({super.key, required this.item});
  final DistribusiItem item;

  @override
  State<DistribusiDetailScreen> createState() => _DistribusiDetailScreenState();
}

class _DistribusiDetailScreenState extends State<DistribusiDetailScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final master = context.watch<MasterData>();
    final user = context.select<SessionController, AppUser>((s) => s.user!);
    final next = item.nextStatus;
    final steps = const ['rencana', 'dikirim', 'selesai'];
    final current = steps.indexOf(item.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Distribusi')),
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
                const SizedBox(height: 8),
                StatusChip.distribusi(item.status),
                const SizedBox(height: 14),
                InfoRow('Jumlah', Fmt.jumlah(item.quantity, master.unitOf(item.komoditasId))),
                InfoRow('Wilayah asal', master.wilayahName(item.originId)),
                InfoRow('Wilayah tujuan', master.wilayahName(item.destinationId)),
                InfoRow('Tanggal distribusi', Fmt.tanggal(item.distributedAt)),
                InfoRow('Dicatat oleh', item.recordedBy ?? '-'),
              ],
            ),
          ),
          const SectionTitle('Alur status'),
          AppCard(
            child: Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          i <= current ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: i <= current ? AppColors.tealGlow : AppColors.tealGlow,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i][0].toUpperCase() + steps[i].substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == current ? FontWeight.w900 : FontWeight.w500,
                            color: i == current
                                ? (isDark ? AppColors.accentMint : AppColors.emeraldDark)
                                : (isDark ? Colors.white54 : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (user.canInputDistribusi && next != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
              ),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      final navigator = Navigator.of(context);
                      final done = await changeDistribusiStatus(context, item);
                      if (!mounted) return;
                      setState(() => _busy = false);
                      if (done) navigator.pop(true);
                    },
              icon: const Icon(Icons.local_shipping_outlined),
              label: Text(_statusAksi(next)),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form distribusi baru
// ---------------------------------------------------------------------------

class DistribusiFormScreen extends StatefulWidget {
  const DistribusiFormScreen({super.key});

  @override
  State<DistribusiFormScreen> createState() => _DistribusiFormScreenState();
}

class _DistribusiFormScreenState extends State<DistribusiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  int? _origin;
  int? _destination;
  int? _komoditas;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Tanggal distribusi',
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit(MasterData master) async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final qty = Fmt.parseAngka(_qty.text)!;
    final unit = master.unitOf(_komoditas!);

    final ok = await confirmAction(
      context,
      title: 'Simpan distribusi?',
      message: '${master.komoditasName(_komoditas!)}\n'
          '${master.wilayahName(_origin!)} → ${master.wilayahName(_destination!)}\n'
          'Jumlah: ${Fmt.jumlah(qty, unit)}\n'
          'Tanggal: ${Fmt.tanggal(Fmt.apiDate(_date))}\n'
          'Status awal: Rencana',
      confirmLabel: 'Simpan',
    );
    if (!ok || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<FoodstockRepository>();
    final session = context.read<SessionController>();
    final navigator = Navigator.of(context);
    try {
      await repo.createDistribusi(
        originId: _origin!,
        destinationId: _destination!,
        komoditasId: _komoditas!,
        quantity: qty,
        date: _date,
      );
      session.bumpData();
      if (!mounted) return;
      showSnack(context, 'Distribusi tersimpan dengan status Rencana.');
      if (navigator.canPop()) {
        navigator.pop(true);
      } else {
        _qty.clear();
        setState(() {
          _komoditas = null;
          _destination = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = context.watch<MasterData>();
    final unit = _komoditas == null ? '' : master.unitOf(_komoditas!);
    final wilayahItems = {for (final w in master.wilayah) w.id: w.name};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Distribusi Baru')),
      body: !master.loaded
          ? StateMessage(
              icon: master.error == null ? Icons.hourglass_empty_rounded : Icons.cloud_off_rounded,
              title: master.error == null ? 'Memuat data wilayah & komoditas...' : 'Data master belum dapat dimuat',
              message: master.error,
              onRetry: master.error == null ? null : master.load,
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tealGlow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.tealGlow.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.tealGlow,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IdDropdown(
                    label: 'Komoditas',
                    value: _komoditas,
                    items: {for (final k in master.komoditas) k.id: k.name},
                    onChanged: (v) => setState(() => _komoditas = v),
                    validator: (v) => v == null ? 'Pilih komoditas' : null,
                  ),
                  const SizedBox(height: 14),
                  IdDropdown(
                    label: 'Wilayah asal',
                    value: _origin,
                    items: wilayahItems,
                    onChanged: (v) => setState(() => _origin = v),
                    validator: (v) => v == null ? 'Pilih wilayah asal' : null,
                  ),
                  const SizedBox(height: 14),
                  IdDropdown(
                    label: 'Wilayah tujuan',
                    value: _destination,
                    items: wilayahItems,
                    onChanged: (v) => setState(() => _destination = v),
                    validator: (v) {
                      if (v == null) return 'Pilih wilayah tujuan';
                      if (v == _origin) return 'Tujuan harus berbeda dari asal';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _qty,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      suffixText: unit.isEmpty ? null : unit,
                    ),
                    validator: (v) => Fmt.parseAngka(v ?? '') == null ? 'Masukkan angka 0 atau lebih' : null,
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal distribusi',
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(Fmt.tanggal(Fmt.apiDate(_date))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                      foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
                    ),
                    onPressed: _saving ? null : () => _submit(master),
                    child: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppColors.emeraldDark : Colors.white,
                            ),
                          )
                        : const Text('Tinjau & simpan'),
                  ),
                ],
              ),
            ),
    );
  }
}