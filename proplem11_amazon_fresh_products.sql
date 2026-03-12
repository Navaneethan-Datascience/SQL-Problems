-- Which product categories in Amazon Fresh are most frequently reordered by customers? Using SQL, analyze reorder behavior to identify customer preferences, calculate the average reorder frequency across categories, and uncover patterns in repeat purchases. Based on this analysis, what insights can be drawn to improve customer satisfaction and strengthen retention strategies?


-- Problem1 : The product team wants to analyze the most frequently reordered product categories. Can you provide a list of the product category codes (using first 3 letters of product code) and their reorder counts for Q4 2024?
-- Fruites(4) are most reordered product and vegtables(1) least reordered products.

SELECT SUBSTRING(p.product_code,1,3) AS prouct_category,
       COUNT(*) AS reorder_count
FROM fct_orders AS o
JOIN dim_products AS p
      ON o.product_id = p.product_id
WHERE o.order_date BETWEEN '2024-10-01' AND '2024-12-31' AND o.reorder_flag = 1
GROUP BY SUBSTRING(p.product_code,1,3);


-- Problem2 : To better understand customer preferences, the team needs to know the details of customers who reorder specific products. Can you retrieve the customer information along with their reordered product code(s) for Q4 2024?
-- Fruite category were ordered by most of the customers.

SELECT DISTINCT c.customer_id,
       c.customer_name,
       p.product_code
FROM fct_orders AS o
JOIN dim_products AS p
      ON o.product_id = p.product_id
JOIN dim_customers AS c
      ON o.customer_id = c.customer_id
WHERE o.order_date BETWEEN '2024-10-01' AND '2024-12-31' AND reorder_flag = 1;

-- Problem3: When calculating the average reorder frequency, it's important to handle cases where reorder counts may be missing or zero. Can you compute the average reorder frequency across the product categories, ensuring that any missing or null values are appropriately managed for Q4 2024?
-- Fruits and dairy products have highest avg reorder frequency because fruits are the most order product and dairy products like milk people order reqularely.

SELECT p.category,
       SUM(CASE WHEN reorder_flag = 1 THEN 1 ELSE 0 END)*1.0/COUNT(*) AS avg_reorder_frequency
FROM fct_orders AS o
JOIN dim_products AS p
      ON o.product_id = p.product_id
WHERE o.order_date BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY p.category;