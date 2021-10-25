/* 28.97.2021 DAwSQL Session 4 -- Set Operators and Case Expression */

-- Question: List customers who have an order prior to the last order of a customer named Sharyn Hopkins 
-- and are residents of the city of San Diego.

WITH T1 AS 
			(
			SELECT MAX(B.order_date) AS last_order
			FROM sales.customers AS A, sales.orders AS B
			WHERE A.customer_id = B.customer_id
			AND	  A.first_name LIKE 'Sharyn'
			AND   A.last_name  LIKE 'Hopkins'
			)
SELECT A.customer_id, first_name, last_name, city, order_date
FROM sales.customers AS A, sales.orders AS B, T1 AS C
WHERE A.customer_id = B.customer_id
AND   B.order_date < C.last_order
AND   A.city LIKE 'San Diego'

-- Question: 0'dan 9'a kadar herbir rakam bir satýrda olacak þekilde bir tablo olusturun.

WITH T1 AS
		  (
		  SELECT 0 AS number
		  UNION ALL
		  SELECT number + 1
		  FROM T1
		  WHERE number <= 8
		  )
SELECT *
FROM T1

--

WITH Users AS
			 (
			  SELECT *
			  FROM (
					VALUES
						  (1,'start', CAST('01-01-20' AS date)),
						  (1,'cancel', CAST('01-02-20' AS date)),
						  (2,'start', CAST('01-03-20' AS date)),
						  (2,'publish', CAST('01-04-20' As date)),
						  (3,'start', CAST('01-05-20' AS date)),
						  (3,'cance1', CAST('01-06-20' AS date)),
						  (1,'start', CAST('01-07-20' AS date)),
						  (1,'publish', CAST('01-08-20' AS date))
					) as tab1e_1 ([user_id], [action], [date])
			 )
SELECT * 
FROM Users

-- Question: Sacramento þehrindeki müþteriler ile Monroe þehrindeki müþterilerin soy isimlerini listeleyin

-- UNION ALL
SELECT last_name
FROM sales.customers
WHERE city = 'Sacramento'

UNION ALL

SELECT last_name
FROM sales.customers
WHERE city = 'Monroe'

-- UNION

SELECT last_name
FROM sales.customers
WHERE city = 'Sacramento'

UNION

SELECT last_name
FROM sales.customers
WHERE city = 'Monroe'

-- WITH first_name

SELECT first_name ,last_name
FROM sales.customers
WHERE city = 'Sacramento'

UNION

SELECT first_name, last_name
FROM sales.customers
WHERE city = 'Monroe'

-- Another Way 'OR' 'IN'

select distinct last_name
from sales.customers
where city = 'Sacramento' or city = 'Monroe'

SELECT last_name
FROM sales.customers
WHERE city IN ('Sacramento', 'Monroe')


-- Question: Write a query that returns brands that have products for both 2016 and 2017.

SELECT B.brand_id, A.brand_name
FROM production.brands A, production.products B
WHERE A.brand_id = B.brand_id
AND B.model_year = 2016
INTERSECT
SELECT B.brand_id, A.brand_name
FROM production.brands A, production.products B
WHERE A.brand_id = B.brand_id
AND B.model_year = 2017

--

-- Leon's Way

SELECT	*
FROM	production.brands
WHERE	brand_id IN (
					SELECT	brand_id
					FROM	production.products
					WHERE	model_year = 2016
					INTERSECT
					SELECT	brand_id
					FROM	production.products
					WHERE	model_year = 2017
					)

-- Question: Write a query that returns customers who have orders for both 2016, 2017, and 2018

SELECT A.first_name, A.last_name
FROM sales.customers A, sales.orders AS B
WHERE A.customer_id = B.customer_id
AND YEAR(B.order_date) = 2016
INTERSECT
SELECT A.first_name, A.last_name
FROM sales.customers A, sales.orders AS B
WHERE A.customer_id = B.customer_id
AND YEAR(B.order_date) = 2017
INTERSECT
SELECT A.first_name, A.last_name
FROM sales.customers A, sales.orders AS B
WHERE A.customer_id = B.customer_id
AND YEAR(B.order_date) = 2018

-- With subquery

SELECT	first_name, last_name
FROM	sales.customers
WHERE	customer_id IN (
						SELECT	customer_id
						FROM	sales.orders
						WHERE	order_date BETWEEN '2016-01-01' AND '2016-12-31'
						INTERSECT
						SELECT	customer_id
						FROM	sales.orders
						WHERE	order_date BETWEEN '2017-01-01' AND '2017-12-31'
						INTERSECT
						SELECT	customer_id
						FROM	sales.orders
						WHERE	order_date BETWEEN '2018-01-01' AND '2018-12-31'
						)

--Question: Write a query that returns products produced in 2016 not in 2017

SELECT B.brand_id, B.brand_name, A.model_year
FROM production.brands AS B, production.products AS A
WHERE A.brand_id=B.brand_id 
AND A.model_year =2016
EXCEPT
SELECT B.brand_id, B.brand_name, A.model_year
FROM production.brands AS B, production.products AS A
WHERE A.brand_id=B.brand_id 
AND A.model_year=2017

--

SELECT	*
FROM	production.brands
WHERE	brand_id IN (
					SELECT	brand_id
					FROM	production.products
					WHERE	model_year = 2016
					EXCEPT
					SELECT	brand_id
					FROM	production.products
					WHERE	model_year = 2017
					)
;

--Question: Write a query that returns only products ordered in 2017 (not ordered in other years).

SELECT B.product_id, C.product_name
FROM sales.orders AS A, sales.order_items AS B, production.products AS C
WHERE A.order_id = B.order_id
AND B.product_id = C.product_id
AND YEAR(A.order_date) = 2017

EXCEPT

SELECT B.product_id, C.product_name
FROM sales.orders AS A, sales.order_items AS B, production.products AS C
WHERE A.order_id = B.order_id
AND B.product_id = C.product_id
AND YEAR(A.order_date) != 2017

--

SELECT	product_id, product_name
FROM	production.products
WHERE	product_id IN (
					SELECT	B.product_id
					FROM	sales.orders A, sales.order_items B
					WHERE	A.order_id= B.order_id
					AND		A.order_date LIKE '%2017%'
					EXCEPT
					SELECT	B.product_id
					FROM	sales.orders A, sales.order_items B
					WHERE	A.order_id= B.order_id
					AND		YEAR(A.order_date) != 2017
					)

--

DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @EndDate = '2017-12-31'
SET @StartDate = '2017-01-01'

SELECT	product_id, product_name
FROM	production.products
WHERE	product_id IN (
						SELECT	B.product_id
						FROM	sales.orders A, sales.order_items B
						WHERE	A.order_id = B.order_id AND
								A.order_date BETWEEN @StartDate AND @EndDate
						EXCEPT
						SELECT	B.product_id
						FROM	sales.orders A, sales.order_items B
						WHERE	A.order_id = B.order_id AND
								A.order_date NOT BETWEEN @StartDate AND @EndDate)

-- Question: Write a query that returns State where 'Trek Remedy 9.8 - 2017' product is not ordered

SELECT D.state
FROM sales.customers D

EXCEPT

SELECT D.state
FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
WHERE A.product_id = B.product_id
AND B.order_id = C.order_id
AND	C.customer_id = D.customer_id
AND A.product_name = 'Trek Remedy 9.8 - 2017'

--

SELECT	E.[state], COUNT (D.product_id) count_of_products
FROM
		(
		SELECT	C.order_id, C.customer_id, B.product_id
		FROM	production.products A, sales.order_items B, sales.orders C
		WHERE	A.product_id = B.product_id
		AND		B.order_id = C.order_id
		AND		A.product_name = 'Trek Remedy 9.8 - 2017'
		) D
RIGHT JOIN sales.customers E ON E.customer_id = D.customer_id
GROUP BY
		E.[state]
HAVING
		COUNT (D.product_id) = 0

-----

SELECT distinct state
FROM
SALES.customers X
WHERE NOT EXISTS
(
SELECT	D.STATE
FROM	production.products A, sales.order_items B, sales.orders C, sales.customers D
WHERE	A.product_id = B.product_id
AND		B.order_id = C.order_id
AND		C.customer_id = D.customer_id
AND		A.product_name = 'Trek Remedy 9.8 - 2017'
AND		D.STATE = X.STATE
) 

-- Question: Question: Generate a new column containing what the mean of the values in the Order_Status column.
-- 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT order_status,
		CASE order_status WHEN 1 THEN 'Pending'
						  WHEN 2 THEN 'Processing'
						  WHEN 3 THEN 'Rejected'
						  WHEN 4 THEN 'Completed'
		END AS MEAN_OF_STATUS
FROM sales.orders

-- Question: Create a new column containing the labels of the customers' email service providers ( "Gmail", "Hotmail", "Yahoo" or "Other" )

SELECT email
FROM sales.customers

SELECT email,
		CASE        WHEN email LIKE '%gmail%' THEN 'GMAIL'
					WHEN email LIKE '%hotmail%' THEN 'HOTMAIL'
					WHEN email LIKE '%yahoo%' THEN 'YAHOO'
					ELSE 'OTHER'
		END AS email_service_providers
FROM sales.customers

