-- What patterns can be observed in user engagement across different knowledge domains on the ChatGPT platform? Using SQL, analyze query data to determine the proportion of queries related to technology and science, assess monthly query volumes, and identify the most active users. Based on this analysis, what insights can be drawn to tailor the user experience and prioritize outreach to highly engaged users?

-- Table Schema:
-- fct_queries(query_id, user_id, query_text, query_domain, query_timestamp)
-- dim_users(user_id, first_name, last_name)

-- What percentage of user queries in July 2024 were related to either 'technology' or 'science' domains?
-- Business Insight: 66.67% of user queries are related to technology and science domain on july 2024 on that which defines most of the users searching tech and science content. 

WITH queries_tech_and_sci_july AS(
SELECT COUNT(*) AS total_queries_tech_sci_july
FROM fct_queries
WHERE (query_domain = 'technology' 
      OR query_domain = 'science')
      AND (query_timestamp >= '2024-07-01'
      AND query_timestamp < '2024-08-01')
),
total_queries_july AS(
SELECT COUNT(*) AS total_quries
FROM fct_queries
WHERE query_timestamp >= '2024-07-01'
      AND query_timestamp < '2024-08-01'
)

SELECT ROUND(qj.total_queries_tech_sci_july*100.0/total_quries,2) AS user_query_percentage
FROM queries_tech_and_sci_july AS qj
CROSS JOIN total_queries_july AS tqj;


 -- Calculate the total number of queries per month in Q3 2024. Which month had the highest number of queries?
-- Business Insight :  In q3 august month has a highest user queries. we can align marketing campaigns, optimize sytem performance and focus on high-demand content to improve user engagement and revenue.
 
 WITH total_queries_q3 AS(
SELECT STRFTIME('%Y-%m',query_timestamp) AS month_year,
       COUNT(*) AS total_queries
FROM fct_queries AS q
JOIN dim_users AS u
      ON q.user_id = u.user_id
WHERE query_timestamp >= '2024-07-01'
      AND query_timestamp < '2024-10-01'
GROUP BY month_year
)

SELECT month_year,
       total_queries
FROM total_queries_q3
ORDER BY total_queries DESC
LIMIT 1;


-- Identify the top 5 users with the most queries in August 2024 by their first and last name. We want to interview our most active users and this information will be used in our outreach to these users.
-- Business Insight : user id 1,2,3,4,5 and 6 users are under top 5 ranking by total queries on august so, we have to interview these users about their experience to enhance our query performance.

WITH user_queries_august AS(
SELECT u.user_id,
       u.first_name,
       u.last_name,
       COUNT(*) AS total_queries_august
FROM fct_queries AS q
JOIN dim_users AS u
      ON q.user_id = u.user_id
WHERE query_timestamp >= '2024-08-01'
      AND query_timestamp < '2024-09-01'
GROUP BY u.user_id,u.first_name,u.last_name
),
user_queries_ranked AS(
SELECT user_id,
       first_name,
       last_name,
       total_queries_august,
       DENSE_RANK() OVER(ORDER BY total_queries_august DESC) AS rnk
FROM user_queries_august
)

SELECT user_id,
       first_name,
       last_name,
       total_queries_august
FROM user_queries_ranked
WHERE rnk <= 5;