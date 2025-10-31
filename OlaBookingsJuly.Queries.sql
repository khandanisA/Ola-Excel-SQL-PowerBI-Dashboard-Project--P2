
-- 1️⃣ Creating Database
CREATE DATABASE Ola;

-- 2️⃣ Creating Table
CREATE TABLE bookings_july(
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    booking_id VARCHAR(15) NOT NULL PRIMARY KEY,
    booking_status VARCHAR(20) NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    vehicle_type VARCHAR(15) NOT NULL,
    pickup_location VARCHAR(20) NOT NULL,
    drop_location VARCHAR(20) NOT NULL,
    v_tat INT,
    c_tat INT,
    canceled_rides_by_customer VARCHAR(50),
    canceled_rides_by_driver VARCHAR(40),
    incomplete_rides VARCHAR(5),
    incomplete_rides_reason VARCHAR(20),
    booking_value INT NOT NULL,
    payment_method VARCHAR(15),
    ride_distance INT NOT NULL,
    driver_ratings NUMERIC(2,1),
    customer_rating NUMERIC(2,1)
);

-- 3️⃣ Importing Data
COPY bookings_july(
    booking_date, booking_time, booking_id, booking_status, customer_id, vehicle_type,
    pickup_location, drop_location, v_tat, c_tat, canceled_rides_by_customer,
    canceled_rides_by_driver, incomplete_rides, incomplete_rides_reason, booking_value,
    payment_method, ride_distance, driver_ratings, customer_rating
)
FROM 'C:\\Users\\MD DANISH KHAN\\OneDrive\\Desktop\\bookings_july.csv'
DELIMITER ','
CSV HEADER;

-------------------------------------------
-- ANALYTICAL QUERIES
-------------------------------------------

-- 1. Retrieve all successful bookings
CREATE VIEW successful_bookings AS
SELECT * FROM bookings_july
WHERE booking_status = 'Success';
SELECT * FROM successful_bookings;

-- 2. Average ride distance per vehicle type
CREATE VIEW average_ride_distance_for_each_vehicle_type AS
SELECT vehicle_type,
       ROUND(AVG(ride_distance),2) AS average_distance
FROM bookings_july
GROUP BY vehicle_type
ORDER BY average_distance DESC;
SELECT * FROM average_ride_distance_for_each_vehicle_type;

-- 3. Total number of rides cancelled by customers
CREATE VIEW total_numbers_of_rides_cancelled_by_customers AS
SELECT COUNT(*) AS total_cancelled_by_customer
FROM bookings_july
WHERE booking_status = 'Canceled by Customer';
SELECT * FROM total_numbers_of_rides_cancelled_by_customers;

-- 4. Top 5 customers with highest number of successful rides
CREATE VIEW top_5_customers AS
SELECT customer_id,
       COUNT(*) AS total_rides
FROM bookings_july
WHERE booking_status = 'Success'
GROUP BY customer_id
ORDER BY total_rides DESC
LIMIT 5;
SELECT * FROM top_5_customers;

-- 5. Cancelled rides by drivers due to personal/car-related issues
CREATE VIEW total_cancelled_rides_personal_car_related_issues AS
SELECT COUNT(*) AS total_cancelled_rides
FROM bookings_july
WHERE booking_status = 'Canceled by Driver'
  AND canceled_rides_by_driver = 'Personal & Car related issue';
SELECT * FROM total_cancelled_rides_personal_car_related_issues;

-- 6. Maximum and minimum driver ratings for Prime Sedan bookings
CREATE VIEW driver_maximum_minimum_rating AS
SELECT MAX(driver_ratings) AS maximum_rating,
       MIN(driver_ratings) AS minimum_rating
FROM bookings_july
WHERE vehicle_type = 'Prime Sedan';
SELECT * FROM driver_maximum_minimum_rating;

-- 7. All rides where payment was made using UPI
CREATE VIEW rides_payment_with_upi AS
SELECT * FROM bookings_july
WHERE payment_method = 'UPI';
SELECT * FROM rides_payment_with_upi;

-- 8. Average customer rating per vehicle type
CREATE VIEW average_rating_per_vehicle_type AS
SELECT vehicle_type,
       ROUND(AVG(customer_rating),2) AS average_rating
FROM bookings_july
GROUP BY vehicle_type
ORDER BY average_rating DESC;
SELECT * FROM average_rating_per_vehicle_type;

-- 9. Total booking value of successful rides
CREATE VIEW total_booking_value_of_successful_rides AS
SELECT SUM(booking_value) AS total_amount
FROM bookings_july
WHERE booking_status = 'Success';
SELECT * FROM total_booking_value_of_successful_rides;

-- 10. Incomplete rides along with reason
CREATE VIEW incomplete_rides_with_reason AS
SELECT booking_id,
       incomplete_rides_reason
FROM bookings_july
WHERE incomplete_rides = 'Yes'
ORDER BY booking_status;
SELECT * FROM incomplete_rides_with_reason;

-- 11. Average booking value per payment method
SELECT payment_method, 
       ROUND(AVG(booking_value),2) AS avg_booking_value
FROM bookings_july
GROUP BY payment_method
ORDER BY avg_booking_value DESC;

-- 12. Vehicle type with highest cancellation rate
SELECT vehicle_type,
       ROUND(100.0 * SUM(CASE WHEN booking_status LIKE 'Canceled%' THEN 1 ELSE 0 END) / COUNT(*),2) AS cancellation_rate
FROM bookings_july
GROUP BY vehicle_type
ORDER BY cancellation_rate DESC;

-- 13. Average booking value per vehicle type
CREATE VIEW average_booking_value_per_vehicle_type AS
SELECT vehicle_type,
       ROUND(AVG(booking_value),2) AS avg_booking_value
FROM bookings_july
GROUP BY vehicle_type
ORDER BY avg_booking_value DESC;
SELECT * FROM average_booking_value_per_vehicle_type;

-- 14. Top 3 pickup locations with most bookings
CREATE VIEW top_3_pickup_locations AS
SELECT pickup_location,
       COUNT(*) AS total_bookings
FROM bookings_july
GROUP BY pickup_location
ORDER BY total_bookings DESC
LIMIT 3;
SELECT * FROM top_3_pickup_locations;

-- 15. Average driver vs customer rating
CREATE VIEW avg_driver_vs_customer_rating AS
SELECT ROUND(AVG(driver_ratings),2) AS avg_driver_rating,
       ROUND(AVG(customer_rating),2) AS avg_customer_rating
FROM bookings_july;
SELECT * FROM avg_driver_vs_customer_rating;

-- 16. Total rides by payment method
CREATE VIEW rides_by_payment_method AS
SELECT payment_method,
       COUNT(*) AS total_rides
FROM bookings_july
GROUP BY payment_method
ORDER BY total_rides DESC;
SELECT * FROM rides_by_payment_method;

-- 17. Ride cancellation rate (Customer vs Driver)
CREATE VIEW ride_cancellation_rate AS
SELECT
  SUM(CASE WHEN booking_status='Canceled by Customer' THEN 1 ELSE 0 END)*100.0/COUNT(*) AS customer_cancel_rate,
  SUM(CASE WHEN booking_status='Canceled by Driver' THEN 1 ELSE 0 END)*100.0/COUNT(*) AS driver_cancel_rate
FROM bookings_july;
SELECT * FROM ride_cancellation_rate;

-- 18. Total revenue and average booking value per customer
CREATE VIEW customer_revenue_summary AS
SELECT customer_id,
       SUM(booking_value) AS total_revenue,
       ROUND(AVG(booking_value),2) AS avg_value_per_ride
FROM bookings_july
WHERE booking_status='Success'
GROUP BY customer_id
ORDER BY total_revenue DESC;
SELECT * FROM customer_revenue_summary;

-- 19. Ride distribution by time of day
CREATE VIEW ride_distribution_by_time AS
SELECT
  CASE
    WHEN EXTRACT(HOUR FROM booking_time) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM booking_time) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM booking_time) BETWEEN 17 AND 21 THEN 'Evening'
    ELSE 'Night'
  END AS time_slot,
  COUNT(*) AS total_rides
FROM bookings_july
GROUP BY time_slot
ORDER BY total_rides DESC;
SELECT * FROM ride_distribution_by_time;

-------------------------------------------END----------------------------------------------------------