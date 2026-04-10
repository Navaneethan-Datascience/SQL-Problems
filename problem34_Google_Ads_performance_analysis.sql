-- How can ad campaign strategies on Google Ads be optimized by analyzing performance data? Using SQL, evaluate the diversity of ad formats, identify high-reach campaigns, and measure return on investment across different campaign segments. Based on this analysis, what insights can be drawn to guide strategic budget allocations and targeting adjustments for future campaigns?

-- Table schema
-- fct_ad_performance(campaign_id, ad_format, impressions, clicks, cost, revenue, campaign_date)
-- dim_campaign(campaign_id, segment)

-- problem1: For each ad campaign segment, what are the unique ad formats used during July 2024? This will help us understand the diversity in our ad formats.

SELECT DISTINCT
       c.segment,
       ad_format
FROM fct_ad_performance AS ap
JOIN dim_campaign AS c
      ON ap.campaign_id = c.campaign_id
WHERE campaign_date >= '2024-07-01'
      AND campaign_date < '2024-08-01';
      
      
-- problem2: Your approach to use a window function to calculate the rolling 7-day sum of impressions per campaign is correct. Filtering for August and then counting distinct campaigns that exceed 1,000 impressions in any 7-day window is exactly what the question asks for.

WITH rolling_impressions AS(
SELECT campaign_id,
       campaign_date,
       SUM(impressions) OVER(
            PARTITION BY campaign_id
            ORDER BY campaign_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS rolling_7_days_impressions
FROM fct_ad_performance
WHERE campaign_date >= '2024-08-01'
      AND campaign_date < '2024-09-01'
)


SELECT COUNT(DISTINCT campaign_id) AS distinct_campaings_aug
FROM rolling_impressions
WHERE rolling_7_days_impressions > 1000;


-- problem3 : What is the total ROI for each campaign segment in Q3 2024? And, how does it compare to the average ROI of all campaigns (return labels 'higher than average' or 'lower than average')? We will use this to identify which segments are outperforming the average.
-- Note 1: ROI is defined as (revenue - cost) / cost.
-- Note 2: For average ROI across segment, calculate the ROI per segment and then calculate the average ROI across segments.


WITH q3_roi_segment AS (
    SELECT 
        c.segment,
        (SUM(ap.revenue) - SUM(ap.cost)) * 1.0 / SUM(ap.cost) AS q3_total_roi
    FROM fct_ad_performance ap
    JOIN dim_campaign c
        ON ap.campaign_id = c.campaign_id
    WHERE ap.campaign_date >= '2024-07-01'
      AND ap.campaign_date < '2024-10-01'
    GROUP BY c.segment
)

SELECT 
    segment,
    ROUND(q3_total_roi, 2) AS q3_total_roi,
    CASE 
        WHEN q3_total_roi > AVG(q3_total_roi) OVER () 
        THEN 'higher than average'
        ELSE 'lower than average'
    END AS roi_comparison_segment
FROM q3_roi_segment;
