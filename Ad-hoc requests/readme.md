 - **Business Request - 1: City—Level Fare and Trip Summary Report**

Generate a report that displays the total trips, average fare per km, average fare per trip, and the percentage contribution of each city’s
trips to the overall trips. This report will help in assessing trip volume, pricing efficiency, and each city’s contribution to the overall
trip count.

  Fields:

    city_name
    tota|_trips
    avg_fare_per_km
    avg_fare_per_trip
    pct_contribution_of_total_trips 


```sql
SELECT
     c.city_name,
     COUNT(trip_id) AS total_trips,
     ROUND((SUM(fare_amount)/SUM(distance_travelled)),2) AS avg_fare_per_km,
     ROUND( AVG(fare_amount),2) AS avg_fare_per_trip,
     ROUND((count(trip_id)/(select count(trip_id) FROM fact_trips)*100),2) AS pct_contribution_of_total_trips
FROM dim_city c
JOIN fact_trips t
ON c.trip_id = t.trip_id
GROUP BY c.city_name ;
```


- **Business Request - 2: Monthly City-Level Trips Target Performance Report**

Generate a report that evaluates the target performance for trips at the monthly and city level. For each city and month, compare the actual
total trips with the target trips and categorise the performance as follows:

  If actual trips are greater than target trips, mark it as "Above Target".
  If actual trips are less than or equal to target trips, mark it as "Below Target".

Additionally, calculate the % difference between actual and target trips to quantify the performance gap.

  Fields:

    City_name
    month_name
    actua|_trips
    target_trips
    performance_status
    %_difference  */


```sql
WITH target AS(
         SELECT MONTHNAME(month) AS month_name,
                 city_id,
                 total_target_trips AS target_trips
          FROM targets_db.monthly_target_trips
                ),
actuals AS (
            SELECT ciy_id,
                   MONTHNAME(month) AS month_name,
                  COUNT(trip_id) AS actual_trips
             FROM fact_trips
            GROUP BY city_id
)

SELECT c.city_name,
       a.month_name,
       a.actual_trips,
       t.target_trips,
      CASE WHEN actual_trips - target_trips > 0 THEN "Above Target" ELSE "Below Target" END AS "performance_status"
      ROUND(100*(a.actual_trips-target_trips)/target_trips,2) AS "pct_difference"
FROM actual a
JOIN target t
ON a.city_id = t.city_id
AND a.month_name = t.month_name
JOIN dim_city c
ON a.city_id = t.city_id
ORDER BY city_name, month_name ;        
```



 - **Business Request - 3: City-Level Repeat Passenger Trip Frequency Report*

Generate a report that shows the percentage distribution of repeat passengers by the number of trips they have taken in each city.
Calculate the percentage of repeat passengers who took 2 trips, 3 trips, and so on, up to 10 trips.

Each column should represent a trip count category, displaying the percentage of repeat passengers who fall into that category out of the
total repeat passengers for that city.

This report will help identify cities with high repeat trip frequency, which can indicate strong customer loyalty or frequent usage patterns.

  Fields: city_name, 2-Trips, 3-Trips, 4-Trips, 5-Trips, 6-Trips, 7-Trips, 8-Trips, 9-Trips, 10-Trips  */


```sql
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
    LEFT JOIN
        trips_db.dim_repeat_trip_distribution AS rtd ON dim_city.city_id = rtd.city_id
    GROUP BY
        dim_city.city_id
),

total_trips AS (
  SELECT
    trips.city_id AS city_id,
    (trips.two + trips.three + trips.four + trips.five + trips.six + trips.seven + trips.eight + trips.nine + trips.ten) AS total
  FROM
    trips
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
    JOIN
    trips ON dim_city.city_id = trips.city_id
    JOIN
    total_trips ON dim_city.city_id = total_trips.city_id
    
ORDER BY dim_city.city_name;
```


- **Business Request - 4: Identify Cities with Highest and Lowest Total New Passengers**

Generate a report that calculates the total new passengers for each city and ranks them based on this value. Identify the top 3 cities with
the highest number of new passengers as well as the bottom 3 cities with the lowest number of new passengers, categorising them as "Top 3"
or "Bottom 3" accordingly.

  Fields

    city_name
    total_new_passengers
    city_category ("Top 3" or "Bottom 3")  */


```sql
WITH rank_cte AS
  (SELECT
    dim_city.city_id,
    SUM(fps.new_passengers) AS new_passengers,
    RANK() OVER (ORDER BY SUM(fps.new_passengers) DESC) AS _rank

  FROM
    trips_db.dim_city
    LEFT JOIN
    trips_db.fact_passenger_summary AS fps ON dim_city.city_id = fps.city_id

  GROUP BY dim_city.city_id)

SELECT
  dim_city.city_name AS city_name,
    rank_cte.new_passengers AS total_new_passengers,
    CASE
    WHEN rank_cte._rank < 4 THEN "Top 3"
        WHEN rank_cte._rank > 7 THEN "Bottom 3"
        ELSE " "
  END AS city_category
           
FROM
  trips_db.dim_city
    JOIN
    rank_cte ON dim_city.city_id = rank_cte.city_id
ORDER BY total_new_passengers DESC;
```



- **Business Request - 5: Identify Month with Highest Revenue for Each City**

Generate a report that identifies the month with the highest revenue for each city. For each city, display the month_name, the revenue amount
for that month, and the percentage contribution of that month’s revenue to the city’s total revenue.

  Fields

    city_name
    highest_revenue_month
    revenue
    percentage_contribution (%)  */


```sql
WITH unique_month AS (
  SELECT DISTINCT 
    start_of_month,
    month_name
  FROM trips_db.dim_date
),

fare_month_city AS (
  SELECT
    city_id,
    DATE_FORMAT(date, "%y-%m-01") AS start_of_month,
    SUM(fare_amount) AS fare,
    RANK() OVER (PARTITION BY city_id ORDER BY SUM(fare_amount) DESC) AS _rank 

  FROM 
    trips_db.fact_trips
        
  GROUP BY city_id, start_of_month
),

fare_city AS (
  SELECT
    city_id,
        SUM(fare_amount) as city_fare
  FROM
    trips_db.fact_trips
    GROUP BY city_id
)

SELECT
  dim_city.city_name AS city_name,
  unique_month.month_name AS highest_revenue_month,
    fare_month_city.fare AS revenue,
    CASE
            WHEN COALESCE(fare_city.city_fare, 0) > 0 THEN 
                ROUND((COALESCE(fare_month_city.fare, 0) * 100 / COALESCE(fare_city.city_fare, 0)), 2)
            ELSE 
                NULL
        END AS percentage_contribution
    
FROM
  trips_db.dim_city
    LEFT JOIN
    fare_month_city ON dim_city.city_id = fare_month_city.city_id
    LEFT JOIN
    unique_month ON unique_month.start_of_month = fare_month_city.start_of_month
    JOIN
    fare_city ON fare_month_city.city_id = fare_city.city_id
    
WHERE
  fare_month_city._rank = 1
    
ORDER BY revenue DESC;
```



- ** Business Request - 6: Repeat Passenger Rate Analysis**

Generate a report that calculates two metrics:

  1. Monthly Repeat Passenger Rate: Calculate the repeat passenger rate for each city and month by com paring the number of repeat passengers
    to the total passengers.
  2. City-wide Repeat Passenger Rate: Calculate the overall repeat passenger rate for each city, considering all passengers across months.

These metrics will provide insights into monthly repeat trends as well as the overall repeat behaviour for each city.

  Fields:

    city_name
    month
    total_passengers
    repeat_passengers
    month|y_repeat_passenger_rate (%): Repeat passenger rate at the city and month level
    city_repeat_passenger_rate (%): Overall repeat passenger rate for each city, aggregated across months */


```sql
WITH date_cte AS (
    SELECT DISTINCT
        start_of_month,
        month_name
    FROM trips_db.dim_date
),

city_cte AS (
    SELECT
        dim_city.city_id AS city_id,
        CASE
            WHEN COALESCE(SUM(fact_passenger_summary.total_passengers), 0) > 0 THEN 
                ROUND((COALESCE(SUM(fact_passenger_summary.repeat_passengers), 0) * 100/ COALESCE(SUM(fact_passenger_summary.total_passengers), 0)), 2)
            ELSE 
                NULL
        END AS city_RPR
    FROM
        trips_db.dim_city
        LEFT JOIN
        trips_db.fact_passenger_summary ON dim_city.city_id = fact_passenger_summary.city_id
    GROUP BY city_id
),

detailed_data AS (
    SELECT
        dim_city.city_name AS city_name,
        date_cte.month_name AS month,
        fact_passenger_summary.total_passengers AS total_passengers,
        fact_passenger_summary.repeat_passengers AS repeat_passengers,
        CASE
            WHEN COALESCE(fact_passenger_summary.total_passengers, 0) > 0 THEN 
                ROUND((COALESCE(fact_passenger_summary.repeat_passengers, 0) * 100/ COALESCE(fact_passenger_summary.total_passengers, 0)), 2)
            ELSE 
                NULL
        END AS monthly_repeat_passenger_rate,
        0 AS city_repeat_passenger_rate,
    date_cte.start_of_month AS start_of_month
    FROM
        trips_db.dim_city
        LEFT JOIN
        trips_db.fact_passenger_summary ON dim_city.city_id = fact_passenger_summary.city_id
        LEFT JOIN
        date_cte ON date_cte.start_of_month = fact_passenger_summary.month
  GROUP BY dim_city.city_name, date_cte.month_name, fact_passenger_summary.city_id, fact_passenger_summary.month
    
),

summary_data AS (
    SELECT
        dim_city.city_name AS city_name,
        'Total' AS month,
        SUM(fact_passenger_summary.total_passengers) AS total_passengers,
        SUM(fact_passenger_summary.repeat_passengers) AS repeat_passengers,
        0 AS monthly_repeat_passenger_rate,
        city_cte.city_RPR AS city_repeat_passenger_rate,
    MIN(date_cte.start_of_month) AS start_of_month
    FROM
        trips_db.dim_city
        LEFT JOIN
        trips_db.fact_passenger_summary ON dim_city.city_id = fact_passenger_summary.city_id
        JOIN
        city_cte ON dim_city.city_id = city_cte.city_id
        LEFT JOIN
        date_cte ON date_cte.start_of_month = fact_passenger_summary.month
        
  GROUP BY dim_city.city_name, city_cte.city_id
    
)

SELECT *
FROM (
    SELECT
    city_name,
    month,
    total_passengers,
    repeat_passengers,
    monthly_repeat_passenger_rate,
    city_repeat_passenger_rate
    FROM
    detailed_data
    UNION ALL
    SELECT
    city_name,
        month,
        total_passengers,
        repeat_passengers,
        monthly_repeat_passenger_rate,
        city_repeat_passenger_rate
  FROM
    summary_data
    ) AS combined_data
ORDER BY
    city_name,
    CASE
    WHEN month = 'Total' THEN 1 ELSE 0 END
;
```
