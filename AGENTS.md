# AGENTS.md - Panduan AI & Standar Koding Proyek Tahfidz Core

File ini berisi instruksi, konteks proyek, dan aturan ketat (strict rules) yang **WAJIB** dipatuhi oleh AI (Gemini, Claude, GPT, dll) atau developer saat mengedit, membuat, atau menganalisis kode dalam proyek "Tahfidz Core".

## 1. Identitas Proyek & Tech Stack
- **Nama Proyek:** Tahfidz Core
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (menggunakan `riverpod_annotation` & code generation)
- **Backend / BaaS:** Supabase (PostgreSQL)
- **Arsitektur Utama:** Feature-First Architecture (Modular)

## 2. Aturan Modifikasi Kode (SAFE CODE UPDATE PROTOCOL)
Setiap kali AI diminta untuk mengubah atau mengupdate kode, AI **WAJIB** menggunakan mode **SAFE CODE UPDATE**.
Aturan wajib:
1. Jangan mengubah, menghapus, menyingkat, merapikan, atau memindahkan kode apa pun kecuali bagian yang secara eksplisit diminta oleh pengguna.
2. Jangan mengganti nama variabel, class, fungsi, file, atau folder (kecuali diminta).
3. Jangan melakukan refactor, optimasi, atau penambahan fitur di luar konteks permintaan.
4. Perubahan hanya boleh pada bagian yang disebutkan. Semua kode lain harus **IDENTIK 100%** dengan versi sebelumnya.
5. Urutan kode dan import tidak boleh berubah.
6. **Output Wajib:** Tampilkan perbandingan (Sebelum → Sesudah) dan berikan kode lengkap menggunakan metode **COPY-SAFE** (salin ulang seluruh kode file secara utuh tanpa ada komentar singkatan seperti `// ... kode lainnya`).

## 3. Arsitektur Model & Database
Proyek ini membedakan secara tegas antara "Data Pondasi (Shared)" dan "Data Fitur".
- **Shared Models (`lib/shared/models/`):** - Hanya untuk entitas global seperti `ProfileModel` (gabungan user, guru, staff, admin), `CabangModel`, dan `LembagaModel`.
    - **Dilarang keras** membuat model duplikat seperti `StaffModel`, `UserModel`, atau `GuruModel`. Semuanya menggunakan `ProfileModel` dan difilter berdasarkan field `role`.
- **Feature Models (`lib/features/[nama_fitur]/models/`):**
    - Untuk model spesifik seperti `KurikulumModel`, `SiswaModel`, atau `AgendaModel`.
    - Nested Model (model di dalam model seperti `Jenjang`, `Level`, `Modul` pada Kurikulum) harus diletakkan dalam **satu file yang sama** dengan entitas induknya (`kurikulum_model.dart`) agar mudah di-maintenance dan tidak mengotori *namespace*.

## 4. Standar Pembuatan Class Model
Setiap Model di Tahfidz Core wajib memiliki standar berikut:
1. **Explicit Casting di `fromJson`:** Mencegah error runtime dari Supabase. (Contoh: `id: json['id'] as String?`).
2. **Safe Nullability & Date Parsing:** Parsing tanggal harus aman. (Contoh: `DateTime.tryParse(json['tgl_lahir'].toString())`).
3. **Konversi Snake Case ke Camel Case:** Field dari Supabase (`nama_lengkap`) harus di-map ke Flutter secara benar (`namaLengkap`).
4. **Method `toJson`:** Wajib ada untuk proses Insert/Update ke Supabase.
5. **Method `copyWith`:** Wajib ada dan parameternya harus komplit untuk mempermudah perubahan *state* di Riverpod.
6. **Jembatan Kompatibilitas (Compatibility Bridge):** Jika ada perubahan nama field database, gunakan `getter` agar UI lama tidak error. (Contoh: `String get nama => namaLengkap;`).

## 5. Standar UI & Flutter Terbaru
1. **Hindari Deprecated Members:** - Dilarang menggunakan `.withOpacity()`. Gunakan `.withValues(alpha: ...)` sebagai gantinya.
2. **Konteks Asinkron (Async Gaps):** - Selalu cek `if (!context.mounted) return;` sebelum memanggil fungsi yang menggunakan `BuildContext` setelah proses `await`.
3. **Keamanan Relasi (Join Query):**
    - Saat menampilkan data hasil relasi Supabase, gunakan alias yang jelas dan pastikan field tidak *null* sebelum diakses (Contoh: `json['guru'] != null ? ProfileModel.fromJson(json['guru']) : null`).

## 6. Prosedur Pengecekan Error (Compiler Warnings)
Jika terdapat peringatan (warning) atau error dari analyzer:
- Prioritaskan memperbaiki isu `uri_does_not_exist` (perbaiki path import).
- Hapus import yang tidak digunakan (`unused_import`).
- Hindari penggunaan operator `!` (bang operator) jika variabel sudah dipastikan tidak *null* (hindari `unnecessary_non_null_assertion`).

---
**PESAN UNTUK AI:** Jika Anda membaca file ini, Anda terikat oleh aturan-aturan di atas. Setiap output kode harus memenuhi standar kualitas Tahfidz Core yang solid, anti-bocor, dan menjunjung tinggi prediktabilitas. TANYAKAN jika ada keraguan, jangan pernah berasumsi.