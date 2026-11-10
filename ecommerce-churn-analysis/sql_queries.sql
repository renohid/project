/*
Olist E-Commerce Churn Analysis
Core Feature Engineering Query (RFM + Churn Target)
*/

WITH rfm_base AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency_total_orders,
        SUM(p.payment_value) AS monetary_total_spent
    FROM 
        customers c
    JOIN 
        orders o ON c.customer_id = o.customer_id
    JOIN 
        order_payments p ON o.order_id = p.order_id
    WHERE 
        o.order_status = 'delivered'
    GROUP BY 
        c.customer_unique_id
),
dataset_max_date AS (
    SELECT MAX(last_purchase_date) AS max_date FROM rfm_base
)
SELECT 
    r.customer_unique_id,
    EXTRACT(DAY FROM (d.max_date - r.last_purchase_date)) AS recency_days,
    r.frequency_total_orders,
    r.monetary_total_spent,
    CASE 
        -- Defining churn as no purchases in the last 180 days
        WHEN EXTRACT(DAY FROM (d.max_date - r.last_purchase_date)) > 180 THEN 1 
        ELSE 0 
    END AS is_churned
FROM 
    rfm_base r
CROSS JOIN 
    dataset_max_date d;
