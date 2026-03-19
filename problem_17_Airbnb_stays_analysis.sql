-- How do listing amenities and pricing strategies impact supplemental income for Airbnb hosts? Using SQL, analyze the influence of features such as pools or ocean views, along with the effect of cleaning fees on overall pricing. Based on this analysis, what insights can be drawn to build a pricing recommendation framework that helps optimize potential nightly earnings for hosts?

-- Problem1 : What is the overall average nightly price for listings with either a 'pool' or 'ocean view' in July 2024? Consider only listings that have been booked at least once during this period.
-- amenitis like pool and ocean view attracting more cutomers so we can invest more these amenities

WITH eligible_listing_ids AS(
SELECT DISTINCT l.listing_id
FROM fct_bookings AS b
JOIN dim_listings AS l
     ON b.listing_id = l.listing_id
WHERE b.booking_date BETWEEN '2024-07-01' AND '2024-07-31' AND (l.amenities LIKE '%pool%' OR l.amenities LIKE '%ocean view%')
)
SELECT AVG(nightly_price) AS avg_nightly_price
FROM fct_bookings AS b
JOIN eligible_listing_ids AS el
     ON b.listing_id = el.listing_id
WHERE b.booking_date BETWEEN '2024-07-01' AND '2024-07-31';



-- Problem2: For listings with no cleaning fee (ie. NULL values in the 'cleaning_fee' column), what is the average difference in nightly price compared to listings with a cleaning fee in July 2024?

-- this metric (1.0102) shows listings without cleaning fee have a highest nightly price. 

SELECT ROUND(AVG(CASE WHEN cleaning_fee IS NULL THEN nightly_price END) - 
             AVG(CASE WHEN cleaning_fee IS NOT NULL THEN nightly_price END)
            ,4) AS nightly_price_difference_cleaning_fee
FROM fct_bookings
WHERE booking_date BETWEEN '2024-07-01' AND '2024-07-31';



-- Based on the top 50% of listings by earnings in July 2024, what percentage of these listings have ‘ocean view’ as an amenity? For this analysis, look at bookings that were made in July 2024.

-- 50% percentage high revenue form 'ocean view amenities' we can promote and suggest more that to customers to maximize the revenue also we can invest more 'ocean view'.

WITH listing_earnings AS(
SELECT l.listing_id,
       SUM((nightly_price + cleaning_fee)*booked_nights) AS Total_revenue
FROM fct_bookings AS b
JOIN dim_listings AS l
     ON b.listing_id = l.listing_id
WHERE booking_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY l.listing_id
),
ranked_listings AS(
SELECT listing_id,
       Total_revenue,
       NTILE(2) OVER(ORDER BY total_revenue DESC) AS half_rank
FROM listing_earnings
),
top_half AS(
SELECT listing_id
FROM ranked_listings
WHERE half_rank = 1
)

SELECT SUM(CASE WHEN l.amenities LIKE '%ocean view%' THEN 1 ELSE 0 END)*100/COUNT(*) AS litstin_ocean_view_percentage   
FROM top_half AS th
JOIN dim_listings AS l
      ON th.listing_id = l.listing_id;
