-- What patterns can be observed in corporate travel expenses on Airbnb for Work? Using SQL, analyze booking data to identify average booking costs, company-specific spending behaviors, and the impact of booking timing on overall costs. Based on this analysis, what insights can be drawn to uncover potential cost-saving opportunities and optimize corporate travel expenses?

-- Problem1 : What is the average booking cost for corporate travelers? For this question, let's look only at trips which were booked in January 2024
-- oraganizations are spent avg $710.25 for each travellers in january 2024. 

SELECT AVG(booking_cost) AS avg_booking_cost
FROM fct_corporate_bookings
WHERE booking_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Problem2 : Identify the top 5 companies with the highest average booking cost per employee for trips taken during the first quarter of 2024. Note that if an employee takes multiple trips, each booking will show up as a separate row in fct_corporate_bookings.
-- synergy Inc spending highest avg amount($1250) for their employees.
SELECT company_name,
       SUM(booking_cost)/COUNT(DISTINCT employee_id) AS avg_booking_cost
FROM fct_corporate_bookings AS cb
JOIN dim_companies AS c
      ON cb.company_id = c.company_id
WHERE travel_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY company_name
ORDER BY avg_booking_cost DESC
LIMIT 5;


-- Problem3: For bookings made in February 2024, what percentage of bookings were made more than 30 days in advance? Use this to recommend strategies for reducing booking costs.
-- 60% precentage booking were happened before 30 days those organizations are reducing cost for the trip.

WITH travel_date_difference_booking AS(
SELECT booking_id,
       JULIANDAY(travel_date) - JULIANDAY(booking_date) AS booking_date_difference
FROM fct_corporate_bookings
WHERE booking_date BETWEEN '2024-02-01' AND '2024-02-29'
)

SELECT SUM(CASE WHEN booking_date_difference > 30 THEN 1 ELSE 0 END)*100/COUNT(*) AS pre_30day_booking_percentage 
FROM travel_date_difference_booking;