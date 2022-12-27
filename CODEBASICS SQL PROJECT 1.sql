                                /* ATLIQ HARDWARE */

/* DIVISION  = P&A (peripheral and accessory) ,PC, N&S (Networking and storage)
   REGION = APAC(asia pacific) EU (european union) NA (north america) LATAM (latin america) */
   
   /* TASK 1 
   To generate report of individual product sales (aggregated on monthly basis on product code level ) for 
   CROMA INDIA in FY 2021 the report must include the following
   month
   variant
   Sold quantity
   Gross Price per item
   Gross price total*/
   
USE gdb041;

SELECT * FROM dim_customer WHERE customer LIKE "%croma%";

SELECT * FROM fact_sales_monthly
WHERE customer_code=90002002 AND YEAR(date)=2021    /* customer_code=90002002 this of CROMA*/
ORDER BY date DESC;

SELECT DATE_ADD("2020-09-01",INTERVAL 4 MONTH);     /* this is fiscal year concept for Atliq it is from SEPT to AUG */

SELECT * FROM fact_sales_monthly
WHERE customer_code=90002002 AND        /* We want data for FY 2021 but for Atliq  the year 2021  starts from SEP 2020 and ends on AUG 2021 */
YEAR(DATE_ADD(date,INTERVAL 4 MONTH))=2021       
ORDER BY date ;

/* so now i created a user defined function called get_fiscal_year and now will use thaat in my query 
DETERMINISTIC = the output will always be same for given input (example our case kabi bhi daalo 4 month hi add hoga)
NON DETERMINISTIC = output will differ depending upon the time of execution even with same input
(example last month sales*/

SELECT * FROM fact_sales_monthly
WHERE customer_code=90002002 AND        
get_fiscal_year (date)=2021       
ORDER BY date ;

/* OUR TASK 1 DONE */
SELECT s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND((s.sold_quantity * g.gross_price),2) as gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p
ON s.product_code = p.product_code                 /* nothing difficult we are just joining tables based on requirements */
JOIN fact_gross_price g
ON s.product_code = g.product_code AND g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code=90002002 AND        
get_fiscal_year (date)=2021       
ORDER BY date
LIMIT 1000000;

   /* TASK 2
   As a product owner I need an aggregate monthly gross sales report for CROMA INDIA 
   The Report should include
   1. Month
   2. Total gross sales amount to Croma India in this month
   */
 ----------------------------------------------------------------------------------------------------------------------------------------  
   /* OUR TASK 2 DONE */
   SELECT s.date,ROUND(SUM(g.gross_price * s.sold_quantity),2) as gross_price_total
   FROM fact_sales_monthly s
   JOIN fact_gross_price g
   ON
     g.product_code = s.product_code AND 
     g.fiscal_year = get_fiscal_year (s.date)
   WHERE customer_code=90002002
   GROUP BY s.date
   ORDER BY s.date ASC;
   
  ---------------------------------------------------------------------------------------------------------------------------------------- 
    /* TASK 3
   Generate a yearly report for Croma India where there are two columns
   1. Fiscal year
   2. Total Gross Sales amount in that year
   */
   
    /* OUR TASK 3 DONE */
   SELECT get_fiscal_year(s.date) as Fiscal_Year,ROUND(SUM(g.gross_price * s.sold_quantity),2) as gross_price_total
   FROM fact_sales_monthly s
   JOIN fact_gross_price g
   ON
     g.product_code = s.product_code AND 
     g.fiscal_year = get_fiscal_year (s.date)
   WHERE customer_code=90002002
   GROUP BY Fiscal_Year
   ORDER BY s.date ASC;
   
 ----------------------------------------------------------------------------------------------------------------------------------------  
     
    /* CONCEPT OF STORED PROCEDURE
   Stored Procedure is a way to automate repeated tasks such as creating same report for different customers
   The Query that needs to be executed in a stored procedure is copied between BEGIN and END clause
   
   FUNCTIONS returns you a single values
   STORE PROCEDURE  can return anything 1 value, many values ,tables
   */
   
   /* you can call stored procedure from schema section or just by using this query */
   
   call gdb041.get_monthly_gross_sales_for_customer(90002002);
   
     /* Now lets say we have different customer code for same customer  */
SELECT * FROM dim_customer
WHERE customer LIKE "%amazon%" AND market = "india";

/* we can use find_in_set to deal with 2 customer codes */
SELECT FIND_IN_SET(90002002,"90002002,90002008");
/* output 1 means 1st is matching out of 2 from list we passed */

SELECT FIND_IN_SET(90002008,"90002002,90002008");
/* output 2 means 2nd is matching out of 2 from list we passed */
   
 SELECT FIND_IN_SET(90002001,"90002002,90002008");
/* output 0 means no match out of 2 from list we passed */  

   /* MARKET BADGE STORED PROCEDURE
   Create a Stored Procedure that can determine market badge based o following logic
   If total sold quantity > 5 million that market is considered GOLD else it is Silver
   
   My input will be 
   market
   fiscal year
   
   OUTPUT
   market badge
   */
   
   SELECT SUM(sold_quantity) as total_qty
   FROM fact_sales_monthly s
   JOIN dim_customer c
   ON s.customer_code = c.customer_code
   WHERE get_fiscal_year(s.date)=2021 and c.market ="india"
   GROUP BY c.market;
   
   /* BENEFITS OF STORED PROCEDURE 
  1) CONVENIENCE
  2) SECURITY ( you can only give read only acces to product managers)
  3) MAINTAINABILITY (you can call stored procedure in jupiter notebook)
  4) PERFORMANCE
  5) DEVELOPER PRODUCTIVITY
    */
   
----------------------------------------------------------------------------------------------------------------------------------------   
   
   /* TASK 4  Find TOP MARKET in terms of Net sales for FY2021
   
                   Gross price 
                 - pre_invoice_deduction
                 --------------------------
                   Net Invoice Sale
				 - post invoive deduction
                 ----------------------------
				   Net sales
                   */
                   
                   
  /* first lets bring gross_sales and pre_invoice_discount_pct in one table */   
  
SELECT s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND((s.sold_quantity * g.gross_price),2) as gross_price_total,
pre.pre_invoice_discount_pct
FROM fact_sales_monthly s                         
JOIN dim_product p                                                                   /* joined fact_sales_monthly and dim_product */
    ON s.product_code = p.product_code                 
JOIN fact_gross_price g                                                             /* joined above big table and  fact_gross_price */
    ON s.product_code = g.product_code AND g.fiscal_year = get_fiscal_year(s.date)
JOIN fact_pre_invoice_deductions pre                                                /* joined above big table and  fact_Pre_invoice_deduction */
    ON pre.customer_code = s.customer_code AND pre.fiscal_year = get_fiscal_year(s.date)
WHERE        
get_fiscal_year (date)=2021       
ORDER BY date                              /* DURATION 18sec  FETCH TIME 1.5 sec */
LIMIT 1000000;                              
                   
 /* LETS OPTIMIZE OUR QUERY
    DURATION is the time  taken for a query to get executed
    FETCH is the time taken to retrieve the data from database server 
    EXPLAIN ANALYZE clause will help one to understand the query performance time */
                   
   
EXPLAIN ANALYZE                  
SELECT s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND((s.sold_quantity * g.gross_price),2) as gross_price_total,
pre.pre_invoice_discount_pct
FROM fact_sales_monthly s                         
JOIN dim_product p                                                                   
    ON s.product_code = p.product_code                 
JOIN fact_gross_price g                                                             
    ON s.product_code = g.product_code AND g.fiscal_year = get_fiscal_year(s.date)
JOIN fact_pre_invoice_deductions pre                                                
    ON pre.customer_code = s.customer_code AND pre.fiscal_year = get_fiscal_year(s.date)
WHERE        
get_fiscal_year (date)=2021       
ORDER BY date                              
LIMIT 1000000;  

/* We found that get_fiscal_year function is taken time because it needs to iterate over 1.4 M rows
  so we create a new dim table  and will get date from that */
  
 /* SOLUTION 1 */
 SELECT s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND((s.sold_quantity * g.gross_price),2) as gross_price_total,
pre.pre_invoice_discount_pct
FROM fact_sales_monthly s                         
JOIN dim_product p                                                                   
     ON s.product_code = p.product_code
JOIN dim_date dt  
     ON dt.calendar_date = s.date                             /* we are joining here our newly created dim_date column and repalcing get_fiscal_year() function */
JOIN fact_gross_price g                                                             
ON s.product_code = g.product_code AND g.fiscal_year =dt.fiscal_year
JOIN fact_pre_invoice_deductions pre                                                
ON pre.customer_code = s.customer_code AND pre.fiscal_year = dt.fiscal_year
WHERE        
dt.fiscal_year=2021       
ORDER BY date                               /* DURATION 8.39sec  FETCH TIME 1.6 sec so our time is reduced by half */
LIMIT 1000000;  
   
 /* SOLUTION 2 */
/* we will not create any extra dim_table because in that then we have to do join lets optimise further what
we can do is in fact_sales_monthly we can directly generate fiscal_year from date column */

SELECT s.date,s.fiscal_year,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND((s.sold_quantity * g.gross_price),2) as gross_price_total,
pre.pre_invoice_discount_pct
FROM fact_sales_monthly s                         
JOIN dim_product p                                                                   
     ON s.product_code = p.product_code
JOIN fact_gross_price g                                                             
     ON s.product_code = g.product_code AND g.fiscal_year =s.fiscal_year
JOIN fact_pre_invoice_deductions pre                                                
     ON pre.customer_code = s.customer_code AND pre.fiscal_year = s.fiscal_year
WHERE        
s.fiscal_year=2021       
ORDER BY date                               /* DURATION 0.67sec  FETCH TIME 4.12 sec so our time is reduced so much */
LIMIT 1000000;  
----------------------------------------------------------------------------------------------------------------------------------------
  /* CONCEPT OF VIEW 
   Views are virtual tables which provide you a traansformed table on the fly without taking up the storage space
   CTE are like views but thet are temporary table restricted to particular session
   */
   
   SELECT * FROM sales_preinv_discount;
  /* now this is our virtual_table we can use this anywhere */ 
 
 /* lets calculate net_invoice_sales */
SELECT * ,ROUND((gross_price_total - (gross_price_total * pre_invoice_discount_pct)),2) as net_invoice_sales
FROM sales_preinv_discount;

 /* lets calculate post_invoice_deduction 
 and make this new table as view */
 
SELECT * ,ROUND((gross_price_total - (gross_price_total * pre_invoice_discount_pct)),2) as net_invoice_sales,
      (po.discounts_pct + po.other_deductions_pct) as post_invoice_discount_pct
FROM sales_preinv_discount s
JOIN fact_post_invoice_deductions po
ON 
   s.date=po.date AND 
   s.product_code=po.product_code AND
   s.customer_code = po.customer_code;
   
SELECT * FROM sales_postinv_discount;

 /* lets calculate net_sales 
 and make this new table as view */
 
 SELECT *,
        (1-post_invoice_discount_pct)*net_invoice_sales AS net_sales
  FROM sales_postinv_discount;
  
  SELECT* FROM net_sales;
  
  /* Top 5 Market net sales in year 2021 
  and create a stored procedure */
  
  SELECT 
        market,
        ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
  FROM net_sales
  WHERE fiscal_year = 2021
  GROUP BY market
  ORDER BY net_sales_millions DESC
  LIMIT 5;
  
    /* Top 5 customers net sales in year 2021 
  and create a stored procedure */
  
  SELECT 
        c.customer,
        ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
  FROM net_sales n
  JOIN dim_customer c
      ON n.customer_code = c.customer_code
  WHERE fiscal_year = 2021
  GROUP BY c.customer
  ORDER BY net_sales_millions DESC
  LIMIT 5;
  ----------------------------------------------------------------------------------------------------------------------------------------   
                                          /* WINDOW FUNCTION */
/* A window function performs a calculation across a specified set of table rows with reference to the current row
  OVER() clause is a window function which will execute the aggregation formula across a specified set of rows
  To specify the set of rows one can use the partition clause inside over clause and specify the category name */
  
  /* New dataset named random_tables uploaded to understand window concept */
  
  USE random_tables;
  SELECT * FROM expenses;
  
  SELECT * ,
         amount*100/sum(amount) as pct FROM expenses
  ORDER BY category;
  /* problem with above query is it returns single output but we want percent for every row 
  window is set of rows and over () clause is used to define window
  */
  
  SELECT * ,
         amount*100/sum(amount)  over() as pct FROM expenses
  ORDER BY category;
  
  /* lets say i want to get percent not with respect to total expense but w.r.t to each category */
  
   SELECT * ,
         amount*100/sum(amount)  over(partition by category) as pct FROM expenses
  ORDER BY category;
  
  /* for food total = 6000+2700+400+2700 =11800
     for A2B restaurant = 6000 *100/11800= 50.84 %  
     this is how partition work
  when you have partition by   Each category acts as a new window
  when only over() is mentioned whole set of rows is one window
     */
     
/* lets say we want to display cumulative expense on given category */

SELECT *,
       SUM(amount) OVER (PARTITION BY category ORDER BY date ) as total_expense_till_date
FROM expenses
ORDER BY category,DATE;

----------------------------------------------------------------------------------------------------------------
/* As a product owner ,I want to see a bar chart report for FY=2021 for top 10 markets by % net sales */
  USE gdb041;
  
  SELECT 
        c.customer,
        ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
  FROM net_sales s
  JOIN dim_customer c
      ON s.customer_code = c.customer_code
  WHERE s.fiscal_year = 2021
  GROUP BY c.customer
  ORDER BY net_sales_millions DESC;
  
  /* now for % we need to use CTE because we cannot use derived column directly */
  
WITH cte1 as (
     SELECT 
        c.customer,
        ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
  FROM net_sales s
  JOIN dim_customer c
      ON s.customer_code = c.customer_code
  WHERE s.fiscal_year = 2021
  GROUP BY c.customer)
  
  SELECT *,
         net_sales_millions*100/SUM(net_sales_millions) over() as pct
  FROM cte1
  ORDER BY net_sales_millions DESC;
-------------------------------------------------------------------------------------------------
  
/* As a product owner ,I want to see region wise % net sales breakdown by customers in a respective region*/  

WITH cte1 as (
     SELECT 
        c.customer,
        c.region,
        ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
  FROM net_sales s
  JOIN dim_customer c
      ON s.customer_code = c.customer_code
  WHERE s.fiscal_year = 2021                  /* we want % net_sales which can derived from net_sales_millions*/
  GROUP BY c.customer,c.region)              /* but we cannot use derived column to create another derived column */
											/* so we create CTE and from that we can get % net_sales */
  SELECT *,
         net_sales_millions *100/SUM(net_sales_millions) OVER (PARTITION BY region) as pct_share_region
  FROM cte1
  ORDER BY region,net_sales_millions DESC;

/*-------------ROW NUMBER , RANK, DENSE RANK --------------------------------- */
 /* ROW NUMBER = It gives unique number
 RANK = It will skip ranks if the ranks are same
 DENSE RANK = Does not skip any rank */
 
 USE random_tables;
 
 SELECT *,
          ROW_NUMBER() OVER(partition by category order by amount desc) as "row number",
          RANK() OVER(partition by category order by amount desc) as "rank",
		  DENSE_RANK() OVER(partition by category order by amount desc) as "dense rank"
 FROM expenses
 ORDER BY category;
 
 /* Lets say i want Top 2 in each category */
 
WITH cte1 AS(
  SELECT *,
          ROW_NUMBER() OVER(partition by category order by amount desc) as rn, 
          RANK() OVER(partition by category order by amount desc) as rnk,
		  DENSE_RANK() OVER(partition by category order by amount desc) as drnk
 FROM expenses
 ORDER BY category)
 
 SELECT * FROM cte1 WHERE drnk <=2;
 
  /* concept of row number rank dense rank using different table */
  
 SELECT *,
          ROW_NUMBER() OVER(order by marks desc) as rn, 
          RANK() OVER(order by marks desc) as rnk,
		  DENSE_RANK() OVER(order by marks desc) as drnk
 FROM student_marks;
---------------------------------------------------------------------------------------------------------------- 
 /* Write a stored proc for getting TOP products in each division by their quantity sold in given financial year */
 
 USE gdb041;
 WITH cte1 AS ( SELECT
          p.division,
          p.product,                                       /*  we can use one cte inside other cte */
          SUM(sold_quantity) AS total_qty
	FROM fact_sales_monthly s
    JOIN dim_product p
	     ON p.product_code = s.product_code
	WHERE fiscal_year =2021
    GROUP BY p.product),
cte2 AS(   
		SELECT *,DENSE_RANK() OVER(partition by division order by total_qty DESC)  as drnk
        FROM cte1
        )
 SELECT * FROM cte2 WHERE drnk<=3;  
 
 /* EXERCISE On row_number,rank,dense_rank
    Retrieve top 2 markets in every region by their gross_sales_amount in fy=2021 */
 
 WITH cte1 AS (
	SELECT c.market,
           c.region,
           ROUND(SUM(gross_price_total)/1000000,2) as gross_sales_million
	FROM net_sales s
    JOIN dim_customer c
    ON c.customer_code=s.customer_code
    WHERE fiscal_year =2021
    GROUP BY c.market
    ORDER BY gross_sales_million DESC
           ),
	cte2 AS (
         SELECT *,dense_rank() over(partition by region order by gross_sales_million desc) as drnk
         FROM cte1
             )
	SELECT * FROM cte2
    WHERE drnk<=2;
  
 ---------------------------------------------------------------------------------------------------------------------------------------
 
 
 
  

