# BUSINESS REQUEST -6
# Generate a report that calculates two metrics:
# MONTHLY REPEAR PASSENGER RATE: calculate the repeat passenger rate for each city and month by commparing the numbers of repeat passenger to the total passenger
# CITY-WISE REPEAT PASSENGER RATE : calculate overall repeat passenger rate frequency for each city, considering all passengers across months


EXPLAIN ANALYZE
WITH city_passenger_stats AS (
    SELECT 
        city_id,
        DATE_FORMAT(month, "%M") AS month_name,
        SUM(total_passengers) AS total_passengers,
        SUM(repeat_passengers) AS repeat_passengers,
        CONCAT(ROUND((SUM(repeat_passengers) * 100) / SUM(total_passengers), 2), "%") AS monthly_repeat_passengers_rate,
        SUM(SUM(repeat_passengers)) OVER (PARTITION BY city_id) AS total_city_repeat_passengers,
        SUM(SUM(total_passengers)) OVER (PARTITION BY city_id) AS total_city_passengers
    FROM 
        trips_db.fact_passenger_summary
    GROUP BY 
        DATE_FORMAT(month, "%M"), city_id
)

SELECT 
    d.city_name AS "City",
    month_name AS "Month",
    total_passengers AS "Total Passengers",
    repeat_passengers AS "Repeat Passengers",
    monthly_repeat_passengers_rate AS "Monthly RPR%",
    CONCAT(ROUND((total_city_repeat_passengers * 100) / total_city_passengers, 2), "%") AS "City RPR%"
FROM 
    city_passenger_stats c
INNER JOIN 
trips_db.dim_city d
ON c.city_id = d.city_id;
