# Student Management Apps (Enterprise Edition)

**Student Management Apps** adalah sebuah aplikasi web *full-stack* modern yang dirancang untuk mengelola ekosistem akademik secara digital. Aplikasi ini memfasilitasi administrasi data siswa, daftar proyek (tugas akhir/kegiatan), hingga sistem *auto-assignment* (penugasan proyek cerdas berdasarkan peringkat nilai/average score).

Dikembangkan dengan memisahkan sisi *Client* (Frontend) dan *Server* (Backend), aplikasi ini mengedepankan keamanan berlapis, antarmuka pengguna yang responsif (*Light Theme*), serta arsitektur kode yang terstruktur.

---

## ✨ Ikhtisar Fitur Lengkap (Comprehensive Features)

### 1. 🛡️ Modul Keamanan & Autentikasi (Security Module)
- **JWT (JSON Web Token):** Sesi pengguna dikelola secara *stateless* menggunakan token JWT berstandar industri.
- **Role-based Authentication:** Akses masuk saat ini dikhususkan bagi administrator.
- **Route Protection:** Semua rute API (kecuali `/auth/login`) dilindungi secara ketat oleh `Spring Security Filter Chain` di backend. Di sisi frontend, rute dilindungi oleh `AuthGuard` dari Angular.
- **HTTP Interceptor:** Token autentikasi disematkan secara otomatis (*intercepted*) ke dalam *Header HTTP Authorization* pada setiap permintaan dari peramban ke server.

### 2. 👥 Modul Manajemen Siswa (Student Module)
- **Registrasi & Pendataan:** Menambah, mengubah, dan menghapus (*CRUD*) profil siswa beserta pencatatan skor rata-rata (*average score*).
- **Pembatasan Proyek:** Administrator dapat mengonfigurasi batas maksimal kuota proyek yang diizinkan untuk diambil oleh setiap siswa (misal: maksimal 3 proyek per siswa).

### 3. 📚 Modul Manajemen Proyek (Project Module)
- **Katalog Proyek:** Pengelolaan data master proyek (*CRUD* master data) yang nantinya dapat dipilih atau ditugaskan kepada siswa.

### 4. 🔗 Modul Penugasan & Relasi (Assignment & Enrollment Module)
- **Enrollment Manual:** Administrator dapat memasukkan seorang siswa ke dalam proyek tertentu secara spesifik.
- **Filter Proyek Tersedia:** Aplikasi pintar membedakan mana proyek yang sudah diambil dan mana yang belum diambil oleh seorang siswa.
- **Smart Auto-Assignment:** Fitur canggih yang secara otomatis menugaskan sisa proyek ke para siswa. Penugasan otomatis ini diurutkan (*sorted*) berdasarkan peringkat nilai tertinggi (siswa paling berprestasi mendapatkan prioritas proyek pertama).

---

## 🛠️ Teknologi & Arsitektur Sistem (Tech Stack)

### Backend (Server-Side)
Dibangun menggunakan prinsip arsitektur *N-Tier* (Layered Architecture):
- **Core Language:** Java 20
- **Framework Utama:** Spring Boot 4.0
- **Keamanan:** Spring Security 7.x & JJWT (io.jsonwebtoken)
- **Data Access & ORM:** Spring Data JPA (Hibernate)
- **Database Engine:** MySQL (Connector/J)
- **Build Tool:** Apache Maven

### Frontend (Client-Side)
- **Core Framework:** Angular 21 (*Zoneless Change Detection*, NgModules)
- **Desain & UI/UX:** Custom CSS (dengan palet warna *slate*, *indigo*, dan antarmuka *modern light mode*)
- **Komunikasi Data:** `HttpClientModule` dan `RxJS` Observables

### Mengapa Menggunakan Arsitektur Monolith, Bukan Microservice?
Saat ini, backend menggunakan pendekatan **Monolith** (seluruh modul digabung dalam satu server) daripada **Microservice** (pemecahan fitur menjadi banyak server mandiri). Keputusan ini diambil berdasarkan pertimbangan berikut:
1. **Mencegah Over-Engineering:** Untuk cakupan fitur saat ini, arsitektur *microservice* akan menambah kerumitan infrastruktur (seperti *Network Latency*, sinkronisasi transaksi data terdistribusi, dan keharusan menggunakan orkestrasi seperti Kubernetes) yang tidak sebanding dengan kebutuhannya.
2. **Kecepatan Pengembangan:** Monolith memungkinkan proses *build*, pengujian (*testing*), dan pemecahan masalah (*debugging*) yang lebih cepat dan terpusat.
3. **Peluang Ekspansi di Masa Depan:** Aplikasi ini sudah dibangun dengan pola *N-Tier / Layered* yang rapi. Apabila di masa mendatang beban *traffic* meledak dan fungsionalitas menjadi raksasa, aplikasi ini dapat dengan mudah dipecah (dimigrasi) menjadi layanan-layanan mikro yang terpisah (*Auth Service*, *Student Service*, dll).

---

## 📂 Struktur Repositori Terperinci (Directory Structure)

```text
student-management-apps/
├── api-documentation.rest    # File interaktif (REST Client) dokumentasi seluruh API
├── README.md                 # Dokumentasi proyek ini
│
├── backend/                  # SERVER-SIDE SPRING BOOT
│   ├── pom.xml               # Konfigurasi dependensi Maven
│   ├── src/main/resources/
│   │   └── application.properties # Konfigurasi Database & Hibernate (PORT 9090)
│   └── src/main/java/com/satya/assignment/
│       ├── controller/       # Layer HTTP Endpoint (Routing & Request Handling)
│       ├── model/            # Layer Entitas JPA (Tabel Database)
│       │   ├── AppUser.java  # Entitas Akun Administrator
│       │   ├── Student.java  # Entitas Siswa
│       │   └── Project.java  # Entitas Proyek
│       ├── repository/       # Layer Komunikasi ke Database (CRUD Otomatis)
│       ├── security/         # Layer Keamanan (Filter JWT, Config Security, dsb)
│       └── config/           # Layer Bootstraping (DataInitializer - Auto Create Admin)
│
└── frontend/                 # CLIENT-SIDE ANGULAR
    ├── angular.json          # Konfigurasi workspace Angular (SSR dinonaktifkan)
    ├── public/               # File statis dan aset grafis (Logo, favicon, dll)
    └── src/app/              # Kode utama aplikasi
        ├── auth/             # Logika Autentikasi (Service, Interceptor, Guard)
        ├── login/            # UI Form Login (Mendukung validasi username/password)
        ├── student-*/        # Modul/UI terkait pengolahan Siswa & Form
        ├── project-*/        # Modul/UI terkait pengolahan Proyek Master
        └── assignment/       # Modul/UI terkait Algoritma Penugasan Proyek
```

---

## 📋 Persyaratan Sistem (Prerequisites)

Sebelum Anda menjalankan proyek ini, pastikan komputer Anda telah terinstal:
1. **Java Development Kit (JDK):** Versi 20 atau lebih baru.
2. **Node.js & npm:** Node.js versi LTS (v18/v20) untuk menjalankan Angular.
3. **Database MySQL:** Server MySQL yang berjalan di komputer lokal Anda (biasanya port 3306).
4. **Angular CLI (Opsional):** Disarankan menginstal Angular CLI secara global (`npm install -g @angular/cli`).

---

## 🚀 Panduan Instalasi dan Menjalankan Proyek (Setup Guide)

### Langkah 1: Persiapan Database
1. Buka MySQL / phpMyAdmin / DBeaver Anda.
2. Buat database baru (jika belum ada) sesuai dengan nama yang ada pada konfigurasi `application.properties` (misalnya: `projectassignment`).
3. Spring Data JPA telah diatur dengan konfigurasi *auto-ddl* (`update`), sehingga tabel `student`, `project`, `student_project`, dan `app_user` akan otomatis dibuat oleh sistem saat backend dinyalakan.

### Langkah 2: Menjalankan Backend (Spring Boot)
1. Buka terminal (CLI) baru, navigasikan ke folder `backend`:
   ```bash
   cd /path/to/student-management-apps/backend
   ```
2. Jalankan perintah Maven berikut untuk mengompilasi dan memulai server:
   ```bash
   ./mvnw spring-boot:run
   ```
3. Tunggu hingga muncul tulisan `Tomcat started on port 9090`. 
   *(Sistem secara otomatis akan mengeksekusi kelas `DataInitializer` yang membuat 1 user admin dengan kredensial `admin` / `admin` jika belum ada di database).*

### Langkah 3: Menjalankan Frontend (Angular)
1. Buka tab terminal baru, navigasikan ke folder `frontend`:
   ```bash
   cd /path/to/student-management-apps/frontend
   ```
2. (Opsional, hanya pertama kali) Instal semua dependensi eksternal:
   ```bash
   npm install
   ```
3. Mulai server pengembangan Angular:
   ```bash
   ng serve
   ```
4. Buka *web browser* (Chrome/Firefox/Safari) dan akses tautan berikut:
   **👉 `http://localhost:4200`**

---

## 🔑 Login & Kredensial Default

Setelah Anda membuka aplikasi di peramban, Anda akan dicegat oleh halaman Login karena perlindungan rute (*AuthGuard*). Gunakan akses ini untuk masuk:

* **Username:** `admin`
* **Password:** `admin`

---

## 🛠️ Penyelesaian Masalah Umum (Troubleshooting)

* **Data tidak muncul di tabel / UI kosong:**
  Angular 21 menggunakan *Zoneless Change Detection* secara default. Semua komponen harus menggunakan `ChangeDetectorRef.detectChanges()` setelah menerima data dari HTTP response. Hal ini sudah diterapkan pada semua komponen di aplikasi ini.
* **Error CORS di peramban / Data gagal dimuat:**
  Pastikan backend telah berhasil menyala di port `9090`. Konfigurasi CORS dikelola secara terpusat melalui `SecurityConfig.java` (bukan `@CrossOrigin` per controller). Origin yang diizinkan: `http://localhost:*` dan `http://127.0.0.1:*`.
* **Error Port Terpakai (Address already in use):**
  Jika port `9090` atau `4200` sudah dipakai oleh program lain, matikan program tersebut atau ubah port sementara di `application.properties` (untuk Spring Boot) atau jalankan `ng serve --port 4201` (untuk Angular).
* **Error 403 saat PUT/POST Student:**
  Jika muncul error 403 saat mengupdate atau menambah student, pastikan model `Student.java` tidak menggunakan `@JsonManagedReference` dan model `Project.java` menggunakan `@JsonIgnore` (bukan `@JsonBackReference`) pada field `students`. Anotasi `@JsonManagedReference`/`@JsonBackReference` tidak kompatibel dengan relasi `@ManyToMany`.
* **SSR (Server-Side Rendering):**
  SSR telah dinonaktifkan pada proyek ini (`angular.json` tidak memuat konfigurasi `server` dan `ssr`). Hal ini dilakukan untuk menghindari *hydration mismatch* yang menyebabkan data tidak tampil di browser.

---

## 📝 Catatan Teknis Penting

* **Environment URL:** Semua service frontend (`student-api.ts`, `project-api.ts`, `auth.service.ts`) menggunakan `http://127.0.0.1:9090` sebagai base URL. Ini lebih stabil dibanding `localhost` pada macOS karena menghindari resolusi IPv6.
* **Autentikasi:** Aplikasi menggunakan JWT Authentication (bukan OAuth). Token disimpan di `localStorage` browser dan dikirim otomatis melalui `AuthInterceptor`.
* **Jackson Serialization:** Relasi `@ManyToMany` antara Student dan Project menggunakan `@JsonIgnore` pada sisi Project untuk mencegah infinite recursion, bukan `@JsonManagedReference`/`@JsonBackReference`.
