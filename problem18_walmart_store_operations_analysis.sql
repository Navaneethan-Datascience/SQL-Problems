-- As a Business Analyst for the Store Operations team at Walmart, you are tasked with examining checkout wait times to enhance the customer shopping experience. Your team aims to identify which stores have longer wait times and determine specific hours when these delays are most pronounced. The insights you provide will guide staffing strategies to reduce customer wait times and improve overall efficiency.

-- What is the average checkout wait time in minutes for each Walmart store during July 2024? Include the store name from the dim_stores table to identify location-specific impacts. This metric will help determine which stores have longer customer wait times.
-- those are the stores have highest avg chekout waiting time those stores are need more supporters and technological feature support.
WITH checkout_wait_time_store AS(
SELECT store_id,
       (JULIANDAY(checkout_end_time) - JULIANDAY(checkout_start_time))*24*60 AS checkout_wait_time
FROM fct_checkout_times
WHERE checkout_start_time >= '2024-07-01' AND checkout_start_time <= '2024-07-31'
)

SELECT s.store_name,
       AVG(checkout_wait_time) AS avg_check_out_wait_time
FROM checkout_wait_time_store AS wt
JOIN dim_stores AS s
     ON wt.store_id = s.store_id
GROUP BY s.store_name;


-- For the stores with an average checkout wait time exceeding 10 minutes in July 2024, what are the average checkout wait times in minutes broken down by each hour of the day? Use the store information from dim_stores to ensure proper identification of each store. This detail will help pinpoint specific hours when wait times are particularly long.
-- these stores facing issue chekout process becuase these stores avg chekout waiting time is more than ten.
WITH avg_wait_time_store AS(
SELECT store_id,
       AVG((JULIANDAY(checkout_end_time) - JULIANDAY(checkout_start_time))*24*60) AS avg_checkout_wait_time
FROM fct_checkout_times
WHERE checkout_start_time >= '2024-07-01' AND checkout_start_time < '2024-08-01'
  AND checkout_end_time IS NOT NULL
  AND checkout_end_time > checkout_start_time
GROUP BY store_id
HAVING avg_checkout_wait_time > 10
),
hourly_waiting_time AS(
SELECT store_id,
       STRFTIME('%H',checkout_start_time) AS hour_of_day,
       (JULIANDAY(checkout_end_time)-JULIANDAY(checkout_start_time))*24*60 AS total_waiting_time
FROM fct_checkout_times
WHERE checkout_start_time >= '2024-07-01' AND checkout_start_time < '2024-08-01'
  AND checkout_end_time IS NOT NULL
  AND checkout_end_time > checkout_start_time
)

SELECT s.store_name,
       hwt.hour_of_day,
       ROUND(AVG(hwt.total_waiting_time),2) AS avg_waiting_time
FROM hourly_waiting_time AS hwt
JOIN avg_wait_time_store AS awt
     ON hwt.store_id = awt.store_id
JOIN dim_stores AS s
     ON hwt.store_id = s.store_id
GROUP BY s.store_name, hwt.hour_of_day;



-- Across all stores in July 2024, which hours exhibit the longest average checkout wait times in minutes? This analysis will guide recommendations for optimal staffing strategies.
-- for july 2024, 19th hour had a high average waiting time 'cause that's peak business hours.

SELECT STRFTIME('%H',checkout_start_time) AS hour_of_day,
       AVG((JULIANDAY(checkout_end_time) - JULIANDAY(checkout_start_time))*24*60) AS avg_waiting_time 
FROM fct_checkout_times AS ct
WHERE checkout_start_time >= '2024-07-01' AND checkout_start_time < '2024-08-01'
GROUP BY hour_of_day
ORDER BY avg_waiting_time DESC
LIMIT 1;