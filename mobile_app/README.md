# 📱 Student Management Mobile App

Aplikasi seluler **Student Management** berbasis Android/iOS yang dibangun menggunakan **Flutter** dan **Dart**.

---

## ✨ Fitur

*   **📊 Dashboard:** Menampilkan statistik riil dari server backend (Total Siswa, Total Proyek, dan Batas Maksimum Proyek).
*   **⚙️ Konfigurasi Batas Proyek:** Kartu *Max Projects* di dashboard dapat diketuk untuk mengubah batasan penugasan proyek per siswa secara langsung ke database server.
*   **👥 Manajemen Siswa (CRUD):** Tambah, lihat detail, edit data, dan hapus siswa.
*   **📁 Unggah Berkas & Gambar Proyek:** Tambah dan edit proyek lengkap dengan fitur *File Picker* untuk melampirkan file PDF laporan atau gambar sampul proyek (unggah berbasis biner *Multipart*).
*   **📅 Penugasan Proyek:** Hubungkan proyek aktif ke siswa pilihan lengkap dengan penentuan tanggal mulai dan tanggal selesai proyek.
*   **🔒 Dialog Konfirmasi Aman:** Seluruh aksi manipulasi data penting (Tambah, Edit, Hapus, dan Tugaskan) dilindungi oleh popup dialog konfirmasi interaktif guna mencegah kesalahan ketukan pengguna.
*   **🩺 Deteksi Jaringan & Diagnostik Pintar:** Sistem login yang mampu mendeteksi detail kendala jaringan (seperti router memblokir koneksi atau IP salah) dan memunculkannya secara transparan di layar HP.

---

## 🛠️ Teknologi & Pustaka

*   **Core Framework:** Flutter (Multi-platform Android, iOS, macOS, Web)
*   **Language:** Dart
*   **State Management & Lifecycle:** StatefulWidget & State-driven UI
*   **Storage Session:** `shared_preferences` (untuk menyimpan JWT token keamanan login)
*   **Network Request:** `http` (menerapkan penanganan berkas multi-bagian / Multipart)
*   **File Selector:** `file_picker` (untuk memilih berkas PDF dan foto/gambar dari galeri HP)

---

## 🚀 Memulai (Quick Start)

Ikuti langkah-langkah di bawah untuk menjalankan proyek mobile ini di komputer Anda:

### 1. Dapatkan Dependensi Proyek
Masuk ke direktori `mobile_app` lewat terminal Anda, lalu pasang seluruh pustaka luar yang dibutuhkan:
```bash
flutter pub get
```

### 2. Hubungkan HP Android ke Laptop via USB
*   Aktifkan fitur **Developer Options** dan **USB Debugging** pada pengaturan HP Anda.
*   Hubungkan HP ke laptop menggunakan kabel data USB berkualitas baik.

### 3. Aktifkan Jembatan Port USB (ADB Reverse)
Jalankan perintah berikut di Terminal laptop Anda agar HP dapat mengalirkan data internet langsung ke server backend lokal laptop Anda:
```bash
adb reverse tcp:9090 tcp:9090
```

### 4. Konfigurasi Alamat Host
Buka file **`lib/services/api_service.dart`**, pastikan alamat IP host disetel ke loopback IP berikut agar terhubung via kabel USB:
```dart
static const String _hostIp = '127.0.0.1'; // Bekerja instan berkat perintah 'adb reverse' di atas!
```

### 5. Jalankan Aplikasi!
Ketik perintah berikut di terminal Anda untuk mulai mengompilasi dan memasang aplikasi ke HP Anda:
```bash
flutter run
```

---

## 📂 Struktur Folder Utama

```text
lib/
├── main.dart                      # Pintu gerbang utama inisialisasi aplikasi
├── theme/
│   └── app_theme.dart             # Konfigurasi interior warna premium Slate & Indigo
├── services/
│   └── api_service.dart           # Logika pemanggilan HTTP API & penanganan Session Token
└── screens/
    ├── login_screen.dart          # Gerbang masuk login admin & diagnosa error
    ├── main_screen.dart           # Wadah navigasi bawah (Bottom Navigation Bar)
    ├── dashboard_view.dart        # Ringkasan statistik interaktif & setelan Max Projects
    ├── students_view.dart         # Halaman kelola data siswa & modal konfirmasi
    ├── projects_view.dart         # Halaman manajemen proyek & unggah berkas PDF/Gambar
    └── assignments_view.dart      # Formulir penugasan proyek aktif ke siswa
```

---

## 📡 Pengujian API REST

Anda juga dapat melakukan simulasi pemanggilan API backend secara terpisah menggunakan ekstensi **REST Client** di VS Code lewat berkas dokumentasi interaktif yang tersedia:
📄 **`api-documentation-mobile.rest`** 
