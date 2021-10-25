------------- 2021-08-03 DAwSQL Lab 2 ---------------------

--Select customers who have purchase both Children Bicycle and Comfort Bicycle on a single order.
--(expected columns: Customer id, first name, last name, order id)

SELECT CU.customer_id,first_name,last_name,O.order_id, 
        SUM(IIF(CA.category_name='Children Bicycles', 1,0)) as IsChild,
        SUM(IIF(CA.category_name='Comfort Bicycles', 1,0)) as IsComfort
FROM sales.customers CU, sales.orders O, sales.order_items OI, production.products P, production.categories CA
WHERE CA.category_id=P.category_id 
    AND P.product_id=OI.product_id
    AND OI.order_id=O.order_id
    AND O.customer_id=CU.customer_id
    AND CA.category_name IN ('Comfort Bicycles', 'Children Bicycles')
GROUP BY CU.customer_id,first_name,last_name,O.order_id
HAVING
		SUM(IIF(CA.category_name='Children Bicycles', 1,0))>0 AND
		SUM(IIF(CA.category_name='Comfort Bicycles', 1,0)) >0
ORDER BY 1
--

SELECT	E.customer_id, E.first_name,E.last_name, D.order_id
FROM	production.categories A,
		production.products B,
		sales.order_items C,
		sales.orders D,
		sales.customers E
WHERE	A.category_id = B.category_id AND
		B.product_id = C.product_id AND
		C.order_id = D.order_id AND
		D.customer_id = E.customer_id
AND		A.category_name = 'Children Bicycles'
INTERSECT
SELECT	E.customer_id, E.first_name,E.last_name, D.order_id
FROM	production.categories A,
		production.products B,
		sales.order_items C,
		sales.orders D,
		sales.customers E
WHERE	A.category_id = B.category_id AND
		B.product_id = C.product_id AND
		C.order_id = D.order_id AND
		D.customer_id = E.customer_id
AND		A.category_name = 'Comfort Bicycles'

--

WITH CTE AS(
SELECT E.customer_id, E.first_name, E.last_name, D.order_id, A.category_name,
	   CASE WHEN A.category_name='Children Bicycles' THEN 1 ELSE 0 END AS is_child
FROM production.categories AS A,
	 production.products AS B,
	 sales.order_items AS C,
	 sales.orders AS D,
	 sales.customers AS E
WHERE A.category_id = B.category_id AND
	  B.product_id = C.product_id AND
	  C.order_id = D.order_id AND
	  D.customer_id = E.customer_id AND
	  A.category_name IN ('Children Bicycles')
),
CTE2 AS(
SELECT E.customer_id, E.first_name, E.last_name, D.order_id, A.category_name,
	   CASE WHEN A.category_name='Comfort Bicycles' THEN 1 ELSE 0 END AS is_comfort
FROM production.categories AS A,
	 production.products AS B,
	 sales.order_items AS C,
	 sales.orders AS D,
	 sales.customers AS E
WHERE A.category_id = B.category_id AND
	  B.product_id = C.product_id AND
	  C.order_id = D.order_id AND
	  D.customer_id = E.customer_id AND
	  A.category_name IN ('Comfort Bicycles')
)
SELECT DISTINCT CTE.customer_id--, CTE.first_name, CTE.last_name, CTE.order_id, CTE.is_child, CTE2.is_comfort
FROM CTE, CTE2
WHERE CTE.customer_id = CTE2.customer_id
AND CTE.is_child = 1 AND CTE2.is_comfort = 1
ORDER BY CTE.customer_id
