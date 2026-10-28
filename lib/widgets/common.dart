import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/theme.dart';

// ---------------------------------------------------------------------------
// Pesan & dialog
// ---------------------------------------------------------------------------

String errorText(Object e) =>
    e is ApiException ? e.detail : 'Terjadi kesalahan tak terduga. Coba lagi.';

void showSnack(BuildContext context, String message, {bool error = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error
            ? AppColors.tealGlow
            : (isDark ? AppColors.accentMint : AppColors.emeraldDark),
      ),
    );
}

/// Konfirmasi sebelum aksi penting dengan gaya modern.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya, lanjutkan',
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          height: 1.4,
          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Batal',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(110, 42),
            backgroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
            foregroundColor: isDark ? AppColors.emeraldDark : Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return res ?? false;
}

// ---------------------------------------------------------------------------
// Status Chip dengan Efek Kapsul Gradasi & Glow 3D
// ---------------------------------------------------------------------------

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  /// aman | shortage | surplus
  factory StatusChip.forecast(String status) => switch (status) {
        'shortage' => const StatusChip(label: 'Potensi Kekurangan', color: AppColors.tealGlow, icon: Icons.trending_down_rounded),
        'surplus' => const StatusChip(label: 'Potensi Surplus', color: AppColors.accentMint, icon: Icons.trending_up_rounded),
        _ => const StatusChip(label: 'Aman', color: AppColors.accentMint, icon: Icons.check_circle_outline_rounded),
      };

  /// menunggu | disetujui | eskalasi | selesai
  factory StatusChip.rekomendasi(String status) => switch (status) {
        'disetujui' => const StatusChip(label: 'Disetujui', color: AppColors.accentMint),
        'eskalasi' => const StatusChip(label: 'Eskalasi', color: AppColors.tealGlow),
        'selesai' => const StatusChip(label: 'Selesai', color: AppColors.neutral),
        _ => const StatusChip(label: 'Menunggu', color: AppColors.accentMint),
      };

  /// rencana | dikirim | selesai
  factory StatusChip.distribusi(String status) => switch (status) {
        'dikirim' => const StatusChip(label: 'Dikirim', color: AppColors.tealGlow),
        'selesai' => const StatusChip(label: 'Selesai', color: AppColors.accentMint),
        _ => const StatusChip(label: 'Rencana', color: AppColors.neutral),
      };

  /// aktif | pending | ditolak | terkunci | nonaktif
  factory StatusChip.akun(String status) => switch (status) {
        'aktif' => const StatusChip(label: 'Aktif', color: AppColors.accentMint),
        'pending' => const StatusChip(label: 'Menunggu verifikasi', color: AppColors.tealGlow),
        'ditolak' => const StatusChip(label: 'Ditolak', color: AppColors.tealGlow),
        'terkunci' => const StatusChip(label: 'Terkunci', color: AppColors.tealGlow),
        _ => const StatusChip(label: 'Nonaktif', color: AppColors.neutral),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu 3D dengan Efek Bayangan Ganda & Kedalaman (Adaptive Dark/Light)
// ---------------------------------------------------------------------------

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.margin});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Efek 3D: Bayangan berlapis (Ambient Shadow + Directional Shadow)
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.emeraldDark).withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action});
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MetricTile dengan Sentuhan Semi-Gradasi 3D
// ---------------------------------------------------------------------------

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, required this.color, this.icon, this.alert = false});
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = alert ? AppColors.tealGlow : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activeColor.withValues(alpha: isDark ? 0.25 : 0.16),
            activeColor.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: isDark ? 0.5 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: isDark ? AppColors.accentMint : activeColor, size: 22),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : activeColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.neutral,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// "Diperbarui: ..." agar pengguna dapat menilai relevansi data.
class FreshnessNote extends StatelessWidget {
  const FreshnessNote(this.label, this.iso, {super.key});
  final String label;
  final String? iso;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      '$label: ${iso == null ? 'belum ada' : Fmt.waktu(iso)}',
      style: TextStyle(
        fontSize: 11.5,
        color: isDark ? Colors.white60 : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Catatan wajib di setiap tampilan prediksi (doc bagian 11).
class ForecastDisclaimer extends StatelessWidget {
  const ForecastDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealGlow.withValues(alpha: isDark ? 0.2 : 0.12),
            AppColors.tealGlow.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tealGlow.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.tealGlow),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Angka ini adalah prediksi model, bukan data aktual maupun kepastian. '
              'MAPE menunjukkan galat historis dan bukan jaminan hasil periode berikutnya.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Keadaan: memuat, kosong, gagal
// ---------------------------------------------------------------------------

class StateMessage extends StatelessWidget {
  const StateMessage({super.key, required this.icon, required this.title, this.message, this.onRetry});
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 54,
              color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  side: BorderSide(color: isDark ? AppColors.accentMint : AppColors.emeraldDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Memuat satu sumber data dengan animasi transisi yang halus.
class AsyncView<T> extends StatefulWidget {
  const AsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.reloadToken = 0,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
  });

  final Future<T> Function() load;
  final List<Widget> Function(BuildContext context, T data) builder;
  final int reloadToken;
  final EdgeInsets padding;

  @override
  State<AsyncView<T>> createState() => AsyncViewState<T>();
}

class AsyncViewState<T> extends State<AsyncView<T>> {
  T? _data;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(covariant AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) reload();
  }

  Future<void> reload() async {
    try {
      final d = await widget.load();
      if (!mounted) return;
      setState(() {
        _data = d;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data == null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Data belum dapat dimuat',
        message: _error == null ? null : errorText(_error!),
        onRetry: () {
          setState(() => _loading = true);
          reload();
        },
      );
    }
    final children = widget.builder(context, _data as T);
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Gagal memperbarui: ${errorText(_error!)}',
                style: const TextStyle(color: AppColors.tealGlow, fontSize: 12),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// Daftar berpaginasi dengan gaya kartu modern.
class PagedList<T> extends StatefulWidget {
  const PagedList({
    super.key,
    required this.fetch,
    required this.itemBuilder,
    this.header,
    this.where,
    this.emptyTitle = 'Belum ada data',
    this.emptyMessage,
    this.reloadToken = 0,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 96),
  });

  final Future<Paged<T>> Function(int page) fetch;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? header;

  final bool Function(T item)? where;
  final String emptyTitle;
  final String? emptyMessage;
  final int reloadToken;
  final EdgeInsets padding;

  @override
  State<PagedList<T>> createState() => PagedListState<T>();
}

class PagedListState<T> extends State<PagedList<T>> {
  final List<T> _items = [];
  int _page = 0;
  int _total = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(covariant PagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) reload();
  }

  Future<void> reload() async {
    try {
      final p = await widget.fetch(1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(p.items);
        _page = p.page;
        _total = p.total;
        _hasMore = p.hasMore;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _more() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final p = await widget.fetch(_page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(p.items);
        _page = p.page;
        _total = p.total;
        _hasMore = p.hasMore;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      showSnack(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _items.isEmpty) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Data belum dapat dimuat',
        message: errorText(_error!),
        onRetry: () {
          setState(() => _loading = true);
          reload();
        },
      );
    }
    final shown = widget.where == null ? _items : _items.where(widget.where!).toList();
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        children: [
          if (widget.header != null) widget.header!,
          if (shown.isEmpty && !_hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: StateMessage(
                icon: Icons.inbox_outlined,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            ),
          for (final item in shown) widget.itemBuilder(context, item),
          if (_hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: _loadingMore ? null : _more,
                child: _loadingMore
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Muat lebih banyak (${_items.length} dari $_total)'),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grafik Batang dengan Gradasi Vertikal 3D
// ---------------------------------------------------------------------------

class ForecastBars extends StatelessWidget {
  const ForecastBars({super.key, required this.points, required this.unit});
  final List<ForecastPoint> points;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double maxV = 0;
    for (final p in points) {
      if ((p.predicted ?? 0) > maxV) maxV = p.predicted!;
      if ((p.stock ?? 0) > maxV) maxV = p.stock!;
    }
    if (points.isEmpty || maxV <= 0) {
      return const SizedBox(height: 60, child: Center(child: Text('Belum ada data grafik.')));
    }
    const chartHeight = 120.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legend(isDark ? AppColors.accentMint : AppColors.emeraldDark, 'Prediksi kebutuhan'),
            const SizedBox(width: 14),
            _legend(AppColors.tealGlow, 'Stok'),
            const Spacer(),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: chartHeight + 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _bar(((p.predicted ?? 0) / maxV) * chartHeight, isDark ? AppColors.accentMint : AppColors.emeraldDark),
                          const SizedBox(width: 4),
                          _bar(((p.stock ?? 0) / maxV) * chartHeight, AppColors.tealGlow),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Fmt.periode(p.periode).split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                        ),
                      ),
                      Text(
                        p.status == 'aman' ? 'Aman' : (p.status == 'shortage' ? 'Kurang' : 'Surplus'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: p.status == 'aman'
                              ? AppColors.accentMint
                              : (p.status == 'shortage' ? AppColors.tealGlow : AppColors.accentMint),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(double h, Color c) => Container(
        width: 20,
        height: h < 2 ? 2 : h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c, c.withValues(alpha: 0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );

  Widget _legend(Color c, String t) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      );
}

// ---------------------------------------------------------------------------
// Pemilih dropdown dari master data
// ---------------------------------------------------------------------------

class IdDropdown extends StatelessWidget {
  const IdDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.allowAll = false,
  });

  final String label;
  final int? value;
  final Map<int, String> items;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;
  final bool allowAll;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      key: ValueKey('$label-$value-${items.length}'),
      initialValue: items.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        if (allowAll) const DropdownMenuItem<int?>(value: null, child: Text('Semua')),
        for (final e in items.entries)
          DropdownMenuItem<int?>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

Future<T?> pushPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));