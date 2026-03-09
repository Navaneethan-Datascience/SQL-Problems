-- How do different app categories on the Google Play Store convert from browsing to actual downloads? Using SQL, analyze user behavior to measure conversion efficiency across categories. Based on this analysis, what insights can be drawn to inform product placement and marketing strategies for app developers and users?
-- Problem 1: The marketplace team wants to identify high and low performing app categories. Provide the total downloads for the app categories for November 2024. If there were no downloads for that category, return the value as 0.

SELECT a.category,
       COALESCE(SUM(ad.download_count),0) AS total_downloads
FROM dim_app AS a
LEFT JOIN fct_app_downloads AS ad 
      ON a.app_id = ad.app_id 
      AND ad.download_date BETWEEN '2024-11-01' AND '2024-11-30'
GROUP BY a.category;

-- Our team's goal is download conversion rate -- defined as downloads per browse event. For each app category, calculate the download conversion rate in December, removing categories where browsing counts are be zero.
-- Book app category have highest cenversion rate(0.36) which impact the people to make more desired action like downloading. 
WITH browse_category AS(
SELECT a.category,
       SUM(ab.browse_count) AS total_browse_count
FROM dim_app AS a
LEFT JOIN fct_app_browsing AS ab  
      ON a.app_id = ab.app_id
      AND ab.browse_date BETWEEN '2024-12-01' AND '2024-12-31'
GROUP BY a.category
),
download_category AS(
SELECT a.category,
       SUM(ad.download_count) AS total_downloads
FROM dim_app AS a
LEFT JOIN fct_app_downloads AS ad 
      ON a.app_id = ad.app_id
      AND ad.download_date BETWEEN '2024-12-01' AND '2024-12-31'
GROUP BY a.category
)


SELECT bc.category,
       ROUND(COALESCE(dc.total_downloads,0)*1.0/bc.total_browse_count,2) AS conversion_rate
FROM browse_category AS bc
LEFT JOIN download_category AS dc
      ON bc.category = dc.category
WHERE total_browse_count > 0;


-- The team wants to compare conversion rates between free and premium apps across all categories. Combine the conversion data for both app types to present a unified view for Q4 2024.
-- book category premium app type have haighest conversion rate(0.35) and in free app type Entertainment app category have highest conversion rate(0.28) it most of the vistors visting book and entertainment category.  
WITH download_categories AS(
SELECT a.category,
       a.app_type,
       SUM(ad.download_count) AS total_downloads
FROM dim_app AS a
LEFT JOIN fct_app_downloads AS ad
      ON a.app_id = ad.app_id
      AND ad.download_date BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY a.category, a.app_type
),
browsing_categories AS(
SELECT a.category,
       a.app_type,
       SUM(ab.browse_count) AS total_browse_count
FROM dim_app AS a
LEFT JOIN fct_app_browsing AS ab
      ON a.app_id = ab.app_id
      AND ab.browse_date BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY a.category, a.app_type
)

SELECT dc.category,
       dc.app_type,
       ROUND(COALESCE(dc.total_downloads,0)*1.0/ bc.total_browse_count,4) AS coversion_rate
FROM download_categories AS dc
JOIN browsing_categories AS bc
      ON dc.category = bc.category
      AND dc.app_type = bc.app_type;