import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/screens/forum/forum_screen.dart';
import 'package:temu_disabilitas/screens/penyandang/penyandang_home_tab.dart';
import 'package:temu_disabilitas/screens/pendampingan/jadwal_screen.dart';
import 'package:temu_disabilitas/screens/profil/profil_screen.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';

class PenyandangMainScreen extends StatefulWidget {
  const PenyandangMainScreen({super.key});

  @override
  State<PenyandangMainScreen> createState() => _PenyandangMainScreenState();
}

class _PenyandangMainScreenState extends State<PenyandangMainScreen> {
  int _currentIndex = 0;

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const LoadingWidget(message: 'Memuat...');
    }

    final pages = [
      PenyandangHomeTab(userId: user.id!),
      JadwalScreen(isRelawan: false, embedded: true),
      const ForumScreen(embedded: true),
      const ProfilScreen(embedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          indicatorColor: _primaryLight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF888888)),
              selectedIcon: Icon(Icons.home_rounded, color: _primaryColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined, color: Color(0xFF888888)),
              selectedIcon: Icon(Icons.event_rounded, color: _primaryColor),
              label: 'Pendampingan',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined, color: Color(0xFF888888)),
              selectedIcon: Icon(Icons.forum_rounded, color: _primaryColor),
              label: 'Forum',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF888888),
              ),
              selectedIcon: Icon(Icons.person_rounded, color: _primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
