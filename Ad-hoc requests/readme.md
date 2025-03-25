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
SELECT 
    c.city_name,
    ROUND((SUM(CASE WHEN trip_count = '2-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "2-Trips",
    ROUND((SUM(CASE WHEN trip_count = '3-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "3-Trips",
    ROUND((SUM(CASE WHEN trip_count = '4-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "4-Trips",
    ROUND((SUM(CASE WHEN trip_count = '5-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "5-Trips",
    ROUND((SUM(CASE WHEN trip_count = '6-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "6-Trips",
    ROUND((SUM(CASE WHEN trip_count = '7-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "7-Trips",
    ROUND((SUM(CASE WHEN trip_count = '8-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "8-Trips",
    ROUND((SUM(CASE WHEN trip_count = '9-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "9-Trips",
    ROUND((SUM(CASE WHEN trip_count = '10-Trips' THEN repeat_passenger_count ELSE 0 END) * 100.0) 
          / NULLIF(SUM(repeat_passenger_count), 0), 2) AS "10-Trips"
FROM 
    dim_repeat_trip_distribution r
JOIN 
    dim_city c 
ON 
    r.city_id = c.city_id
GROUP BY 
    c.city_name
ORDER BY 
    c.city_name;

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
WITH city_total AS (
    SELECT 
        c.city_name,
        SUM(new_passengers) AS total_new_passengers
    FROM fact_passenger_summary ps
    JOIN dim_city c 
    ON ps.city_id = c.city_id
    GROUP BY city_name
),
city_rank AS (
    SELECT 
        city_name,
        total_new_passengers,
        DENSE_RANK() OVER (ORDER BY total_new_passengers DESC) AS rank_desc,
        DENSE_RANK() OVER (ORDER BY total_new_passengers ASC) AS rank_asc
    FROM city_total
),
city_categories AS (
    SELECT 
        city_name,
        total_new_passengers,
        CASE 
            WHEN rank_desc <= 3 THEN 'Top 3'
            WHEN rank_asc <= 3 THEN 'Bottom 3'
            ELSE NULL 
        END AS city_category
    FROM city_rank
)
SELECT 
    city_name,
    total_new_passengers,
    city_category
FROM city_categories
WHERE city_category IS NOT NULL
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
WITH 
revenue_monthly AS (
    SELECT 
        c.city_name,
        MONTHNAME(t.date) AS month,
        SUM(t.fare_amount) AS revenue
    FROM fact_trips t
    JOIN dim_city c 
    ON t.city_id = c.city_id
    GROUP BY c.city_name, month
),
revenue_ranking AS (
    SELECT 
        city_name,
        month AS highest_revenue_month,
        revenue,
        DENSE_RANK() OVER (PARTITION BY city_name ORDER BY revenue DESC) AS revenue_rank
    FROM revenue_monthly
),
revenue_total AS (
    SELECT 
        city_name,
        SUM(revenue) AS total_revenue
    FROM revenue_monthly
    GROUP BY city_name
)
SELECT 
    r.city_name,
    r.highest_revenue_month,
    r.revenue,
    ROUND((r.revenue / t.total_revenue) * 100, 2) AS percentage_contribution
FROM revenue_ranking r
JOIN revenue_total t 
ON r.city_name = t.city_name
WHERE r.revenue_rank = 1;

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
