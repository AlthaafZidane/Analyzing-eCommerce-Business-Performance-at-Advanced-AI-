--- Menampilkan rata-rata jumlah customer aktif bulanan (monthly active user) untuk setiap tahun

WITH monthly_active_users AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month, 
        COUNT(DISTINCT c.customer_unique_id) AS total
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY year, month
)
SELECT 
    year, 
    ROUND(AVG(total), 2) AS avg_mau
FROM monthly_active_users
GROUP BY year;


--- Menampilkan jumlah customer baru pada masing-masing tahun 

WITH first_order AS (
    SELECT c.customer_id,
           min(o.order_purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT EXTRACT(YEAR FROM first_order) AS year, COUNT(customer_id) AS new_customers
FROM first_order
GROUP BY year
ORDER BY year;


--- Menampilkan jumlah customer yang melakukan pembelian lebih dari satu kali

WITH total_order AS (
    SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
           c.customer_unique_id, 
           COUNT(o.order_id) AS total_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY year, c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
)
SELECT year, COUNT(customer_unique_id) AS repeat_order
FROM total_order
GROUP BY year;


--- Menampilkan rata-rata jumlah order yang dilakukan customer untuk masing-masing tahun

WITH frequency AS (
    SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
           c.customer_unique_id, 
           COUNT(o.order_id) AS freq_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY year, c.customer_unique_id
)
SELECT year, ROUND(AVG(freq_order), 2) AS avg_order
FROM frequency
GROUP BY year;


--- Menggabungkan ketiga metrik yang telah berhasil ditampilkan menjadi satu tampilan tabel

WITH 
monthly_active_users AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month, 
        COUNT(DISTINCT c.customer_unique_id) AS total
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY year, month
),
avg_mau AS (
    SELECT 
        year, 
        ROUND(AVG(total), 2) AS avg_mau
    FROM monthly_active_users
    GROUP BY year
),
first_order AS (
    SELECT c.customer_id,
           min(o.order_purchase_timestamp) AS first_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
new_customers AS (
    SELECT EXTRACT(YEAR FROM first_order) AS year, COUNT(customer_id) AS new_customers
    FROM first_order
    GROUP BY year
),
total_order AS (
    SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
           c.customer_unique_id, 
           COUNT(o.order_id) AS total_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY year, c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
),
repeat_order AS (
    SELECT year, COUNT(customer_unique_id) AS repeat_order
    FROM total_order
    GROUP BY year
),
frequency AS (
    SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
           c.customer_unique_id, 
           COUNT(o.order_id) AS freq_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY year, c.customer_unique_id
),
avg_order AS (
    SELECT year, ROUND(AVG(freq_order), 2) AS avg_order
    FROM frequency
    GROUP BY year
)
SELECT a.year, a.avg_mau, n.new_customers, r.repeat_order, ao.avg_order 
FROM avg_mau a 
JOIN new_customers n ON a.year = n.year 
JOIN repeat_order r ON a.year = r.year 
JOIN avg_order ao ON a.year = ao.year;





