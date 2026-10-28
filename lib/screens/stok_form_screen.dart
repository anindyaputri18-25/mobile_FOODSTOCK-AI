import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class StokFormScreen extends StatefulWidget {
  const StokFormScreen({super.key});

  @override
  State<StokFormScreen> createState() => _StokFormScreenState();
}

class _StokFormScreenState extends State<StokFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();

  int? _wilayah;
  int? _komoditas;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Tanggal pencatatan stok',
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit(MasterData master) async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final qty = Fmt.parseAngka(_qtyController.text)!;
    final unit = master.unitOf(_komoditas!);

    final ok = await confirmAction(
      context,
      title: 'Simpan data stok?',
      message: 'Komoditas: ${master.komoditasName(_komoditas!)}\n'
          'Wilayah: ${master.wilayahName(_wilayah!)}\n'
          'Jumlah: ${Fmt.jumlah(qty, unit)}\n'
          'Tanggal: ${Fmt.tanggal(Fmt.apiDate(_date))}',
      confirmLabel: 'Simpan',
    );
    if (!ok || !mounted) return;

    setState(() => _saving = true);
    final repo = context.read<FoodstockRepository>();
    final session = context.read<SessionController>();
    final navigator = Navigator.of(context);

    try {
      await repo.createStok(
        wilayahId: _wilayah!,
        komoditasId: _komoditas!,
        quantity: qty,
        recordedAt: _date,
      );
      session.bumpData();
      if (!mounted) return;
      showSnack(context, 'Catatan stok berhasil disimpan.');
      if (navigator.canPop()) {
        navigator.pop(true);
      } else {
        _qtyController.clear();
        setState(() {
          _komoditas = null;
          _wilayah = null;
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
      appBar: AppBar(title: const Text('Tambah Catatan Stok')),
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
                    label: 'Wilayah',
                    value: _wilayah,
                    items: wilayahItems,
                    onChanged: (v) => setState(() => _wilayah = v),
                    validator: (v) => v == null ? 'Pilih wilayah' : null,
                  ),
                  const SizedBox(height: 14),
                  IdDropdown(
                    label: 'Komoditas',
                    value: _komoditas,
                    items: {for (final k in master.komoditas) k.id: k.name},
                    onChanged: (v) => setState(() => _komoditas = v),
                    validator: (v) => v == null ? 'Pilih komoditas' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Jumlah Stok',
                      suffixText: unit.isEmpty ? null : unit,
                    ),
                    validator: (v) => Fmt.parseAngka(v ?? '') == null ? 'Masukkan jumlah angka yang valid' : null,
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pencatatan',
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
                        : const Text('Tinjau & Simpan'),
                  ),
                ],
              ),
            ),
    );
  }
}