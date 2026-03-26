-- How can essential household items be categorized by price range to better understand sales trends in physical stores? Using SQL, analyze product and sales data to identify which price ranges drive the highest sales volume. Based on this analysis, what insights can be drawn to support competitive pricing strategies and maintain affordability for customers?

-- Table Schema:
-- fct_sales(sale_id, product_id, quantity_sold, sale_date, unit_price)
-- dim_products(product_id, product_name, category)

-- What is the total sales volume (i.e. total quantity sold) for essential household items in July 2024? Provide the result with a column named 'Total_Sales_Volume'.
-- totaly 110 product quantity sold those are products under the 'Essential Household' items on July 2024 

SELECT SUM(quantity_sold) AS 'Total_Sales_Volume'
FROM fct_sales AS s
JOIN dim_products AS p
     ON s.product_id = p.product_id
WHERE s.sale_date BETWEEN '2024-07-01' AND '2024-07-31' AND p.category = 'Essential Household';


-- For essential household items sold in July 2024, categorize the items into 'Low', 'Medium', and 'High' price ranges based on their average price. Use the following criteria: 'Low' for prices below $5, 'Medium' for prices between $5 and $15, and 'High' for prices above $15.
-- under Essential household items most product price under $5 following by medium and High.
 SELECT p.product_name,
       CASE 
          WHEN AVG(unit_price) < 5 THEN 'Low'
          WHEN AVG(unit_price) >= 5 AND AVG(unit_price) <= 15 THEN 'Medium'
          WHEN AVG(unit_price) > 15 THEN 'High'
          ELSE 'Non-Segment'
       END AS pricing_range_segment
FROM fct_sales AS s
JOIN dim_products AS p
     ON s.product_id = p.product_id
WHERE s.sale_date BETWEEN '2024-07-01' AND '2024-07-31' AND p.category = 'Essential Household'
GROUP BY product_name;


-- Identify the price range with the highest total sales volume for essential household items in July 2024. Use the same criteria as the previous question: 'Low' for prices below $5, 'Medium' for prices between $5 and $15, and 'High' for prices above $15.
-- those are the products under the Low pricing range has the highest sales(54) volume whic needs to be maintain the same pricing for the product to maintaine competiveness 

WITH product_price_range_quantity AS(
SELECT p.product_id,
       CASE
          WHEN unit_price < 5 THEN 'Low'
          WHEN unit_price >= 5 AND unit_price <= 15 THEN 'Medium'
          WHEN unit_price > 15 THEN 'High'
       END AS Price_Range,
       quantity_sold
FROM fct_sales AS s
JOIN dim_products AS p
     ON s.product_id = p.product_id
WHERE sale_date BETWEEN '2024-07-01' AND '2024-07-31' 
      AND p.category = 'Essential Household'
)

SELECT Price_Range,
       SUM(quantity_sold) AS Total_Sales_Volume
FROM product_price_range_quantity
GROUP BY Price_Range
ORDER BY Total_Sales_Volume DESC
LIMIT 1;

-- after analyzing the data for july. we found the that data essential household items those are the products under the less than $5 sold most quantity we have to maintain the position price for this product for market competetion since those are products under the Medium($5 - $15) and High(> $15) pricing range has the less sales volume for these can be different promotional startegies.