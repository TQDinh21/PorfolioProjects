-- create clean customer order table

SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE
        WHEN exclusions = 'null' THEN null
        ELSE exclusions
    END as exclusions,
    CASE
        WHEN extras = 'null' THEN null
        ELSE extras
    END as extras,
    order_time
INTO #cleaned_customer_orders
FROM customer_orders;


--Create clean runner_orders table
SELECT 
    order_id,
    runner_id,
    cast(CASE 
        WHEN pickup_time = 'null' THEN null
        ELSE pickup_time
    END as datetime) as pickup_time,
    cast(CASE 
        WHEN distance = 'null' THEN null
        ELSE TRIM('km' from distance)
    END as float) as distance,
    cast(CASE
        WHEN duration = 'null' THEN null
        ELSE SUBSTRING(duration, 1, 2)
    END as int)as duration,
    CASE
        WHEN cancellation in ('null', '') THEN null
        ELSE cancellation
END as cancellation
INTO #cleaned_runner_orders
FROM runner_orders;
