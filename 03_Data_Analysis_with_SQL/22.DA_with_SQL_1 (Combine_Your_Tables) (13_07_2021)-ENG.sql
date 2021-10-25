/* 12 july 2021 -- Data Analysis with SQL */

USE BikeStores

-- INNER JOIN
-- list products with category name
-- select product_id, product_name, category_id, category_name

-- 1. WAY
SELECT A.product_id, A.product_name, B.category_id, B.category_name
FROM production.products AS A
INNER JOIN production.categories AS B
ON A.category_id = B.category_id;


-- 2. WAY
SELECT A.product_id, A.product_name, B.category_name, B.category_id
FROM production.products A, production.categories B
WHERE A.category_id = B.category_id


-- INNER JOIN
-- List store employees with their store information
-- Select employee name, surname, store names

-- 1. WAY
SELECT A.first_name, A.last_name, B.store_name
FROM sales.staffs A, sales.stores B
WHERE A.store_id = B.store_id

-- 2. WAY
-- Without allias
SELECT sales.staffs.first_name, sales.staffs.last_name, sales.stores.store_name
FROM sales.staffs
JOIN sales.stores
ON sales.staffs.store_id = sales.stores.store_id

-- 3. WAY (GulF)
SELECT first_name,last_name, sales.stores.store_name 
FROM sales.staffs
INNER JOIN sales.stores
ON sales.stores.store_id = sales.staffs.store_id;


-- LEFT JOIN
-- List the products with their category names.
-- Select product ID, product name, category name, and categoryID

-- 1. WAY
SELECT A.product_id, A.product_name, B.category_name, B.category_id
FROM production.products AS A
LEFT JOIN production.categories AS B
ON A.category_id = B.category_id

-- 2. WAY
-- Without allias
SELECT production.products.product_id, production.products.product_name,  production.categories.category_name, production.categories.category_id
FROM production.products
LEFT JOIN production.categories 
ON production.products.category_id = production.categories.category_id


-- LEFT JOIN
-- report the stock status of the products that product id greater than 310 in the store
-- expected columns: product id, product name, store id, quantity

-- 1.WAY
SELECT PP.product_id, PP.product_name, PS.store_id, PS.quantity
FROM production.products AS PP
LEFT JOIN production.stocks AS PS
ON PP.product_id = PS.product_id
WHERE PP.product_id > 310;


-- RIGHT JOIN
-- report the stock status of the products that product id greater than 310 in the store
-- expected columns: product id, product name, store id, quantity

-- 1. WAY
SELECT A.product_id, A.product_name, B.store_id, B.quantity
FROM production.stocks AS B
RIGHT JOIN production.products AS A
ON A.product_id = B.product_id
WHERE A.product_id > 310

-- 2. WAY
SELECT B.product_id, B.product_name, A.store_id, A.quantity
FROM production.stocks as A
RIGHT JOIN production.products as B
ON A.product_id = B.product_id
where B.product_id > 310


-- RIGHT JOIN
-- Report the orders information made by all staffs.
-- Expected columns: Staff_id, first_name, last_name, all the information about orders

SELECT * 
FROM sales.staffs; -- 10

SELECT COUNT (DISTINCT staff_id)
FROM sales.orders; --6
-- (This counts unique 'staff_id's from orders, how many of staff entered the order details. We found 6 of them used it.
-- 4 of them weren't using the system, no input so their ids are missing. We are gonna sack them from their job. :) )

-- 1. WAY
SELECT A.staff_id, A.first_name,A.last_name, B.*
FROM sales.staffs A
RIGHT JOIN sales.orders B
ON A.staff_id = B.staff_id

-- 2. WAY
SELECT B.staff_id, B.first_name, B.last_name, A.*
FROM sales.orders A
RIGHT JOIN sales.staffs B
ON A.staff_id = B.staff_id


-- FULL OUTER JOIN
-- Write a query that returns stock and order information together for all products
-- Expected columns: product_id, store_id, quantity, order_id, list_price

-- 1. WAY
SELECT EMIR.product_id, HAN.store_id, HAN.quantity, EMIR.order_id, EMIR.list_price
FROM sales.order_items AS EMIR
FULL OUTER JOIN production.stocks AS HAN
ON EMIR.product_id = HAN.product_id

-- 2. WAY
SELECT EMIR.product_id, EMIR.store_id, EMIR.quantity, HAN.order_id,  HAN.list_price
FROM production.stocks AS EMIR
FULL OUTER JOIN sales.order_items AS HAN
ON EMIR.product_id = HAN.product_id

-- 3. WAY
SELECT A.product_id, A.store_id, B.quantity, B.order_id, B.list_price
FROM production.stocks A
FULL OUTER JOIN sales.order_items B
ON A.product_id = B.product_id;


-- CROSS JOIN
-- Write a query that returns all brand x category possibilities.
-- Expected columns: brand_id, brand_name, category_id, category_name

-- 1. WAY
SELECT A.brand_id, A.brand_name, B.category_id, B.category_name
FROM production.brands AS A
CROSS JOIN production.categories AS B
-- THERE IS NO "ON" WITH CROSS JOIN


-- CROSS JOIN
-- Write a query that returns the table to be used to add products that are in the Products table but not in the stocks table to the stocks table with quantity = 0. 
-- (Do not forget to add products to all stores.)
-- Expected columns: store_id, product_id, quantity

-- To understand question, let's check

SELECT *
FROM production.stocks

SELECT *
FROM production.products

-- As you can see some of products are not in the stocks table, now let's find:
-- Number of items not on stock list but on product list


SELECT *
FROM production.products AS A
WHERE A.product_id NOT IN (SELECT product_id FROM production.stocks);

-- We find which product_id in stores but not in stocks

SELECT B.store_id, A.product_id, A.product_name, 0 quantity
FROM production.products AS A
CROSS JOIN sales.stores AS B
WHERE A.product_id NOT IN (SELECT product_id FROM production.stocks)
ORDER BY A.product_id, B.store_id


-- SELF JOIN
-- Write a query that returns the staff with their managers.
-- Expected columns: staff first name, staff last name, manager name

SELECT * 
FROM sales.staffs AS A
JOIN sales.staffs AS B
ON A.manager_id = B.staff_id