                                                              /* SUPPLY CHAIN DOMAIN */
                                                              
  /* We are joining 2 tables fully but in mysql there is no full outer join we need to union using LEFT and RIGHT JOIN */  

CREATE TABLE fact_act_est(
SELECT
      s.date as date,
      s.fiscal_year as fiscal_year,
      s.product_code as product_code,
      s.customer_code as customer_code,
      s.sold_quantity as sold_quantity,
      f.forecast_quantity as forecast_quantity
FROM
    fact_sales_monthly s 
LEFT JOIN fact_forecast_monthly f
USING (date,customer_code,product_code)

UNION

SELECT
      f.date as date,                                /* THIS query might take time it took me around 600 sec */
      f.fiscal_year as fiscal_year,                  /* If get msg of  lost connection to mysql server */
      f.product_code as product_code,                /*go to edit - prefrences- sql editor - and change all dbms time to 700 sec */
      f.customer_code as customer_code,
      s.sold_quantity as sold_quantity,
      f.forecast_quantity as forecast_quantity
FROM
    fact_sales_monthly s 
RIGHT JOIN fact_forecast_monthly f
USING (date,customer_code,product_code)
);

select*from fact_act_est;

----------------------------------------------------------------------------------------------------------------------------------------
                                                   /* TRIGGERS (concept more useful for data engineers)*/ 
/* Lets say you have two tables fact_sales_monthy
	                            fact_forecast_monthly
      NOW as you have seen in above case we have joined these two tables to form new table called fact_act_est
      so now when we will add new records in fact_sales_monthly and fact_forecast_monthly it should get updated automatically
      in fact_act_est during such time we can create a TRIGGER so that our manual work is reduced
	       you can create triggers for BEFORE INSERT  AFTER INSERT
									   BEFORE UPDATE  AFTER UPDATE
                                       BEFORE DELETE  AFTER DELETE
	MAJOR DISADVANTAGE OF TRIGGERS is it is hard to debug like you have some internal triggers and it automatically gets updated etc
    COMMON USECASES OF TRIGGERS
    To create aggregated / derived data
    Create historical update logs
    Data Validation
    */

-------------------------------------------------------------------------------------------------------------------------------------
                                          /* EVENTS (concept more useful for data engineers)*/
/* 
Events are nothing but bunch of SQL code which will run on your database on time you have defined automatically.

One can create an event to perform various actions and deleting session logs is one of them .

Usecase
1) DELETING old data from database at specified interval of time
2) Database Schedule and maintenance
3)Generating aggregated data ( you can dump data into your data warehouse from database at regular intervals )
4) CLEAR LOGS
*/
------------------------------------------------------------------------------------------------------------------------------------
/* Task to create a report requested by manager */

WITH forecast_err_table as(
		SELECT 
             s.customer_code,
			 SUM(s.sold_quantity) as total_sold_qty,
             SUM(s.forecast_quantity) as total_forecast_qty,
			 SUM((forecast_quantity - sold_quantity)) as net_err,
			 SUM((forecast_quantity - sold_quantity))*100/SUM(forecast_quantity)as net_err_pct,
			 SUM(ABS(forecast_quantity - sold_quantity)) as abs_err,
			 SUM(ABS(forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as abs_err_pct
		 FROM fact_act_est s
		 WHERE s.fiscal_year=2021
		 GROUP BY customer_code)
         
SELECT e.* ,
       c.customer,
       c.market,
       
       IF(abs_err_pct>100,0,100-abs_err_pct) as forecast_accuracy
FROM forecast_err_table e
JOIN dim_customer c
USING (customer_code)
ORDER BY forecast_accuracy desc;

/* TEMPORARY TABLE IS LIKE CTE but the only difference is temporary table can be used at multiple places  in single session of SQL
   while CTE is valid only within the scope of sql statement 
   This temporary table is created in memory you cannot see this in schema but its validity is only till one session
   lets say you turn off your computer  and again comeback then this table will be gone*/
  
  CREATE TEMPORARY TABLE forecast_err_table 
		SELECT 
             s.customer_code,
			 SUM(s.sold_quantity) as total_sold_qty,
             SUM(s.forecast_quantity) as total_forecast_qty,
			 SUM((forecast_quantity - sold_quantity)) as net_err,
			 SUM((forecast_quantity - sold_quantity))*100/SUM(forecast_quantity)as net_err_pct,
			 SUM(ABS(forecast_quantity - sold_quantity)) as abs_err,
			 SUM(ABS(forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as abs_err_pct
		 FROM fact_act_est s
		 WHERE s.fiscal_year=2021
		 GROUP BY customer_code;
         
/* now you can use this table in below expression to get desired result */

SELECT e.* ,
       c.customer,
       c.market,
       
       IF(abs_err_pct>100,0,100-abs_err_pct) as forecast_accuracy
FROM forecast_err_table e    /* temporary table */
JOIN dim_customer c
USING (customer_code)
ORDER BY forecast_accuracy desc;

--------------------------------------------------------------------------------------------------------------------------------
  /* DIFFERENCE BETWEEN SUBQUERY CTE VIEW TEMPORARY TABLE
  All these have one thing in common and that is
      They hold result set returned by some SQL query so you can write further complex queries on top of that
      
                 Subquery                 CTE                     Temporary Table               Views
 -----------------------------------------------------------------------------------------------------------------------            
Validity     |    Scope of the          Scope of the              Session                  Forever
             |    Statement             Statement    
-------------|            
Readability  |    low                    high                     high                     high
-------------|
 Ideal use   |    In Where clause       Reuse Sub result          Perform multipass        Derived tables thaat will
 case        |    In select clause      Recursive usecase         procssing steps          be used in multiple queries
			 |						    At all places where       on a dataset
             |                          you can replace 
             |                          subquery with CTE.
--------------------------------------------------------------------------------------------------------------------------    */                     
												/* INDEXES (concept more useful for data engineers) */  

/*  Datebase index is a way to speed up SQL queries
    Most of the indexes use B TREE (not binary tree  ) data structure 
    binary tree has 2 nodes
    B TREE has many nodes
    
    
Lets say you have 2 million records and you run a query find data where year 2019 then it will can whole 2 million recored 
to fetch the result but if you use index it will create B tree like this
           
				                               2020  2022 
                                     
					   2016   |   2018            2021            2023
                         
                   2014       2017     2019                                                                            */
                         
/* When you add index on more then 1 column then it is called as composite index this is done to make your query faster
    here you need to be careful with the order lets say you decide to give index on
     Customer code (1) and product code (2) 
     Then it will first scan customer code and then product code*/  
     
 -------------------------------------------------------------------------------------------------------------------------------------    
                         
                         


