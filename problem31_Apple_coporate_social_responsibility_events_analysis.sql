-- How effective are Apple’s recent philanthropic initiatives in engaging participants across different communities and programs? Using SQL, analyze engagement data to evaluate participation levels and identify patterns of involvement. Based on this analysis, what insights can be drawn to guide strategic decisions for resource allocation and future program expansions?

-- Table schema:
-- fct_philanthropic_initiatives(program_id, community_id, event_date, participants, program_name)
-- dim_community(community_id, community_name, region)

-- Problem1: Apple's Corporate Social Responsibility team wants a summary report of philanthropic initiatives in January 2024. Please compile a report that aggregates participant numbers by community and by program.
-- we measured total participants by community programs under the each community which shows which event performing most participants engaged with. For instance the chicago community program called Mac coding camp have 65 participants.
SELECT community_name,
       program_name,
       SUM(participants) AS total_participants
FROM fct_philanthropic_initiatives AS pi
JOIN dim_community AS c
      ON pi.community_id = c.community_id
WHERE event_date >= '2024-01-01'
      AND event_date < '2024-02-01'
GROUP BY community_name, program_name;


-- Problem2: The team is reviewing the execution of February 2024 philanthropic programs. For each initiative, provide details along with the earliest event date recorded within each program campaign to understand start timings.
-- the program names "Apple community Healt" and "Tech for kids" starting date is febraury 05 and 10
SELECT program_id,
       program_name,
       MIN(event_date) AS earlies_event_date
FROM fct_philanthropic_initiatives
WHERE event_date >= '2024-02-01'
      AND event_date < '2024-03-01'
GROUP BY program_id, program_name;


-- For a refined analysis of initiatives held during the first week of March 2024, include for each program the maximum participation count recorded in any event. This information will help highlight the highest engagement levels within each campaign.
-- In the first week of march in 2024 program id 5 and 6 have a highest participants count in any event.
SELECT program_id,
       program_name,
       MAX(participants) AS highest_participants
FROM fct_philanthropic_initiatives
WHERE event_date >= '2024-03-01'
      AND event_date <= '2024-03-07'
GROUP BY program_id, program_name;
