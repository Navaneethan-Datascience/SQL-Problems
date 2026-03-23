-- What are the payout success rates across different seller segments in Stripe Connect’s marketplace ecosystem? Using SQL, analyze payout data to identify segments with lower performance and potential friction points. Based on this analysis, what insights can be drawn to guide interventions that enhance payout success and improve reliability across seller groups?
-- Table Schema : 
-- fct_payouts(payout_id, seller_id, payout_status, payout_date)
-- dim_sellers(seller_id, seller_segment)


-- Problem1: What are the payout success rates across different seller segments in Stripe Connect’s marketplace ecosystem? Using SQL, analyze payout data to identify segments with lower performance and potential friction points. Based on this analysis, what insights can be drawn to guide interventions that enhance payout success and improve reliability across seller groups?

SELECT s.seller_segment,
       COUNT(*) AS total_no_of_payouts
FROM fct_payouts AS p
JOIN dim_sellers AS s
     ON p.seller_id = s.seller_id
WHERE payout_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY s.seller_segment;



-- Problem2 : Identify the seller segment with the highest payout success rate in July 2024 by comparing successful and failed payouts.

WITH payout_summary_segment AS(
SELECT s.seller_segment,
       SUM(CASE WHEN payout_status = 'successful' THEN 1 ELSE 0 END) AS successful_payouts,
       SUM(CASE WHEN payout_status = 'failed' THEN 1 ELSE 0 END) AS failed_payouts,
       COUNT(*) AS total_payouts
FROM fct_payouts AS p
JOIN dim_sellers AS s
     ON p.seller_id = s.seller_id
WHERE p.payout_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY s.seller_segment
)

SELECT seller_segment,
       successful_payouts,
       failed_payouts,
       total_payouts,
       successful_payouts*100/total_payouts AS successful_payout_rate 
FROM payout_summary_segment
ORDER BY successful_payout_rate DESC
LIMIT 1;


-- What percentage of payouts were successful versus failed for each seller segment in July 2024, and how can this be used to recommend targeted improvements?

-- these percentages explains which seller segment need more devolopemend based on failedo output rate ans which segment should maintain the retention sucess rate.

SELECT seller_segment,
       SUM(CASE WHEN payout_status = 'successful' THEN 1 ELSE 0 END)*100/COUNT(*) AS sucessfull_payout_rate,
       SUM(CASE WHEN payout_status = 'failed' THEN 1 ELSE 0 END)*100/COUNT(*) AS failed_payout_rate
FROM fct_payouts AS p
JOIN dim_sellers AS s
     ON p.seller_id = s.seller_id
WHERE payout_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY seller_segment;


-- Findings : In payout anlysis july 2024 'Gold' segment has the highest sucessful payout rate which is 83%. while the 'silver' segment has the highest both successful(57%) and failed(42%) payout rate is this because payment method errors or account verfication delays and which is the area we have to focus on our efforts.