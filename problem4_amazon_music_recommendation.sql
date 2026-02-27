-- The Amazon Music Recommendation Team needs to analyze how playlist characteristics influence user engagement. Using SQL, the task is to examine the correlation between the number of tracks in a playlist and user listening time, with the goal of optimizing playlist recommendations. This analysis will guide strategies to enhance user experience by tailoring playlists that maximize listening time and encourage music discovery.

-- Problem1 : The Amazon Music Recommendation Team wants to know which playlists have the least number of tracks. Can you find out the playlist with the minimum number of tracks?
-- Indie discoveries playlist have less number(8) of tracks and it probably less listening time and comparing to other playlist. 
WITH ranked_play_list AS(
SELECT playlist_name,
       number_of_tracks,
       DENSE_RANK() OVER(ORDER BY number_of_tracks ASC) AS rnk
FROM playlists
)

SELECT playlist_name,
       number_of_tracks
FROM ranked_play_list
WHERE rnk = 1;





-- Problem2 : We are interested in understanding the engagement level of playlists. Specifically, we want to identify which playlist has the lowest average listening time per track. This means calculating the total listening time for each playlist in October 2024 and then normalizing it by the number of tracks in that playlist. Can you provide the name of the playlist with the lowest value based on this calculation?
-- 3.125 listening minutes per track which is Indie discovery playlist becuase this the playlist have bottom of tracks have and probably the listening time also been less. 
WITH playlist_listening_minutes AS(
SELECT playlist_id,
       SUM(listening_time_minutes) AS total_listening_minutes
FROM playlist_engagement
WHERE engagement_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY playlist_id
)

SELECT p.playlist_name,
       ROUND(plm.total_listening_minutes*1.0/ p.number_of_tracks,4) AS avg_listening_time_per_track
FROM playlist_listening_minutes AS plm
JOIN playlists AS p
      ON plm.playlist_id = p.playlist_id
ORDER BY avg_listening_time_per_track ASC
LIMIT 1;

-- To optimize our recommendations, we need the average monthly listening time per listener for each playlist in October 2024. For readibility, please round down to the average listening time to the nearest whole number.
-- the playlist Top 50 have highest avg listening time in october 2024 based on these we can give personlized song recommendation for listeners.
SELECT p.playlist_id,
       p.playlist_name,
       FLOOR(SUM(pe.listening_time_minutes)*1.0/COUNT(DISTINCT user_id)) AS avg_listening_time
FROM playlist_engagement AS pe
JOIN playlists AS p
     ON pe.playlist_id = p.playlist_id
WHERE pe.engagement_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY p.playlist_id,p.playlist_name;


