-- How do skill endorsements contribute to professional profiles on LinkedIn? Using SQL, analyze endorsement data to uncover patterns and factors that drive meaningful skill recognition among users. Specifically, evaluate key metrics that reflect how endorsements validate skills across different categories, such as TECHNICAL and MANAGEMENT. Based on this analysis, what insights can be drawn to better understand the role of endorsements in professional credibility?

-- Table schema:
-- fct_skill_endorsements(endorsement_id, user_id, skill_id, endorsement_date)
-- dim_skills(skill_id, skill_name, skill_category)
-- dim_users(user_id, user_name, profile_creation_date)

-- What percentage of users have at least one skill endorsed by others during July 2024?

WITH user_skills_endorsed AS(
SELECT user_id,
       COUNT(skill_id) AS total_skills_endorsed
FROM fct_skill_endorsements
WHERE endorsement_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY user_id
HAVING total_skills_endorsed >= 1
),
users_july AS(
SELECT COUNT(*) AS total_users_endorsed_july
FROM user_skills_endorsed
)
SELECT uj.total_users_endorsed_july*100/COUNT(u.user_id) AS endorsed_skill_users_percentage
FROM users_july AS uj
CROSS JOIN dim_users AS u;



-- What is the average number of endorsements received per user for skills categorized as 'TECHNICAL' during August 2024?


WITH total_endorsments_user AS(
SELECT user_id,
       COUNT(*) AS total_endorsments
FROM fct_skill_endorsements AS se
JOIN dim_skills AS s
      ON se.skill_id = s.skill_id
WHERE endorsement_date BETWEEN '2024-08-01' AND '2024-08-31' AND skill_category = 'TECHNICAL'
GROUP BY user_id
)

SELECT ROUND(AVG(total_endorsments),4) AS avg_total_endorsments
FROM total_endorsments_user;


-- For the MANAGEMENT skill category, what percentage of users who have ever received an endorsement for that skill received at least one endorsement in September 2024?

WITH sep_management_users AS(
SELECT DISTINCT se.user_id
FROM fct_skill_endorsements AS se
JOIN dim_skills AS s
     ON se.skill_id = s.skill_id
WHERE s.skill_category = 'MANAGEMENT' AND endorsement_date BETWEEN '2024-09-01' AND '2024-09-30'
),
management_users AS(
SELECT DISTINCT se.user_id
FROM fct_skill_endorsements AS se 
JOIN dim_skills AS s
     ON se.skill_id = s.skill_id
WHERE s.skill_category = 'MANAGEMENT'
)

SELECT COUNT(DISTINCT smu.user_id) * 100 / COUNT(DISTINCT mu.user_id) AS user_endorsement_management_percentage
FROM management_users AS mu
LEFT JOIN sep_management_users AS smu
      ON mu.user_id = smu.user_id;
