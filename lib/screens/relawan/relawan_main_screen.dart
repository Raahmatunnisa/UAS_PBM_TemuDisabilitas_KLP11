import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/screens/forum/forum_screen.dart';
import 'package:temu_disabilitas/screens/pendampingan/jadwal_screen.dart';
import 'package:temu_disabilitas/screens/profil/profil_screen.dart';
import 'package:temu_disabilitas/screens/relawan/relawan_home_tab.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';

class RelawanMainScreen extends StatefulWidget {
  const RelawanMainScreen({super.key});

  @override
  State<RelawanMainScreen> createState() => _RelawanMainScreenState();
}

class _RelawanMainScreenState extends State<RelawanMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const LoadingWidget();

    final pages = [
      RelawanHomeTab(relawanId: user.id!),
      JadwalScreen(isRelawan: true, embedded: true),
      const ForumScreen(embedded: true),
      const ProfilScreen(embedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Jadwal'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Forum'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
