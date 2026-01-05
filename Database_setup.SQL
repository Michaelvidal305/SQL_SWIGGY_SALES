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
