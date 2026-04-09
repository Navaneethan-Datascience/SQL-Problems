-- How do different telecom partners influence Netflix subscriber conversion, retention, and engagement when bundled with phone plans? Using SQL, analyze subscription and usage data to identify which partners drive the highest conversions, longest retention, and strongest engagement. Based on this analysis, what insights can be drawn to inform future partnership strategies and optimize pricing models?


-- Table schema:
-- fct_bundle_subscriptions(subscriber_id, partner_id, bundle_id, conversion_date, retention_days, engagement_score)
-- dim_telecom_partners(partner_id, partner_name)


-- Problem1: For subscribers who converted in January 2024, give us the name of the Telecom partner that led to acquiring the most new subscribers?

SELECT partner_name,
       COUNT(*) AS new_subsribers_jan
FROM dim_telecom_partners AS tp
JOIN fct_bundle_subscriptions AS bs
      ON tp.partner_id = bs.partner_id
WHERE conversion_date >= '2024-01-01'
      AND conversion_date < '2024-02-01'
GROUP BY partner_name
ORDER BY COUNT(*) DESC
LIMIT 1;


-- Problem2: For each telecom partner, what is the longest number of days that a subscriber remained active after conversion and which bundle(s) did they subscribe on? For this analysis, only look at conversions between October 8th, 2024 and October 14th, 2024. If there are multiple bundles resulting in the same highest retention, return all the bundles.

WITH partner_bundle_retention AS(
SELECT partner_name,
       bundle_id,
       retention_days
FROM fct_bundle_subscriptions AS bs
JOIN dim_telecom_partners AS tp
      ON bs.partner_id = tp.partner_id
WHERE conversion_date >= '2024-10-08'
      AND conversion_date <= '2024-10-14'
),
ranked_table AS(
SELECT partner_name,
       bundle_id,
       retention_days,
       RANK() OVER(PARTITION BY partner_name ORDER BY retention_days DESC) AS rnk
FROM partner_bundle_retention
)

SELECT partner_name,
       bundle_id,
       retention_days
FROM ranked_table
WHERE rnk = 1;

-- Problem3: For subscribers who converted in November 2024, what is the average engagement score for each bundle within each telecom partner?
-- How does each bundle’s average engagement score compare to the all-time highest engagement score recorded by its respective telecom partner expressed as a percentage of that maximum?

WITH partner_avg_engagement_score AS(
SELECT tp.partner_id,
       partner_name,
       bundle_id,
       AVG(engagement_score) AS avg_engagement_score
FROM fct_bundle_subscriptions AS bs
JOIN dim_telecom_partners AS tp
      ON bs.partner_id = tp.partner_id
WHERE conversion_date >= '2024-11-01'
      AND conversion_date < '2024-12-01'
GROUP BY tp.partner_id, partner_name, bundle_id
),

partner_high_engagement AS(
SELECT partner_id,
       MAX(engagement_score) AS highest_engagement_score
FROM fct_bundle_subscriptions
GROUP BY partner_id
)

SELECT partner_name,
       bundle_id,
       ROUND(avg_engagement_score,4) AS avg_engagement_score,
       highest_engagement_score,
       ROUND(
        avg_engagement_score * 100 / highest_engagement_score
       ) AS percentage_of_max
FROM partner_avg_engagement_score AS avge
JOIN partner_high_engagement AS highe
      ON avge.partner_id = highe.partner_id;
