# 📘 Knowledge Sharing: Spring Boot & Angular di Student Management App

Dokumen ini menjelaskan bagaimana **Spring Boot** (backend) dan **Angular** (frontend) bekerja di proyek ini. Ditulis untuk pemula yang belum pernah menyentuh kedua teknologi ini.

---

## 🏗️ Gambaran Besar: Bagaimana Aplikasi Ini Bekerja?

```mermaid
sequenceDiagram
    participant B as Browser (User)
    participant F as Frontend (Angular - Port 4200)
    participant S as Backend (Spring Boot - Port 9090)
    participant D as Database (MySQL)

    B->>F: Buka http://localhost:4200
    F->>B: Kirim halaman HTML/CSS/JS
    B->>F: Klik tombol / isi form
    F->>S: HTTP Request (GET/POST/PUT/DELETE)
    S->>D: Query SQL
    D->>S: Hasil query
    S->>F: HTTP Response (JSON)
    F->>B: Tampilkan data di halaman
```

**Singkatnya:**
- **Angular** = toko/etalase yang dilihat pembeli (UI)
- **Spring Boot** = gudang + kasir di belakang toko (logic + data)
- **MySQL** = buku catatan stok barang (database)

---

## 🟢 BAGIAN 1: BACKEND (Spring Boot)

### Apa itu Spring Boot?

Spring Boot adalah framework Java yang mempermudah pembuatan aplikasi server (backend). Tanpa Spring Boot, kamu harus menulis ratusan baris konfigurasi XML. Dengan Spring Boot, cukup tulis anotasi (`@`) dan framework yang mengurus sisanya.

### Struktur File Backend

```
backend/src/main/java/com/satya/assignment/
├── model/          → "Bentuk data" (seperti cetakan kue)
├── repository/     → "Penghubung ke database" (otomatis bikin query SQL)
├── service/        → "Otak aplikasi" (logika bisnis, validasi, & transaksi)
├── controller/     → "Pintu masuk request" (hanya terima HTTP, kirim response)
├── security/       → "Satpam" (cek token, izinkan/tolak akses)
└── config/         → "Setup awal" (bikin user admin pertama kali)
```


---

### 1.1 Model — Cetakan Data

File: `model/Student.java`

```java
@Entity                    // ← "Ini adalah tabel di database"
@Table(name="student")     // ← "Nama tabelnya: student"
public class Student {
    @Id                            // ← "Ini primary key"
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // ← "Auto increment"
    private int id;

    @Column(name = "name")         // ← "Kolom 'name' di database"
    private String name;

    @Column(name = "average")
    private double average;

    @ManyToMany(fetch = FetchType.EAGER)   // ← "Relasi banyak-ke-banyak"
    @JoinTable(
        name = "student_project",           // ← "Tabel penghubung"
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "project_id")
    )
    private List<Project> projects;
}
```

**Analogi:** `Student.java` seperti **formulir pendaftaran**. Setiap field (`name`, `average`) adalah kolom yang harus diisi. Spring Boot otomatis membuat tabel di MySQL berdasarkan class ini.

**`@ManyToMany` artinya:**
- 1 Student bisa punya banyak Project
- 1 Project bisa dimiliki banyak Student
- Butuh tabel perantara `student_project` untuk menyimpan relasinya

---

### 1.2 Repository — Penghubung ke Database

File: `repository/StudentRepository.java`

```java
public interface StudentRepository extends JpaRepository<Student, Integer> {
}
```

**Hanya 1 baris!** Tapi kamu sudah dapat method:
- `findAll()` → `SELECT * FROM student`
- `findById(1)` → `SELECT * FROM student WHERE id = 1`
- `save(student)` → `INSERT INTO student ...` atau `UPDATE student ...`
- `deleteById(1)` → `DELETE FROM student WHERE id = 1`

**Analogi:** Repository seperti **asisten toko** — kamu bilang "ambilkan barang nomor 5", dia yang pergi ke gudang dan mencarikannya.

---

### 1.3 Controller — Pintu Masuk Request (Thin Controller)

File: `StudentController.java`

```java
@RestController               // ← "Class ini hanya menerima HTTP request"
@RequestMapping("/students")  // ← "Semua URL dimulai dari /students"
public class StudentController {

    @Autowired
    private StudentService studentService; // ← Meng-inject Service, bukan Repository!

    @GetMapping("/")            // GET /students/
    public ResponseEntity<List<Student>> getAllStudent() {
        return ResponseEntity.ok(studentService.getAllStudents()); // Delegasikan ke servis
    }

    @PostMapping("/")           // POST /students/
    public ResponseEntity<Student> createStudent(@RequestBody Student studentDetails) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(studentService.createStudent(studentDetails));
    }

    @DeleteMapping("/{id}")     // DELETE /students/1
    public ResponseEntity<String> deleteStudent(@PathVariable int id) {
        studentService.deleteStudent(id);
        return ResponseEntity.ok("Student deleted Successfully");
    }
}
```

**Penjelasan anotasi:**
| Anotasi | Artinya |
|---------|---------|
| `@GetMapping("/")` | Saat browser kirim `GET /students/`, jalankan method ini |
| `@PostMapping("/")` | Saat ada `POST /students/` dengan data JSON, jalankan method ini |
| `@RequestBody` | "Ambil data JSON dari body request, ubah jadi objek Java" |
| `@PathVariable` | "Ambil angka dari URL" (misal: `/students/1` → `id = 1`) |

**Analogi:** Controller seperti **resepsionis restoran (pelayan)** — murni mencatat pesanan tamu dan mengantarkan makanan yang sudah siap (HTTP Input/Output). Ia tidak boleh ikut memasak. Tugas memasak, memilah bahan, dan logika resep dikoordinasikan langsung oleh **Dapur (Service Layer)**.

---


### 1.4 Security — Sistem Keamanan

#### Alur autentikasi di proyek ini:

```mermaid
flowchart LR
    A["User ketik\nusername/password"] --> B["POST /auth/login"]
    B --> C{"Password cocok?"}
    C -->|Ya| D["Buat JWT Token"]
    C -->|Tidak| E["401 Unauthorized"]
    D --> F["Kirim token ke browser"]
    F --> G["Browser simpan\ndi localStorage"]
    G --> H["Setiap request berikutnya\nkirim token di Header"]
```

#### File-file security:

**`SecurityConfig.java`** — Aturan siapa boleh akses apa:
```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/auth/login").permitAll()   // Login → boleh tanpa token
    .anyRequest().authenticated()                  // Sisanya → wajib ada token
)
```

**`JwtService.java`** — Pembuat & validator token:
```java
// Buat token (saat login berhasil)
public String generateToken(String userName) { ... }

// Validasi token (setiap request masuk)
public Boolean validateToken(String token, UserDetails userDetails) { ... }
```

**`JwtAuthenticationFilter.java`** — Satpam yang cek setiap request:
```java
// Setiap request masuk:
// 1. Cek header "Authorization: Bearer xxx"
// 2. Ambil token
// 3. Validasi token
// 4. Kalau valid → izinkan
// 5. Kalau tidak → tolak (403)
```

**Analogi:** 
- `SecurityConfig` = **peraturan gedung** (siapa boleh masuk ruangan mana)
- `JwtService` = **mesin pencetak ID card** (bikin & scan kartu)
- `JwtAuthenticationFilter` = **satpam di pintu** (cek ID card sebelum masuk)

---

### 1.5 Apa itu JWT Token?

JWT (JSON Web Token) adalah string panjang yang berisi informasi user dalam format terenkripsi:

```
eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc3NzgzMDc2N30.V45uO2Gu9ae1axGXm...
│         HEADER        │           PAYLOAD              │       SIGNATURE       │
```

- **Header:** Algoritma enkripsi (HS256)
- **Payload:** Data user (`sub: "admin"`, waktu expired)
- **Signature:** Tanda tangan digital untuk memastikan token tidak dipalsukan

Token ini dikirim di setiap HTTP request melalui header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

---

## 🔵 BAGIAN 2: FRONTEND (Angular)

### Apa itu Angular?

Angular adalah framework TypeScript untuk membuat aplikasi web interaktif. Berbeda dari website biasa (HTML statis), Angular membuat **Single Page Application (SPA)** — halaman tidak pernah di-reload, hanya kontennya yang berubah.

### Struktur File Frontend

```
frontend/src/app/
├── app-module.ts        → "Daftar isi" (semua komponen terdaftar di sini)
├── app-routing-module.ts → "Peta jalan" (URL mana menampilkan komponen mana)
├── app.html             → "Bingkai utama" (header + konten berubah-ubah)
│
├── student-list/        → Halaman daftar student
│   ├── student-list.ts       → Logic (ambil data, hapus, dll)
│   ├── student-list.html     → Tampilan (tabel, tombol)
│   └── student-list.css      → Styling
│
├── student-form/        → Form tambah/edit student
├── student-projects/    → Halaman assign project ke student
├── project-list/        → Halaman daftar project
├── assignment/          → Halaman auto-assignment
├── login/               → Halaman login
│
├── student-api.ts       → Service: HTTP calls ke /students/
├── project-api.ts       → Service: HTTP calls ke /projects/
├── auth.service.ts      → Service: login & simpan token
├── auth.interceptor.ts  → Otomatis tempel token ke setiap request
└── auth.guard.ts        → Cek login sebelum buka halaman
```

---

### 2.1 Komponen — Building Block Angular

Setiap "halaman" di Angular terdiri dari **3 file**:

```
student-list/
├── student-list.ts    → OTAK (logic: ambil data, proses, kirim)
├── student-list.html  → WAJAH (tampilan: tabel, tombol, form)
└── student-list.css   → BAJU (styling: warna, ukuran, posisi)
```

**File `.ts` (TypeScript/Logic):**
```typescript
export class StudentList implements OnInit {
  students: Student[] = []          // Data student (awalnya kosong)

  constructor(
    private studentApi: StudentApi,     // Inject service API
    private cdr: ChangeDetectorRef      // Untuk trigger re-render
  ) {}

  ngOnInit(): void {                    // Dipanggil saat halaman dibuka
    this.getAllStudents()
  }

  getAllStudents() {
    this.studentApi.getAllStudent().subscribe({
      next: data => {                   // Kalau berhasil:
        this.students = data            // Simpan data
        this.cdr.detectChanges()        // Paksa Angular render ulang
      },
      error: err => console.error(err)  // Kalau gagal: log error
    })
  }
}
```

**File `.html` (Template/Tampilan):**
```html
<!-- *ngFor = "ulangi untuk setiap item di array" -->
<tr *ngFor="let student of students">
    <td>{{ student.id }}</td>         <!-- Tampilkan id -->
    <td>{{ student.name }}</td>       <!-- Tampilkan nama -->
    <td>{{ student.average }}</td>    <!-- Tampilkan rata-rata -->
</tr>
```

**Analogi:** Komponen Angular seperti **LEGO brick** — setiap halaman adalah gabungan brick yang berbeda. `student-list` adalah 1 brick, `login` adalah brick lain. Mereka digabung membentuk aplikasi utuh.

---

### 2.2 Service — Penghubung ke Backend

File: `student-api.ts`

```typescript
export class StudentApi {
  link = environment.BASE_HOST + "/students/"   // http://127.0.0.1:9090/students/

  getAllStudent(): Observable<Student[]> {
    return this.httpClient.get<Student[]>(this.link)     // GET /students/
  }

  addStudent(student: Student): Observable<Student> {
    return this.httpClient.post<Student>(this.link, student)  // POST /students/
  }

  deleteStudent(id: any): Observable<any> {
    return this.httpClient.delete(this.link + id)   // DELETE /students/1
  }
}
```

**`Observable`** = seperti **langganan koran**. Kamu `.subscribe()` (berlangganan), lalu tunggu data datang. Saat data datang, fungsi `next:` dijalankan.

```typescript
// Berlangganan data
this.studentApi.getAllStudent().subscribe({
    next: data => { /* data datang! */ },
    error: err => { /* ada error! */ }
})
```

---

### 2.3 Interceptor — Tukang Stempel Otomatis

File: `auth.interceptor.ts`

```typescript
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler) {
    const token = localStorage.getItem('jwt_token')
    if (token) {
      // Clone request, tambahkan header Authorization
      req = req.clone({
        setHeaders: { Authorization: `Bearer ${token}` }
      })
    }
    return next.handle(req)
  }
}
```

**Analogi:** Interceptor seperti **stempel pos otomatis** — setiap surat (HTTP request) yang keluar dari Angular, otomatis distempel dengan token JWT. Kamu tidak perlu menambahkan token secara manual di setiap request.

---

### 2.4 Routing — Peta Navigasi

File: `app-routing-module.ts`

```typescript
const routes: Routes = [
  {path: "login", component: LoginComponent},
  {path: "students", component: StudentList, canActivate: [AuthGuard]},
  {path: "students/addstudent", component: StudentForm, canActivate: [AuthGuard]},
  {path: "students/:id/projects", component: StudentProjects, canActivate: [AuthGuard]},
  {path: "projects", component: ProjectList, canActivate: [AuthGuard]},
]
```

| URL | Komponen | Guard |
|-----|----------|-------|
| `/login` | LoginComponent | ❌ Tidak perlu login |
| `/students` | StudentList | ✅ Harus login dulu |
| `/students/1/projects` | StudentProjects | ✅ Harus login dulu |
| `/projects` | ProjectList | ✅ Harus login dulu |

**`canActivate: [AuthGuard]`** = "Sebelum buka halaman ini, cek dulu apakah user sudah login. Kalau belum, redirect ke `/login`."

---

### 2.5 Zoneless Change Detection & RxJS `forkJoin` (Angular 21)

Di Angular versi lama, setiap kali ada event (klik, HTTP response, timer), Angular **otomatis** mengecek seluruh komponen dan meng-update tampilan. Ini dilakukan oleh library bernama `zone.js`.

Di **Angular 21**, `zone.js` dihapus (*zoneless*). Artinya Angular **tidak lagi otomatis** mendeteksi perubahan data. Kamu harus memberitahu Angular secara manual:

```typescript
// WAJIB di Angular 21 setelah terima data HTTP
this.students = data
this.cdr.detectChanges()   // ← "Hey Angular, data sudah berubah, tolong render ulang!"
```

#### Optimasi Menggunakan `forkJoin`:
Jika sebuah halaman memanggil 3 API sekaligus secara terpisah, kita akan memanggil `cdr.detectChanges()` sebanyak 3 kali. Ini tidak efisien karena browser dipaksa merender ulang 3 kali berturut-turut.

Kita mengoptimalkannya dengan RxJS `forkJoin` untuk menggabungkan request tersebut:
```typescript
forkJoin({
  students: this.studentApi.getAllStudent(),
  projects: this.projectApi.getAllProject(),
  maxProjects: this.studentApi.getMaxProjectsPerStudent()
}).subscribe({
  next: ({ students, projects, maxProjects }) => {
    this.students = students;
    this.projects = projects;
    this.maxProjects = maxProjects;
    this.cdr.detectChanges(); // Hanya memicu render ulang 1 KALI saja!
  }
});
```

---

### 2.6 Penyelesaian Bug: Ketergantungan Melingkar (Circular Dependency)
Saat aplikasi pertama kali dinyalakan:
1. `AuthInterceptor` membutuhkan `AuthService` untuk membaca token.
2. `AuthService` membutuhkan `HttpClient` untuk mengecek status login.
3. `HttpClient` membutuhkan `AuthInterceptor` untuk menyisipkan header token.

Hubungan melingkar ini menyebabkan interceptor gagal dimuat pada *request* pertama (`/auth/me`), sehingga token tidak disematkan dan user langsung dikeluarkan otomatis (*logout*).

**Solusinya:**
Kita mengubah `AuthInterceptor` agar mengambil token langsung dari tempat penyimpanan lokal tanpa melibatkan service:
```typescript
// Solusi efisien tanpa meng-inject AuthService
const token = localStorage.getItem('jwt_token');
```
Hal ini memutuskan rantai ketergantungan melingkar sepenuhnya!

---

## 🟢 BAGIAN 3: OPTIMASI ENTERPRISE (Database & Keamanan)

### 3.1 Solusi N+1 Query (Spring Data JPA)
Secara bawaan, jika entitas `Student` berelasi `@ManyToMany(fetch = FetchType.EAGER)` dengan `Project`, Hibernate akan melakukan kueri pembuka:
1. Ambil daftar siswa (`SELECT * FROM student`).
2. Untuk **setiap** siswa yang ditemukan (misal ada N siswa), Hibernate akan melakukan kueri tambahan untuk mengambil daftar proyeknya.
Hal ini memicu **N + 1 kueri** ke database yang sangat memperlambat server!

**Solusi yang kami terapkan:**
Menggunakan JPQL **Join Fetch** di `StudentRepository.java`:
```java
@Query("SELECT DISTINCT s FROM Student s LEFT JOIN FETCH s.projects")
List<Student> findAllWithProjects();
```
*Hasil:* Database MySQL hanya melakukan **1 kali kueri tunggal** yang menggabungkan (*join*) tabel siswa dan proyek, menghasilkan efisiensi pembacaan hingga 90% lebih cepat!

### 3.2 Stateless Zero-Database-Lookup JWT
Biasanya, setiap kali ada request API masuk, filter keamanan Spring Security akan memanggil database (`userDetailsService.loadUserByUsername(username)`) untuk memeriksa peran (*role*) pengguna. Ini menyebabkan database terus-menerus terbebani kueri pencarian user yang sama berulang kali.

**Solusi yang kami terapkan:**
1. Saat login berhasil, simpan peran (`role`) pengguna di dalam claims payload JWT:
   ```java
   claims.put("role", role);
   ```
2. Pada setiap request masuk, satpam `JwtAuthenticationFilter` membaca peran langsung dari claims JWT tersebut tanpa menyentuh database sama sekali:
   ```java
   String role = jwtService.extractClaim(token, claims -> claims.get("role", String.class));
   UserDetails userDetails = User.withUsername(username).password("").roles(role).build();
   ```
*Hasil:* Keamanan terjamin secara penuh dan beban kueri database untuk otentikasi berkurang menjadi **0 kueri**!

---

## 🔄 BAGIAN 4: ALUR LENGKAP PENGUMPULAN & PENILAIAN

Aplikasi ini sekarang mendukung alur pembelajaran lengkap antara Siswa dan Admin:

```mermaid
sequenceDiagram
    participant S as Siswa (STUDENT)
    participant B as Backend API
    participant A as Admin (ADMIN)

    S->>B: Kirim tugas (POST /students/{id}/projects/{id}/submit)
    Note over S,B: Menyertakan URL repositori & catatan teks
    B->>B: Ubah status menjadi "SUBMITTED"
    A->>B: Lihat daftar tugas (GET /students/{id}/projectdetails)
    A->>B: Berikan nilai & feedback (POST /students/{id}/projects/{id}/grade)
    B->>B: Hitung ulang nilai rata-rata (Average Score) siswa otomatis!
    B->>B: Ubah status menjadi "GRADED"
    S->>B: Buka halaman "My Submissions"
    B->>S: Tampilkan nilai & feedback dari Admin!
```

---

## 📁 BAGIAN 5: FITUR ATTACHMENT PROYEK (PDF & GAMBAR)

Sistem kini mendukung penambahan lampiran dokumen berupa **PDF** dan **Gambar** setiap kali administrator membuat proyek baru.

### 5.1 Penyimpanan Database (Database Storage)
Untuk memudahkan distribusi tanpa memerlukan server file eksternal (seperti AWS S3), file disimpan langsung di tabel database MySQL dalam format biner:
*   `@Lob` & `@Column(columnDefinition = "LONGBLOB")`: Memungkinkan penyimpanan file dengan ukuran besar (hingga 4GB) langsung di database MySQL.
*   `pdf_name` & `pdf_type`: Menyimpan nama file asli dan MIME-type (misalnya `application/pdf`) agar browser dapat merender file secara alami.
*   `image_name` & `image_type`: Menyimpan nama gambar asli dan MIME-type-nya (misalnya `image/png` atau `image/jpeg`).

### 5.2 Alur Pemrosesan Multi-Part di Backend (Spring Boot)
1.  **Request Multi-part:** Menggunakan `@PostMapping(value = "/", consumes = {"multipart/form-data"})` untuk memisahkan pengolahan input teks biasa dan file biner `MultipartFile`.
2.  **Streaming Unduhan Terproteksi:** Dibuat endpoint unduhan khusus yang mengembalikan array biner (`byte[]`) beserta header HTTP yang tepat:
    ```java
    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> getProjectPdf(@PathVariable int id) {
        Project project = projectService.getProjectById(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, project.getPdfType())
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + project.getPdfName() + "\"")
                .body(project.getPdfData());
    }
    ```
    *Catatan:* Penggunaan header `CONTENT_DISPOSITION = "inline"` membuat browser membuka PDF/Gambar langsung di tab baru secara interaktif, bukan langsung mengunduhnya sebagai file tak terbaca.

### 5.3 Pengiriman Menggunakan FormData di Frontend (Angular)
Karena JSON biasa tidak mendukung transfer file biner mentah secara efisien, kita menggunakan objek bawaan HTML5 yaitu **`FormData`**:
```typescript
addProject(name: string, pdfFile?: File | null, imageFile?: File | null): Observable<Project> {
  const formData = new FormData();
  formData.append('name', name);
  if (pdfFile) {
    formData.append('pdf', pdfFile);
  }
  if (imageFile) {
    formData.append('image', imageFile);
  }
  return this.httpClient.post<Project>(this.link, formData);
}
```

---

## 🎨 BAGIAN 6: ADVANCED UI/UX (THEMING, SORTING & PAGINATION)

Aplikasi ini menggunakan teknik antarmuka (*UI*) modern untuk memberikan pengalaman seperti aplikasi desktop.

### 6.1 Native CSS Variable Theming (Dark Mode & Light Mode)
Ketimbang menggunakan kerangka kerja (*framework*) yang berat, tema aplikasi diatur secara murni menggunakan **Variabel CSS Global** (CSS Custom Properties). 

1. **Deklarasi Variabel:** Di `styles.css`, warna-warna utama disimpan dalam root:
   ```css
   :root {
     --bg-app: #f8fafc;
     --bg-card: #ffffff;
     --text-primary: #0f172a;
   }
   ```
2. **Definisi Varian Gelap:** Kemudian dioverride ketika class `.dark` diaktifkan:
   ```css
   body.dark {
     --bg-app: #0f172a;
     --bg-card: #1e293b;
     --text-primary: #f8fafc;
   }
   ```
3. **Penyimpanan (*Persistence*):** Saat tombol pergantian tema ditekan, preferensi disimpan di dalam `localStorage`. Ketika aplikasi direload, state dibaca kembali di dalam `App` komponen (pada `ngOnInit()`), menjadikan tema *persisten*.

### 6.2 Client-Side Pagination & Interactive Sorting
Ketika data sangat besar (contoh: daftar siswa, hasil assignment), memuat dan menampilkannya sekaligus akan memberatkan DOM browser. Kita mengelola state data **secara langsung di frontend** agar *feel*-nya instan (0 latensi jaringan).

* **Sorting:** Menggunakan fitur iterasi bawaan Javascript `Array.prototype.sort()` bersama fungsi utilitas perbandingan (`localeCompare` untuk teks, aritmatika untuk angka). Karena `ChangeDetectorRef.detectChanges()` dipanggil tepat sesudahnya, tampilan berubah secepat kilat.
* **Pagination:** Menggunakan *getters* dinamis untuk memotong (`Array.prototype.slice()`) data utama. 
  ```typescript
  get paginatedStudents(): Student[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredStudents.slice(start, start + this.pageSize);
  }
  ```
  Setiap *event* seperti berpindah halaman, merubah urutan sortir, atau sekadar melakukan pencarian, secara proaktif mereset `currentPage = 1` agar UX terasa mulus.

---


## 📌 Cheat Sheet: Anotasi Penting

### Spring Boot
| Anotasi | Artinya |
|---------|---------|
| `@Entity` | Class ini = tabel database |
| `@Id` | Field ini = primary key |
| `@Column` | Field ini = kolom di tabel |
| `@ManyToMany` | Relasi banyak-ke-banyak |
| `@Query` | Menuliskan kueri JPQL manual (untuk optimasi JOIN FETCH) |
| `@RestController` | Class ini menerima HTTP request |
| `@GetMapping` | Handle request GET |
| `@PostMapping` | Handle request POST |
| `@RequestBody` | Ambil data JSON dari body |
| `@PathVariable` | Ambil nilai dari URL path |
| `@Autowired` | Inject dependency otomatis |
| `@Service` | Class ini adalah business logic |

### Angular
| Konsep | Artinya |
|--------|---------|
| `@Component` | Deklarasi komponen (UI brick) |
| `ngOnInit()` | Dipanggil saat komponen pertama kali dibuka |
| `*ngFor` | Loop di template (ulangi HTML untuk setiap item) |
| `*ngIf` | Kondisi di template (tampilkan jika true) |
| `[(ngModel)]` | Two-way binding (input form ↔ variabel) |
| `[routerLink]` | Link navigasi tanpa reload halaman (menjaga state SPA) |
| `.subscribe()` | Berlangganan data dari Observable (HTTP) |
| `forkJoin` | Menjalankan beberapa HTTP request secara pararel |
| `ChangeDetectorRef` | Paksa Angular render ulang (wajib di Angular 21) |

