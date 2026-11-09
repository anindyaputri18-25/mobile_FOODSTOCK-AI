import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/app_actions.dart';

/// Landing screen modern & dinamis untuk FOODSTOCK AI.
/// Menggabungkan efek 3D glassmorphic, gradasi Emerald-Teal-Mint, 
/// serta dukungan penuh Light & Dark Mode tanpa tampilan monoton.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, required this.onStart});

  /// Callback ketika pengguna menekan tombol untuk masuk/mulai aplikasi.
  final VoidCallback onStart;

  static const _features = [
    (
      Icons.monitor_heart_rounded,
      'Monitoring Real-Time',
      'Pantau ketersediaan & pergerakan stok pangan secara transparan.'
    ),
    (
      Icons.auto_graph_rounded,
      'AI Forecasting',
      'Prediksi kebutuhan & ketersediaan komoditas dengan algoritma cerdas.'
    ),
    (
      Icons.warning_amber_rounded,
      'Early Warning System',
      'Deteksi otomatis potensi defisit atau surplus stok lebih awal.'
    ),
    (
      Icons.swap_horizontal_circle_rounded,
      'Realokasi Logistik',
      'Rekomendasi taktis pemindahan pasokan pangan antarwilayah.'
    ),
  ];

  static const _steps = [
    (
      '01',
      'Akses Sistem',
      'Masuk ke portal terintegrasi sesuai kewenangan operasional.'
    ),
    (
      '02',
      'Pantau Dashboard',
      'Tinjau statistik ketersediaan, tren prediksi, dan alert aktif secara instan.'
    ),
    (
      '03',
      'Eksekusi Tindakan',
      'Jalankan rekomendasi realokasi stok dan pantau status distribusi.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. LATAR BELAKANG GRADASI UTAMA
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkBg, AppColors.emeraldDark, AppColors.emeraldDeep]
                      : [AppColors.emeraldDark, AppColors.emeraldDeep, AppColors.emeraldDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 2. ORNAMEN GLOW DEKORATIF ABSTRAK
          Positioned(
            top: -80,
            left: -60,
            child: _buildGlowOrb(
              size: 300,
              color: AppColors.accentMint.withValues(alpha: isDark ? 0.15 : 0.22),
            ),
          ),
          Positioned(
            top: 360,
            right: -70,
            child: _buildGlowOrb(
              size: 260,
              color: AppColors.tealGlow.withValues(alpha: isDark ? 0.18 : 0.25),
            ),
          ),

          // 3. AREA KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                // NAVBAR ATAS
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentMint, AppColors.tealGlow],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentMint.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 20,
                          color: AppColors.emeraldDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'FOODSTOCK AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      const ThemeToggleButton(),
                    ],
                  ),
                ),

                // SCROLLABLE BODY
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    children: [
                      // HERO BADGE
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppColors.accentMint,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'PLATFORM CERDAS STOK PANGAN',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.accentMint,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // JUDUL HERO UTAMA
                      const Text(
                        'Navigasi Pangan,\nLebih Akurat & Dini.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Solusi terpadu pemantauan stok nasional, peramalan kebutuhan berbasis AI, Early Warning System, dan koordinasi distribusi.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TOMBOL UTAMA
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentMint,
                          foregroundColor: AppColors.emeraldDark,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.accentMint.withValues(alpha: 0.45),
                        ),
                        onPressed: onStart,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text(
                          'MULAI EKSPLORASI',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // KARTU METRIK KACA 3D
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: _StatMetric('24/7', 'Real-Time Monitoring')),
                                _VDivider(),
                                Expanded(child: _StatMetric('AI Powered', 'Prediksi Presisi')),
                                _VDivider(),
                                Expanded(child: _StatMetric('Verified', 'Validasi Data')),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // SEKSI FITUR UTAMA (GRID 2 KOLOM YANG LEBIH RAMPING & PAS)
                      _buildSectionHeader('Fitur Unggulan System', Icons.grid_view_rounded),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.15, // Diperlebar agar kotaknya tidak terlalu tinggi/besar
                        ),
                        itemCount: _features.length,
                        itemBuilder: (context, index) {
                          final f = _features[index];
                          return _FeatureGridCard(
                            icon: f.$1,
                            title: f.$2,
                            desc: f.$3,
                            isDark: isDark,
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // SEKSI ALUR KERJA / TIMELINE
                      _buildSectionHeader('Alur Operasional', Icons.alt_route_rounded),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < _steps.length; i++)
                              _StepTimelineTile(
                                number: _steps[i].$1,
                                title: _steps[i].$2,
                                desc: _steps[i].$3,
                                isLast: i == _steps.length - 1,
                                isDark: isDark,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // KARTU CALL-TO-ACTION (CTA) AKHIR
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.emeraldDark, AppColors.emeraldDeep]
                                : [AppColors.emeraldDeep, AppColors.emeraldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.accentMint.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emeraldDark.withValues(alpha: 0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.rocket_launch_rounded,
                              color: AppColors.accentMint,
                              size: 34,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Kelola Pangan Lebih Cerdas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Masuk ke sistem sekarang untuk mengakses dashboard monitoring dan rekomendasi AI.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentMint,
                                  side: const BorderSide(
                                    color: AppColors.accentMint,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: onStart,
                                child: const Text(
                                  'MASUK SEKARANG',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // FOOTER
                      const Center(
                        child: Text(
                          '© 2026 FOODSTOCK AI • Professional Financial & Operations UI',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentMint),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET METRIK & KARTU FITUR 2 KOLOM (YANG SUDAH DIPERKECIL & DIRAMPINGKAN)
// ---------------------------------------------------------------------------

class _StatMetric extends StatelessWidget {
  const _StatMetric(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accentMint,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}

class _FeatureGridCard extends StatelessWidget {
  const _FeatureGridCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.accentMint : AppColors.emeraldDark;

    return Container(
      padding: const EdgeInsets.all(12), // Padding dikurangi dari 16 ke 12 agar lebih kompak
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.emeraldDark).withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.20),
                      accent.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.3,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTimelineTile extends StatelessWidget {
  const _StepTimelineTile({
    required this.number,
    required this.title,
    required this.desc,
    required this.isLast,
    required this.isDark,
  });

  final String number;
  final String title;
  final String desc;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentMint, AppColors.tealGlow],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.emeraldDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: AppColors.accentMint.withValues(alpha: 0.35),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}