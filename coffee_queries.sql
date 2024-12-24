use `Coffee Sales`;

select * 
from city;

select *
from customers;

select *
from products;

select *
from sales;






-- How many people in each city are estimated to consume coffee, given that 25% of the population does?


select city_name,population*0.25 as coffee_consumers,city_rank
from city
order by 2 desc;




-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select sum(x.total)
from (
select total,sale_id,case when left(sale_date,7) between '2023-09' and '2023-12' then 'last_quarter' else 'not' end as quarter
from Sales)x
where x.quarter='last_quarter';



-- How many units of each coffee product have been sold?

select products.product_name,count(*) as totalproductssold
from products 
inner join sales
on products.product_id=sales.product_id
group by products.product_name
order by totalproductssold desc;


-- What is the average sales amount per customer in each city?

select city.city_name,sum(sales.total) as totalrevnue,count(distinct customers.customer_id) as totalcustomers,
ROUND(sum(sales.total)/count(distinct customers.customer_id),2) as avgsalesamt
from city
inner join customers
on city.city_id=customers.city_id
inner join sales
on customers.customer_id=sales.customer_id
group by city.city_name
order by sum(sales.total) desc;


-- Provide a list of cities along with their populations and estimated coffee consumers.

select city.city_name,city.population,x.totalcount
from (
select customers.city_id as city_id ,count(distinct customers.customer_id) as totalcount
from customers
inner join sales
on customers.customer_id=sales.customer_id
group by customers.city_id
order by count(customers.customer_id) desc) x
inner join city
on city.city_id=x.city_id;




-- What are the top 3 selling products in each city based on sales volume?


select y.city_name,y.product_name,y.totalproductssold
from (select *,rank() over(partition by x.city_name order by x.totalproductssold desc) as ranking
from (
select city.city_name,products.product_name,count(sale_id) as totalproductssold
from city
inner join customers
on city.city_id=customers.city_id
inner join sales
on customers.customer_id=sales.customer_id
inner join products
on sales.product_id=products.product_id
group by city.city_name,products.product_name
order by totalproductssold desc) x)y
where y.ranking<4;




-- How many unique customers are there in each city who have purchased coffee products?


select city.city_name,count(distinct customers.customer_id) as unique_customers
from city
inner join customers
on city.city_id=customers.city_id
inner join sales
on customers.customer_id=sales.customer_id
group by city.city_name
order by unique_customers desc;



-- Find each city and their average sale per customer and avg rent per customer


with city_table as (
select city.city_name as city_name,sum(sales.total) as totalrevnue,count(distinct customers.customer_id) as totalcustomers,
ROUND(sum(sales.total)/count(distinct customers.customer_id),2) as avgsalesamt
from city
inner join customers
on city.city_id=customers.city_id
inner join sales
on customers.customer_id=sales.customer_id
group by city.city_name
order by sum(sales.total) desc),

city_rent as (

select city_name,estimated_rent
from city)



select city_rent.city_name,ROUND((estimated_rent/totalcustomers),2) as avgrentamt,city_table.avgsalesamt
from city_rent
inner join city_table
on city_rent.city_name=city_table.city_name;






-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
select *,COALESCE(ROUND(((x.totalsum-(lag(x.totalsum) over ()))/lag(x.totalsum) over ())*100,2),0)  as difference
from (
select distinct month(sale_date),sum(total) over(partition by MONTH(sale_date) ) as totalsum
from sales) x;




-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with city_table as (
select city.city_name as city_name,sum(sales.total) as totalrevnue,count(distinct customers.customer_id) as totalcustomers,
ROUND(sum(sales.total)/count(distinct customers.customer_id),2) as avgsalesamt
from city
inner join customers
on city.city_id=customers.city_id
inner join sales
on customers.customer_id=sales.customer_id
group by city.city_name
order by sum(sales.total) desc),

city_rent as (

select city_name,estimated_rent,population*0.25 as estimated_coffee_consumers
from city)

select city_rent.city_name,ROUND((estimated_rent/totalcustomers),2) as avgrentamt,city_table.avgsalesamt,city_table.totalrevnue,
city_rent.estimated_coffee_consumers,city_table.totalcustomers
from city_rent
inner join city_table
on city_rent.city_name=city_table.city_name
order by city_table.totalrevnue desc;

