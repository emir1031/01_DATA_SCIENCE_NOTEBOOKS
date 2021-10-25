

--DAwSQL Session -8 

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. 
--(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

SELECT Customer_Name, Province, Region, Customer_Segment, A.Cust_id, B.Ord_id, D.Prod_id, E.Ship_id, Sales, Discount
		order_quantity, Product_Base_Margin, Order_Date, Order_Priority, Product_Category, Product_Sub_Category, Order_ID,
		Ship_Mode, Ship_Date

INTO combined_table

FROM cust_dimen A, market_fact B, orders_dimen C, prod_dimen D, shipping_dimen E
		WHERE A.Cust_id = B.Cust_id
		and B.Ord_id = C.Ord_id
		and B.Prod_id = D.Prod_id
		and B.Ship_id = E.Ship_id

-- Hatalý gösterim. Tekrar eden sütunlar var. Buna INTO atanamýyor.

select * 
		
		from cust_dimen A, market_fact B, orders_dimen C, prod_dimen D, shipping_dimen E
		where A.Cust_id = B.Cust_id
		and B.Ord_id = C.Ord_id
		and B.Prod_id = D.Prod_id
		and B.Ship_id = E.Ship_id
 
 -- Teacher's answer

SELECT *
INTO combined_table
FROM (
		SELECT  cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment,
				mf.Ord_id, mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin,
				od.Order_Date, od.Order_Priority,
				pd.Product_Category, pd.Product_Sub_Category,
				sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
		FROM market_fact AS mf
		INNER JOIN cust_dimen AS cd 
		ON mf.Cust_id = cd.Cust_id
		INNER JOIN orders_dimen AS od 
		ON od.Ord_id = mf.Ord_id
		INNER JOIN prod_dimen AS pd 
		ON pd.Prod_id = mf.Prod_id
		INNER JOIN shipping_dimen AS sd 
		ON sd.Ship_id = mf.Ship_id
	  ) AS A;

SELECT * 
FROM combined_table

--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 customer_name, COUNT(ord_id) AS number_of_orders 
FROM combined_table
GROUP BY Customer_Name
ORDER BY number_of_orders DESC;

SELECT TOP 3 customer_name, COUNT(Order_ID) AS number_of_orders FROM combined_table
GROUP BY Customer_Name
ORDER BY number_of_orders DESC;

-- Teacher's answer  (we need to count order id, cause order id's are unique)

SELECT TOP 3 cust_id, Customer_Name, COUNT (DISTINCT Ord_id) AS COUNT_ORDER
FROM combined_table
GROUP BY Cust_id, Customer_Name
ORDER BY 3 DESC;

--/////////////////////////////////

--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

SET DATEFORMAT dmy  -- year month day olan formatý day month year olarak tanttýk

-- SELECT datediff(D, CAST(order_date as Date), CAST(ship_date as date)) as A from combined_table 

UPDATE combined_table SET order_date =  CONVERT(DATE,order_date,103) -- sütunlarýn tür dönüþümlerini yaptýk
UPDATE combined_table SET Ship_Date =  CONVERT(DATE,Ship_Date,103)  -- sütunlarýn tür dönüþümlerni yaptýk

SELECT order_date, ship_date, DATEDIFF(D, order_Date, ship_date) AS date_diff_day
FROM combined_table  -- tür dönüþümü iþlemi baþarýlý kontroll ettik

-- DaysTakenForDelivery adýnda yeni bir sütun oluþturduk ( INSERT = ALTER TABLE + UPDATE )

ALTER TABLE combined_table ADD DaysTakenForDelivery INT

-- oluturduðumuz yeni sütuna deðerlerimizi atýyoruz

UPDATE combined_table SET DaysTakenForDelivery = DATEDIFF(D,Order_Date, Ship_Date)

-- sütun deðerlerini kontrol ediyoruz. 

SELECT Order_Date,Ship_Date, DaysTakenForDelivery, DATEDIFF(D,Order_Date,Ship_Date) as date_diff
FROM combined_table  -- deðerler uyuþuyor (daystakenfordelivery ve date_diff)
ORDER BY date_diff;


-- Burada convert kullandýk ama cast ile geçici bir iþlem yaptýk, anlýk.

/* CREATE VÝEW tablo AS 
SELECT *, 
		 DATEDÝFF(D, CAST(order_date as Date), 
		 CAST(ship_date as date)) AS DaysTakenForDelivery
FROM combined_table */


-- Teacher's answer 
--Use "ALTER TABLE", "UPDATE" etc.

-- so we need to change type's of some columns i guess
UPDATE combined_table SET order_date =  CONVERT(DATE,order_date,103) 
UPDATE combined_table SET Ship_Date =  CONVERT(DATE,Ship_Date,103)

-- We will add row
ALTER TABLE combined_table
ADD	DaysTakenForDelivery INT;

-- And we will update the table and we will put it into new created column

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(day, Order_Date, Ship_Date)

SELECT * 
FROM combined_table


--//////////////////////////////////

--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

SELECT TOP 1 Customer_Name, Order_Date, Ship_Date, DaysTakenForDelivery
FROM combined_table
ORDER BY DaysTakenForDelivery DESC;

SELECT TOP 1 FIRST_VALUE(customer_name) OVER(ORDER BY DaysTakenForDelivery DESC)FROM combined_table


SELECT MAX(DaysTakenForDelivery), Customer_Name
FROM combined_table
GROUP BY Customer_Name
HAVING MAX(DaysTakenForDelivery) = (SELECT MAX(DaysTakenForDelivery)
								    FROM combined_table
								    )

-- Teacher's answer

SELECT	Cust_id, Customer_Name, Order_Date, Ship_Date, DaysTakenForDelivery
FROM	combined_table
WHERE	DaysTakenForDelivery =(
								SELECT	MAX(DaysTakenForDelivery)
								FROM combined_table
								)
SELECT top 1 Customer_Name,Cust_id,DaysTakenForDelivery
FROM combined_table
order by DaysTakenForDelivery desc

SELECT MAX(DaysTakenForDelivery)
FROM combined_table

SELECT TOP 1 Customer_name ,Ord_id, DaysTakenForDelivery
FROM combined_table
ORDER BY DaysTakenForDelivery DESC

--////////////////////////////////


--5. Count the total number of unique customers in January / 
-- and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries

-- Count the total number of unique customers in January

SELECT COUNT(DISTINCT Cust_id) AS unique_customer_in_January
FROM combined_table
-- where MONTH(Order_Date ) = 1
WHERE DATENAME(MONTH,Order_Date) = 'January'

-- how many of them came back every month over the entire year in 2011

SELECT DATENAME(MONTH,order_date) AS month_name,
	   MONTH(order_date) AS month_number,  COUNT(cust_id) AS come_back 
FROM combined_table
WHERE cust_id IN (
				  SELECT DISTINCT Cust_id
				  FROM combined_table
				  WHERE MONTH(Order_Date ) = 1
				  )
AND YEAR(order_date ) = 2011
GROUP BY DATENAME(MONTH, order_date), MONTH(order_date)
ORDER BY month_number; --MONTH(order_date)

-- Teacher's answers

SELECT COUNT(DISTINCT Cust_id) AS Unique_Customer
FROM combined_table
WHERE YEAR(Order_Date) = 2011
AND MONTH(Order_Date) = 01

SELECT MONTH(Order_Date) AS [Month],
	   COUNT(DISTINCT Cust_id) AS COUNT_CUST
FROM combined_table AS A
WHERE
EXISTS (
		SELECT Cust_id
		FROM combined_table AS B
		WHERE A.Cust_id = B.Cust_id
		AND YEAR(Order_Date) = 2011
		AND MONTH(Order_Date) = 01
		)
AND YEAR(Order_date) = 2011
GROUP BY MONTH(Order_Date)

--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions

-- CTE table ile

WITH first_with AS (
					  SELECT * 
					  FROM (
							SELECT cust_id,Customer_Name, order_date, 
							ROW_NUMBER() OVER(partition by customer_name order by order_date) AS rownum1
							FROM combined_table
							) AS F
					  where F.rownum1 = 1
					  ),

third_with AS(
			  SELECT * 
			  FROM (
				    SELECT cust_id,Customer_Name, order_date, 
					ROW_NUMBER() OVER(partition by customer_name order by order_date ) AS rownum3
					FROM combined_table) AS F
					WHERE F.rownum3 = 3
					)

SELECT T.Customer_Name, 
	   DATEDIFF(D,f.Order_Date, T.Order_Date) AS elapsed_time_from_orders
FROM first_with AS F, third_with AS T
WHERE F.Cust_id = T.Cust_id
ORDER BY elapsed_time_from_orders DESC

-- VIEW ile

-- create first view
CREATE VIEW first_view AS  (							SELECT * 							FROM   (									SELECT cust_id,Customer_Name, order_date, 									ROW_NUMBER() OVER(partition by customer_name order by order_date) AS rownum1									FROM combined_table									) AS F							where F.rownum1 = 1							)-- crete third viewCREATE VIEW third_view AS	(							SELECT * 							FROM	(									SELECT cust_id,Customer_Name, order_date, 									ROW_NUMBER() OVER(partition by customer_name order by order_date ) AS rownum3									FROM combined_table									) AS F							WHERE F.rownum3 = 3							)

SELECT T.Customer_Name, 
	   DATEDIFF(D,f.Order_Date, T.Order_Date) AS elapsed_time_from_orders
FROM first_view AS F, third_view AS T
WHERE F.Cust_id = T.Cust_id
ORDER BY elapsed_time_from_orders DESC

-- Teacher's answer

SELECT Cust_id, MIN(Order_date) first_purchase
FROM combined_table
GROUP BY Cust_id;

--Use "MIN" with Window Functions

SELECT DISTINCT cust_id,
				order_date AS ThirdPurchase,
				DENSE_DATE,
				first_purchase,
				DATEDIFF(day, first_purchase, order_date) DAYS_ELAPSED
FROM (
	  SELECT	Cust_id, ord_id, order_DATE,
	  MIN (Order_Date) OVER (PARTITION BY cust_id) first_purchase,
	  DENSE_RANK () OVER (PARTITION BY cust_id ORDER BY Order_date) DENSE_DATE
	  FROM	combined_table
	  ) A
WHERE	DENSE_DATE = 3



--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions

-- 11 ve 14 ürünleri alan müþteriler

SELECT cust_id,Customer_Name
FROM combined_table
WHERE Prod_id = 'Prod_11'
INTERSECT
SELECT cust_id,Customer_Name
FROM combined_table
WHERE Prod_id = 'Prod_14'

-- 11 ve 14 ü alanlarýn aldýklarý toplam ürün sayýsý

CREATE VIEW total_cust_bought_11_14 AS  (
										 SELECT Prod_id, Cust_id, Customer_Name, COUNT(Order_ID) as number_of_orders
										 FROM combined_table
										 WHERE Cust_id IN (
														   SELECT cust_id
														   FROM combined_table
														   WHERE Prod_id = 'Prod_11'
														   INTERSECT
														   SELECT Cust_id
														   FROM combined_table
														   WHERE Prod_id = 'Prod_14'
														   )
										 GROUP BY Prod_id, Cust_id, Customer_Name
										 )
SELECT SUM(number_of_orders) -->210
FROM total_cust_bought_11_14

-- Hem 14'ü hem de 11'i ayný anda alan müþterilerin, sadece (hem 14'ü ve hem 11'i aldýklarý sayý) -->17

SELECT SUM(A.number_of_orders)
FROM (
	  SELECT Customer_Name, number_of_orders
	  FROM total_cust_bought_11_14
	  WHERE Prod_id = 'Prod_11'
	  INTERSECT
	  SELECT Customer_Name, number_of_orders
	  FROM total_cust_bought_11_14
	  WHERE Prod_id = 'Prod_14'
	 ) AS A

-- 17/210 = 0,080952380952381


-- Teacher's Answer
WITH T1 AS (
SELECT	cust_id,
		SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity else 0 end ) as P11,
		SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity else 0 end ) as P14,
		SUM(order_quantity) TOTAL_Prod
FROM combined_table
GROUP BY cust_id
HAVING SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity else 0 end ) >=1  AND
		SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity else 0 end ) >=1
)
SELECT
		cust_id,
		P11,
		P14,
		TOTAL_Prod,
		cast (1.0*p11/TOTAL_Prod as numeric(3,2)) AS RATIOP11,
		cast (1.0*p14/TOTAL_Prod as numeric(3,2)) AS RATIOP14
FROM T1
--/////////////////



--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. 
--(For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
create view tablo as 
select Cust_id, YEAR(Order_Date) as year, MONTH(Order_Date) as month
from combined_table;

select * from tablo

-- Teacher's answer

CREATE VIEW CUSTOMER_LOGS AS  (
								SELECT Cust_id,
									   YEAR(Order_Date) as [Year], 
									   MONTH(Order_Date) as [Month]
								FROM combined_table
								--ORDER BY 1,2,3
								);

--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.

create view number_of_monthly_visits as
select Cust_id, month(Order_Date) as month ,count(MONTH(Order_Date)) as number_of_visit
from combined_table
group by Cust_id, month(Order_Date)

-- Teacher's answer

CREATE VIEW Number_of_visit AS (
								SELECT Cust_id, [Year], [Month], COUNT(*) AS total_visit
								FROM CUSTOMER_LOGS
								GROUP BY Cust_id, [Year], [Month]
								)

SELECT Cust_id, [Year], [Month], COUNT(*) AS total_visit
FROM Number_of_visit
GROUP BY Cust_id, [Year], [Month]

SELECT * 
FROM Number_of_visit





--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
create view next_month_visit as 
select Cust_id,month,DENSE_RANK() over(partition by cust_id order by month) as visit_rank
from tablo

select distinct visit_rank, Cust_id,month,
lead(visit_rank) over(partition by cust_id order by month) from next_month_visit
where visit_rank > 1

-- Teacher's answer
CREATE VIEW Next_visit AS
SELECT *,
		LEAD (Current_Month) OVER (PARTITION BY cust_id ORDER BY Current_Month) NEXT_VISIT_MONTH
FROM
	(SELECT	*,
			DENSE_RANK() over (ORDER BY [YEAR],[MONTH]) AS Current_Month
	FROM Number_of_visit
	--ORDER BY 1,2,3
	) A


--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

select Cust_id, Customer_Name,Order_Date
from combined_table
group by  Cust_id, Customer_Name,Order_Date
having COUNT(Cust_id) > 1

-- Teacher's Answer

CREATE VIEW time_gaps AS
SELECT *,
		NEXT_VISIT_MONTH-Current_Month AS TIME_GAP
FROM Next_visit


--/////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.

-- Teacher's Answer
SELECT cust_id, avg_time_gap,
		CASE WHEN avg_time_gap = 1 THEN 'retained'
			WHEN avg_time_gap > 1 THEN 'irregular'
			WHEN avg_time_gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN DATA' END CUST_LABELS
FROM
		(
		SELECT Cust_id, AVG(TIME_GAP) avg_time_gap
		FROM	time_gaps
		GROUP BY Cust_id
		) A
ORDER BY 2 DESC;




--/////////////////////////////////////




--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

-- Teacher's Answer
 SELECT DISTINCT [YEAR],
		[MONTH],
		NEXT_VISIT_MONTH AS retention_month,
		COUNT (Cust_id) OVER (PARTITION BY NEXT_VISIT_MONTH) AS RETENTION_SUM_MONTHLY
 FROM time_gaps
 WHERE TIME_GAP = 1



--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

-- Teacher's Answer

-- DROP VIEW CURRENT_NUM_OF_CUST
CREATE VIEW CURRENT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY CURRENT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
SELECT *
FROM	CURRENT_NUM_OF_CUST
---
--DROP VIEW NEXT_NUM_OF_CUST
CREATE VIEW NEXT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
WHERE	time_gaps = 1
AND		CURRENT_MONTH > 1


SELECT DISTINCT
		B.[YEAR],
		B.[MONTH],
		B.CURRENT_MONTH,
		B.NEXT_VISIT_MONTH,
		1.0 * B.RETENTITON_MONTH_WISE / A.RETENTITON_MONTH_WISE RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH

---///////////////////////////////////
--Good luck!