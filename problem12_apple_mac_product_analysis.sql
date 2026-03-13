-- How are users engaging with multimedia tools on Mac software? Using SQL, analyze usage data to identify key patterns and measure the amount of time users spend on these tools. Based on this analysis, what insights can be drawn to enhance product features and improve overall user experience?

-- Problem1: As a Product Analyst on the Mac software team, you need to understand the engagement of professional content creators with multimedia tools. What is the number of distinct users on the last day in July 2024?
-- only 4 users used a product by end of the month. 

SELECT COUNT(DISTINCT user_id) AS users_count
FROM fct_multimedia_usage
WHERE usage_date = '2024-07-31';

-- Problem2: As a Product Analyst on the Mac software team, you are assessing how much time professional content creators spend using multimedia tools. What is the average number of hours spent by users during August 2024? Round the result up to the nearest whole number.
-- users average four hours spending their time on this platform.

WITH user_hours AS(
SELECT user_id,
       SUM(hours_spent) AS total_hours_spent
FROM fct_multimedia_usage
WHERE usage_date BETWEEN '2024-08-01' AND '2024-08-31'
GROUP BY user_id
)

SELECT ROUND(AVG(total_hours_spent)) AS avg_hours_user
FROM user_hours;

-- Problem3: As a Product Analyst on the Mac software team, you are investigating exceptional daily usage patterns in September 2024. For each day, determine the distinct user count and the total hours spent using multimedia tools. Which days have both metrics above the respective average daily values for September 2024?
-- septemper 04 and 05 users spent time morethan avg time and visits also more than average.

WITH sep_hours_users AS(
SELECT usage_date,
       SUM(hours_spent) AS total_hours_spent,
       COUNT(DISTINCT user_id) AS total_users
FROM fct_multimedia_usage
WHERE usage_date BETWEEN '2024-09-01' AND '2024-09-31'
GROUP BY usage_date
),
avg_hours_users AS(
SELECT AVG(total_hours_spent) AS avg_hours_spent,
       AVG(total_users) AS avg_users_count
FROM sep_hours_users
)

SELECT usage_date,
       total_hours_spent,
       total_users
FROM sep_hours_users AS shu
CROSS JOIN avg_hours_users AS ahu
WHERE shu.total_hours_spent > ahu.avg_hours_spent AND shu.total_users > ahu.avg_users_count;