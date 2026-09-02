use candidate_source;

-- 1A. PROFILING DATA
-- Cek data keseluruhan

select 'branches' as nama_tabel, count(*)as jumlah_baris from branches
union all
select 'doctors', count(*) from doctors
union all
select 'soruce_patients', count(*) from source_patients
union all
select 'transaction', count(*) from transactions
union all
select 'treatment_details', count(*) from treatment_details
union all
select 'product_details', count(*) from product_details;

-- Cek transaksi tanpa pasien/dokter

select
	count(*)total_transaksi,
    sum(case when patient_key is null or patient_key = '' then 1 else 0 end) as transaksi_tanpa_pasien,
    sum(case when doctor_id is null then 1 else 0 end) as transaksi_tanpa_dokter
from transactions;

-- Cek detail tanpa header

select 
    'product_tanpa_header' as jenis_anomali, 
    count(*) as jumlah_data 
from product_details pd
left join transactions t on pd.transaction_key = t.transaction_key
where t.transaction_key is null

union all

select 
    'treatment_tanpa_header' as jenis_anomali, 
    count(*) as jumlah_data 
from treatment_details td
left join transactions t on td.transaction_key = t.transaction_key
where t.transaction_key is null;

-- Cek duplikasi data pasien

select
	count(*) as total_pasien,
    sum(case when legacy_rm_code is null or legacy_rm_code = '' then 1 else 0 end) as rm_kosong,
    sum(case when legacy_phone = '' then 1 else 0 end) as telepon_kosong
from source_patients;

select
	legacy_rm_code,
	count(*) jumlah_duplikasi
from source_patients
where legacy_rm_code is not null and legacy_rm_code != ''
group by legacy_rm_code
having count(*) > 1
order by jumlah_duplikasi desc;


-- 1b. Analisis performa

with MonthlyStats as(
	select
		date_format(transaction_date, '%y-%m') as bulan,
		branch_id,
		sum(header_total_amount) as total_revenue,
		count(distinct invoice_number) jumlah_invoice,
		count(distinct patient_key) as jumlah_pasien_unik,
		sum(header_total_amount) / count(distinct invoice_number) as average_transaction_value
	from transactions
	where transaction_date >= '2022-10-01' and transaction_date <= '2022-12-31'

	group by 1, 2
)
select
	bulan,
    branch_id,
    total_revenue,
    jumlah_invoice,
    jumlah_pasien_unik,
    average_transaction_value,
    -- hitung total revenue (growth persentase)
    -- nb. bulan oktober akan null karena tidak ada data bulan september untuk pembanding
    (total_revenue - lag(total_revenue) over (partition by branch_id order by bulan)) /
    lag(total_revenue) over (partition by branch_id order by bulan) * 100 as pertumbuhan_revenue_persen,
    
    -- hitung kontribusi cabang per Bulan(kontribusi dalam persentase)
    total_revenue / sum(total_revenue) over (partition by bulan) * 100 as kontribusi_cabang_persen

from MonthlyStats
order by branch_id, bulan;

-- 1c. Analisis Customer
-- Melihat isi dictionary
select *
from(data_dictionary)
limit 50;

-- Cek nilai kolom yang berkaitan dengan customer di tabel transaction

select distinct customer_source, is_non_member
from transactions;

-- Analisis customer segment
-- Menggunakan CTE untuk menentukan segment per transaksi

with CustomerSegmentation as (
	select
		date_format(t.transaction_date, '%y-%m') as bulan,
        t.branch_id,
        t.patient_key,
        t.header_total_amount,
        -- Logika segmentasi customer
        case
			when t.is_non_member = 1 then 'Non Member'
            when pts.lifetime_transaction_number = 1 then 'New Customer'
            when datediff(t.transaction_date, pts.previous_transaction_date) > 180 then 'Reactivate Customer'
            else 'Repeat Customer'
		end as customer_segment
        
	from transactions t
    -- Join ke tabel sequance untuk mendapatkan history kunjungan
    LEFT JOIN patient_transaction_sequence pts ON t.transaction_key = pts.transaction_key
    -- Filter periode Q4 2022
    where t.transaction_date >= '2022-10-01' and t.transaction_date <= '2022-12-31'
)
-- Mengaggregasikan data berdasarkan bulan, cabang, dan segment
select
	bulan,
    branch_id,
    customer_segment,
    count(distinct patient_key) as jumlah_customer,
    sum(header_total_amount) as total_revenue
from CustomerSegmentation
group by 1, 2, 3
order by branch_id, bulan, customer_segment;

-- 1D: Analisis Produk, Treatment, dan Dokter

-- Top 10 Treatment berdasarkan Revenue (Q4 2022)
select 
    td.treatment_name, 
    count(td.transaction_key) as jumlah_terjual,
    sum(td.item_final_amount) as total_revenue
from treatment_details td
join transactions t on td.transaction_key = t.transaction_key
where t.transaction_date >= '2022-10-01' and t.transaction_date <= '2022-12-31'
group by 1
order by 3 desc
limit 10;    

-- Top 10 Produk berdasarkan Revenue (Q4 2022)
select 
    pd.product_name, 
    sum(pd.quantity) as jumlah_terjual,
    sum(pd.item_final_amount) as total_revenue
from product_details pd
join transactions t on pd.transaction_key = t.transaction_key
where t.transaction_date >= '2022-10-01' and t.transaction_date <= '2022-12-31'
group by 1
order by 3 desc
limit 10;

-- Performa Dokter berdasarkan Jumlah Transaksi dan Revenue
select 
    doctor_id, 
    count(DISTINCT invoice_number) as jumlah_transaksi, 
    sum(header_total_amount) as total_revenue
from transactions
where transaction_date >= '2022-10-01' and transaction_date <= '2022-12-31'
  and doctor_id is not null
group by 1
order by 3 desc;

-- Komposisi Transaksi (Treatment Only, Product Only, Mixed)
with CekKomposisi as (
    select 
        t.transaction_key,
        case when td.transaction_key is not null then 1 else 0 end as has_treatment,
        case when pd.transaction_key is not null then 1 else 0 end as has_product
    from transactions t
    -- DISTINCT agar tidak duplikat saat di-join
    left join (select distinct transaction_key from treatment_details) td on t.transaction_key = td.transaction_key
    left join (select distinct transaction_key from product_details) pd on t.transaction_key = pd.transaction_key
    where t.transaction_date >= '2022-10-01' and t.transaction_date <= '2022-12-31'
)
select 
    case 
        when has_treatment = 1 and has_product = 1 then 'Mixed (Treatment & Product)'
        when has_treatment = 1 and has_product = 0 then 'Treatment Only'
        when has_treatment = 0 and has_product = 1 then 'Product Only'
        else 'Lainnya (Tanpa Detail)'
    end as kategori_komposisi,
    count(transaction_key) as jumlah_transaksi
from CekKomposisi
group by 1
order by 2 desc;

-- Investigasi Cabang Prioritas (Cabang 2 - Volume vs Value)
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS bulan,
    SUM(header_total_amount) AS total_revenue,
    COUNT(DISTINCT invoice_number) AS jumlah_invoice,
    COUNT(DISTINCT patient_key) AS jumlah_pasien,
    SUM(header_total_amount) / COUNT(DISTINCT invoice_number) AS average_transaction_value
FROM transactions
WHERE branch_id = 2 
  AND transaction_date >= '2022-10-01' AND transaction_date <= '2022-11-30'
GROUP BY 1;

-- Investigasi Cabang Prioritas (Cabang 2 - Segmen Pelanggan)
WITH Segmentasi AS (
    SELECT 
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS bulan,
        t.patient_key,
        t.header_total_amount,
        CASE 
            WHEN t.is_non_member = 1 THEN 'Non Member'
            WHEN pts.lifetime_transaction_number = 1 THEN 'New Customer'
            WHEN DATEDIFF(t.transaction_date, pts.previous_transaction_date) > 180 THEN 'Reactivated Customer'
            ELSE 'Repeat Customer'
        END AS customer_segment
    FROM transactions t
    LEFT JOIN patient_transaction_sequence pts ON t.transaction_key = pts.transaction_key
    WHERE t.branch_id = 2 
      AND t.transaction_date >= '2022-10-01' AND t.transaction_date <= '2022-11-30'
)
SELECT 
    customer_segment,
    SUM(CASE WHEN bulan = '2022-10' THEN header_total_amount ELSE 0 END) AS revenue_okt,
    SUM(CASE WHEN bulan = '2022-11' THEN header_total_amount ELSE 0 END) AS revenue_nov,
    -- Menghitung selisih penurunan
    SUM(CASE WHEN bulan = '2022-11' THEN header_total_amount ELSE 0 END) - SUM(CASE WHEN bulan = '2022-10' THEN header_total_amount ELSE 0 END) AS selisih_revenue
FROM Segmentasi
GROUP BY 1
ORDER BY selisih_revenue ASC;

