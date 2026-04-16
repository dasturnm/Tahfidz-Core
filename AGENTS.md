// lib/core/constants/agents_prompt.dart
// Prompt standar AI untuk proyek Tahfidz Core
// Versi: v2026.03.22 FINAL

const String kAgentsPrompt = r'''
AGENTS.md — Panduan AI & Standar Koding Tahfidz Core (v2026.03.22 FINAL)

Dokumen ini adalah ATURAN ABSOLUT (STRICT RULES) yang WAJIB dipatuhi oleh AI
(GPT, Gemini, Claude, dll) maupun developer dalam mengedit, membuat, atau
menganalisis kode pada proyek Tahfidz Core.

Kegagalan mengikuti aturan ini dianggap sebagai KEGAGALAN TUGAS.

════════════════════════════════════════════════════════════
1. IDENTITAS PROYEK & TECH STACK
   ════════════════════════════════════════════════════════════

- Nama Proyek : Tahfidz Core
- Framework   : Flutter (Dart)
- State Mgmt  : Riverpod (riverpod_annotation + code generation)
- Backend/BaaS: Supabase (PostgreSQL)
- Arsitektur  : Feature-First (Modular Architecture)

════════════════════════════════════════════════════════════
2. PRINSIP ARSITEKTUR UTAMA (FEATURE-FIRST)
   ════════════════════════════════════════════════════════════

AI DILARANG KERAS mencampur tanggung jawab antar layer.

── lib/core/  (Pondasi Global) ──────────────────────────────
services/base_service.dart       → logika dasar database & keamanan
providers/app_context_provider.dart → state lembaga/cabang aktif
constants/                       → warna, ukuran, routing

── lib/features/[nama_fitur]/  (Modular Feature) ────────────
models/    → definisi data
services/  → CRUD Supabase + business logic murni
providers/ → state management (Riverpod)
screens/   → halaman utama (navigasi + layout)
widgets/   → komponen reusable kecil

── lib/shared/  (Reusable Global) ───────────────────────────
Digunakan jika dipakai minimal oleh 3 fitur.
Contoh: ProfileModel, shared widgets

════════════════════════════════════════════════════════════
3. PEMBAGIAN TANGGUNG JAWAB LAYER (WAJIB DIPATUHI)
   ════════════════════════════════════════════════════════════

3.1 MODELS
- Hanya berisi struktur data
- Tidak boleh ada logic UI atau network

3.2 SERVICES
BOLEH  : Query Supabase (CRUD), business logic murni
DILARANG: BuildContext, SnackBar, Dialog, UI apapun
WAJIB  : extends BaseService

3.3 PROVIDERS
- Mengelola state (Riverpod)
- Menghubungkan Service ↔ UI
- Mengambil konteks global secara reaktif

3.4 UI (Screens & Widgets)
- Hanya untuk tampilan & interaksi user
- Tidak boleh ada query database langsung

════════════════════════════════════════════════════════════
4. PROTOKOL BASESERVICE (ANTI DATA LEAK)
   ════════════════════════════════════════════════════════════

Semua service yang terhubung ke database WAJIB:
- extends BaseService
- applyLembagaFilter() → filter multi-tenant
- cleanData()          → ubah string kosong jadi null
- toSafeId(dynamic)    → safe UUID casting
- toSafeDate(dynamic)  → safe date parsing

PERINGATAN: Tanpa ini = RAWAN DATA BOCOR / ERROR DATABASE

════════════════════════════════════════════════════════════
5. ARSITEKTUR MODEL & DATABASE
   ════════════════════════════════════════════════════════════

5.1 SHARED MODELS  →  lib/shared/models/
Untuk entitas global:
- ProfileModel  (SEMUA role: user, guru, staff, admin)
- CabangModel
- LembagaModel

DILARANG membuat: UserModel, GuruModel, StaffModel
Gunakan 1 model + field `role`

5.2 FEATURE MODELS  →  lib/features/[fitur]/models/
Untuk entitas spesifik:
- SiswaModel
- KurikulumModel
- AgendaModel

5.3 NESTED MODEL RULE (PENTING)
Model turunan harus dalam FILE YANG SAMA.
Contoh kurikulum_model.dart berisi:
- Kurikulum
- Jenjang
- Level
- Modul
Tujuan: tidak mengotori namespace, mudah maintenance

════════════════════════════════════════════════════════════
6. STANDAR WAJIB CLASS MODEL
   ════════════════════════════════════════════════════════════

Setiap model HARUS memiliki:

1. Safe JSON Parsing
   id: json['id']?.toString()

2. Explicit Casting
   harga: (json['harga'] as num?)?.toDouble()

3. Safe Date Parsing
   DateTime.tryParse(json['tgl_lahir'].toString())

4. Snake → Camel Case
   nama_lengkap → namaLengkap

5. Method WAJIB
   fromJson / toJson / copyWith

6. Compatibility Bridge (jika ada perubahan field DB)
   String get nama => namaLengkap;

════════════════════════════════════════════════════════════
7. PROTOKOL PROVIDER (RIVERPOD)
   ════════════════════════════════════════════════════════════

- Gunakan @riverpod + code generation
- Penamaan singular:
  BENAR : SiswaProvider
  SALAH : SiswasProvider

Akses Context Global — WAJIB gunakan:
ref.watch(appContextProvider)

DILARANG: kirim lembagaId manual dari UI
jika sudah tersedia di appContextProvider

════════════════════════════════════════════════════════════
8. STANDAR UI & NAVIGASI
   ════════════════════════════════════════════════════════════

Navigasi   : context.go / context.pushNamed (sesuai app_routes.dart)
Async Safety (WAJIB): if (!context.mounted) return;

Theme Warna:
- Akademik / Kurikulum → Biru    #3B82F6
- Kesiswaan / SDM      → Emerald #10B981

Deprecated:
DILARANG : .withOpacity()
GUNAKAN  : .withValues(alpha: ...)

Relasi Supabase — WAJIB null check:
json['guru'] != null
? ProfileModel.fromJson(json['guru'])
: null

════════════════════════════════════════════════════════════
9. PROTOKOL SAFE CODE UPDATE (KRITIS)
   ════════════════════════════════════════════════════════════

Saat AI diminta update kode, WAJIB PATUH:
1. Jangan ubah kode di luar permintaan
2. Jangan rename apapun
3. Jangan refactor tanpa diminta
4. Jangan ubah urutan kode / import
5. Jangan hapus kode lama

OUTPUT WAJIB berformat:
SEBELUM
...

SESUDAH
...

Dan tampilkan SELURUH file (COPY-SAFE FULL CODE).
DILARANG menulis: // ... kode lainnya

════════════════════════════════════════════════════════════
10. PROSEDUR ERROR & WARNING HANDLING
    ════════════════════════════════════════════════════════════

Prioritas perbaikan:
1. uri_does_not_exist
2. unused_import
3. Hindari: ! (unnecessary_non_null_assertion)

════════════════════════════════════════════════════════════
11. ALUR PEMBUATAN FITUR (WAJIB URUT)
    ════════════════════════════════════════════════════════════

Urutan WAJIB saat membuat fitur baru:
1. Model
2. Service  (extends BaseService)
3. Provider
4. UI       (Screen + Widget)

════════════════════════════════════════════════════════════
12. PRINSIP UTAMA TAHFIDZ CORE
    ════════════════════════════════════════════════════════════

- Predictable  : tidak mengejutkan
- Aman         : anti data leak
- Strict separation of concerns
- Scalable     : siap besar

════════════════════════════════════════════════════════════
PESAN FINAL UNTUK AI
════════════════════════════════════════════════════════════

Jika Anda membaca file ini:
- Anda WAJIB patuh 100%
- JANGAN PERNAH berasumsi
- SELALU tanyakan jika ragu

Prioritaskan:
1. Keamanan data
2. Konsistensi arsitektur
3. Kode yang stabil & tidak breaking
''';