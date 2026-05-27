# Student Management Apps (Enterprise Edition)

**Student Management Apps** adalah sebuah aplikasi web *full-stack* modern yang dirancang untuk mengelola ekosistem akademik secara digital. Aplikasi ini memfasilitasi administrasi data siswa, daftar proyek (tugas akhir/kegiatan), hingga sistem *auto-assignment* (penugasan proyek cerdas berdasarkan peringkat nilai/average score).

Dikembangkan dengan memisahkan sisi *Client* (Frontend) dan *Server* (Backend), aplikasi ini mengedepankan keamanan berlapis, antarmuka pengguna yang responsif (*Light Theme*), serta arsitektur kode yang terstruktur.

---

## ✨ Ikhtisar Fitur Lengkap (Comprehensive Features)

### 1. 🛡️ Modul Keamanan & Autentikasi (Security Module)
- **JWT (JSON Web Token):** Sesi pengguna dikelola secara *stateless* menggunakan token JWT berstandar industri.
- **Role-based Authentication:** Mendukung multi-role terproteksi (`ADMIN` dan `STUDENT`). Administrator memiliki kontrol penuh atas manajemen data akademik, penugasan, dan penilaian. Siswa (`STUDENT`) memiliki portal khusus yang diproteksi untuk melihat daftar tugas serta mengunggah jawaban/tautan proyek (*Submissions*).
- **Route Protection:** Semua rute API (kecuali `/auth/login` dan `/auth/register`) dilindungi secara ketat oleh `Spring Security Filter Chain` di backend. Di sisi frontend, rute dilindungi oleh `AuthGuard` dari Angular.
- **HTTP Interceptor (Optimized):** Token autentikasi disematkan secara otomatis (*intercepted*) ke dalam *Header HTTP Authorization* pada setiap request. Menghapus ketergantungan melingkar (*circular dependency*) pada startup aplikasi dengan mengakses `localStorage` secara terpisah dari inisialisasi awal.
- **Zero-DB Lookup JWT Filter:** Sistem mengekstrak klaim nama pengguna dan peran (`role`) langsung dari token JWT terenkripsi untuk merekonstruksi context keamanan Spring Security secara instan. Ini menghilangkan pemanggilan kueri database kueri (`findByUsername`) ke tabel user pada setiap pemanggilan API, sehingga meningkatkan performa respon backend secara dramatis.

### 2. 👥 Modul Manajemen Siswa (Student Module)
- **Registrasi & Pendataan:** Menambah, mengubah, dan menghapus (*CRUD*) profil siswa beserta pencatatan skor rata-rata (*average score*).
- **Pembatasan Proyek:** Administrator dapat mengonfigurasi batas maksimal kuota proyek yang diizinkan untuk diambil oleh setiap siswa (misal: maksimal 3 proyek per siswa).

### 3. 📚 Modul Manajemen Proyek & Tugas (Project Module)
- **Katalog Proyek:** Pengelolaan data master proyek (*CRUD* master data) yang nantinya dapat dipilih atau ditugaskan kepada siswa.

### 4. 🔗 Modul Penugasan & Relasi (Assignment & Enrollment Module)
- **Enrollment Manual:** Administrator dapat memasukkan seorang siswa ke dalam proyek tertentu secara spesifik.
- **Filter Proyek Tersedia:** Aplikasi pintar membedakan mana proyek yang sudah diambil dan mana yang belum diambil oleh seorang siswa.
- **Smart Auto-Assignment:** Fitur canggih yang secara otomatis menugaskan sisa proyek ke para siswa. Penugasan otomatis ini diurutkan (*sorted*) berdasarkan peringkat nilai tertinggi (siswa paling berprestasi mendapatkan prioritas proyek pertama).

### 5. 📝 Modul Pengumpulan & Penilaian (Submissions & Grading Module)
- **Submission Portal (Student):** Siswa dapat menyertakan URL tautan (misalnya repositori GitHub) serta teks ringkasan untuk mengumpulkan pekerjaan proyek mereka.
- **Grading & Feedback (Admin):** Administrator dapat menilai pekerjaan siswa, memberikan skor numerik secara instan, serta menyertakan umpan balik (*feedback*) tekstual yang mendalam. Nilai rata-rata siswa otomatis diperbarui ketika nilai proyek diberikan.


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
- **Desain & UI/UX:** Custom CSS dengan antarmuka yang sangat premium dan interaktif. Mendukung **Dark Mode** dan **Light Mode** yang persisten (disimpan di `localStorage`), animasi halus, tabel yang bisa diurutkan secara interaktif (*Interactive Sorting*), dan **Pagination** pada sisi klien untuk menangani data berjumlah besar.
- **Komunikasi Data:** `HttpClientModule` dan `RxJS` Observables

### Mengapa Menggunakan Arsitektur Monolith, Bukan Microservice?
Saat ini, backend menggunakan pendekatan **Monolith** (seluruh modul digabung dalam satu server) daripada **Microservice** (pemecahan fitur menjadi banyak server mandiri). Keputusan ini diambil berdasarkan pertimbangan berikut:
1. **Mencegah Over-Engineering:** Untuk cakupan fitur saat ini, arsitektur *microservice* akan menambah kerumitan infrastruktur (seperti *Network Latency*, sinkronisasi transaksi data terdistribusi, dan keharusan menggunakan orkestrasi seperti Kubernetes) yang tidak sebanding dengan kebutuhannya.
2. **Kecepatan Pengembangan:** Monolith memungkinkan proses *build*, pengujian (*testing*), dan pemecahan masalah (*debugging*) yang lebih cepat dan terpusat.
3. **Peluang Ekspansi di Masa Depan:** Aplikasi ini sudah dibangun dengan pola *N-Tier / Layered* yang rapi. Apabila di masa mendatang beban *traffic* meledak dan fungsionalitas menjadi raksasa, aplikasi ini dapat dengan mudah dipecah (dimigrasi) menjadi layanan-layanan mikro yang terpisah (*Auth Service*, *Student Service*, dll).

---

## 📊 Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    student {
        int id PK "AUTO_INCREMENT"
        varchar name
        double average
    }

    project {
        int id PK "AUTO_INCREMENT"
        varchar name
    }

    student_project {
        int student_id PK "FK"
        int project_id PK "FK"
    }

    student_project_detail {
        int id PK "AUTO_INCREMENT"
        int student_id "FK"
        int project_id "FK"
        datetime start_date
        datetime end_date
        varchar status "ASSIGNED, SUBMITTED, GRADED"
        double grade
        varchar feedback
        varchar submission_url
        varchar submission_text
        datetime submitted_at
        varchar book_id "FK (Logical to mylib-be)"
    }

    book {
        varchar id PK "UUID"
        varchar title
        varchar author
        varchar isbn
        varchar synopsis
        varchar thumbnail_url
    }

    app_user {
        bigint id PK "AUTO_INCREMENT"
        varchar username
        varchar password
        varchar role
    }

    student ||--o{ student_project : "ManyToMany enrollment"
    project ||--o{ student_project : "ManyToMany enrollment"
    student ||--o{ student_project_detail : "has assignment dates/grades"
    project ||--o{ student_project_detail : "assigned under dates"
    student_project_detail }o--..|| book : "references book (Logical BFF)"
```

### Penjelasan Relasi
- **Student ↔ Project:** Relasi *Many-to-Many* murni melalui tabel junction `student_project` (kolom `project_order` telah dihapus secara permanen dari skema database agar data tidak melahirkan *gap null*).
- **student_project_detail:** Tabel pencatatan transaksional penugasan proyek. Menyimpan relasi foreign key dari `student_id` dan `project_id` beserta metadata penugasan seperti rentang waktu aktif (*Start & End Date*), tautan deliverable (*Submission URL* & *Comments*), riwayat penilaian (*Grade* & *Feedback*), dan status tugas.
- **student_project_detail ↔ Book:** Relasi logis asinkronus berbasis arsitektur **BFF (Backend-For-Frontend)**. Kolom `book_id` menyimpan UUID buku referensi yang dikonsumsi secara dinamis melalui REST API microservice `mylib-be` (tanpa perlu melakukan replikasi tabel buku di database lokal).
- **AppUser:** Entitas kredensial terpisah untuk modul keamanan dan autentikasi login (ADMIN / STUDENT).

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
│       ├── service/          # Layer Logika Bisnis & Transaksi Database (Otak Aplikasi)
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

## 📝 Catatan Teknis & Optimasi Performa (Technical Notes & Optimizations)

* **Zero-Database-Lookup JWT Filter (Keamanan & DB):** 
  Autentikasi pada setiap *HTTP request* biasanya memicu kueri pencarian user ke database (`loadUserByUsername`). Di proyek ini, `JwtAuthenticationFilter` dioptimalkan untuk memuat data peran (`role`) langsung dari klaim payload token JWT. Ini memotong overhead kueri database untuk autentikasi menjadi **0 kueri**, membuat aplikasi sangat cepat menangani ribuan *request* konkuren.
* **Resolusi Masalah N+1 Kueri JPA (Hibernate):**
  Relasi `@ManyToMany` dengan mode EAGER pada entitas `Student` berpotensi memicu masalah N+1 kueri (1 kueri student memicu N kueri proyek tambahan). Kami mengoptimalkannya dengan menuliskan JPQL *Join Fetch* khusus di `StudentRepository.java`:
  `@Query("SELECT DISTINCT s FROM Student s LEFT JOIN FETCH s.projects")`
  Hal ini mereduksi kueri database penarikan grafik data siswa beserta daftar proyeknya menjadi tepat **1 kueri database tunggal**.
* **RxJS `forkJoin` Stream Merging (Frontend Render):**
  Pada zoneless Angular 21, setiap panggilan API asinkronus yang memicu `ChangeDetectorRef.detectChanges()` dapat menyebabkan siklus rendering ulang browser berulang-ulang secara beruntun. Kami mengoptimalkan halaman *Dashboard* dan *Student List* untuk menembakkan seluruh *HTTP request* secara pararel menggunakan RxJS `forkJoin` dan hanya memicu deteksi perubahan tepat **1 kali** setelah seluruh data selesai diterima.
* **SPA Routing (`routerLink` vs `href`):**
  Seluruh link navigasi internal di header dan dashboard menggunakan `routerLink` milik Angular. Hal ini menghindari terjadinya *full browser refresh* (pemuatan ulang halaman utuh) saat berpindah menu yang biasanya merusak state sesi aktif dan memicu bug otentikasi bootstrap awal.
* **Environment URL:** Semua service frontend (`student-api.ts`, `project-api.ts`, `auth.service.ts`) menggunakan `http://127.0.0.1:9090` sebagai base URL. Ini lebih stabil dibanding `localhost` pada macOS karena menghindari resolusi IPv6.
* **Autentikasi:** Aplikasi menggunakan JWT Authentication (bukan OAuth). Token disimpan di `localStorage` browser dan dikirim otomatis melalui `AuthInterceptor`.
* **Jackson Serialization:** Relasi `@ManyToMany` antara Student dan Project menggunakan `@JsonIgnore` pada sisi Project untuk mencegah infinite recursion, bukan `@JsonManagedReference`/`@JsonBackReference`.
* **Client-Side State Management (Frontend):** Fitur seperti pengurutan (*sorting*) tabel dan *pagination* diterapkan pada sisi *client* di memory (*in-memory processing*). Hal ini membuat transisi antar halaman tabel dan pengurutan data terasa seketika (0 ms) tanpa perlu melakukan *network roundtrip* ke server backend, memastikan pengalaman pengguna (*User Experience*) terbaik.
* **Semantic CSS Variables untuk Theming:** Implementasi Dark Mode dan Light Mode dikembangkan dengan sangat elegan murni menggunakan *Native CSS Custom Properties* (variabel CSS) pada elemen pseudo-class `:root` dan `body.dark`. Tidak membutuhkan framework eksternal raksasa yang memberatkan, sehingga memberikan performa ekstra optimal saat berganti tema secara seketika (*instant toggle*).

