-- The procurement team needs to analyze supplier performance to ensure reliable delivery of components. 
-- The task is to use SQL to find the most active suppliers, identify which suppliers dominate in different manufacturing regions, and detect any supply gaps in Asia. This will help improve vendor selection and reduce supply chain risks.



-- problem 1: Identify the top 5 suppliers based on the total volume of components delivered in October 2024.
-- suppliers Beta electronics(4300), Gamma materials(3700), Alpha components(2700), Dela manufacturing(2500), Eta technologies(2300) are the top 5 active suppliers. 

WITH supplier_component AS(
SELECT supplier_name,
       SUM(sd.component_count) AS total_volume_component
FROM supplier_deliveries AS sd
JOIN suppliers AS s
     ON sd.supplier_id = s.supplier_id
WHERE sd.delivery_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY supplier_name
),
ranked_suppliers AS(
SELECT supplier_name,
       total_volume_component,
       DENSE_RANK() OVER(ORDER BY total_volume_component DESC) AS rnk
FROM supplier_component
)

SELECT supplier_name,
       total_volume_component,
       rnk
FROM ranked_suppliers
WHERE rnk <= 5;


-- Problem 2 : For each region, find the supplier ID that delivered the highest number of components in November 2024. This will help us understand which supplier is handling the most volume per market.
-- supplier 108 handling the most volume(7300) in North america market, 109 in Europe(2800) and 110 in Asia market(5100) 

WITH region_suppliers AS(
SELECT sd.manufacturing_region,
       s.supplier_id,
       SUM(sd.component_count) AS total_components
FROM supplier_deliveries AS sd
JOIN suppliers AS s
     ON sd.supplier_id = s.supplier_id
WHERE sd.delivery_date BETWEEN '2024-11-01' AND '2024-11-30'
GROUP BY sd.manufacturing_region, s.supplier_id
),
ranked_suppliers AS(
SELECT manufacturing_region,
       supplier_id,
       total_components,
       DENSE_RANK() OVER(PARTITION BY manufacturing_region ORDER BY total_components DESC) AS rnk
FROM region_suppliers
)
SELECT manufacturing_region,
       supplier_id,
       total_components,
       rnk
FROM ranked_suppliers
WHERE rnk = 1;



-- problem 3 : We need to identify potential gaps in our supply chain for Asia. List all suppliers by name who have not delivered any components to the 'Asia' manufacturing region in December 2024.
WITH suppliers_asia AS(
SELECT DISTINCT supplier_id
FROM supplier_deliveries
WHERE manufacturing_region = 'Asia' AND delivery_date BETWEEN '2024-12-01' AND '2024-12-31'
)
  
SELECT supplier_name
FROM suppliers AS s
LEFT JOIN suppliers_asia AS sa
    ON s.supplier_id = sa.supplier_id
WHERE sa.supplier_id IS NULL;
