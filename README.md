# 🚖 GoodCabs: Transportation Performance Analysis


## Company Overview

GoodCabs, an imaginary company established two years ago, has quickly become a leading cab service provider in India's tier-II cities. Unlike traditional competitors, GoodCabs is driven by a mission to empower local drivers, helping them build sustainable livelihoods within their communities while providing passengers with exceptional service. Operating across 10 tier-II cities, GoodCabs combines a community-focused approach with a commitment to delivering a seamless travel experience. It aims to solidify its position as a trusted mobility partner in underserved markets.

## 🔎 Problem Statement

Goodcabs has been operating in tier-II cities for two years, but it is still far from reaching its market penetration goals. Despite establishing a solid presence in these areas, the company is struggling to meet its ambitious 2024 targets.  
To overcome this challenge, Goodcabs needs an in-depth analysis of key performance metrics. This analysis will help identify critical growth opportunities and resolve operational inefficiencies that are hindering progress.

## 🎯 Project Objective

The objective of this project is to conduct a comprehensive analysis of Goodcabs' performance across key metrics—such as trip volume, passenger satisfaction, retention rates, trip distribution, and the balance between new and repeat passengers. By evaluating these metrics, the project aims to identify critical growth opportunities, address operational inefficiencies, and provide actionable insights to help Goodcabs achieve its market penetration goals and meet its ambitious targets for 2024.  
The insights from this analysis will support strategic decision-making and drive the company’s growth in tier-2 cities.

## 🛢 Data Overview

Received two SQL databases and eight CSV files for analysis. However, I primarily worked with the SQL databases, using the CSV files for cross-verification purposes.

The two databases are as follows:

1. trips_db: Contains fact tables (fact_trips, fact_passenger_summary) and dimension tables (dim_date, dim_city, dim_repeat_trip_distribution).
2. targets_db: Contains city- and month-specific target tables (monthly_target_trips, monthly_target_new_passengers, city_target_passenger_rating).

The dataset spans from January 1, 2024, to June 30, 2024.

It is fully accessible on the Codebasics website and can be viewed via the following link:  
https://codebasics.io/challenge/codebasics-resume-project-challenge

## 🛠️ Tools

- Data Visualization: Power BI
- Data Analysis: MySQL, DAX

## 🧹️ Data Cleaning & Transformation:

- Used Power Query to clean and transform raw data.  
- Removed duplicates and unnecessary columns.  
- Applied the TRIM function to eliminate leading and trailing spaces.  
- Added conditional columns where necessary.  
- Created a dim_month table with unique months and their start dates.  
- Generated two additional tables in Power BI for filtering purposes:  
  - passenger_type: Contains a single column for passenger type (new/repeated).  
  - Set BM: Includes two columns—Benchmarks (vs Previous month/vs Target) and IDs.


## 📑 Report Inclusions

- [Ad-hoc Business Requests](https://github.com/Joyeta16/Goodcabs-Performance-Overview/blob/main/Ad-hoc%20Business_requests.sql)
- [Goodcabs Detailed Analysis Presentation](https://github.com/Joyeta16/Goodcabs-Performance-Overview/blob/main/RPC13%20GoodCabs_ppt.pptx)

### Power BI Report and Data Model Overview  

This repository showcases a Power BI report hosted on the Power BI Service, along with its underlying data model. Below is a screenshot of the data model and a PDF of the report for a quick preview:  

- [Data Model](https://github.com/Joyeta16/Goodcabs-Performance-Overview/blob/main/Data_Modeling.png)
- [Goodcabs Dashboard](https://github.com/Joyeta16/Goodcabs-Performance-Overview/blob/main/Goodcabs%20Dashboard.pdf)

For the full interactive experience, please contact me to request access to the report on Power BI Service.

## 💡 Insights

#### Top Cities by Revenue Contribution:

- Jaipur (₹37.21M), Kochi (₹17.00M), and Chandigarh (₹11.06M) are the top 3 cities by revenue contribution.

#### Bottom Cities by Revenue Contribution:

- Mysore (₹4.05M), Vadodara (₹3.80M), and Coimbatore (₹3.52M) are the bottom 3 cities by revenue contribution.

#### Monthly Revenue Contribution:

- February (18.36%) contributes the most to revenue.
- June (14.19%) contributes the least to revenue.

#### Top Cities by Trip Volume:

- Jaipur (18.05%), Lucknow (15.10%), and Surat (12.88%) are the top 3 cities by trip volume.

#### Bottom Cities by Trip Volume:

- Visakhapatnam (6.66%), Coimbatore (4.96%), and Mysore (3.81%) are the bottom 3 cities by trip volume.

#### Fare and Trip Distance Insights:

- Jaipur reports the highest average fare per trip (₹483.92) and the highest average trip distance (30.02 km).
- Surat reports the lowest average fare per trip (₹117.27) and the lowest average trip distance (11 km).

#### Average Passenger Ratings:

- Tourist cities such as Mysore (8.70), Jaipur (8.58), and Kochi (8.52) have the highest average passenger ratings.
- Business-focused cities such as Vadodara (6.60), Lucknow (6.40), and Surat (6.40) have the lowest average passenger ratings.

#### Trip Demand Patterns:

- Tourist cities like Jaipur, Kochi, and Mysore show high weekend trip demand.
- Business-focused cities like Lucknow, Surat, and Vadodara show high weekday trip demand.

#### Repeat Passenger Rate (RPR):

- Surat (42.63%) and Lucknow (37.12%) have the highest Repeat Passenger Rates.
- Mysore (11.23%) and Jaipur (17.43%) have the lowest Repeat Passenger Rates.

## 📝 Recommendations

#### Enhance Passenger Experience:
- Improve safety, comfort, and professionalism to boost ratings in business cities.

#### City-Specific Strategic Partnerships:

- For tourist hubs, partner with hotels, resorts, local tour operators, and online travel agencies to provide a seamless travel experience and attract more passengers.
- For business hubs, collaborate with tech parks, malls, shopping centers, and conference venues to cater to professionals and business travelers.
- Establish partnerships at transit hubs to boost visibility and drive demand.

#### Targeted City-Specific Marketing:

- Align marketing strategies with key local events in tourism and business cities to increase trip volumes.
- Leverage social media and location-based advertising to target specific audiences effectively.

#### Innovative Ride Options:

- Introduce carpooling and shared ride options to cater to cost-conscious passengers and reduce environmental impact.
- Transition to electric or hybrid vehicles to cut operational costs and enhance brand reputation.

#### Market Trend Analysis:

- Track market trends and event-based demand to anticipate surges and avoid shortages during peak times.
- Use this data to optimize resource allocation, ensuring a balanced supply-demand ratio.

#### Data Collection:

- Collect additional data, including customer profiling, driver and vehicle performance metrics, wait time and pickup time, competitor pricing and offers, and event and tourism data, to support more accurate and enhanced analysis.

## 🧠 Skills Gained

- Enhanced understanding of business metrics and their impact on performance.
- Created insightful, user-centric Power BI dashboards.
- Learned the art of storytelling with data.
- Gained knowledge in the transportation and mobility domain, focusing on Mobility as a Service (MaaS) and operational functions.
---
