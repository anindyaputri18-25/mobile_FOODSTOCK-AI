import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/repository.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'screens/account_status_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodstockApp());
}

class FoodstockApp extends StatefulWidget {
  const FoodstockApp({super.key});

  @override
  State<FoodstockApp> createState() => _FoodstockAppState();
}

class _FoodstockAppState extends State<FoodstockApp> {
  late final FoodstockRepository _repo;
  late final MasterData _master;
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _repo = FoodstockRepository();
    _master = MasterData(_repo);
    _session = SessionController(repo: _repo, master: _master);
    _session.restore();
  }

  @override
  void dispose() {
    _session.dispose();
    _master.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FoodstockRepository>.value(value: _repo),
        ChangeNotifierProvider<MasterData>.value(value: _master),
        ChangeNotifierProvider<SessionController>.value(value: _session),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FOODSTOCK AI',
        theme: buildLightAppTheme(),
        darkTheme: buildDarkAppTheme(),
        themeMode: ThemeMode.system,
        home: const RootGate(),
      ),
    );
  }
}

/// Memilih layar berdasarkan status sesi dan status akun dari backend.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    switch (session.status) {
      case AuthStatus.unknown:
        return const _Splash();
      case AuthStatus.signedOut:
        return const AuthScreen();
      case AuthStatus.signedIn:
        final user = session.user!;
        if (!user.isActive) return const AccountStatusScreen();
        return const HomeShell();
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.emeraldDark]
                : [AppColors.emeraldDark, AppColors.emeraldDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, size: 64, color: AppColors.accentMint),
              SizedBox(height: 16),
              Text(
                'FOODSTOCK AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accentMint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}