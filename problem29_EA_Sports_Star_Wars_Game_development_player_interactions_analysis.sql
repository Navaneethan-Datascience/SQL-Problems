-- How do player interactions with different storyline components in a Star Wars game reveal engagement patterns? Using SQL, analyze gameplay data to evaluate how narrative elements capture player attention and drive interaction. Based on this analysis, what insights can be drawn to understand which storylines are most effective in sustaining player engagement?


-- Table Schema
-- fct_storyline_interactions(interaction_id, player_id, storyline_component_id, interaction_date)
-- dim_storyline_components(storyline_component_id, component_name)

-- Problem1: For each storyline component, how many unique players interacted with that component during the entire month of May 2024? If a storyline component did not have any interactions, return the component name with the player count of 0.
-- Business Insight : Darkside Temptations, Light side redemptions, Force awakening and Rebel alliance components interacted by highest count distinct player. which defines those specific players of often usng this component it was thier favourite component so to keep this retention we can give offer for this component to the user.
SELECT component_name,
       COUNT(DISTINCT player_id) AS unique_players_count_may
FROM dim_storyline_components AS sc
LEFT JOIN fct_storyline_interactions AS si
      ON sc.storyline_component_id = si.storyline_component_id
      AND si.interaction_date >= '2024-05-01'
      AND si.interaction_date < '2024-06-01'
GROUP BY component_name;


-- Problem2: What is the total number of storyline interactions for each storyline component and player combination during May 2024? Consider only those players who have interacted with at least two different storyline components.
-- Business Insights : In may 2024 components Force awakening and Light Side Redemption have highest total number of intrection across user who interacted more thane one different component. 
WITH player_component_may AS(
SELECT player_id,
       COUNT(DISTINCT storyline_component_id) AS total_storyline_components
FROM fct_storyline_interactions AS si
WHERE interaction_date >= '2024-05-01'
      AND interaction_date < '2024-06-01'
GROUP BY player_id
HAVING COUNT(DISTINCT storyline_component_id) >= 2
)

SELECT sc.component_name,
       si.player_id,
       COUNT(*) AS total_interactions_may
FROM fct_storyline_interactions AS si
JOIN dim_storyline_components AS sc
      ON si.storyline_component_id = sc.storyline_component_id
JOIN player_component_may AS pmc
      ON si.player_id = pmc.player_id
WHERE si.interaction_date >= '2024-05-01'
      AND si.interaction_date < '2024-06-01'
GROUP BY sc.component_name, si.player_id;


-- Problem3: Can you rank the storyline components by the average number of interactions per player during May 2024? Provide a list of storyline component names and their ranking.
-- Business Insights : Force Awakening, Jedi Resurrection and Sith Prohecy components have top ranked by avg interactions which defines the palyers are using this components for often in the game based on these we increase charge for these component ocassionaly we should give the offers for these components.
WITH player_component_interactions AS(
SELECT player_id,
       component_name,
       COUNT(*) AS total_interactions
FROM fct_storyline_interactions AS si
JOIN dim_storyline_components AS sc
      ON si.storyline_component_id = sc.storyline_component_id
WHERE interaction_date >= '2024-05-01'
      AND interaction_date < '2024-06-01'
GROUP BY player_id,component_name
),
avg_interactions_component AS(
SELECT component_name,
       ROUND(AVG(total_interactions),2) AS avg_no_of_interactions
FROM player_component_interactions
GROUP BY component_name
)
SELECT component_name,
       avg_no_of_interactions,
       DENSE_RANK() OVER(ORDER BY avg_no_of_interactions DESC) AS rnk
FROM avg_interactions_component;