# Business Analysis & Data Migration (Q4 2022)

Repositori ini berisi rangkaian kode SQL, hasil analisis bisnis, *dashboard* visualisasi, serta skrip migrasi data pasien untuk studi kasus performa klinik pada Kuartal 4 (Q4) Tahun 2022.

---

## 📁 Struktur Folder & Berkas

01_profiling_and_analysis.sql

02_patient_migration.sql

03_migration_validation.sql

Juragan99.twb

---

## 📊 Ringkasan Komponen Proyek

### 1. Analisis Bisnis & Profiling Data (`01_profiling_and_analysis.sql`)

- **Periode Analisis:** Fokus pada Q4 2022 (1 Oktober – 31 Desember 2022)[cite: 1].
- **Temuan Utama:**
    - **Cabang Prioritas:** **Cabang 2** diidentifikasi sebagai prioritas intervensi karena mencatatkan *revenue* tertinggi secara absolut (~Rp 8,94 Miliar) namun mengalami penurunan terparah di bulan November sebesar **11.54%**[cite: 1].
    - **Akar Masalah (Root Cause):** Penurunan pendapatan disebabkan oleh merosotnya segmen *Repeat Customer* (-Rp 302,58 juta) serta turunnya *Average Transaction Value* (ATV) dari Rp 537.600 ke Rp 503.881 di Cabang 2[cite: 1].
    - **Segmentasi & Layanan:** Bisnis sangat ditopang oleh *Repeat Customer* (~Rp 18,18 Miliar)[cite: 1]. Produk terlaris adalah *Whitening Sun Cream 3*, sementara layanan terfavorit adalah *Skin Booster 3 in 1* dan *Pico Clear Melasma*[cite: 1].

### 2. Migrasi & Normalisasi Data Pasien (`02_patient_migration.sql`)

- **Normalisasi Data:** Membersihkan format nomor telepon menjadi standar (`628...`), menormalisasi format gender (*L* / *P*), serta menyaring anomali tanggal lahir (seperti `0000-00-00` atau di luar rentang wajar menjadi `NULL`)[cite: 1].
- **Penanganan Konflik & Duplikasi:** Menggunakan teknik *fallback* konsisten untuk nomor rekam medis (*RM*) yang kosong dan menerapkan mekanisme aman (*INSERT IGNORE*) untuk mengatasi duplikasi RM tanpa menimpa data yang ada[cite: 1].
- **Pencatatan Mapping:** Menyimpan relasi kunci antara data *legacy* dan tabel target ke dalam `patient_legacy_mappings`[cite: 1].

### 3. Rekonsiliasi & Validasi Akhir (`03_migration_validation.sql`)

Berdasarkan hasil eksekusi validasi akhir:

- **Total Source Patients:** 21.993 baris data[cite: 1].
- **Total Migrated Patients (Target):** 21.959 baris data berhasil dimigrasi[cite: 1].
- **Total Patient Legacy Mappings:** 21.959 data terpetakan dengan akurat[cite: 1].
- **Orphan / Unmapped Records (Konflik/Duplikat RM):** 34 baris data (berhasil dideteksi dan dilewati sesuai aturan penanganan duplikasi data)[cite: 1].

---

## 🚀 Cara Menjalankan Skrip SQL

1. Buka aplikasi **MySQL Workbench**[cite: 1].
2. Jalankan skrip profil dan analisis secara bertahap untuk melihat performa bisnis Q4[cite: 1].
3. Jalankan skrip migrasi **`02_patient_migration.sql`** pada database target[cite: 1].
4. Jalankan skrip validasi **`03_migration_validation.sql`** untuk memastikan hasil rekonsiliasi sudah seimbang dan sesuai[cite: 1].
