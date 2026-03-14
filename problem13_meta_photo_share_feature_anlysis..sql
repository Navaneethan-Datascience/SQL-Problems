-- How are users engaging with the photo sharing feature on Facebook across different age and geographic segments? Using SQL, analyze interaction data to identify how users under 18, users over 50, and international users utilize these features. Based on this analysis, what insights can be drawn to tailor product strategies and enhancements that boost engagement among these key user groups?

-- Problem1 : How many photos were shared by users who are either under 18 years old or over 50 years old during July 2024? This metric will help us understand if these age segments are engaging with the photo sharing feature.
-- totally  7 shared by users across global the age below 18 or above 50 in the july 2024.
SELECT COUNT(*) AS total_photos_shared_by_user
FROM fct_photo_sharing AS fps
JOIN dim_user AS u
      ON fps.user_id = u.user_id
WHERE shared_date BETWEEN '2024-07-01' AND '2024-07-31' AND (age < 18 OR age > 50);

-- Problem2 : What are the user IDs and the total number of photos shared by users who are not from the United States during August 2024? This analysis will help us identify engagement patterns among international users.
-- user id 1,2,6,7,8,11 and these all users shared only photos on august 2024 these are users not from USA.
SELECT u.user_id,
       COUNT(*) AS total_photos_shared
FROM fct_photo_sharing AS fps
JOIN dim_user AS u
      ON fps.user_id = u.user_id
WHERE shared_date BETWEEN '2024-08-01' AND '2024-08-31' AND (country != 'United States')
GROUP BY u.user_id;


-- Proplem3 : What is the total number of photos shared by users who are either under 18 years old or over 50 years old and who are not from the United States during the third quarter of 2024? This measure will inform us if there are significant differences in usage across these age and geographic segments.
-- totally 14 photos shared by users those aren't from USA and age below 18 or age above 50 in the third quarter of 2024.
SELECT COUNT(*) AS total_photos_shared
FROM fct_photo_sharing AS fps
JOIN dim_user AS u
      ON fps.user_id = u.user_id
WHERE shared_date BETWEEN '2024-07-01' AND '2024-09-30' AND (age < 18 OR age > 50) AND (country != 'United States');