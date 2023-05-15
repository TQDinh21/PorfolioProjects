-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	DATEPART(WEEK, registration_date) AS [week],
	COUNT(runner_id) AS runners_signed_up
FROM   runners
GROUP  BY DATEPART(WEEK, registration_date);

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	r.runner_id,
	AVG(DATEDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_time_to_hq
FROM   
	#cleaned_runner_orders r,
	#cleaned_customer_orders c
WHERE c.order_id = r.order_id
GROUP  BY r.runner_id;

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte AS
(
	SELECT 
		c.order_id,
		COUNT(c.pizza_id) AS num_of_pizzas,
		DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_taken_per_order,
		DATEDIFF(MINUTE, c.order_time, r.pickup_time) / COUNT(c.pizza_id) AS time_taken_per_pizza
	FROM   
		#cleaned_runner_orders r,
		#cleaned_customer_orders c
	WHERE c.order_id = r.order_id
	GROUP BY 
		c.order_id,
		c.order_time,
		r.pickup_time
)
SELECT 
	num_of_pizzas,
	AVG(time_taken_per_order) AS avg_total_time_taken,
	AVG(time_taken_per_pizza) AS avg_time_taken_per_pizza
FROM prep_time_cte
GROUP BY num_of_pizzas;

-- 4. What was the average distance travelled for each customer?
SELECT 
	c.customer_id,
	ROUND(AVG(r.distance), 2) AS avg_distance
FROM   
	#cleaned_runner_orders r,
	#cleaned_customer_orders c
WHERE c.order_id = r.order_id
GROUP BY c.customer_id;

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	MAX(duration) AS max_delivery_time,
	MIN(duration) AS min_delivery_time,
	MAX(duration) - MIN(duration) AS time_difference
FROM #cleaned_runner_orders;

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	runner_id,
	distance,
	duration,
	ROUND(distance/ duration * 60, 2) AS speed_km_hr
FROM #cleaned_runner_orders
WHERE cancellation is null
ORDER BY 
	runner_id,
	speed_km_hr
;

--7. What is the successful delivery percentage for each runner?
SELECT 
	runner_id,	
	count(order_id) as total_orders,
	count(pickup_time) as total_orders_delivered,
	cast(count(pickup_time) as float) / cast(count(order_id) as float) * 100 
		as successful_delivery_percent
FROM #cleaned_runner_orders
GROUP BY runner_id;