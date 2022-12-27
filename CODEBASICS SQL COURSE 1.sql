/*                                          USE OF SQL
  Ad Hoc Analysis
  Report Generation
  EDA and Machine Learning
  ETL and Data Migration
  Inside BI tools */

USE moviesdb;
SELECT * FROM actors;
SELECT * FROM financials;
SELECT * FROM languages;
SELECT * FROM movie_actor;
SELECT * FROM movies;

                                /*LESSON 1*/
SELECT DISTINCT industry FROM movies;
SELECT DISTINCT(COUNT(industry)) FROM movies;    /*First count will work and then distinct*/
SELECT COUNT(DISTINCT(industry)) FROM movies;    /*First disntinst will work and then count*/
SELECT DISTINCT(COUNT(*)) FROM movies;
SELECT * FROM movies WHERE industry = "Bollywood";        /*SQL is case insensitive*/
SELECT * FROM movies WHERE title LIKE "THOR%";              /* % hold 0 to more characters in a string*/        
SELECT * FROM movies WHERE title LIKE "%america%";
SELECT * FROM movies WHERE title LIKE "_holay";            /*_ hold 1 character in a string*/
SELECT * FROM movies WHERE title LIKE "s_o%";    
----------------------------------------------------------------------------------------------------------------------------------------
                                    /*EXERCISE 1*/
SELECT title,release_year FROM movies WHERE studio ="Marvel Studios";
SELECT * FROM movies WHERE title LIKE "%avenger%";
SELECT release_year FROM movies WHERE title = "The Godfather";
SELECT DISTINCT studio FROM movies WHERE industry ="bollywood";
----------------------------------------------------------------------------------------------------------------------------------------

                             /*LESSON 2*/
SELECT * FROM movies WHERE imdb_rating>9;
SELECT * FROM movies WHERE imdb_rating>=9;
SELECT * FROM movies WHERE imdb_rating>=6 AND imdb_rating<=8;
SELECT * FROM movies WHERE imdb_rating BETWEEN 6 AND 8;
SELECT * FROM movies WHERE release_year =2022 OR release_year =2019 OR release_year =2018;
SELECT * FROM movies WHERE release_year IN (2022,2019,2018); 
SELECT * FROM movies WHERE studio IN ("Marvel studios","Zee Studios"); 
SELECT * FROM movies WHERE release_year IN (2022,2019,2018);
SELECT * FROM movies WHERE imdb_rating IS NULL;
SELECT * FROM movies WHERE imdb_rating IS NOT  NULL;
SELECT * FROM movies WHERE industry = "Bollywood" ORDER BY imdb_rating; 
SELECT * FROM movies WHERE industry = "Bollywood" ORDER BY imdb_rating DESC; 
SELECT * FROM movies WHERE industry = "Bollywood" ORDER BY imdb_rating DESC LIMIT 5; 
SELECT * FROM movies WHERE industry = "Bollywood" ORDER BY imdb_rating DESC LIMIT 5 OFFSET 1; 
 /*offset by default starts from 0 so offset 1 means you are extracting 2nd highest movie and from there top 5*/
 
 ----------------------------------------------------------------------------------------------------------------------------------------
                                     /*EXERCISE 2*/
 
SELECT * FROM movies ORDER BY release_year DESC;
SELECT * FROM movies WHERE release_year = 2022;
SELECT * FROM movies WHERE release_year > 2020;
SELECT * FROM movies WHERE release_year > 2020 AND imdb_rating >8;
SELECT * FROM movies WHERE studio = "Marvel studios" AND studio = "Hombale films";
SELECT title, release_year FROM movies WHERE title LIKE "%thor%" ORDER BY release_year;
SELECT * FROM movies WHERE studio != "Marvel studios";

----------------------------------------------------------------------------------------------------------------------------------------
                                   /*LESSON 3*/
SELECT MIN(imdb_rating) as min_rating,
MAX(imdb_rating) as max_rating,
ROUND(AVG(imdb_rating),2) as avg_rating
FROM movies WHERE studio= "marvel studios";

SELECT studio,COUNT(studio) as cnt,ROUND(AVG(imdb_rating),1) as avg_rating
FROM movies
WHERE studio != ""  /* this will remove the blank row if present */
GROUP BY studio
ORDER BY avg_rating DESC;

 SELECT release_year, COUNT(release_year) as cnt FROM movies
 GROUP BY release_year
 HAVING Cnt>2                    /* the column you use in HAVING clause must be present in select statement but for WHERE there is no such condition */ 
 ORDER BY release_year DESC;          

----------------------------------------------------------------------------------------------------------------------------------------
                                /*EXERCISE 3*/
 SELECT COUNT(*) FROM movies WHERE release_year BETWEEN 2015 AND 2022;
 SELECT MIN(release_year) AS min_year ,MAX(release_year) AS max_year FROM movies;
 
 SELECT release_year, COUNT(release_year) as cnt FROM movies
 GROUP BY release_year
 ORDER BY release_year DESC;
 
 ----------------------------------------------------------------------------------------------------------------------------------------
                                   /*LESSON 4*/
SELECT *,YEAR(CURDATE())-birth_year AS age FROM actors;    /* calculated column in mysql */
SELECT *,(revenue-budget)  AS profit FROM financials;

SELECT *,
IF(currency="USD",revenue*77,revenue) AS revenue_inr
FROM financials;

SELECT *,
CASE
     WHEN unit="thousands" THEN revenue/1000             /* When you have more than two conditions use case statement */
     WHEN unit="billions" THEN revenue*1000      /* 1 billion = 1000 million */
     ELSE  revenue
END AS revenue_million
FROM financials;
 
 ----------------------------------------------------------------------------------------------------------------------------------------
                                           /*EXERCISE 4*/
 
 SELECT *,(revenue-budget) as profit,
 (revenue-budget)*100/budget as profit_percent
 FROM financials;
 ----------------------------------------------------------------------------------------------------------------------------------------
                                           /*LESSON 5 JOINS AND CASE */
  
  SELECT m.movie_id,title,budget,revenue,currency,unit
  FROM movies m
  INNER JOIN financials f
  ON m.movie_id = f.movie_id;
  
  SELECT m.movie_id,title,budget,revenue,currency,unit
  FROM movies m
  LEFT JOIN financials f                                    /*By default there is INNER JOIN in MYSQL*/
  ON m.movie_id = f.movie_id                                  /* LEFT and LEFT OUTER are same*/
UNION                                                           /* UNION is used to perform full outer join in mysql*/
 SELECT f.movie_id,title,budget,revenue,currency,unit
  FROM movies m
  RIGHT JOIN financials f
  ON m.movie_id = f.movie_id;
  
 SELECT m.movie_id,title,budget,revenue,currency,unit
  FROM movies m
  LEFT JOIN financials f                            /*instead of ON you can use USING but your joining column must have same name*/
  USING (movie_id); 
  
 SELECT m.movie_id,title,budget,revenue,currency,unit
  FROM movies m
  RIGHT JOIN financials f                            /*you can join based on multiple column also*/
  ON m.movie_id=f.movie_id AND m.col1 = f.col2;
  
  SELECT
   m.movie_id,title,budget,revenue,currency,unit,
   CASE
       WHEN unit="thousand" THEN ROUND((revenue-budget)/1000,1)     /*we used CASE here to covert everthing in millions*/
       WHEN unit="billions" THEN ROUND((revenue-budget)*1000,1)
       ELSE ROUND((revenue-budget),1)
   END as profit_million
FROM movies m
JOIN financials f ON m.movie_id=f.movie_id
WHERE industry="bollywood"
ORDER BY profit_million DESC;

SELECT
      m.title,GROUP_CONCAT(a.name SEPARATOR " | ") AS actors          /*example of GROUP CONCAT* The GROUP_CONCAT() function in MySQL is used to concatenate data from multiple rows into one field. This is an aggregate (GROUP BY) function which returns a String value, if the group contains at least one non-NULL value. Otherwise, it returns NULL*/
FROM movies m
JOIN movie_actor ma ON ma.movie_id=m.movie_id
JOIN actors a ON a.actor_id= ma.actor_id
GROUP BY m.movie_id;

SELECT * FROM MOVIES;
SELECT*FROM MOVIE_ACTOR;
SELECT * FROM ACTORS;

SELECT
   a.name AS actor,GROUP_CONCAT(m.title SEPARATOR " , ") AS movies,COUNT(m.title) AS movie_count
FROM movies m
JOIN movie_actor ma ON m.movie_id=ma.movie_id
JOIN actors a ON a.actor_id = ma.actor_id
GROUP BY a.actor_id
ORDER BY movie_count DESC;

                               /*example of cross join*/
SELECT * FROM items;
SELECT * FROM variants;

USE food_db;  
SELECT CONCAT(i.name,"-",v.variant_name) as Menu,(price+variant_price) as full_price
FROM items i
CROSS JOIN variants;
----------------------------------------------------------------------------------------------------------------------------------------
                                      /*EXERCISE 5*/
SELECT * FROM MOVIES;
SELECT * FROM LANGUAGES;

SELECT m.title,l.name 
FROM movies m
JOIN languages l
ON m.language_id=l.language_id;

SELECT l.name ,COUNT(l.name) as movie_cnt
FROM movies m
LEFT JOIN languages l
ON m.language_id=l.language_id
GROUP BY l.name
ORDER BY movie_cnt DESC ;

SELECT m.title,l.name 
FROM movies m
LEFT JOIN languages l
ON m.language_id=l.language_id
WHERE l.name="telugu";

  SELECT
   m.title,f.revenue,f.currency,f.unit,
   CASE
       WHEN unit="thousand" THEN ROUND((revenue-budget)/1000,1)     /*we used CASE here to covert everthing in millions*/
       WHEN unit="billions" THEN ROUND((revenue-budget)*1000,1)
       ELSE ROUND((revenue-budget),1)
   END as profit_million
FROM movies m
JOIN financials f ON m.movie_id=f.movie_id
JOIN languages l ON m.language_id=l.language_id
WHERE industry="bollywood"
ORDER BY profit_million DESC;
----------------------------------------------------------------------------------------------------------------------------------------

                                                   /*LESSON 6 SUBQUERIES*/
 /*case 1 = returns single value*/
/*select a movie with highest imdb_rating*/
SELECT * FROM movies
WHERE imdb_rating =(SELECT MAX(imdb_rating)FROM movies);

/*case 2 = returns multiple value*/
/*select a movie with highest and lowest imdb_rating*/
SELECT * FROM movies
WHERE imdb_rating IN ((SELECT MAX(imdb_rating)FROM movies),(SELECT MIN(imdb_rating)FROM movies));

/*case 3 = returns a table*/
/*select all actors whose age > 70 and age < 85 */
SELECT * FROM 
(SELECT name,YEAR(CURDATE())-birth_year AS age FROM actors) AS actor_age  /* this query will act as a table and from that we extract age*/
WHERE age>70 AND age<85;

/*IN,ANY,ALL*/
SELECT *FROM MOVIES;
SELECT * FROM ACTORS;
SELECT * FROM MOVIE_ACTOR;
SELECT * FROM actors WHERE actor_id IN (SELECT actor_id FROM movie_actor WHERE movie_id IN(101,110,121));
SELECT * FROM actors WHERE actor_id = ANY (SELECT actor_id FROM movie_actor WHERE movie_id IN(101,110,121));
SELECT * FROM actors WHERE actor_id = ALL (SELECT actor_id FROM movie_actor WHERE movie_id IN(101,110,121));

/*Co-related subqueries*/

#EXPLAIN ANALYZE
SELECT a.actor_id,a.name,COUNT(*) as movies_count
FROM movie_actor ma
JOIN actors a
ON a.actor_id=ma.actor_id                            /*groupby and join solution is faster than corelated*/
GROUP BY actor_id                                      /*use EXPLAIN ANALYZE to check performance*/
ORDER BY movies_count DESC;

#EXPLAIN ANALYZE
SELECT actor_id,name,
(SELECT COUNT(*) FROM movie_actor                    /*same above result using co-related subquery*/
WHERE actor_id=actors.actor_id) AS movies_count    /*we are using outer query i.e we are using actors from FROM into our subquery hence corelated*/
FROM actors
ORDER BY movies_count DESC;

/*CTE (common table espression)*/
/*select all actors whose age > 70 and age < 85 */ 
 
SELECT * FROM 
(SELECT name,YEAR(CURDATE())-birth_year AS age FROM actors) AS actor_age     /* solved using subquery*/
WHERE age>70 AND age<85;

WITH actors_age AS (SELECT name as actor_name,YEAR(CURDATE())-birth_year AS age FROM actors)
SELECT actor_name,age
FROM actors_age                                 /* same result using CTE*/
WHERE age>70 AND age<85;  /* WITH alias name AS (subquery that gives table)*/

/* movies that produced 500 % or more profit and their rating was less than avg rating of all movies */

/* first lets do using sub query */
SELECT 
      x.movie_id,x.pct_profit,
      y.title,y.imdb_rating
  FROM ( SELECT *,(revenue-budget)*100/budget as pct_profit FROM financials) x
  JOIN (
        SELECT * FROM movies WHERE imdb_rating <(SELECT AVG(imdb_rating) FROM movies)) y
  ON x.movie_id = y.movie_id
  WHERE pct_profit >= 500;
  
  /*  lets do using CTE*/
  
  WITH x AS (SELECT *,(revenue-budget)*100/budget as pct_profit FROM financials),
       y AS (SELECT * FROM movies WHERE imdb_rating <(SELECT AVG(imdb_rating) FROM movies))
  SELECT 
      x.movie_id,x.pct_profit,
      y.title,y.imdb_rating
  FROM x
  JOIN y
  ON x.movie_id = y.movie_id
  WHERE pct_profit >= 500;
  
    /* benefits of CTE*/
   /* query readability is easier
   query reusability (lets say you have created table x now within that scope of with you can use multiple times
visibility for creating VIEWS */

----------------------------------------------------------------------------------------------------------------------------------------
  

                                          /*EXERCISE 6*/
SELECT*FROM movies WHERE release_year IN(                                      
(SELECT MIN(release_year) FROM movies),(SELECT MAX(release_year) FROM movies)
);

SELECT * FROM movies WHERE imdb_rating >
(SELECT AVG(imdb_rating) FROM movies);


SELECT*FROM movies;
select*from financials;

WITH x AS (SELECT *,(revenue-budget) as profit FROM financials WHERE (revenue-budget)>500 ),
     y AS (SELECT * FROM movies WHERE release_year>2000 AND industry="hollywood")
SELECT y.title,y.release_year,x.profit
FROM x
JOIN y
ON x.movie_id =y.movie_id;

----------------------------------------------------------------------------------------------------------------------------------------

                                                    /* LESSON 7 */
      /* Database design consist of 3 stages 1) Conceptual model , ERD (entity relationship diagram) , Database Schema */  
      /* NORMALIZATION is a process of organizing a data base and improve data integrity */ 
    /* Data integrity is the measure of consistency and accuracy of data over its life cycle */
    /* Good data base has following 1) Less duplication 2) Better Data integrity 3) Flexible design */
    /* link table = movie     movie_actor(link table)    actor* /
    
    /* DATA TYPES*/ 
    /* NUMERIC = Integers (tiny int,small int,int,big int) and floating point (float,double,decimaal) */ 
	/* STRING = char,varchar,text,  blob(binary large obeject to store images) ,  enum (category) */ 
    /* DATE & TIME = DATE,TIME,DATETIME,YEAR,TIMESTAMP */ 
     /* JSON (Java Script Object Notation ) SPATIAL (geo locations such as latitude longitude) */ 
     
     /* problems solved on JSON*/ 
USE superstore_db;
SELECT*FROM items ;

SELECT*FROM items 
WHERE properties-> "$.gluten_free"=1;   /* -> this operator is used to extract JSON object  and $. by default you have to put*/ 

SELECT*FROM items 
WHERE JSON_EXTRACT (properties,"$.gluten_free")=1;  /* same query but approach different used JSON_EXTRACT*/ 

 /* PRIMARY KEY = It is a unique identifier which cannot have duplicates*/ 
 /* NATURAL KEY = It is the primary key created using original dataset*/ 
 /* SURROGATE KEY  = It is the primary key created using our extra added column*/ 
  /* COMPOSITE KEY = combining too many column in 1 primary key to create uniqueness*/ 
   /* UNIQUE KEY = It can store NULL value but only 1 NULL per column*/ 
     /* Non Identifying relationship in 1 to many means the foreign key is not part of primary key in table
      e.g in movies table foreign key is language id but primary key is movies id*/ 
 
	/* INSERT COMMAND*/ 
    USE moviesdb;
    SELECT * FROM movies;
    
INSERT INTO  movies VALUES(141,"Bahuhbali 3","Bollywood",2030,9.0,"Arka Media Works",2);

INSERT INTO movies (title,industry,release_year,imdb_rating,studio,language_id)  
VALUES("Bahuhbali 4","Bollywood",2030,9.2,"Arka Media Works",2); 
/* as we have kept movie_id at auto increment so even if you don't specify it will work*/ 

INSERT INTO movies (movie_id,title,industry,release_year,imdb_rating,studio,language_id)  
VALUES(DEFAULT,"Bahuhbali 5","Bollywood",2032,NULL,"Arka Media Works",2); 
/* DEFAULT means pre defined value NULL means if allowed to that column we can give that*/ 

INSERT INTO movies (movie_id,title,industry,release_year,imdb_rating,studio,language_id)  
VALUES(DEFAULT,"Bahuhbali 5","Bollywood",2032,NULL,"Arka Media Works",30); 
/*  we get ERROR foreign key constraint fails because we have given wrong language_id*/ 

INSERT INTO movies (title,industry,language_id) VALUES ("Inception 3","Hollywood",5),
("Inception 4","Hollywood",5),
("Inception 5","Hollywood",5);
/* This is how you insert multiple records*/ 

/* UPDATE AND DELETE COMMAND*/ 

UPDATE movies SET studio="MANJU" ,language_id=3
WHERE movie_id=143;

UPDATE movies SET studio="manjunath productions" ,language_id=4
WHERE title LIKE "%bahuhbali%";
/* before using update always use SELECT query first to see which record you want to update*/ 

DELETE FROM movies WHERE title LIKE "%bahuhbali%";
DELETE FROM movies WHERE title LIKE "%inception%";  /* benefit of foreign key it is not allowing to delete*/ 

DELETE FROM movies WHERE movie_id IN (145,146,147);

--------------------------------------   Congratulations you made it to the END  ---------------------------------------------------------------------------------------------



























  
 
 
 


  
  
  
 
 
 
 
 
 




























        


