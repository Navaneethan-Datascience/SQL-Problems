-- What is the impact of the recommendation algorithm on user engagement within Netflix’s content discovery system? Using SQL, analyze how recommendations influence total watch time and categorize user watch sessions to identify engagement patterns. Based on this analysis, what insights can be drawn to refine the recommendation engine, enhance user satisfaction, and encourage more diverse content exploration?

-- Problem1 : What is the total watch time for content after it was recommended to users? To correctly attribute watch time to the recommendation, it is critical to only include watch time after the recommendation was made to the user. A content could get recommended to a user multiple times. If so, we want to use the first date that the content was recommended to a user.


WITH first_recommend_user AS(
SELECT content_id,
       user_id,
       MIN(recommended_date) AS first_recommended_date
FROM fct_recommendations
GROUP BY content_id, user_id
)

SELECT wh.content_id,
       SUM(wh.watch_time_minutes) AS total_watch_minutes
FROM fct_watch_history AS wh
JOIN first_recommend_user AS ru
     ON wh.content_id = ru.content_id
     AND wh.user_id = ru.user_id
WHERE wh.watch_date >= ru.first_recommended_date
GROUP BY wh.content_id;


-- Problem2: The team wants to know the total watch time for each genre in first quarter of 2024, split by whether or not the content was recommended vs. non-recommended to a user.
-- Requirements : Watch time should be bucketed into 'Recommended' by joining on both user and content, regardless of when they watched it vs. when they received the recommendation.

-- Action genre content had highest watch time minutes under both recommended(530) and non recommended content(125).
 WITH recommended_watch AS (
    SELECT 
        wh.user_id,
        wh.content_id,
        wh.watch_time_minutes,
        c.genre
    FROM fct_watch_history AS wh
    JOIN fct_recommendations AS r
        ON wh.user_id = r.user_id
       AND wh.content_id = r.content_id
    JOIN dim_content AS c
        ON wh.content_id = c.content_id
    WHERE wh.watch_date BETWEEN '2024-01-01' AND '2024-03-31'
),
non_recommended_watch AS (
    SELECT 
        wh.user_id,
        wh.content_id,
        wh.watch_time_minutes,
        c.genre
    FROM fct_watch_history AS wh
    LEFT JOIN fct_recommendations AS r
        ON wh.user_id = r.user_id
       AND wh.content_id = r.content_id
    JOIN dim_content AS c
        ON wh.content_id = c.content_id
    WHERE r.content_id IS NULL
      AND wh.watch_date BETWEEN '2024-01-01' AND '2024-03-31'
)
SELECT 
    genre,
    'Recommended' AS bucket,
    SUM(watch_time_minutes) AS total_watch_minutes
FROM recommended_watch
GROUP BY genre

UNION ALL

SELECT 
    genre,
    'Non-Recommended' AS bucket,
    SUM(watch_time_minutes) AS total_watch_minutes
FROM non_recommended_watch
GROUP BY genre;


-- The team aims to categorize user watch sessions into 'Short', 'Medium', or 'Long' based on watch time for recommended content to identify engagement patterns.
-- Requirements : 'Short' for less than 60 minutes, 'Medium' for 60 to 120 minutes, and 'Long' for more than 120 minutes. Can you classify and count the sessions in Q1 2024 accordingly?
-- user watch session under the 'Medium" means watchtime between 60 and 120 muntes bucket have highest session count(14) which means most our users watching recommend content 60 to 120 minutes.
WITH watch_time_content AS(
SELECT wh.user_id,
       wh.content_id,
       wh.watch_time_minutes
FROM fct_watch_history AS wh
JOIN fct_recommendations AS r
      ON wh.content_id = r.content_id 
      AND wh.user_id = r.user_id
WHERE wh.watch_date BETWEEN '2024-01-01' AND '2024-03-31'
)

SELECT 
       CASE
          WHEN watch_time_minutes < 60 THEN 'Short'
          WHEN watch_time_minutes BETWEEN 60 AND 120 THEN 'Medium'
          WHEN watch_time_minutes > 120 THEN 'Long'
       END AS watch_time_bucket,
       COUNT(*) AS session_count
FROM watch_time_content
GROUP BY watch_time_bucket;

