import 'package:flutter/material.dart';
import 'perfil_screen.dart';
import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_bottom_nav.dart';
import '../widgets/cyclix_header.dart';
import '../widgets/cyclix_drawer.dart';
import 'map_screen.dart';
import 'puestos_bicicletas_screen.dart';
import 'qr_scan_screen.dart';
import 'wallet_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyclixColors.backgroundWhite,
      appBar: const CyclixHeader(),
      drawer: const CyclixDrawer(),
      body: switch (_index) {
        0 => const MapScreen(),
        1 => const QrScanScreen(embeddedInShell: true),
        2 => const PuestosBicicletasScreen(embeddedInShell: true),
        3 => const WalletScreen(embeddedInShell: true),
        _ => const PerfilScreen(),
      },
      bottomNavigationBar: CyclixBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
