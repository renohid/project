-- ==========================================================
-- 02_patient_migration.sql
-- ==========================================================

-- 1. Proses Migrasi dan Normalisasi Data Pasien (Mengabaikan duplikat RM yang melanggar unique key)
INSERT IGNORE INTO candidate_target.patients (
    rm_code, 
    name, 
    phone, 
    dob, 
    gender
)
SELECT 
    COALESCE(
        NULLIF(TRIM(s.legacy_rm_code), ''), 
        CONCAT('UNKNOWN-RM-', LPAD(CAST(s.legacy_patient_id AS CHAR), 4, '0'))
    ) AS rm_code,
    s.legacy_name,
    CASE 
        WHEN REGEXP_REPLACE(s.legacy_phone, '[^0-9]', '') LIKE '08%' 
            THEN CONCAT('62', SUBSTRING(REGEXP_REPLACE(s.legacy_phone, '[^0-9]', ''), 2))
        WHEN REGEXP_REPLACE(s.legacy_phone, '[^0-9]', '') LIKE '8%' 
            THEN CONCAT('62', REGEXP_REPLACE(s.legacy_phone, '[^0-9]', ''))
        WHEN REGEXP_REPLACE(s.legacy_phone, '[^0-9]', '') LIKE '62%' 
            THEN REGEXP_REPLACE(s.legacy_phone, '[^0-9]', '')
        ELSE NULL 
    END AS phone,
    CASE 
        WHEN s.legacy_birth_date IS NULL 
             OR CAST(s.legacy_birth_date AS CHAR) = '0000-00-00' 
             OR s.legacy_birth_date < '1900-01-01' 
             OR s.legacy_birth_date > '2022-12-31' 
            THEN NULL
        ELSE s.legacy_birth_date 
    END AS dob,
    CASE 
        WHEN UPPER(TRIM(s.legacy_gender)) IN ('L', 'LAKI-LAKI', 'PRIA', 'MALE') THEN 'L'
        WHEN UPPER(TRIM(s.legacy_gender)) IN ('P', 'W', 'PEREMPUAN', 'WANITA', 'FEMALE') THEN 'P'
        ELSE NULL 
    END AS gender
FROM candidate_source.source_patients s
WHERE NOT EXISTS (
    SELECT 1 FROM candidate_target.patient_legacy_mappings m 
    WHERE m.legacy_patient_id = s.legacy_patient_id
);

-- 2. Catat pemetaan ke tabel patient_legacy_mappings
INSERT IGNORE INTO candidate_target.patient_legacy_mappings (legacy_patient_id, target_patient_id, source_system)
SELECT s.legacy_patient_id, t.id, 'clinic_prod'
FROM candidate_source.source_patients s
JOIN candidate_target.patients t ON t.rm_code = COALESCE(NULLIF(TRIM(s.legacy_rm_code), ''), CONCAT('UNKNOWN-RM-', LPAD(CAST(s.legacy_patient_id AS CHAR), 4, '0')))
WHERE NOT EXISTS (
    SELECT 1 FROM candidate_target.patient_legacy_mappings m 
    WHERE m.legacy_patient_id = s.legacy_patient_id
);