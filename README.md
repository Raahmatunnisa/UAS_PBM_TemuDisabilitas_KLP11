# TemuDisabilitas

## Deskripsi

TemuDisabilitas adalah aplikasi mobile berbasis Flutter yang dirancang untuk menghubungkan penyandang disabilitas dengan relawan pendamping. Aplikasi ini bertujuan membantu penyandang disabilitas mendapatkan pendampingan dalam berbagai aktivitas sehari-hari, kegiatan pendidikan, kegiatan sosial, maupun layanan publik.

Melalui aplikasi ini, pengguna dapat mengajukan permintaan pendampingan, memilih relawan yang sesuai, berinteraksi melalui forum komunitas, serta memberikan penilaian terhadap layanan pendampingan yang diterima.

## Tujuan

Mendukung Sustainable Development Goals (SDGs) poin 10 yaitu **Reduced Inequalities (Mengurangi Kesenjangan)** dengan meningkatkan aksesibilitas dan partisipasi sosial penyandang disabilitas dalam kehidupan bermasyarakat.

---

## Teknologi yang Digunakan

* Flutter
* SQLite (sqflite)
* Provider (State Management)
* SharedPreferences
* flutter_local_notifications
* image_picker
* Material Design 3

---

## Fitur Utama

### 1. Autentikasi Pengguna

* Registrasi sebagai Penyandang Disabilitas
* Registrasi sebagai Relawan
* Login dan Logout
* Penyimpanan sesi menggunakan SharedPreferences

### 2. Permintaan Pendampingan

* Membuat permintaan pendampingan
* Menentukan jenis bantuan
* Menentukan lokasi kegiatan
* Menentukan tanggal dan waktu kegiatan

### 3. Pencarian Relawan

* Menampilkan daftar relawan
* Pemilihan relawan berdasarkan kebutuhan
* Menampilkan rating relawan

### 4. Manajemen Pendampingan

* Status Menunggu Relawan
* Status Diterima
* Status Ditolak
* Status Selesai

### 5. Forum Komunitas

* Membuat postingan
* Mengedit postingan
* Menghapus postingan
* Memberikan like
* Memberikan komentar

### 6. Notifikasi

* Notifikasi permintaan baru
* Notifikasi penerimaan pendampingan
* Notifikasi penolakan pendampingan
* Reminder kegiatan

### 7. Profil Pengguna

* Edit data profil
* Upload foto profil
* Kelola informasi pengguna

### 8. Rating dan Ulasan

* Memberikan rating relawan
* Memberikan ulasan
* Perhitungan rating rata-rata relawan

---

## Struktur Project

```text
lib/
├── models/
├── database/
├── providers/
├── services/
├── screens/
│   ├── auth/
│   ├── home/
│   ├── pendampingan/
│   ├── forum/
│   ├── profil/
│   └── notifikasi/
├── widgets/
├── routes/
├── utils/
└── main.dart
```

---

## Struktur Database SQLite

### users

Menyimpan data pengguna dan relawan.

### pendampingan

Menyimpan data permintaan pendampingan.

### forum

Menyimpan postingan komunitas.

### komentar

Menyimpan komentar pada postingan.

### likes

Menyimpan data like postingan.

### rating

Menyimpan rating dan ulasan relawan.

### notifikasi

Menyimpan data notifikasi pengguna.

---

## Alur Penggunaan

### Penyandang Disabilitas

1. Registrasi/Login.
2. Membuat permintaan pendampingan.
3. Memilih relawan yang tersedia.
4. Menunggu konfirmasi relawan.
5. Mengikuti kegiatan pendampingan.
6. Memberikan rating dan ulasan setelah kegiatan selesai.

### Relawan

1. Registrasi/Login.
2. Melihat permintaan pendampingan masuk.
3. Menerima atau menolak permintaan.
4. Melakukan pendampingan sesuai jadwal.
5. Menerima rating dan ulasan dari pengguna.

---

## Cara Menjalankan Aplikasi

### Clone atau buka project

```bash
cd temu_disabilitas
```

### Install dependency

```bash
flutter pub get
```

### Menjalankan aplikasi

```bash
flutter run
```

### Build APK

```bash
flutter build apk
```

---

## Aksesibilitas

Aplikasi dirancang dengan mempertimbangkan aksesibilitas melalui:

* Dukungan ukuran teks yang lebih besar
* Tombol dengan ukuran yang mudah ditekan
* Kontras warna yang baik
* Dukungan screen reader Flutter
* Responsive pada berbagai ukuran layar Android

---

## Kelompok: 11

**Rahmatun Nisa (2308107010016)**
**Davina Aura (2308107010052)**

---

## Lisensi

Project ini dikembangkan untuk keperluan akademik pada mata kuliah pengembangan aplikasi mobile dan tidak ditujukan untuk penggunaan komersial.
