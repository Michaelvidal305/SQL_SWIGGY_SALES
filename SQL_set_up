--    Swiggy Sale Analysis SQL - Postgres Database Setup
============================================================
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

--CREATE SCHEMA 
--CREATE ALL DIMENSIONS TABLE 
--dim_date
CREATE TABLE dim_date (
	date_id SERIAL PRIMARY KEY,
	full_date DATE,
	Year INT,
	Month INT,
	Month_name VARCHAR(20),
	Quarter INT, 
	Day INT,
	Week INT
);

	
--dim_location
CREATE TABLE dim_location (
	Location_id SERIAL PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);

--dim_restaurant
CREATE TABLE dim_restaurant (
	restaurant_id SERIAL PRIMARY KEY,
	restaurant_name VARCHAR(200)
);

--dim_category
CREATE TABLE dim_category (
	category_id SERIAL PRIMARY KEY,
	category VARCHAR(200)
);

--dim_dish
CREATE TABLE dim_dish (
	dish_id SERIAL PRIMARY KEY,
	dish_name VARCHAR(200)
);

============================================================
--CREATE FACT TABLE 
============================================================

CREATE TABLE fact_swiggy_orders(
	order_id SERIAL PRIMARY KEY,
	
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
    EXTRACT(YEAR FROM order_date)        AS year,
    EXTRACT(MONTH FROM order_date)       AS month,
    TO_CHAR(order_date, 'Month')         AS month_name,
    EXTRACT(QUARTER FROM order_date)     AS quarter,
    EXTRACT(DAY FROM order_date)         AS day,
    EXTRACT(WEEK FROM order_date)        AS week
FROM swiggy_sales
WHERE order_date IS NOT NULL;

--dim_location 
INSERT INTO dim_location (state, city, location)
SELECT DISTINCT
	state,
	city,
	location
FROM swiggy_sales;

--dim_restaurant
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT
	restaurant_name
FROM swiggy_sales

--dim_category
INSERT INTO dim_category (category)
SELECT DISTINCT
	category
FROM swiggy_sales;

--dim_dish
INSERT INTO dim_dish (dish_name)
SELECT DISTINCT
	dish_name
FROM swiggy_sales;

============================================================
--INSERT INTO FACT TABLE
============================================================

INSERT INTO fact_swiggy_orders
(
	date_id,
	price,
	rating,
	rating_count,
	location_id,
	restaurant_id,
	category_id,
	dish_id
)
SELECT 
	dd.date_id,
	s.price,
	s.rating,
	s.rating_count,

	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id
FROM swiggy_sales s 

JOIN dim_date dd
	ON dd.full_date = s.order_date

JOIN dim_location dl
	ON dl.state = s.state
	AND dl.city = s.city

JOIN dim_restaurant dr
	ON dr.restaurant_name = s.restaurant_name

JOIN dim_category dc
	ON dc.category = s.category

JOIN dim_dish dsh
	ON dsh.dish_name = s.dish_name;

SELECT * FROM dim_date;
SELECT * FROM dim_location;
SELECT * FROM dim_restaurant;
SELECT * FROM dim_category;
SELECT * FROM dim_dish;
SELECT * FROM fact_swiggy_orders;

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
