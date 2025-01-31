#BUSINESS REQUEST-2
# MONTHLY CITY-LEVEL TRIPS TARGET PERFORMANCE REPORT
# Generate a report that evaluates the target performance for trips at monthly and city level. For each city and month, 
#   compare actual trips with target trips and categorize the performance.


WITH monthly_actual_trips AS (
    SELECT 
        COUNT(DISTINCT trip_id) AS Actual_trips,
        DATE_FORMAT(date, '%Y-%m-01') AS month,
        city_id
    FROM trips_db.fact_trips
    GROUP BY DATE_FORMAT(date, '%Y-%m-01'), city_id
),
final_trips AS (
    SELECT 
        a.city_id,
        a.month,
        a.Actual_trips,
        t.total_target_trips
    FROM monthly_actual_trips a
    INNER JOIN targets_db.monthly_target_trips t 
    ON a.city_id = t.city_id AND a.month = t.month
),
total AS (SELECT 
    c.city_name AS `City_name`,
    d.month_name AS `Month_name`,
    f.Actual_trips AS `Actual_trips`,
    f.total_target_trips AS `Target_trips`,
    CASE 
        WHEN f.Actual_trips > f.total_target_trips THEN 'Above Target'
        ELSE 'Below Target'
    END AS `Performance_Status`,
    ROUND(((f.Actual_trips - f.total_target_trips) / f.total_target_trips) * 100, 2) AS `%_Difference`
FROM 
    final_trips f
INNER JOIN trips_db.dim_date d
    ON f.month = d.start_of_month
INNER JOIN trips_db.dim_city c
    ON f.city_id = c.city_id)
    
SELECT distinct * FROM total
