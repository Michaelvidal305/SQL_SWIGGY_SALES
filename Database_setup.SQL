--        Swiggy Sale Analysis SQL - Postgres Database Setup
CREATE TABLE swiggy_sales (
	state varchar(255),
	city varchar(255),
	order_date date, 
	restaurant_name varchar(255),
	location varchar(255),
	category varchar(255),
	dish_name varchar(255),
	price int,
	rating int,
	rating_count int	
);

====================================================
--Data Cleaning 
--Check for NULL Values in each column
====================================================

SELECT
	SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
	SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_sales;

============================================================
--Blank or Empty strings
============================================================

SELECT *
FROM swiggy_sales
WHERE 
	state = '' OR city = '' OR restaurant_name = ''
	OR location = '' OR category = '' OR dish_name = ''

--Incorrect Date Types

SELECT
	state, city, order_date, restaurant_name, location,
	category, dish_name, price, rating, rating_count, 
	COUNT(*) AS cnt
FROM 
	swiggy_sales
GROUP BY 
	state, city, order_date, restaurant_name, location,
	category, dish_name, price, rating, rating_count
HAVING COUNT(*) > 1; 

==========================================================
--Delete duplicated (keep the first)
==========================================================

WITH cte AS (
	SELECT *,
			ROW_NUMBER() OVER(
				PARTITION BY state, city, order_date, restaurant_name, location,
							 category, dish_name, price, rating, rating_count
				ORDER BY (SELECT NULL)
			) AS rn
	FROM swiggy_sales
)
DELETE FROM cte WHERE rn > 1;
