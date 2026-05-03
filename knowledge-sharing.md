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
├── controller/     → "Pintu masuk request" (terima HTTP, kirim response)
├── security/       → "Satpam" (cek token, izinkan/tolak akses)
├── config/         → "Setup awal" (bikin user admin pertama kali)
└── dto/            → "Amplop surat" (format data request/response)
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

### 1.3 Controller — Pintu Masuk Request

File: `StudentController.java`

```java
@RestController             // ← "Class ini menerima HTTP request"
@RequestMapping("/students")   // ← "Semua URL dimulai dari /students"
public class StudentController {

    @GetMapping("/")            // GET /students/
    public List<Student> getAllStudents() {
        return studentRepo.findAll();   // Ambil semua dari database
    }

    @PostMapping("/")           // POST /students/
    public Student addStudent(@RequestBody Student student) {
        return studentRepo.save(student);  // Simpan ke database
    }

    @PutMapping("/{id}")        // PUT /students/1
    public Student updateStudent(@PathVariable int id, @RequestBody Student student) {
        student.setId(id);
        return studentRepo.save(student);  // Update di database
    }

    @DeleteMapping("/{id}")     // DELETE /students/1
    public void deleteStudent(@PathVariable int id) {
        studentRepo.deleteById(id);
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

**Analogi:** Controller seperti **resepsionis hotel** — terima permintaan tamu, lalu koordinasi dengan bagian terkait (repository) untuk memenuhi permintaan.

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

### 2.5 Zoneless Change Detection (Angular 21)

Di Angular versi lama, setiap kali ada event (klik, HTTP response, timer), Angular **otomatis** mengecek semua komponen dan update tampilan. Ini dilakukan oleh library bernama `zone.js`.

Di **Angular 21**, `zone.js` dihapus (*zoneless*). Artinya Angular **tidak lagi otomatis** mendeteksi perubahan data. Kamu harus memberitahu Angular secara manual:

```typescript
// WAJIB di Angular 21 setelah terima data HTTP
this.students = data
this.cdr.detectChanges()   // ← "Hey Angular, data sudah berubah, tolong render ulang!"
```

Tanpa `detectChanges()`, data sudah masuk ke variabel, tapi **tampilan tetap kosong** — itulah bug yang kita perbaiki sebelumnya.

---

## 🔄 BAGIAN 3: ALUR LENGKAP (End-to-End)

### Contoh: User membuka halaman Student List

```mermaid
flowchart TD
    A["User buka /students"] --> B["AuthGuard: ada token di localStorage?"]
    B -->|Tidak| C["Redirect ke /login"]
    B -->|Ya| D["Render StudentList component"]
    D --> E["ngOnInit() dipanggil"]
    E --> F["studentApi.getAllStudent() dipanggil"]
    F --> G["AuthInterceptor: tambah header Authorization: Bearer xxx"]
    G --> H["HTTP GET http://127.0.0.1:9090/students/"]
    H --> I["JwtAuthenticationFilter: validasi token"]
    I -->|Invalid| J["403 Forbidden"]
    I -->|Valid| K["StudentController.getAllStudents()"]
    K --> L["StudentRepository.findAll()"]
    L --> M["MySQL: SELECT * FROM student"]
    M --> N["Return data JSON ke Angular"]
    N --> O["this.students = data"]
    O --> P["cdr.detectChanges()"]
    P --> Q["Angular render tabel dengan *ngFor"]
    Q --> R["User melihat daftar student di browser"]
```

---

## 📌 Cheat Sheet: Anotasi Penting

### Spring Boot
| Anotasi | Artinya |
|---------|---------|
| `@Entity` | Class ini = tabel database |
| `@Id` | Field ini = primary key |
| `@Column` | Field ini = kolom di tabel |
| `@ManyToMany` | Relasi banyak-ke-banyak |
| `@RestController` | Class ini menerima HTTP request |
| `@GetMapping` | Handle request GET |
| `@PostMapping` | Handle request POST |
| `@RequestBody` | Ambil data JSON dari body |
| `@PathVariable` | Ambil nilai dari URL path |
| `@Autowired` | Inject dependency otomatis |
| `@Service` | Class ini adalah business logic |
| `@Configuration` | Class ini berisi konfigurasi |

### Angular
| Konsep | Artinya |
|--------|---------|
| `@Component` | Deklarasi komponen (UI brick) |
| `ngOnInit()` | Dipanggil saat komponen pertama kali dibuka |
| `*ngFor` | Loop di template (ulangi HTML untuk setiap item) |
| `*ngIf` | Kondisi di template (tampilkan jika true) |
| `[(ngModel)]` | Two-way binding (input form ↔ variabel) |
| `[routerLink]` | Link navigasi tanpa reload halaman |
| `.subscribe()` | Berlangganan data dari Observable (HTTP) |
| `ChangeDetectorRef` | Paksa Angular render ulang (wajib di Angular 21) |
