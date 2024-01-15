--- Membuat tabel yang berisi informasi pendapatan/revenue perusahaan total untuk masing-masing tahun

CREATE TABLE IF NOT EXISTS revenue AS
   (SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
           sum(i.price + i.fright_value) AS revenue
    FROM orders o
    JOIN items i 
       ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY year);
	
	
--- Membuat tabel yang berisi informasi jumlah cancel order total untuk masing-masing tahun

CREATE TABLE IF NOT EXISTS cancel_order AS
   (SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
           count(order_status) AS cancel_order
    FROM orders
    WHERE order_status = 'canceled'
    GROUP BY year);
	
	
--- Membuat tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi untuk masing-masing tahun

CREATE TABLE IF NOT EXISTS best_category AS
   (SELECT year, 
           product_category_name as best_cat, 
           cat_revenue
    FROM
       (SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
               product_category_name, 
               sum(price + fright_value) AS cat_revenue,
               rank() over(PARTITION BY EXTRACT(YEAR FROM order_purchase_timestamp)
                           ORDER BY sum(price + fright_value) DESC)
        FROM items i
        JOIN products p 
           ON i.product_id = p.product_id
        JOIN orders o 
           ON o.order_id = i.order_id
        WHERE order_status = 'delivered'
        GROUP BY 1, 2) rank_category
    WHERE rank = 1);
	

	
--- Membuat tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak untuk masing-masing tahun

CREATE TABLE IF NOT EXISTS most_cancel_cat2 AS
   (SELECT year, 
           product_category_name as cancel_cat, 
           num_of_cancel
    FROM
       (SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
               product_category_name, 
               count(order_status) AS num_of_cancel,
               rank() over(PARTITION BY EXTRACT(YEAR FROM order_purchase_timestamp)
                           ORDER BY count(order_status) DESC)
        FROM orders o
        JOIN items i 
           ON i.order_id = o.order_id
        JOIN products p 
           ON p.product_id = i.product_id
        WHERE order_status = 'canceled'
        GROUP BY 1, 2) cancel_rank
    WHERE rank = 1);
	
	
--- Menggabungkan informasi-informasi yang telah didapatkan ke dalam satu tampilan tabel

SELECT r.year,
       r.revenue,
       c.cancel_order,
       bc.best_cat,
       mc.cancel_cat
FROM revenue r
LEFT JOIN cancel_order c ON r.year = c.year
LEFT JOIN best_category bc ON r.year = bc.year
LEFT JOIN most_cancel_cat mc ON r.year = mc.year;













