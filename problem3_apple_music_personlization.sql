-- The Apple Music Personalization Team needs to evaluate the effectiveness of its recommendation engine by analyzing user playlist interactions. Using SQL, the task is to measure how many users add recommended tracks to their playlists, calculate the average number of recommended tracks added per user, and identify users who add non-recommended tracks. This analysis will determine whether the recommendation algorithm requires refinement to improve user engagement and retention.

-- Problem1 : How many unique users have added at least one recommended track to their playlists in October 2024?
-- there are 6 distinct users added recommended track to thier playlist in october 2024

SELECT COUNT(DISTINCT user_id) AS total_users_added_reccomendation_track
FROM tracks_added
WHERE is_recommended = 1 AND added_date BETWEEN '2024-10-01' AND '2024-10-31';

-- Problem2 : Among the users who added recommended tracks in October 2024, what is the average number of recommended tracks added to their playlists? Please round this to 1 decimal place for better readability.
-- 3.8 tracks is the average amount of recommended tracks added by users in october 2024. this means apple music have to focus on enhancing their reccommendation system.
WITH user_reccomend_tracks_added AS(
SELECT user_id,
       COUNT(*) AS total_tracks_added
FROM tracks_added
WHERE is_recommended = 1 AND added_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY user_id
)

SELECT ROUND(AVG(total_tracks_added),1) AS avg_recommend_tracks_added
FROM user_reccomend_tracks_added;


-- Problem3: Can you give us the name(s) of users who added a non-recommended track to their playlist on October 2nd, 2024?
-- Frank is the user who added non recommended track to his playlist becuase he often or occasionaly listen the that track our reccomendation model isn't detectin his activity we need more enhancement in the recommendation.

SELECT u.user_name
FROM tracks_added AS ta
JOIN users AS u
     ON ta.user_id = u.user_id
WHERE is_recommended = 0 AND added_date = '2024-10-02'; 
