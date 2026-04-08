-- Which content types most effectively drive creator success on Meta’s platform? Using SQL, analyze creator data to evaluate how different content formats influence engagement and follower growth. Based on this analysis, what insights can be drawn to help optimize content strategies for maximum audience expansion?

-- Table schema:
-- fct_creator_content(content_id, creator_id, published_date, content_type, impressions_count, likes_count, comments_count, shares_count, new_followers_count)
-- dim_creator(creator_id, creator_name, category)

-- Problem1 : For content published in May 2024, which creator IDs show the highest new follower growth within each content type? If a creator published multiple of the same content type, we want to look at the total new follower growth from that content type.

WITH new_followers_content_creator AS(
SELECT content_type,
       creator_id,
       SUM(new_followers_count) AS total_new_followers
FROM fct_creator_content
WHERE published_date >= '2024-05-01'
      AND published_date < '2024-06-01'
GROUP BY content_type, creator_id
),
ranked_content AS(
SELECT content_type,
       creator_id,
       total_new_followers,
       RANK() OVER(PARTITION BY content_type ORDER BY total_new_followers DESC) AS rnk
FROM new_followers_content_creator
)

SELECT content_type,
       creator_id,
       total_new_followers
FROM ranked_content
WHERE rnk = 1;

-- Problem2: Your Product Manager requests a report that shows impressions, likes, comments, and shares for each content type between April 8 and 21, 2024. She specifically requests that engagement metrics are unpivoted into a single 'metric type' column.

SELECT content_type,
       'impressions' AS metric_type,
        SUM(impressions_count) AS metric_values
FROM fct_creator_content
WHERE published_date >= '2024-04-08'
      AND published_date <= '2024-04-21'
GROUP BY content_type

UNION ALL

SELECT content_type,
       'likes',
        SUM(likes_count)
FROM fct_creator_content
WHERE published_date >= '2024-04-08'
      AND published_date <= '2024-04-21'
GROUP BY content_type

UNION ALL

SELECT content_type,
       'comments',
        SUM(comments_count)
FROM fct_creator_content
WHERE published_date >= '2024-04-08'
      AND published_date <= '2024-04-21'
GROUP BY content_type

UNION ALL

SELECT content_type,
       'shares',
        SUM(shares_count)
FROM fct_creator_content
WHERE published_date >= '2024-04-08'
      AND published_date <= '2024-04-21'
GROUP BY content_type;

-- problem3 : For content published between April and June 2024, can you calculate for each creator, what % of their new followers came from each content type?

WITH creator_followers AS (
    SELECT 
        c.creator_id,
        c.creator_name,
        cc.content_type,
        SUM(cc.new_followers_count) AS followers_per_type
    FROM fct_creator_content cc
    JOIN dim_creator c
        ON cc.creator_id = c.creator_id
    WHERE cc.published_date >= '2024-04-01'
      AND cc.published_date < '2024-07-01'
    GROUP BY c.creator_id, c.creator_name, cc.content_type
)

SELECT 
    creator_id,
    creator_name,
    content_type,
    followers_per_type,
    ROUND(
        followers_per_type * 100.0 / 
        SUM(followers_per_type) OVER (PARTITION BY creator_id),
    2) AS percentage_contribution
FROM creator_followers;