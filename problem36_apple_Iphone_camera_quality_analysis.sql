-- How do camera quality metrics vary across different user groups for the iPhone? Using SQL, analyze photo and video capture performance data to identify trends and differences in user experiences. Based on this analysis, what insights can be drawn to guide hardware or software improvements and prioritize future camera development efforts?

-- Tableschmema:
-- fct_capture_quality(capture_id, user_group_id, capture_date, photo_quality_score, video_quality_score)
-- dim_user_group(user_group_id, user_group_name, user_group_description)

-- Problem1: For the month of July 2024, how do average photo capture quality scores vary across different user groups? This analysis will help us identify segments where camera performance improvements could be prioritized.
-- these are the user group names we have to focus because the average camera quality is 70 from all group
SELECT user_group_name,
       ROUND(AVG(photo_quality_score),2) AS avg_photo_quality_score
FROM fct_capture_quality AS cq
JOIN dim_user_group AS ug
      ON cq.user_group_id = ug.user_group_id
WHERE capture_date >= '2024-07-01'
      AND capture_date < '2024-08-01'
GROUP BY user_group_name;


-- Problem2 : Between August 1st and August 7th, 2024, how do photo capture quality scores change for each iPhone user group? Use a 3-day average rolling window for this analysis.

SELECT ug.user_group_name,
       capture_date,
       AVG(photo_quality_score) OVER(PARTITION BY ug.user_group_name 
            ORDER BY capture_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_rolling_3_day_photo_quality
FROM fct_capture_quality AS cq
JOIN dim_user_group AS ug
      ON cq.user_group_id = ug.user_group_id
WHERE capture_date >= '2024-08-01'
      AND capture_date <= '2024-08-07';
      
-- Problem3: For Q3 2024 (July 1st to September 30th), how do video capture quality scores trend for each iPhone user group when comparing each capture to the subsequent one? This insight will support our approach to optimize video performance through targeted hardware or software improvements.

SELECT ug.user_group_name,
       cq.capture_date,
       cq.video_quality_score,
       LEAD(video_quality_score) OVER(PARTITION BY user_group_name ORDER BY capture_date) AS subsequent_day_video_quality,
       LEAD(video_quality_score) OVER(PARTITION BY user_group_name ORDER BY capture_date) - cq.video_quality_score AS video_quality_trend
FROM fct_capture_quality AS cq
JOIN dim_user_group AS ug
      ON cq.user_group_id = ug.user_group_id
WHERE capture_date >= '2024-07-01'
      AND capture_date < '2024-10-01';



