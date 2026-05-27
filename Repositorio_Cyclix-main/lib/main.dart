import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'screens/login.dart';
import 'screens/main_shell.dart';
import 'screens/maintenance_shell.dart';
import 'theme/cyclix_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CyclixApp());
}

class CyclixApp extends StatelessWidget {
  const CyclixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CyclixColors.primaryBlue,
          primary: CyclixColors.primaryBlue,
          secondary: CyclixColors.accentGreen,
          surface: CyclixColors.backgroundWhite,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          displaySmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: CyclixColors.textDark,
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: CyclixColors.textDark,
          ),
          titleMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: CyclixColors.textDark,
          ),
          titleSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: CyclixColors.textDark,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: CyclixColors.textDark,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            color: CyclixColors.textDark,
          ),
        ),
        scaffoldBackgroundColor: CyclixColors.backgroundWhite,
        cardTheme: const CardThemeData(color: CyclixColors.cardGrey),
        appBarTheme: const AppBarTheme(
          backgroundColor: CyclixColors.backgroundWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: CyclixColors.textDark),
        ),
      ),

      home: const _AuthGate(),

      // Ruta para ir a la pantalla principal después del login
      routes: {
        '/main': (context) => const MainShell(),
        '/maintenance': (context) => const MaintenanceShell(),
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<_StartupDestination> _sessionFuture = _resolveDestination();

  Future<_StartupDestination> _resolveDestination() async {
    final authService = AuthService();
    final hasSession = await authService.hasPreviousLogin().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );
    if (!hasSession) return _StartupDestination.login;

    final isMaintenance = await authService.isMaintenanceUser().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );
    return isMaintenance
        ? _StartupDestination.maintenance
        : _StartupDestination.main;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupDestination>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupScreen();
        }

        switch (snapshot.data) {
          case _StartupDestination.maintenance:
            return const MaintenanceShell();
          case _StartupDestination.main:
            return const MainShell();
          case _StartupDestination.login:
          case null:
            return const LoginScreen();
        }
      },
    );
  }
}

enum _StartupDestination { login, main, maintenance }

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyclixColors.backgroundWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo_cyclix.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_bike,
                  size: 80,
                  color: CyclixColors.primaryBlue,
                );
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: CyclixColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}
