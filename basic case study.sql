 
 -----Basic Case Study

 ---using the database [db_SQLCaseStudies]
 Use db_SQLCaseStudies;

 ---get the data present in customer table
  select top 1 * from Customer;
  select top 1 * from prod_cat_info;
  select top 1 * from Transactions;

  
---1) TOTAL NO. OF ROWS IN EACH 3 TABLES

	select count (*) as cnt_of_rows from prod_cat_info
	union all
	select count(*) from Customer
	union all
	select count (*) from Transactions

--2) TOTAL NO. OF TRANSACTIONS THAT HAVE A RETURN


	SELECT 
	COUNT(transaction_id) AS RETURN_TRANSACTION
	FROM TRANSACTIONS
	WHERE QTY < 0;

---3) CONVERT DATE VARIABLES INTO VALID DATE FORMATS

	ALTER TABLE CUSTOMER
	ALTER COLUMN DOB DATE

	ALTER TABLE TRANSACTIONS
	ALTER COLUMN TRAN_DATE DATE

---4) TIME RANGE OF TRANSACTION DATA AVAILABLE FOR ANALYSIS
----FOR NO. OF YEAR, MONTH AND DAYS

	SELECT MAX(TRAN_DATE) AS LAST_TRAN,
	MIN(TRAN_DATE) AS FIRST_TRAN,
	DATEDIFF(YEAR, MIN(TRAN_DATE),MAX(TRAN_DATE)) AS NO_OF_YEARS,
	DATEDIFF(MONTH, MIN(TRAN_DATE),MAX(TRAN_DATE)) AS NO_OF_MONTHS,
	DATEDIFF(DAY, MIN(TRAN_DATE),MAX(TRAN_DATE)) AS NO_OF_DAYS
	FROM Transactions

---5)PRODUCT CATEGORY TO WHICH 'DIY' SUBCATEGORY BELONGS TO

	SELECT PROD_CAT
	FROM PROD_CAT_INFO
	WHERE PROD_SUBCAT LIKE '%DIY%'
	
	-------OTHER WAY----------

	SELECT PROD_CAT
	FROM PROD_CAT_INFO
	WHERE PROD_SUBCAT LIKE 'DIY'


----DATA ANALYSIS
----1) CHANNEL MOST FREQUENTLY USED FOR TRANSACTIONS - eShop

	SELECT TOP 1 STORE_TYPE,
	COUNT(TRANSACTION_ID) AS CNT_CHANNELS
	FROM Transactions
	GROUP BY Store_type 
	ORDER BY CNT_CHANNELS DESC

----2) COUNT OF MALE AND FEMALE CUSTOMERS IN DATABASE

	SELECT GENDER,
	COUNT(GENDER) CNT
	FROM CUSTOMER
	WHERE GENDER IS NOT NULL
	GROUP BY GENDER


---3) WHICH CITY HAVE MAXIMUM NUMBER OF CUSTOMER AND HOW MANY

	SELECT TOP 1 city_code,
	COUNT(customer_Id) AS NO_OF_CUST
	FROM CUSTOMER
	GROUP BY city_code
	ORDER BY NO_OF_CUST DESC

---4)COUNT OF SUBCATGORIES UNDER BOOKS CATEGORY

	SELECT PROD_CAT,
	COUNT(prod_subcat) AS CNT_SUBCATEGORY
	FROM prod_cat_info
	WHERE prod_cat = 'BOOKS'
	GROUP  BY prod_cat

-----ANOTHER METHOD
	SELECT
	COUNT(prod_subcat) AS CNT_SUBCATEGORY
	FROM prod_cat_info
	WHERE prod_cat = 'BOOKS'

---5)MAXIMUM QUANTITY OF PRODUCT EVER ORDERED

	SELECT MAX(QTY) AS MAX_QUAN
	FROM Transactions

---6)NET TOTAL REVENUE GENERATED IN 'ELECTRONICS' AND 'BOOKS' CATEGORIES

	SELECT PROD_CAT,
	SUM(total_amt) AS TOTAL_REVENUE
	FROM prod_cat_info AS P
	INNER JOIN Transactions AS T 
	ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
	WHERE prod_cat IN ('ELECTRONICS','BOOKS')
	GROUP BY prod_cat

---7)COUNT OF CUSTOMERS HAVING >10 TRANSACTIONS , EXCLUDING RETURNS

	 SELECT COUNT(A.cust_id) AS CNT
	 FROM(SELECT CUST_id,
	 COUNT(transaction_id) AS CNT_OF_TRANS
	 FROM Transactions
	 WHERE QTY > 0
	 GROUP BY cust_id
	 HAVING COUNT(transaction_id)> 10) AS A



 ---8)COMBINED REVENUE EARNED FROM ELECTRONICS AND CLOTHING CATEGORIES FROM FLAGSHIP STORES

	 SELECT 
	 SUM(total_amt) AS COMBINED_REVENUE
	 FROM prod_cat_info AS P
	 INNER JOIN Transactions AS T
	 ON P.PROD_CAT_CODE = T.PROD_CAT_CODE AND P.PROD_SUB_CAT_CODE = T.PROD_SUBCAT_CODE
	 WHERE PROD_CAT IN ('Electronics','Clothing') AND STORE_TYPE = 'Flagship store'

 --9)TOTAL REVENUE GENERATED BY 'MALE' CUSTOMERS IN 'ELECTRONICS CATEGORY'.
 ---OUTPUT SHOULD DISPLAY TOTAL REVENUE BY PROD_SUBCAT

	 SELECT 
	PROD_SUBCAT,
	SUM(total_amt) AS TOTAL_REVENUE
	FROM Customer AS C
	INNER JOIN Transactions AS T ON C.customer_Id = T.cust_id
	INNER JOIN prod_cat_info AS P
	ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
	WHERE PROD_CAT = 'ELECTRONICS' AND GENDER = 'M'
	GROUP BY PROD_SUBCAT



--10)PERCENTAGE OF SALES AND RETURNS BY PROD_SUB CATEGORY , DISPLAY ONLY TOP 5 SUBCATEGORIES IN TERMS OF SALES AND RETURNS.

	---percentage of sales by top 5 sub category

	select top 5 prod_subcat_code , sum(total_amt)*100/(select sum(total_amt) from Transactions) as [SALE PERCENTAGE]  
	from Transactions
	where total_amt > 0
	group by prod_subcat_code
	order by [SALE PERCENTAGE] desc
	
	---percentage of returns by top 5 sub category

	select prod_subcat_code , sum(abs(total_amt))*100/(select sum(total_amt) from Transactions) as [RETURN PERCENTAGE] 
	from Transactions
	where total_amt < 0
	group by prod_subcat_code
	order by [RETURN PERCENTAGE] desc

 ----11) NET TOTAL REVENUE GENERATED BY CONSUMERS AGED BETWEEN 25 TO 35 YEARS 
 --IN LAST 30 DAYS OF TRANSACTIONS FROM MAXIMUM TRANSACTION DATE AVAILABLE IN THE DATA
 
	 SELECT SUM(A.TOTAL_REVENUE) AS NET_TOT_REVENUE
	 FROM
	 (SELECT customer_id,
	 SUM(total_amt) AS TOTAL_REVENUE
	 FROM CUSTOMER AS C
	 LEFT JOIN Transactions AS T
	 ON C.customer_Id = T.cust_id
	 WHERE  DATEDIFF(YEAR,DOB,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS AS T))  BETWEEN 25 AND 35
	 GROUP BY customer_Id, DOB, TRAN_DATE
	 HAVING DATEDIFF (DAY,tran_date,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS AS T)) < 30
	 ) AS A


 ----12) WHICH PRODUCT CATEGORY HAS SEEN THE MAX VALUE OF RETURNS IN THE LAST 3 MONTHS OF TRANSACTIONS
     
 
	 SELECT TOP 1 PROD_CAT, ABS(SUM(QTY)) AS CNT_RETURNS
	 FROM prod_cat_info AS P
	 INNER JOIN Transactions AS T
	 ON P.PROD_CAT_CODE = T.PROD_CAT_CODE AND P.PROD_SUB_CAT_CODE = T.PROD_SUBCAT_CODE
	 WHERE QTY <0 AND DATEDIFF (MONTH,TRAN_DATE,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS AS T)) < 3
	 GROUP BY PROD_CAT
	 ORDER BY CNT_RETURNS DESC
 
 
-----13) WHICH STORE TYPE SELLS THE MAXIMUM PRODUCTS, BY VALUE OF SALES AMOUNT AND BY QUANTITY SOLD


	SELECT STORE_TYPE,
	SUM(QTY) AS QUANTITY_SOLD,
	SUM(total_amt) AS SALES_AMOUNT
	FROM Transactions
	WHERE QTY > 0
	GROUP BY STORE_TYPE
	ORDER BY SALES_AMOUNT DESC


-----14)CATEGORIES FOR WHICH AVERAGE REVENUE IS ABOVE THE OVERALL AVERAGE

	SELECT *
	FROM(
	SELECT PROD_CAT,
	AVG(TOTAL_AMT) AS AVG_REVENUE
	FROM prod_cat_info AS P
	INNER JOIN Transactions AS T
	ON P.PROD_CAT_CODE = T.PROD_CAT_CODE AND P.PROD_SUB_CAT_CODE = T.PROD_SUBCAT_CODE
	GROUP BY prod_cat
	HAVING AVG(TOTAL_AMT) > (SELECT AVG(TOTAL_AMT) FROM Transactions) ) AS A


-----15) FIND AVERAGE AND TOTAL REVENUE BY EACH SUBCATEGORY FOR CATEGORIES 
--WHICH ARE AMONG TOP 5 CAEGORIES IN TERMS OF QUANTITY SOLD.

	SELECT PROD_CAT, PROD_SUBCAT, AVG(TOTAL_AMT) AS AVERAGE_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_REVENUE_SUBCAT
	FROM TRANSACTIONS T INNER JOIN prod_cat_info P
	ON P.PROD_CAT_CODE = T.PROD_CAT_CODE AND P.PROD_SUB_CAT_CODE = T.PROD_SUBCAT_CODE
	WHERE PROD_CAT IN
	(SELECT TOP 5 prod_cat
	FROM prod_cat_info AS P
	INNER JOIN Transactions AS T
	ON P.PROD_CAT_CODE = T.PROD_CAT_CODE AND P.PROD_SUB_CAT_CODE = T.PROD_SUBCAT_CODE
	GROUP BY prod_cat
	ORDER BY  SUM(QTY) DESC)
	GROUP BY  P.PROD_CAT,P.PROD_SUBCAT

