-- Example analytical and relational queries

-- 1. Deliveries from a selected supplier
SELECT d.delivery_id,
       d.delivery_date,
       d.total_price
FROM delivery d
JOIN supplier s ON d.supplier_id = s.supplier_id
WHERE s.company_name = 'Fr Ex';

-- 2. Total value of deliveries from a selected supplier
SELECT s.company_name,
       SUM(d.total_price) AS total_delivery_value
FROM delivery d
JOIN supplier s ON d.supplier_id = s.supplier_id
WHERE s.company_name = 'Fr Ex'
GROUP BY s.company_name;

-- 3. Products currently stored in each branch
SELECT b.branch_name,
       p.product_name,
       la.quantity
FROM located_at la
JOIN branch b ON la.branch_id = b.branch_id
JOIN product p ON la.product_id = p.product_id
ORDER BY b.branch_name, p.product_name;

-- 4. Total quantity sold per product
SELECT p.product_name,
       SUM(s.quantity) AS total_sold
FROM sold s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

-- 5. Total stock per branch
SELECT b.branch_name,
       SUM(la.quantity) AS total_in_stock
FROM located_at la
JOIN branch b ON la.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY b.branch_name;

-- 6. Product price history
SELECT p.product_name,
       ph.price,
       ph.price_date
FROM product p
JOIN price_history ph ON p.product_id = ph.product_id
WHERE EXISTS (
    SELECT 1
    FROM price_history ph2
    WHERE ph2.product_id = p.product_id
)
ORDER BY p.product_name, ph.price_date;

-- 7. Branches with no inventory
SELECT b.branch_name
FROM branch b
WHERE b.branch_id NOT IN (
    SELECT DISTINCT la.branch_id
    FROM located_at la
);

-- 8. Revenue summary using a CTE and CASE expression
WITH sales_summary AS (
    SELECT branch_id,
           SUM(total_price) AS total_revenue,
           SUM(item_count) AS total_items_sold
    FROM sale
    GROUP BY branch_id
)
SELECT b.branch_name,
       ss.total_revenue,
       ss.total_items_sold,
       CASE
           WHEN ss.total_revenue > 200 THEN 'High'
           WHEN ss.total_revenue > 100 THEN 'Medium'
           ELSE 'Low'
       END AS revenue_category
FROM sales_summary ss
JOIN branch b ON b.branch_id = ss.branch_id
ORDER BY ss.total_revenue DESC;

-- 9. Latest known price for each product using a window function
SELECT product_name,
       price,
       price_date
FROM (
    SELECT p.product_name,
           ph.price,
           ph.price_date,
           ROW_NUMBER() OVER (
               PARTITION BY ph.product_id
               ORDER BY ph.price_date DESC
           ) AS rn
    FROM price_history ph
    JOIN product p ON p.product_id = ph.product_id
)
WHERE rn = 1
ORDER BY product_name;
