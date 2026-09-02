-- ==========================================================
-- 03_migration_validation.sql
-- Script Rekonsiliasi dan Validasi Akhir Migrasi Pasien
-- ==========================================================

-- 1. Total Data Sumber (Source)
select 'Total Source Patients' as metric_name, count(*) as total_count 
from candidate_source.source_patients

union all

-- 2. Total Data yang Berhasil Dimigrasi ke Target
select 'Total Migrated Patients (Target)' as metric_name, count(*) as total_count 
from candidate_target.patients

union all

-- 3. Total Data yang Tercatat di Tabel Pemetaan (Mapping)
select 'Total Patient Legacy Mappings' as metric_name, count(*) as total_count 
from candidate_target.patient_legacy_mappings

union all

-- 4. Deteksi Potensi Konflik / Data Tanpa Mapping
select 'Orphan / Unmapped Source Records' as metric_name, count(*) as total_count 
from candidate_source.source_patients s
where not exists (
    select 1 from candidate_target.patient_legacy_mappings m 
    where m.legacy_patient_id = s.legacy_patient_id
);