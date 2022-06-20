/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id
,SUM(m.price) AS total_spent
FROM dannys_diner.sales s 
LEFT JOIN dannys_diner.menu m 
	ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT customer_id
,COUNT(DISTINCT(order_date)) AS n_visits
FROM dannys_diner.sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?


WITH cte_first_item AS (
		SELECT s.customer_id
		,s.order_date
		,s.product_id
		,m.product_name
		,RANK () OVER ( 
					PARTITION BY customer_id
					ORDER BY order_date ASC
					) rank_order_date
		FROM dannys_diner.sales s
		JOIN dannys_diner.menu m
			ON s.product_id = m.product_id
) 
SELECT customer_id
,product_name  AS first_product_purchase
FROM cte_first_item
WHERE rank_order_date = 1
GROUP BY customer_id;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name
,COUNT(customer_id) AS top_purchased_product
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY COUNT(customer_id) DESC
LIMIT 1;



-- 5. Which item was the most popular for each customer?
WITH cte1 AS (
	SELECT s.customer_id
	,m.product_name
	,COUNT(s.product_id) AS number_of_purchases
	FROM dannys_diner.sales s
	JOIN dannys_diner.menu m
		ON s.product_id = m.product_id
	GROUP BY s.customer_id, s.product_id
),
cte2 AS (
	SELECT *,
	RANK() OVER (PARTITION BY customer_id ORDER BY number_of_purchases DESC) AS ranked
	FROM cte1
)
SELECT *
FROM cte2
WHERE ranked = 1;


-- 6. Which item was purchased first by the customer after they became a member?

SELECT s.customer_id
,m.product_name
,min(s.order_date) order_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
RIGHT JOIN dannys_diner.members me
	ON me.customer_id = s.customer_id
WHERE order_date >= join_date
GROUP BY customer_id
ORDER BY s.customer_id;



-- 7. Which item was purchased just before the customer became a member?

SELECT s.customer_id
,m.product_name
-- ,max(s.order_date)
,s.order_date
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
RIGHT JOIN dannys_diner.members me
	ON me.customer_id = s.customer_id
WHERE order_date < join_date
-- GROUP BY customer_id
ORDER BY s.customer_id;



-- 8. What is the total items and amount spent for each member before they became a member?

WITH cte AS (
				SELECT m.customer_id
                ,me.product_name
                ,me.price
				FROM dannys_diner.sales s
				JOIN dannys_diner.members m
					ON s.customer_id = m.customer_id
                JOIN dannys_diner.menu me
					ON s.product_id = me.product_id
				WHERE s.order_date < m.join_date)
SELECT customer_id
,COUNT(*) AS total_items
,SUM(price) AS total_spent
FROM cte
GROUP BY 1;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id
,sum(CASE WHEN product_name = "sushi" THEN price*10*2 ELSE price*10 END) AS points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id
,sum(CASE 
    WHEN product_name = "sushi" THEN price*10*2
    WHEN price BETWEEN me.join_date AND DATE_ADD(me.join_date, INTERVAL 7 DAY) THEN price*10*2
    WHEN price BETWEEN me.join_date AND DATE_ADD(me.join_date, INTERVAL 7 DAY) 
		AND product_name = "sushi" THEN price*10*2*2
	ELSE price*10
    END) AS points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
RIGHT JOIN dannys_diner.members me
	ON s.customer_id = me.customer_id
GROUP BY customer_id;
