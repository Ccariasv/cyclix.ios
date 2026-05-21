import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyclix_colors.dart';

class CyclixHeader extends StatelessWidget implements PreferredSizeWidget {
  const CyclixHeader({super.key, this.showBack = false});

  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      leadingWidth: 64,
      leading: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              tooltip: showBack ? 'Volver' : 'Menú',
              icon: Icon(
                showBack ? Icons.arrow_back : Icons.menu,
                color: CyclixColors.primaryBlue,
              ),
              onPressed: () {
                if (showBack) {
                  Navigator.of(context).maybePop();
                } else {
                  Scaffold.maybeOf(context)?.openDrawer();
                }
              },
            ),
          );
        },
      ),
      title: Text(
        'Cyclix',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: CyclixColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.pedal_bike,
            color: CyclixColors.accentGreen,
            size: 28,
          ),
        ),
      ],
    );
  }
}
