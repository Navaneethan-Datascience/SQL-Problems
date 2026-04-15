-- You are a Data Scientist on the WhatsApp consumer experience team focusing on enhancing user interaction with call and group chat features. Your team aims to understand user engagement patterns with family-focused group chats, average call durations, and group chat participation levels. The end goal is to simplify the user interface and interaction flows based on these insights.

-- Table Schema:
-- fct_user_calls(user_id, call_id, call_duration, call_date)
-- fct_group_chats(chat_id, user_id, chat_name, chat_creation_date)

-- Problem1: How many distinct users have participated in group chats with names containing the word ''family'', where the chat was created in April 2024? This analysis will inform product managers about user engagement trends with family-focused chat groups.
-- Business Insight: April 2024 only 4 users have participated in family group chats that means we have add customize features for family related group chats that brings more users to create group chats and keep retention.
SELECT COUNT(DISTINCT user_id) AS users_family_chat
FROM fct_group_chats
WHERE chat_name LIKE '%family%'
      AND chat_creation_date >= '2024-04-01'
      AND chat_creation_date < '2024-05-01';
      
      
-- Problem2: To better understand user call behavior, we want to analyze the total call duration per user in May 2024. What is the average total call duration across all users?
-- Business Insight: users spent avg of 5 hours 26 minutes of theirs time in whatsapp calls in may 2024. comparing whatsapp group chat calls are performing well to keep this retention we continue thr process also we can apply the same able feature to whatsapp group chats.
WITH user_call_duration_may AS(
SELECT user_id,
       SUM(call_duration) AS call_duration_may
FROM fct_user_calls
WHERE call_date >= '2024-05-01'
      AND call_date < '2024-06-01'
GROUP BY user_id
)

SELECT AVG(call_duration_may) AS avg_call_duration_may
FROM user_call_duration_may;


-- Problem3 :What is the maximum number of group chats any user has participated in during the second quarter of 2024 and how does this compare to the average participation rate? This insight will guide decisions on simplifying the chat interface for both heavy and average users.
-- Business Insight: In the second quarter of 2024 maximum users maximum chats is 4 and overall user participation rate is 3.2. comparing each metrics maximum chat higher thant avg participation rate.
WITH group_chats_user_q2 AS(
SELECT user_id,
       COUNT(*) AS chats_user_q2
FROM fct_group_chats
WHERE chat_creation_date >= '2024-04-01'
      AND chat_creation_date < '2024-07-01'
GROUP BY user_id
)

SELECT MAX(chats_user_q2) AS max_chats,
       SUM(chats_user_q2) * 1.0 / COUNT(*) AS avg_participation_rate
FROM group_chats_user_q2;
