-- How effective is the recommendation algorithm for artist discovery on Apple Music? Using SQL, analyze user interactions with recommended artists to evaluate performance. Consider key metrics such as engagement levels, discovery rates, and conversions, and provide insights on how the recommendation engine can be enhanced to improve overall user engagement.

-- Problem1: How many unique users have streamed an artist on or after the date it was recommended to them?
-- 10 unique users streamed after the artist recommendated to them by our recommendattion system that means out recommendation performing well we got retention here we have to maintain the pace here.

SELECT COUNT(DISTINCT us.user_id) AS user_streamed_artist_count
FROM artist_recommendations AS ar
JOIN user_streams AS us
     ON ar.artist_id = us.artist_id AND ar.user_id = us.user_id
WHERE us.stream_date >= ar.recommendation_date;

-- Problem2: What is the average number of times a recommended artist is streamed by users in May 2024? Similar to the previous question, only include streams on or after the date the artist was recommended to them.
-- 1.8 avg artist streamed by users after the artist recommented to them in my 2024 which is in may month that means out reccommendation systemt doesn't follow worked on that month it affects retention rate.

WITH streams_user_artist AS(
SELECT us.user_id,
       us.artist_id,
       COUNT(*) AS total_streams
FROM user_streams AS us
JOIN artist_recommendations AS ar
     ON us.artist_id = ar.artist_id AND us.user_id = ar.user_id
WHERE us.stream_date BETWEEN'2024-05-01' AND '2024-05-31' AND us.stream_date >= ar.recommendation_date
GROUP BY us.user_id, us.artist_id
)

SELECT AVG(total_streams) AS avg_streams_user_artist
FROM streams_user_artist;

-- Across users who listened to at least one recommended artist, what is the average number of distinct recommended artists they listened to? As in the previous question, only include streams that occurred on or after the date the artist was recommended to the user.
-- 1.2 unique artist's songs were listened by users across the users who listened atleast one recommended artist after artist recommended to user which defines the poor performance of recommendation becuase our recommedation isn't doing well and it's not optimizing artist suggestion based on user behaviour.

WITH artist_recommended_count AS(
SELECT us.user_id,
       COUNT(DISTINCT us.artist_id) AS recommended_artist_count
FROM user_streams AS us
JOIN artist_recommendations AS ar
     ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
WHERE us.stream_date >= ar.recommendation_date
GROUP BY us.user_id
)

SELECT AVG(recommended_artist_coxunt) AS avg_artist_listened
FROM artist_recommended_count;  