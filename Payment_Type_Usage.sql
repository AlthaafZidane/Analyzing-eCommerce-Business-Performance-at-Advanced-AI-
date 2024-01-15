-- Menampilkan jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit

SELECT payment_type, count(1)
FROM payments
GROUP BY 1
ORDER BY 2 DESC;

--  Menampilkan detail informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun

SELECT payment_type,
       COUNT(CASE WHEN EXTRACT(YEAR FROM order_purchase_timestamp) = 2016 THEN 1 END) AS "2016",
       COUNT(CASE WHEN EXTRACT(YEAR FROM order_purchase_timestamp) = 2017 THEN 1 END) AS "2017",
       COUNT(CASE WHEN EXTRACT(YEAR FROM order_purchase_timestamp) = 2018 THEN 1 END) AS "2018"
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY payment_type
ORDER BY "2018" DESC;
