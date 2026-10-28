import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/session.dart';
import '../core/theme.dart';

/// Layar Masuk/Daftar dengan Tampilan Frosted Glass 3D & Vibrant Gradient.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _busy = false;
  bool _showPassword = false;
  String _role = 'dinas';
  String? _error;
  String? _success;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _instansiController = TextEditingController();
  final _confirmController = TextEditingController();

  // Gambar Sawah Hijau Segar
  final String paddyFieldUrl =
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _instansiController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _switchMode(bool login) {
    setState(() {
      isLogin = login;
      _error = null;
      _success = null;
    });
  }

  static const _roles = [
    ('dinas', 'Dinas'),
    ('bulog', 'Bulog'),
    ('distributor', 'Distributor'),
    ('admin', 'Admin'),
  ];

  Widget _roleSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masuk sebagai (mode contoh)',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final r in _roles)
                ChoiceChip(
                  label: Text(r.$2),
                  selected: _role == r.$1,
                  selectedColor: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                  backgroundColor: isDark ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.6),
                  elevation: _role == r.$1 ? 4 : 0,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _role == r.$1
                        ? (isDark ? AppColors.emeraldDark : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark),
                  ),
                  onSelected: (_) => setState(() => _role = r.$1),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    if (!isLogin && _nameController.text.trim().length < 3) {
      return 'Nama lengkap minimal 3 karakter.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    if (!isLogin && _instansiController.text.trim().length < 2) {
      return 'Instansi wajib diisi.';
    }
    if (pass.isEmpty) return 'Kata sandi wajib diisi.';
    if (!isLogin) {
      if (pass.length < 8) return 'Kata sandi minimal 8 karakter.';
      if (pass != _confirmController.text) return 'Konfirmasi kata sandi tidak sama.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;
    final problem = _validate();
    if (problem != null) {
      setState(() {
        _error = problem;
        _success = null;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    final session = context.read<SessionController>();
    try {
      if (isLogin) {
        await session.login(_emailController.text, _passwordController.text, role: _role);
      } else {
        await session.register(
          name: _nameController.text,
          email: _emailController.text,
          instansi: _instansiController.text,
          password: _passwordController.text,
          confirmation: _confirmController.text,
        );
        if (!mounted) return;
        setState(() {
          isLogin = true;
          _passwordController.clear();
          _confirmController.clear();
          _success =
              'Pendaftaran berhasil. Akun Anda menunggu verifikasi Administrator, '
              'yang juga menetapkan role Anda. Silakan masuk setelah disetujui.';
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.detail);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _forgotPassword(bool isDark) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Lupa kata sandi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
          ),
        ),
        content: const Text(
          'Fitur ini belum tersedia pada prototipe. '
          'Nantinya pemulihan kata sandi mengikuti backend FoodStock AI.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mengerti'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notice = context.select<SessionController, String?>((s) => s.notice);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND HAMPARAN SAWAH + GRADASI ORGANIK
          Positioned.fill(
            child: Image.network(
              paddyFieldUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.darkBg : AppColors.emeraldDark,
                      isDark ? AppColors.emeraldDark : AppColors.emeraldDeep,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Layer Blur Sawah & Overlay Warna Hijau Organik
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: (isDark ? AppColors.darkBg : AppColors.emeraldDark).withValues(alpha: isDark ? 0.85 : 0.45),
              ),
            ),
          ),

          // Partikel Melayang 3D Glow
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.accentMint : Colors.white).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentMint.withValues(alpha: isDark ? 0.15 : 0.25),
              ),
            ),
          ),

          // 2. KONTEN UTAMA (KARTU KACA FROSTED GLASS 3D)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(26, 56, 26, 32),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface.withValues(alpha: 0.75)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : Colors.white.withValues(alpha: 0.9),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'FOODSTOCK AI',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isLogin
                                    ? 'S M A R T  I N V E N T O R Y  S Y S T E M'
                                    : 'K E L O L A  S T O K  F R E S H',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.tealGlow : AppColors.emeraldDeep,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildTabSwitcher(isDark),
                              const SizedBox(height: 24),
                              if (notice != null && isLogin && _error == null && _success == null)
                                _banner(notice, Icons.info_outline_rounded, AppColors.tealGlow),
                              if (_success != null) _banner(_success!, Icons.check_circle_outline_rounded, AppColors.tealGlow),
                              if (_error != null) _banner(_error!, Icons.error_outline_rounded, AppColors.tealGlow),
                              if (!isLogin) ...[
                                _buildNeumorphicInput(
                                  controller: _nameController,
                                  hint: 'Nama Lengkap',
                                  icon: Icons.person_outline_rounded,
                                  capitalization: TextCapitalization.words,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildNeumorphicInput(
                                controller: _emailController,
                                hint: 'Email',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              if (!isLogin) ...[
                                _buildNeumorphicInput(
                                  controller: _instansiController,
                                  hint: 'Instansi / Perusahaan',
                                  icon: Icons.apartment_rounded,
                                  capitalization: TextCapitalization.words,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildNeumorphicInput(
                                controller: _passwordController,
                                hint: 'Kata Sandi',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                onSubmit: isLogin ? _submit : null,
                                isDark: isDark,
                              ),
                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                _buildNeumorphicInput(
                                  controller: _confirmController,
                                  hint: 'Ulangi Kata Sandi',
                                  icon: Icons.lock_reset_rounded,
                                  isPassword: true,
                                  onSubmit: _submit,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Role (Dinas/Bulog/Distributor) ditetapkan Administrator saat verifikasi akun.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : AppColors.emeraldDark.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (isLogin) _roleSelector(isDark),
                              if (isLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _forgotPassword(isDark),
                                    child: Text(
                                      'Lupa Kata Sandi?',
                                      style: TextStyle(
                                        color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 22),
                              _buildPrimaryButton(isDark),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Logo Embun Melayang 3D
                    Positioned(
                      top: -36,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.darkSurface, AppColors.emeraldDark]
                                : [Colors.white, const Color(0xFFE2EFE6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isDark ? AppColors.accentMint : Colors.white,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.eco_rounded,
                            size: 36,
                            color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, height: 1.35, color: color, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // Tab Switcher Login/Register 3D
  Widget _buildTabSwitcher(bool isDark) {
    Widget tab(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: isDark
                            ? [AppColors.accentMint, AppColors.tealGlow]
                            : [AppColors.emeraldDark, AppColors.emeraldDeep],
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: selected
                        ? (isDark ? AppColors.emeraldDark : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark),
                  ),
                ),
              ),
            ),
          ),
        );

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        children: [
          tab('Masuk', isLogin, () => _switchMode(true)),
          tab('Daftar', !isLogin, () => _switchMode(false)),
        ],
      ),
    );
  }

  // Tombol Utama (Pill Glossy Button 3D)
  Widget _buildPrimaryButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.accentMint, AppColors.tealGlow]
                : [AppColors.emeraldDark, AppColors.emeraldDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.white).withValues(alpha: 0.6),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _busy ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
          ),
          child: _busy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: isDark ? AppColors.emeraldDark : Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.emeraldDark : Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.emeraldDark : Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Widget Field Input Timbul Soft Neumorphism 3D
  Widget _buildNeumorphicInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    VoidCallback? onSubmit,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : Colors.white.withValues(alpha: 0.95),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: !_busy,
        obscureText: isPassword && !_showPassword,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        autocorrect: false,
        enableSuggestions: !isPassword,
        textInputAction: onSubmit != null ? TextInputAction.done : TextInputAction.next,
        onSubmitted: onSubmit == null ? null : (_) => onSubmit(),
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : AppColors.emeraldDark.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppColors.accentMint : AppColors.emeraldDark.withValues(alpha: 0.75),
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  tooltip: _showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi',
                  icon: Icon(
                    _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: isDark ? AppColors.accentMint : AppColors.emeraldDark.withValues(alpha: 0.65),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        ),
      ),
    );
  }
}