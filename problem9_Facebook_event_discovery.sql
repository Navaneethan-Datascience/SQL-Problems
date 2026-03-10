-- Which event categories receive the most user clicks on Facebook’s Events Discovery platform? Using SQL, analyze user interaction data to determine whether users are engaging with events in their preferred categories and to uncover broader engagement patterns. Based on this analysis, what insights can be drawn to optimize recommendation algorithms, increase user satisfaction, and boost event attendance?
-- Problem1 : How many times did users click on event recommendations for each event category in March 2024? Show the category name and the total clicks.
-- Insights : Event music(2) is highest user click event on march 2024 which means this category attracted most users.
SELECT e.category_name,
       COUNT(*) AS total_user_clicks
FROM fct_event_clicks AS ec
JOIN dim_events AS e
      ON ec.event_id = e.event_id
WHERE ec.click_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY e.category_name;


-- For event clicks in March 2024, identify whether each user clicked on an event in their preferred category. Return the user ID, event category, and a label indicating if it was a preferred category ('Yes' or 'No').
-- user 101,102, 103 used also accesssed us not preferred category content.

SELECT u.user_id,
       e.category_name,
       CASE
          WHEN e.category_name = u.preferred_category THEN 'Yes'
          ELSE 'No'
       END AS category_label
FROM fct_event_clicks AS ec
JOIN dim_events AS e
      ON ec.event_id = e.event_id
JOIN dim_users AS u
      ON ec.user_id = u.user_id
WHERE ec.click_date BETWEEN '2024-03-01' AND '2024-03-31';
      

-- Generate a report that combines the user ID, their full name (first and last name), and the total clicks for events they interacted with in March 2024. Sort the report by user ID in ascending order.
-- user 101,102, and 103 have highest clicks in march 2024 because they also accessed un preffered category content.

SELECT u.user_id,
       CONCAT(first_name," ",last_name) AS full_name,
       COUNT(*) AS total_click_event
FROM fct_event_clicks AS ec
JOIN dim_users AS u
      ON ec.user_id = u.user_id
WHERE ec.click_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY u.user_id, CONCAT(first_name," ",last_name)
ORDER BY u.user_id ASC;