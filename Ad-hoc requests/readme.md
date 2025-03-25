/* Business Request - 1: City-Level Fare and Trip Summary Report */

SELECT
    dim_city.city_name,
    COUNT(fact_trips.trip_id) AS total_trips,
    CASE
        WHEN COALESCE(SUM(fact_trips.distance_travelled_km), 0) > 0 THEN 
            ROUND(COALESCE(SUM(fact_trips.fare_amount),0) / COALESCE(SUM(fact_trips.distance_travelled_km), 0), 2)
        ELSE NULL
    END AS avg_fare_per_km,
    CASE
        WHEN COALESCE(COUNT(fact_trips.trip_id), 0) > 0 THEN 
            ROUND(COALESCE(SUM(fact_trips.fare_amount),0) / COALESCE(COUNT(fact_trips.trip_id), 0),2)
        ELSE NULL
    END AS avg_fare_per_trip,
    CASE
        WHEN COALESCE((SELECT COUNT(fact_trips.trip_id) FROM trips_db.fact_trips), 0) > 0 THEN 
            ROUND(COALESCE(COUNT(fact_trips.trip_id), 0) * 100 / COALESCE((SELECT COUNT(fact_trips.trip_id) FROM trips_db.fact_trips), 0), 2)
        ELSE NULL
    END AS percentage_contribution_to_total_trips
FROM
    trips_db.fact_trips
LEFT JOIN 
    trips_db.dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY
    dim_city.city_name
ORDER BY
    total_trips DESC;


/* Business Request - 2: Monthly City-Level Trips Target Performance Report */

WITH trips_actual AS (
    SELECT
        city_id,
        DATE_FORMAT(date, '%Y-%m-01') AS start_of_month,
        COUNT(trip_id) AS actual_trips
    FROM trips_db.fact_trips
    GROUP BY city_id, start_of_month
),
dim_date_monthly AS (
    SELECT
        start_of_month,
        month_name
    FROM trips_db.dim_date
    GROUP BY start_of_month, month_name
)
SELECT
    dim_city.city_name,
    dim_date_monthly.month_name,
    COALESCE(trips_actual.actual_trips, 0) AS actual_trips,
    COALESCE(trip_targets.total_target_trips, 0) AS target_trips,
    CASE
        WHEN COALESCE(trips_actual.actual_trips, 0) > COALESCE(trip_targets.total_target_trips, 0) THEN "Above Target"
        ELSE "Below Target" 
    END AS performance_status,
    CASE
        WHEN COALESCE(trip_targets.total_target_trips, 0) > 0 THEN 
           ROUND((COALESCE(trips_actual.actual_trips,0) - COALESCE(trip_targets.total_target_trips,0))* 100 / COALESCE(trip_targets.total_target_trips, 0), 2)
        ELSE NULL
    END AS percentage_difference
FROM
    dim_date_monthly
LEFT JOIN trips_actual ON dim_date_monthly.start_of_month = trips_actual.start_of_month
LEFT JOIN trips_db.dim_city ON dim_city.city_id = trips_actual.city_id
LEFT JOIN targets_db.monthly_target_trips AS trip_targets ON trips_actual.start_of_month = trip_targets.month
    AND trips_actual.city_id = trip_targets.city_id
ORDER BY
    dim_city.city_name, dim_date_monthly.start_of_month;


/* Business Request - 3: City-Level Repeat Passenger Trip Frequency Report */

WITH trips AS (
    SELECT
        dim_city.city_id AS city_id,
        SUM(CASE WHEN rtd.trip_count = "2-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS two,
        SUM(CASE WHEN rtd.trip_count = "3-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS three,
        SUM(CASE WHEN rtd.trip_count = "4-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS four,
        SUM(CASE WHEN rtd.trip_count = "5-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS five,
        SUM(CASE WHEN rtd.trip_count = "6-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS six,
        SUM(CASE WHEN rtd.trip_count = "7-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS seven,
        SUM(CASE WHEN rtd.trip_count = "8-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS eight,
        SUM(CASE WHEN rtd.trip_count = "9-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS nine,
        SUM(CASE WHEN rtd.trip_count = "10-Trips" THEN rtd.repeat_passenger_count ELSE 0 END) AS ten
    FROM
        trips_db.dim_city
    LEFT JOIN trips_db.dim_repeat_trip_distribution AS rtd ON dim_city.city_id = rtd.city_id
    GROUP BY dim_city.city_id
),
total_trips AS (
    SELECT
        trips.city_id AS city_id,
        (trips.two + trips.three + trips.four + trips.five + trips.six + trips.seven + trips.eight + trips.nine + trips.ten) AS total
    FROM trips
)
SELECT
    dim_city.city_name,
    ROUND((COALESCE(trips.two, 0) * 100 /total_trips.total), 2) AS "2-Trips",
    ROUND((COALESCE(trips.three, 0) * 100 /total_trips.total), 2) AS "3-Trips",
    ROUND((COALESCE(trips.four, 0) * 100 /total_trips.total), 2) AS "4-Trips",
    ROUND((COALESCE(trips.five, 0) * 100 /total_trips.total), 2) AS "5-Trips",
    ROUND((COALESCE(trips.six, 0) * 100 /total_trips.total), 2) AS "6-Trips",
    ROUND((COALESCE(trips.seven, 0) * 100 /total_trips.total), 2) AS "7-Trips",
    ROUND((COALESCE(trips.eight, 0) * 100 /total_trips.total), 2) AS "8-Trips",
    ROUND((COALESCE(trips.nine, 0) * 100 /total_trips.total), 2) AS "9-Trips",
    ROUND((COALESCE(trips.ten, 0) * 100 /total_trips.total), 2) AS "10-Trips"
FROM 
    trips_db.dim_city
JOIN trips ON dim_city.city_id = trips.city_id
JOIN total_trips ON dim_city.city_id = total_trips.city_id
ORDER BY dim_city.city_name;

