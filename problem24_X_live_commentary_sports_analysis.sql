-- How do user interactions with live sports commentary and highlights on the X sports updates platform reveal patterns and preferences in engagement? Using SQL, analyze interaction data to compare engagement across these content types. Based on this analysis, what insights can be drawn to prioritize content strategies and improve the user experience during live events?

-- Table Schema:
-- fct_user_interactions(interaction_id, user_id, content_type, interaction_duration, interaction_date, category_id)
-- dim_sports_categories(category_id, category_name)

-- What is the average duration of user interactions with live sports commentary during April 2024? Round the result to the nearest whole number.
-- In april 2024 users spent their time avergely 136 minutes in the paltform for live commentary sport which the strong content quality from our and it defines the strong user engagement that period of time. 

SELECT ROUND(AVG(interaction_duration)) AS avg_user_interaction_duration_live
FROM fct_user_interactions
WHERE interaction_date >= '2024-04-01'
      AND interaction_date < '2024-05-01'
      AND content_type = 'live sports commentary';
      

-- For the month of May 2024, determine the total number of users who interacted with live sports commentary and highlights. Ensure to include users who interacted with either or both content types.
-- 25 users interacted both content type live sports commentary and highlights or either of one on may 2024. this number shows the popularity of two content. 

SELECT COUNT(DISTINCT user_id) AS users_interacted_lives_commentary
FROM fct_user_interactions
WHERE interaction_date >= '2024-05-01'
      AND interaction_date < '2024-06-01'
      AND (content_type = 'live sports commentary' OR content_type = 'highlights');
      
-- Identify the top 3 performing sports categories for live sports commentary based on user engagement in May 2024. Focus on those with the highest total interaction time.
-- baseball, hockey, cricket and football these content categories top total interaction duration time. which defines users spending more time on these type of sport content and we have to that retention alive. 
WITH interaction_duration_category_may AS(
SELECT sc.category_name,
       SUM(ui.interaction_duration) AS total_interaction_duration
FROM fct_user_interactions AS ui
JOIN dim_sports_categories AS sc
      ON ui.category_id = sc.category_id
WHERE interaction_date >= '2024-05-01'
      AND interaction_date < '2024-06-01'
      AND ui.content_type = 'live sports commentary'
GROUP BY sc.category_name
),
ranked_category AS(
SELECT category_name,
       total_interaction_duration,
       DENSE_RANK() OVER(ORDER BY total_interaction_duration DESC) AS rnk
FROM interaction_duration_category_may
)

SELECT category_name,
       total_interaction_duration,
       rnk
FROM ranked_category
WHERE rnk <= 3;

-- Business explanation : in live sports commentary derives the most user retention centainly baseball, hockey, cricket and football these sports content listened by more users keeping that retention is good apply those techniques used in all other sports category.