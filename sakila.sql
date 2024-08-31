-- ⦁ What is the total number of rentals for the last 12 months?
select count(rental_id) as no_of_rents
from rental
where rental_date-interval '12' month;
/* ⦁ What is the total revenue generated from movie rentals for the last 12 
months?*/
select sum(amount) as `total revenue` 
from payment
where payment_date-interval '12' month
order by 1 desc;
-- ⦁ What are the top-rented movies for the last 12 months?
select count(f.film_id) as top_rented, f.title
from rental r
join inventory i on i.inventory_id= r.inventory_id
join film f on f.film_id=i.inventory_id
where rental_date-interval '12' month
group by 2
order by 1 desc;
-- ⦁ who are the best performing customers
-- base on amount paid
select concat_ws(' ',c.first_name,c.last_name) as fullname,sum(p.amount)
from customer c
join payment p on c.customer_id=p.customer_id
group by 1
order by 2 desc
limit 10; 
-- base on number of rents
with cte_1 as(
select concat_ws(' ',c.first_name,c.last_name) as fullname,r.rental_id
from customer c
join rental r on r.customer_id=c.customer_id
)
select fullname,count(fullname) as no_of_times
from cte_1
group by 1
order by 2 desc;
/*⦁ How many big spenders among our walk-in customers stay in any of our 
hot selling cities?*/

-- ⦁ which genre of movies should we focus on?
select count(r.rental_id) as total_rent,c.name,count(film_id) as no_of_film
from rental r 
join customer k on r.customer_id=k.customer_id
join category c on c.category_id=c.category_id
join film f on f.film_id =f.film_id
group by c.name
order by no_of_film,total_rent desc;
-- ⦁ which rating of movie is popular among our frequent luxury customers?
select f.rating,count(f.rating)
from film f 
join inventory i on i.film_id= f.film_id
join store s on s.store_id=i.store_id
join customer c on c.store_id=s.store_id
group by 1
order by 2 desc
limit 1;
-- ⦁ What is the average rental duration for the last 12 months?
select avg(f.rental_duration) as `avg rental duration`
from rental r  
join inventory i on i.inventory_id=r.inventory_id
join film f on f.film_id=i.film_id
where rental_date - interval '12' month;
-- ⦁ What is the distribution of rental duration for the last 12 months?
SELECT r.rental_id, f.rental_duration, r.rental_date
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON i.inventory_id = f.film_id
WHERE rental_date - INTERVAL '12' MONTH
ORDER BY r.rental_id DESC;
-- ⦁ Which actors are the most popular among customers?
with cte_1 as(
select concat_ws('',a.first_name,a.last_name) as fullname,r.rental_id
from rental r
join customer c on c.customer_id=r.customer_id
join actor a on a.actor_id=a.actor_id
)
select fullname,count(fullname) as `total rent` 
from cte_1 
group by 1
order by 2 desc;
-- ⦁ Are there any seasonal trends in DVD rentals?
select year(rental_date) as year,
date_format(rental_date,'%month') as month_name,
count(month(rental_date)) as seasional_sale
from rental
group by 1,2;
-- ⦁ What is the relationship between customer age and rental behavior?
/* one and only one
	to
	one or maany*/
    -- ⦁ What is the customer retention rate for the last 12 months?
select c.first_name,c.last_name,f.rental_rate
from customer c
join store s on s.store_id= c.store_id
join inventory i on i.store_id= s.store_id
join film f on f.film_id= i.film_id
join rental r on r.inventory_id= i.inventory_id
where rental_date - interval '12' month;
-- ⦁ what is the churn rate of our luxury customers?
-- Define the time period
SET @months_period = 12;

-- Identify active customers
CREATE TEMPORARY TABLE active_customers AS
SELECT DISTINCT customer_id
FROM rental
WHERE rental_date >= CURDATE() - INTERVAL @months_period MONTH;

-- Identify all customers
CREATE TEMPORARY TABLE all_customers AS
SELECT customer_id
FROM customer;

-- Identify churned customers
CREATE TEMPORARY TABLE churned_customers AS
SELECT customer_id
FROM all_customers
WHERE customer_id NOT IN (SELECT customer_id FROM active_customers);

-- Calculate churn rate
SELECT
    (SELECT COUNT(*) FROM churned_customers) * 100.0 / (SELECT COUNT(*) FROM all_customers) AS churn_rate_percentage;

-- Drop temporary tables if no longer needed
DROP TEMPORARY TABLE IF EXISTS active_customers;
DROP TEMPORARY TABLE IF EXISTS all_customers;
DROP TEMPORARY TABLE IF EXISTS churned_customers;
