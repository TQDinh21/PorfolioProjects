--1. How many pizzas were ordered?

select count(*) as Ordered_Pizza
from customer_orders

--2. How many unique customer orders were made?

select count(distinct order_id) as unique_orders
from #clean_customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT 
    runner_id,
    count(order_id) as successful_orders
FROM #cleaned_runner_orders
WHERE cancellation is null
GROUP BY runner_id;

--5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	customer_id,
	pizza_name,
	COUNT(c.order_id) as ordered
FROM 
	#cleaned_customer_orders c,
	pizza_names p
WHERE c.pizza_id = p.pizza_id
GROUP BY 
	customer_id,
	pizza_name
ORDER BY customer_id;

--6. What was the maximum number of pizzas delivered in a single order?

SELECT TOP(1)
	c.order_id,
	count(pizza_id) as max_pizzas_delivered
FROM 
	#cleaned_customer_orders c,
	#cleaned_runner_orders r
WHERE
	c.order_id = r.order_id
	AND
	r.cancellation is null
GROUP BY c.order_id
ORDER BY 2 DESC;


--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
	c.customer_id,
	sum(CASE
		WHEN c.exclusions is not null 
			OR c.extras is not null
			THEN 1
		ELSE 0
	END) AS at_least_1_change,
	sum(CASE
		WHEN c.exclusions is null 
			AND c.extras is null
			THEN 1
		ELSE 0
	END) AS no_changes
FROM 
	#cleaned_customer_orders c,
	#cleaned_runner_orders r
WHERE
	c.order_id = r.order_id
	AND
	r.cancellation is null
GROUP BY c.customer_id

--8. How many pizzas were delivered that had both exclusions and extras?

SELECT
	count(pizza_id) as orders_fully_changed
FROM 
	#cleaned_customer_orders c,
	#cleaned_runner_orders r
WHERE
	c.order_id = r.order_id
	AND
	r.cancellation is null
	AND
	c.exclusions is not null
	AND
	c.extras is not null
;

--9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
	DATEPART(HOUR, order_time) as hour_of_day,
	COUNT(pizza_id) as total_orders
FROM #cleaned_customer_orders c
GROUP BY DATEPART(HOUR, order_time);

10. What was the volume of orders for each day of the week?
SELECT 
	FORMAT(order_time, 'dddd') as day_of_week,
	COUNT(pizza_id) as total_orders
FROM #cleaned_customer_orders c
GROUP BY FORMAT(order_time, 'dddd');



