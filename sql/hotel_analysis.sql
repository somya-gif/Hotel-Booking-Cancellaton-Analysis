-- ================================================================
-- HOTEL BOOKING CANCELLATION ANALYSIS - SQL QUERIES
-- Dataset: 36,285 historical hotel reservations
-- Objective: Uncover cancellation drivers and protect hotel revenue
-- ================================================================

-- ----------------------------------------------------------------
-- 1. TABLE CREATION
-- Compatible with MySQL, PostgreSQL, SQL Server, and SQLite
-- ----------------------------------------------------------------
DROP TABLE IF EXISTS hotel_bookings;

CREATE TABLE hotel_bookings (
    Booking_ID               VARCHAR(20) PRIMARY KEY,
    number_of_adults         INT,
    number_of_children       INT,
    number_of_weekend_nights INT,
    number_of_week_nights    INT,
    type_of_meal             VARCHAR(50),
    car_parking_space        INT,
    room_type                VARCHAR(50),
    lead_time                INT,
    market_segment_type      VARCHAR(50),
    repeated                 INT,
    P_C                      INT,  -- Previous cancellations count
    P_not_C                  INT,  -- Previous confirmed (not cancelled) count
    average_price            DECIMAL(10, 2),
    special_requests         INT,
    date_of_reservation      VARCHAR(30),
    booking_status           VARCHAR(20) -- 'Not_Canceled' or 'Canceled'
);

-- Note: In MySQL Workbench, pgAdmin, or DBeaver:
-- Right-click table -> "Import Data" -> select data/booking.csv.


-- ----------------------------------------------------------------
-- 2. EXECUTIVE OVERVIEW & KEY KPIS
-- Answers: What is the overall cancellation rate and volume?
-- Matches Power BI Page 1: Executive Overview
-- ----------------------------------------------------------------
SELECT 
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancelled_bookings,
    SUM(CASE WHEN booking_status = 'Not_Canceled' THEN 1 ELSE 0 END) AS confirmed_bookings,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct,
    ROUND(AVG(average_price), 2) AS average_daily_rate_adr,
    ROUND(AVG(lead_time), 1) AS average_lead_time_days
FROM hotel_bookings;


-- ----------------------------------------------------------------
-- 3. FINANCIAL IMPACT & LOST REVENUE
-- Answers: How much revenue is lost to cancellations?
-- Calculation: (weekend_nights + week_nights) * average_price
-- ----------------------------------------------------------------
SELECT 
    -- Gross Portfolio Value across all bookings (€11.35 Million)
    ROUND(SUM((number_of_weekend_nights + number_of_week_nights) * average_price), 2) AS total_portfolio_value_eur,

    -- Revenue Lost to Cancellations (€4.30 Million / ~37.9%)
    ROUND(SUM(CASE 
        WHEN booking_status = 'Canceled' 
        THEN (number_of_weekend_nights + number_of_week_nights) * average_price 
        ELSE 0 
    END), 2) AS lost_revenue_eur,

    -- Realized Revenue from Guests who checked in (€7.05 Million)
    ROUND(SUM(CASE 
        WHEN booking_status = 'Not_Canceled' 
        THEN (number_of_weekend_nights + number_of_week_nights) * average_price 
        ELSE 0 
    END), 2) AS realized_revenue_eur
FROM hotel_bookings;


-- ----------------------------------------------------------------
-- 4. LEAD TIME ANALYSIS (THE #1 DRIVER OF CANCELLATIONS)
-- Answers: Does booking far in advance increase cancellation probability?
-- Matches Power BI Page 2: Cancellation Drivers
-- ----------------------------------------------------------------
SELECT 
    CASE 
        WHEN lead_time <= 7 THEN '0 to 7 days'
        WHEN lead_time <= 30 THEN '8 to 30 days'
        WHEN lead_time <= 90 THEN '31 to 90 days'
        WHEN lead_time <= 180 THEN '91 to 180 days'
        ELSE 'More than 180 days'
    END AS lead_time_tier,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct,
    ROUND(SUM(CASE 
        WHEN booking_status = 'Canceled' 
        THEN (number_of_weekend_nights + number_of_week_nights) * average_price 
        ELSE 0 
    END), 2) AS lost_revenue_eur
FROM hotel_bookings
GROUP BY 
    CASE 
        WHEN lead_time <= 7 THEN '0 to 7 days'
        WHEN lead_time <= 30 THEN '8 to 30 days'
        WHEN lead_time <= 90 THEN '31 to 90 days'
        WHEN lead_time <= 180 THEN '91 to 180 days'
        ELSE 'More than 180 days'
    END
ORDER BY cancellation_rate_pct ASC;


-- ----------------------------------------------------------------
-- 5. BOOKING CHANNELS & MARKET SEGMENTS
-- Answers: Which channels bring the most unreliable bookings?
-- Online OTAs (Booking.com, Expedia) vs Corporate
-- ----------------------------------------------------------------
SELECT 
    market_segment_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM hotel_bookings), 1) AS share_of_bookings_pct,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct,
    ROUND(AVG(average_price), 2) AS avg_price_per_night,
    ROUND(SUM(CASE 
        WHEN booking_status = 'Canceled' 
        THEN (number_of_weekend_nights + number_of_week_nights) * average_price 
        ELSE 0 
    END), 2) AS revenue_lost_eur
FROM hotel_bookings
GROUP BY market_segment_type
ORDER BY total_bookings DESC;


-- ----------------------------------------------------------------
-- 6. SPECIAL REQUESTS VS GUEST COMMITMENT
-- Answers: Does customizing stay preferences reduce cancellations?
-- ----------------------------------------------------------------
SELECT 
    special_requests AS number_of_special_requests,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY special_requests
ORDER BY special_requests ASC;


-- ----------------------------------------------------------------
-- 7. REPEAT GUEST LOYALTY IMPACT
-- Answers: Do repeat customers show higher commitment?
-- ----------------------------------------------------------------
SELECT 
    CASE WHEN repeated = 1 THEN 'Repeat Guest' ELSE 'First-Time Guest' END AS guest_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY repeated;


-- ----------------------------------------------------------------
-- 8. PARKING SPACE AS A COMMITMENT SIGNAL
-- Answers: Do guests requesting parking have lower cancellations?
-- ----------------------------------------------------------------
SELECT 
    CASE WHEN car_parking_space = 1 THEN 'Parking Requested' ELSE 'No Parking Requested' END AS parking_preference,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY car_parking_space;


-- ----------------------------------------------------------------
-- 9. ROOM TYPE POPULARITY & CANCELLATION RATE
-- Answers: Which room categories have the highest churn?
-- ----------------------------------------------------------------
SELECT 
    room_type,
    COUNT(*) AS total_bookings,
    ROUND(AVG(average_price), 2) AS avg_room_price,
    SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY room_type
ORDER BY total_bookings DESC;
