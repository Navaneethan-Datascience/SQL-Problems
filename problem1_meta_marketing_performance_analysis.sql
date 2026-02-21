-- How effective are custom audience segments and lookalike audiences in driving user acquisition and conversions? Using SQL, evaluate advertising performance by analyzing key metrics such as ad impressions, total conversions, and cost per conversion across different audience groups. Based on this analysis, what actionable insights can be provided to optimize campaign efficiency and improve overall marketing performance?
-- Table1 : ad_performance(ad_id, audience_segment_id, impressions, conversions, ad_spend, date)
-- Table2 : audience_segments(audience_segment_id, segment_name)


-- Problem 1: How many total ad impressions did we receive from custom audience segments in October 2024?
SELECT SUM(ap.impressions) AS total_impressions
FROM ad_performance AS ap
JOIN audience_segments AS a
     ON ap.audience_segment_id = a.audience_segment_id
WHERE a.segment_name LIKE '%Custom Audience%' AND ap.date BETWEEN '2024-10-01' AND '2024-10-31';

-- Totally 74000 impressions we got from different Custom Audience segment in October 2024.alter

-- Problem 2: What is the total number of conversions we achieved from each custom audience segment in October 2024?
SELECT a.segment_name,
       SUM(ap.conversions) AS total_conversions
FROM ad_performance AS ap
JOIN audience_segments AS a
     ON ap.audience_segment_id = a.audience_segment_id
WHERE a.segment_name LIKE '%Custom Audience%' AND ap.date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY a.segment_name;

-- In october 2024 under the custom audience segment the App installers have 170 conversions, Email List Subscribers have 230 conversions and Video Viewers(25% Watched) have 255 conversions.
-- Cost per conversion = Total ad spend / Total number of conversions
SELECT a.segment_name,
       ROUND(SUM(ap.ad_spend) / SUM(ap.conversions),4) AS cost_per_conversions
FROM ad_performance AS ap
JOIN audience_segments AS a
     ON ap.audience_segment_id = a.audience_segment_id
GROUP BY a.segment_name
HAVING cost_per_conversions > 0
ORDER BY cost_per_conversions DESC;

-- Comparing different segment using the Cost per conversion the Custom Audience - App Installers segment have low rate(0.4988) that defines audience under the that segment easily possible to make conversion in less amount investment.