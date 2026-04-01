-- How do delivery partners manage multiple order pickups, and what does the data reveal about the efficiency of order clustering and routing strategies? Using SQL, analyze delivery data to evaluate route performance and identify patterns that impact partner earnings and operational effectiveness. Based on this analysis, what insights can be drawn to optimize delivery routes and improve overall efficiency

-- Table Schema
-- fct_delivery_routes(route_id, delivery_partner_id, pickup_count, delivery_time, earnings, route_date)

-- Problem1 : For all delivery routes between October 1st and December 31st, 2024, what percentage of routes had multiple (ie. 2 or more) order pickups? This metric will quantify how often order bundling occurs to help evaluate routing efficiency.

SELECT ROUND(SUM(CASE WHEN pickup_count >= 2 THEN 1 ELSE 0 END)*100.00/COUNT(*),2) AS multiple_order_pickup_percentage
FROM fct_delivery_routes
WHERE route_date >= '2024-10-01'
      AND route_date <= '2024-12-31';
      
      
-- Problem2 : For delivery routes with multiple pickups between October 1st and December 31st, 2024, how does the average delivery time differ between routes with exactly 2 orders and routes with 3 or more orders? Use a CASE statement to segment the routes accordingly. This analysis will clarify the impact of different levels of order clustering on delivery performance.

WITH routes_multiple_orders_route AS(
SELECT route_id,
       CASE
          WHEN pickup_count = 2 THEN 'Exactly two orders'
          WHEN pickup_count > 2 THEN 'More than two orders'
       END AS order_segment,
       delivery_time
FROM fct_delivery_routes
WHERE route_date >= '2024-10-01'
      AND route_date <= '2024-12-31'
      AND pickup_count >= 2
)

SELECT ROUND(
       AVG(CASE WHEN order_segment = 'More than two orders' THEN delivery_time END) - 
       AVG(CASE WHEN order_segment = 'Exactly two orders' THEN  delivery_time END) 
      ,2)AS avg_deliverytime_difference
FROM routes_multiple_orders_route;

-- Problem3 : What is the average earnings per pickup across all routes?
-- Note: Some rows have missing values in the earnings column. Before calculating the final value, replace any missing earnings with the average earnings value.

WITH avg_earnings AS(
SELECT AVG(earnings) AS avg_value
FROM fct_delivery_routes
),
updated_routes AS(
SELECT COALESCE(earnings,avg_value) AS earnings,
       pickup_count
FROM fct_delivery_routes, avg_earnings
)

SELECT ROUND(SUM(earnings)*1.0/SUM(pickup_count),4) AS avg_earning_per_pickup
FROM updated_routes;