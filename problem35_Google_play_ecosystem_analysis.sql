-- How do different app categories and monetization models influence developer revenue and app distribution on the Google Play platform? Using SQL, analyze developer and app performance data to evaluate revenue patterns and distribution trends. Based on this analysis, what insights can be drawn to optimize monetization strategies and enhance overall platform engagement?

-- Table schmema
-- fct_app_revenue(app_id, category_id, revenue_date, revenue_amount)
-- dim_app_category(category_id, category_name)
-- dim_monetization_model(app_id, monetization_type)

-- Problem1: For the month of April 2024, which app categories generated the highest total revenue (top 10 only)? This insight will be used to refine monetization strategies for developers.
-- Business Insight: In April 2024 revenue by each category the "Games" applications are generated the highest revenue. because on that particular month the games where installed by kids and streamers and the new famous game installed on that particular month.
WITH category_revenue AS(
SELECT ac.category_name,
       SUM(revenue_amount) AS total_revenue
FROM dim_app_category AS ac
JOIN fct_app_revenue AS ar
      ON ac.category_id = ar.category_id
WHERE ar.revenue_date >= '2024-04-01'
      AND ar.revenue_date < '2024-05-01'
GROUP BY ac.category_name
),
ranked_category AS(
SELECT category_name,
       total_revenue,
       DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rnk
FROM category_revenue
)

SELECT category_name,
       total_revenue
FROM ranked_category
WHERE rnk <= 10;


-- Problem2: During the second quarter of 2024, how does the weekly revenue ranking of each app category change? The team will use this analysis to identify performance trends and adjust engagement efforts.
-- Business insight: In each app category category weekly revenue the "social" category generated the highest revenue in Q2. becuase that's application category used by most of the users. 
WITH category_revenue AS(
SELECT ac.category_name,
       STRFTIME('%Y-%W',revenue_date) AS year_week,
       SUM(revenue_amount) AS total_revenue
FROM fct_app_revenue AS ap
JOIN dim_app_category AS ac
      ON ap.category_id = ac.category_id
WHERE revenue_date >= '2024-04-01'
      AND revenue_date < '2024-07-01'
GROUP BY ac.category_name, year_week
)

SELECT category_name,
       year_week,
       total_revenue,
       DENSE_RANK() OVER(PARTITION BY category_name ORDER BY total_revenue DESC) AS rnk
FROM category_revenue;


-- Problem3: For apps using a subscription monetization model, can you give us the running total revenue by app for every day in April 2024? We are investigating a complaint from app developers about a slow down in revenue in that month.
-- Business insight: For app using "Subscription"  monetization type revenue was slightly increased that's not a slow down in revenue, check the data pipeline to get correct metrics.
SELECT m.app_id,
       revenue_date,
       revenue_amount,
       SUM(revenue_amount) OVER(PARTITION BY m.app_id ORDER BY revenue_date) AS running_total_april
FROM fct_app_revenue AS ar
JOIN dim_monetization_model AS m
      ON ar.app_id = m.app_id
WHERE m.monetization_type = "subscription"
      AND (revenue_date >= '2024-04-01'
      AND revenue_date < '2024-05-01');
      
      

