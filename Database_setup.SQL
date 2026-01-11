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

============================================================
--Data Cleaning 
--Check for NULL Values in each column
============================================================

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

============================================================
--Delete duplicated (keep the first)
============================================================

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

============================================================
--CREATE SCHEMA 
--CREATE ALL DIMENSIONS TABLE 
--dim_date
============================================================

CREATE TABLE dim_date (
	date_id INT PRIMARY KEY,
	full_date DATE,
	year INT,
	month INT,
	month_name VARCHAR(20),
	quarter INT, 
	day INT,
	week INT
);


--dim_location
CREATE TABLE dim_location (
	location_id INT PRIMARY KEY,
	state VARCHAR(100),
	city VARCHAR(100),
	location VARCHAR(200)
);

--dim_restaurant
CREATE TABLE dim_restaurant (
	restaurant_id INT PRIMARY KEY,
	restaurant_name VARCHAR(200)
);

--dim_category
CREATE TABLE dim_category (
	category_id INT PRIMARY KEY,
	category VARCHAR(200)
);

--dim_dish
CREATE TABLE dim_dish (
	dish_id INT PRIMARY KEY,
	dish_name VARCHAR(200)
);

--CREATE FACT TABLE 
CREATE TABLE fact_swiggy_orders(
	order_id INT PRIMARY KEY,
	
	date_id INT, 
	price DECIMAL(10,2),
	rating DECIMAL(4,2),
	rating_count INT,

	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

============================================================
--INSERT DATE TO ALL TABLES
--dim_date
============================================================

INSERT INTO dim_date (full_date, year, month, month_name, quarter, day, week)
SELECT DISTINCT
	order_date,
	EXTRACT(year from order_date),
	EXTRACT(month from order_date),
	datename(month, order_date),
	datepart(quarter,order_date),
	EXTRACT(day from order_date),
	datepart(week, order_date)
FROM swiggy_sales
WHERE order_date IS NOT NULL;
