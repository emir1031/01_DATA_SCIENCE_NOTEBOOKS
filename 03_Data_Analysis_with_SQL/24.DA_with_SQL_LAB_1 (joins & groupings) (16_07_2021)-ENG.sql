-------------16.07.2021 DAwSQL LAb 1 - ENG ---------------

USE BikeStores

-- TASK 1: Write a query that returns the average prices according to brands and categories.

SELECT TOP 20 * FROM production.products  -- Let's check what's inside products?

SELECT brand_name, category_name, AVG(list_price) AS AVG_price
FROM production.products P, production.categories C, production.brands B
WHERE B.brand_id = P.brand_id AND P.category_id = C.category_id
GROUP BY brand_name, category_name
ORDER BY 1 DESC, 2 DESC;  -- DEFAULT SORTING IS ASCENDING


-- TASK 2: Write a query that returns the store which has the most sales quantitiy in 2016

SELECT TOP 20 * FROM sales.orders  -- Some customers did orders at some date frome some stores.
SELECT TOP 20 * FROM sales.order_items -- We have order_id, quantity here also.
SELECT TOP 20 * FROM sales.stores

SELECT TOP 1 O.store_id, store_name, SUM(quantity) AS TOTAL_Quantity -- TOP 1 is for limiting
FROM sales.orders AS O, sales.order_items AS OI, sales.stores AS S
WHERE O.order_id = OI.order_id AND O.store_id = S.store_id
AND O.order_date BETWEEN '2016-01-01' AND '2016-12-31' -- AND O.order_date LIKE '%16%' --> this one also will work but we will see at upcoming lesseons
GROUP BY O.store_id, store_name
ORDER BY TOTAL_Quantity DESC;  -- we can use also "ORDER BY 3 DESC;


-- TASK 3: --Write a query that returns state(s) where ‘Trek Remedy 9.8 - 2017’ product  is not ordered

SELECT C.[state], COUNT(OI.product_id) AS count_of_product
FROM production.products AS P, sales.order_items AS OI, sales.orders AS O, sales.customers AS C
WHERE P.product_id = OI.product_id AND  OI.order_id = O.order_id AND O.customer_id = c.customer_id
AND P.product_name = 'Trek Remedy 9.8 - 2017'
GROUP BY C.[state]

-- Now we will use subquery :D

SELECT C.[state], COUNT(SUB.product_id) AS count_of_product
FROM
(
SELECT OI.order_id, O.customer_id, P.product_id
FROM production.products AS P, sales.order_items AS OI, sales.orders AS O
WHERE P.product_id = OI.product_id AND  OI.order_id = O.order_id
AND P.product_name = 'Trek Remedy 9.8 - 2017'
) SUB

FULL OUTER JOIN sales.customers AS C 
ON C.customer_id = SUB.customer_id
GROUP BY C.[state]
HAVING COUNT(SUB.product_id)=0


-- TASK 3: --Write a query that returns state(s) where ‘Trek Remedy 9.8 - 2017’ product  is not ordered
-- With description


-- How many orders of this product were placed in which state? I need to find this first
-- therefore, this value will appear as 0 in the state where no order is placed.
-- state information --> at customers table
-- product names --> at products table
-- we need to chose our way sales.customers > sales.orders > sales.order_items > production.products

SELECT *
FROM sales.customers 

SELECT C.order_id, C.customer_id, A.product_id, product_name
FROM production.products A, sales.order_items B, sales.orders C
-- I can't join orders and product table. for this i need to go through the order_items table
WHERE A. product_id = B.product_id
AND B.order_id = C.order_id
AND A.product_name = 'Trek Remedy 9.8 - 2017'
-- I got the customer information

-- Now I need to find in which states these products are sold. for this I will fetch the state from table D
SELECT C.order_id, C.customer_id, A.product_id, product_name, D.state
FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
-- I can't join orders and product table. for this i need to go through the order_items table
WHERE A. product_id = B.product_id
AND B.order_id = C.order_id
AND C.customer_id = D.customer_id
AND A.product_name = 'Trek Remedy 9.8 - 2017'
-- I have now brought the states as well. I can see that this product is sold in 14 states. 
-- but in which state was it never sold?


-- Now I use the table I created in the above code in a new SELECT-FROM by enclosing it in parentheses. (SUBquery
-- and I will RIGHT JOIN this table with the sales.customers table and group it according to the state column in the sales.customers table.
SELECT E.state, COUNT(product_id) CNT_PRODUCT 
-- I used the COUNT code to GROUP BY according to the state and count the rows of product ids 47 as aggregate.
-- so I have the sales quantities of this product brought against the state names. now my table is down to 3 rows.
-- First line is the state where this product has never been sold.
FROM
(
SELECT C.order_id, C.customer_id, A.product_id, product_name
FROM production.products A, sales.order_items B, sales.orders C
WHERE A. product_id = B.product_id
AND B.order_id = C.order_id
AND A.product_name = 'Trek Remedy 9.8 - 2017'
) D
RIGHT JOIN sales.customers E 
ON D.customer_id = E.customer_id
GROUP BY
		E.state

-- but I want to see the unsold state. I will use HAVING for this.
SELECT E.state, COUNT(product_id) CNT_PRODUCT 
FROM
(
SELECT C.order_id, C.customer_id, A.product_id, product_name
FROM production.products A, 
	sales.order_items B, 
	sales.orders C
WHERE A. product_id = B.product_id
AND B.order_id = C.order_id
AND A.product_name = 'Trek Remedy 9.8 - 2017'
) D
RIGHT JOIN sales.customers E --
ON D.customer_id = E.customer_id
GROUP BY
		E.state
HAVING COUNT(product_id) = 0