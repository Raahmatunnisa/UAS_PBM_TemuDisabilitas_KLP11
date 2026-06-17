import 'package:flutter/material.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/screens/auth/login_screen.dart';
import 'package:temu_disabilitas/screens/auth/register_screen.dart';
import 'package:temu_disabilitas/screens/forum/buat_posting_screen.dart';
import 'package:temu_disabilitas/screens/forum/detail_forum_screen.dart';
import 'package:temu_disabilitas/screens/forum/edit_posting_screen.dart';
import 'package:temu_disabilitas/screens/forum/forum_screen.dart';
import 'package:temu_disabilitas/screens/notifikasi/notifikasi_screen.dart';
import 'package:temu_disabilitas/screens/penyandang/buat_permintaan_screen.dart';
import 'package:temu_disabilitas/screens/penyandang/cari_relawan_screen.dart';
import 'package:temu_disabilitas/screens/penyandang/penyandang_main_screen.dart';
import 'package:temu_disabilitas/screens/pendampingan/detail_pendampingan_screen.dart';
import 'package:temu_disabilitas/screens/pendampingan/jadwal_screen.dart';
import 'package:temu_disabilitas/screens/pendampingan/rating_screen.dart';
import 'package:temu_disabilitas/screens/profil/edit_profil_screen.dart';
import 'package:temu_disabilitas/screens/profil/profil_screen.dart';
import 'package:temu_disabilitas/screens/relawan/relawan_main_screen.dart';
import 'package:temu_disabilitas/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String penyandangMain = '/penyandang';
  static const String relawanMain = '/relawan';
  static const String buatPermintaan = '/buat-permintaan';
  static const String cariRelawan = '/cari-relawan';
  static const String detailPendampingan = '/detail-pendampingan';
  static const String jadwal = '/jadwal';
  static const String rating = '/rating';
  static const String forum = '/forum';
  static const String buatPosting = '/buat-posting';
  static const String editPosting = '/edit-posting';
  static const String detailForum = '/detail-forum';
  static const String notifikasi = '/notifikasi';
  static const String profil = '/profil';
  static const String editProfil = '/edit-profil';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case penyandangMain:
        return MaterialPageRoute(builder: (_) => const PenyandangMainScreen());
      case relawanMain:
        return MaterialPageRoute(builder: (_) => const RelawanMainScreen());
      case buatPermintaan:
        return MaterialPageRoute(builder: (_) => const BuatPermintaanScreen());
      case cariRelawan:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CariRelawanScreen(
            pendampinganId: args['pendampinganId'] as int,
            jenisBantuan: args['jenisBantuan'] as String,
          ),
        );
      case detailPendampingan:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailPendampinganScreen(pendampinganId: id),
        );
      case jadwal:
        final isRelawan = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => JadwalScreen(isRelawan: isRelawan),
        );
      case rating:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RatingScreen(
            pendampinganId: args['pendampinganId'] as int,
            relawanId: args['relawanId'] as int,
          ),
        );
      case forum:
        return MaterialPageRoute(builder: (_) => const ForumScreen());
      case buatPosting:
        return MaterialPageRoute(builder: (_) => const BuatPostingScreen());
      case editPosting:
        final post = settings.arguments as ForumModel;
        return MaterialPageRoute(
          builder: (_) => EditPostingScreen(post: post),
        );
      case detailForum:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailForumScreen(forumId: id),
        );
      case notifikasi:
        return MaterialPageRoute(builder: (_) => const NotifikasiScreen());
      case profil:
        return MaterialPageRoute(builder: (_) => const ProfilScreen());
      case editProfil:
        return MaterialPageRoute(builder: (_) => const EditProfilScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan: ${settings.name}')),
          ),
        );
    }
  }
}
