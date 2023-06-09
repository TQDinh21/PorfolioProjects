CREATE TABLE Sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO Sales
  ("customer_id","order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE Menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO Menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');


CREATE TABLE Members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO Members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('C', '2021-01-07');

WITH join_all_cte AS(
    SELECT
        s.customer_id,
        men.product_name,
        men.price,
        s.order_date,
        mem.join_date,
        CASE
            WHEN s.order_date >= mem.join_date THEN 'Yes'
            ELSE 'No'
        END as "is_member"
    FROM
        menu men,
        sales s
        LEFT JOIN members mem
        ON s.customer_id = mem.customer_id
    WHERE men.product_id = s.product_id
)

SELECT * FROM join_all_cte;


Select *
From Members
Join Sales
on Members.customer_id  = Sales.customer_id
join Menu
on menu.product_id = Sales.product_id;

-- 1.What is the total amount each customer spent at the restaurant?
Select customer_id, sum(price) as spent
From Sales as S, Menu as M
Where M.product_id = S.product_id
Group By customer_id; 

--2. How many days has each customer visited the restaurant?
Select Customer_ID, Count(Distinct Order_date) as Visit_Count
From Sales
Group by customer_id 


--3. What was the first item from the menu purchased by each customer? create cte table to use "rank" based on order_date

WITH First_Sale_cte AS
(
 SELECT customer_id, order_date, product_name,
  ROW_NUMBER() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
 FROM Sales as S
 JOIN Menu as Men
  ON S.product_id = Men.product_id
)

Select customer_id, product_name
from First_Sale_cte
where rank =1
group by customer_id, product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	top(1)
	product_name,
	count(S.product_id) as Most_Purchased
FROM
	Sales S,
	Menu M
WHERE S.product_id = M.product_id
GROUP BY product_name
ORDER BY Most_Purchased DESC;

-- 5. Which item was the most popular for each customer?

WITH Most_Popular_Item AS
(
 SELECT customer_id, product_name, 
  COUNT(m.product_id) AS order_count,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY COUNT(s.customer_id) DESC) AS rank
FROM Menu AS m
JOIN sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM Most_Popular_Item
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH memb_orders_cte AS(
	SELECT
		s.customer_id,
		order_date,
		join_date,
		product_id,
		row_number() over (partition by s.customer_id
		order by order_date) as rank
	FROM
		sales s,
		members m
	WHERE
		m.customer_id = s.customer_id
		AND
		order_date >= join_date
)

SELECT 
	customer_id,
	product_name,
	order_date, 
	join_date
FROM 
	memb_orders_cte mo,
	menu m
WHERE 
	m.product_id = mo.product_id
	AND
	rank = 1
;

-- 7. Which item was purchased just before the customer became a member?
WITH before_memb_orders_cte AS(
	SELECT
		s.customer_id,
		order_date,
		join_date,
		product_id,
		row_number() over (partition by s.customer_id
		order by order_date desc) as rank
	FROM
		sales s,
		members m
	WHERE
		m.customer_id = s.customer_id
		AND
		order_date < join_date
)

SELECT 
	customer_id,
	product_name,
	order_date, 
	join_date
FROM 
	before_memb_orders_cte mo,
	menu m
WHERE 
	m.product_id = mo.product_id
	AND
	rank = 1
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	s.customer_id,
	count(s.product_id) as items,
	sum(men.price) as spent
FROM
	sales s,
	members mem,
	menu men
WHERE
	mem.customer_id = s.customer_id
	AND
	men.product_id = s.product_id
	AND
	order_date < join_date
GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer_id,
	sum(CASE
		WHEN s.product_id = 1 THEN price*20
		ELSE price*10 
	END) as total_points
FROM
	sales s,
	menu m
WHERE m.product_id = s.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

WITH dates_cte AS(
	SELECT *, 
		DATEADD(DAY, 6, join_date) AS valid_date, 
		EOMONTH('2021-01-1') AS last_date
	FROM members
)

SELECT
	s.customer_id,
	sum(CASE
		WHEN s.product_id = 1 THEN price*20
		WHEN s.order_date between d.join_date and d.valid_date THEN price*20
		ELSE price*10 
	END) as total_points
FROM
	dates_cte d,
	sales s,
	menu m
WHERE
	d.customer_id = s.customer_id
	AND
	m.product_id = s.product_id
	AND
	s.order_date <= d.last_date
GROUP BY s.customer_id;

