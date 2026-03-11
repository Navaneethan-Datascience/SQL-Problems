-- How are Amazon services such as Echo, Fire TV, and Kindle being used across different devices? Using SQL, categorize device usage, assess overall engagement levels, and analyze the contribution of Prime Video and Amazon Music to total usage. Based on this analysis, what insights can be drawn to optimize service offerings and improve customer satisfaction?

-- problem1 : The team wants to identify the total usage duration of the services for each device type by extracting the primary device category from the device name for the period from July 1, 2024 to September 30, 2024. The primary device category is derived from the first word of the device name.
-- Echo TV had a highest(495 minutes) device usage time from July 2025 to Septemper 2024 
SELECT SUBSTRING(device_name,1,CHARINDEX(' ',device_name)-1) AS primary_device_category,
       SUM(du.usage_duration_minutes) AS total_usage_duration
FROM fct_device_usage AS du
JOIN dim_device AS d
      ON du.device_id = d.device_id
WHERE du.usage_date BETWEEN '2024-07-01' AND '2024-09-30'
GROUP BY primary_device_category;

-- Problem2: The team also wants to label the usage of each device category into 'Low' or 'High' based on usage duration from July 1, 2024 to September 30, 2024. If the total usage time was less than 300 minutes, we'll categorize it as 'Low'. Otherwise, we'll categorize it as 'High'. Can you return a report with device ID, usage category, and total usage time?
-- device id 4 have a highest(365) usage time that means more than 300 other devices are categorized as 'Low' usage category.

WITH device_usage_time AS(
SELECT d.device_id,
       SUM(usage_duration_minutes) AS total_usage_time          
FROM fct_device_usage AS du
JOIN dim_device AS d
      ON du.device_id = d.device_id
WHERE du.usage_date BETWEEN '2024-07-01' AND '2024-09-30'
GROUP BY d.device_id
)

SELECT device_id,
       CASE
          WHEN total_usage_time < 300 THEN 'Low'
          ELSE 'High'
       END usage_category,
       total_usage_time
FROM device_usage_time;

-- The team is considering bundling the Prime Video and Amazon Music subscription. They want to understand what percentage of total usage time comes from Prime Video and Amazon Music services respectively. Please use data from July 1, 2024 to September 30, 2024.
-- prime video service have a highest percentage(51%) of total usage time because it has the highest usages

WITH usage_time AS(
SELECT SUM(usage_duration_minutes) AS usage_time_jul_sep
FROM fct_device_usage
WHERE usage_date BETWEEN '2024-07-01' AND '2024-09-30'
),
service_usage_time AS(
SELECT s.service_name,
       SUM(du.usage_duration_minutes) AS total_usage_time
FROM fct_device_usage AS du
JOIN dim_service AS s
      ON du.service_id = s.service_id
WHERE service_name IN ('Prime Video','Amazon Music') AND (usage_date BETWEEN '2024-07-01' AND '2024-09-30')
GROUP BY s.service_name
)

SELECT service_name,
       ROUND(total_usage_time * 100 / usage_time_jul_sep,2) AS percentage_of_total_usage
FROM service_usage_time AS sut
CROSS JOIN usage_time AS ut;