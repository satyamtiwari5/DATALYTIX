







--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS


--Q1--BEGIN 
select distinct State from 
   
	(select State , Date 
	from DIM_LOCATION 
	left join FACT_TRANSACTIONS
	on 
	DIM_LOCATION.IDLocation=FACT_TRANSACTIONS.IDLocation)
	as x
	left join DIM_DATE 
	on
	x.Date=DIM_DATE.DATE
	where YEAR >= 2005



--Q1--END

--Q2--BEGIN-----OR
SELECT TOP 1 State , SUM (QUANTITY) AS TOTAL_QUANTITY FROM

(
SELECT Manufacturer_Name, Quantity , IDLocation
FROM 
(SELECT Manufacturer_Name, IDModel 
FROM DIM_MANUFACTURER
LEFT JOIN DIM_MODEL
ON 
DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer) AS J
LEFT JOIN FACT_TRANSACTIONS
ON J.IDModel=FACT_TRANSACTIONS.IDModel) AS R 
LEFT JOIN
DIM_LOCATION 
ON
R.IDLOCATION=DIM_LOCATION.IDLOCATION
WHERE Country='US' AND Manufacturer_Name='SAMSUNG'
GROUP BY STATE 
ORDER BY TOTAL_QUANTITY DESC


--Q2--END

--Q3--BEGIN      


	SELECT [State],ZipCode , IDModel 
	 , COUNT(DATE) AS NO_TRANSACTION FROM DIM_LOCATION
	LEFT JOIN FACT_TRANSACTIONS
	ON DIM_LOCATION.IDLocation=FACT_TRANSACTIONS.IDLocation
	GROUP BY [State],ZipCode , IDModel 


	

--Q3--END

--Q4--BEGIN

     SELECT TOP 1 Model_Name, Unit_price FROM DIM_MODEL
	  ORDER BY Unit_price


--Q4--END

--Q5--BEGIN

select IDManufacturer, DIM_MODEL.IDModel,AVG(totalprice) as avgprice from DIM_MODEL
left join FACT_TRANSACTIONS
on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
where IDManufacturer in (
                          select IDManufacturer from ( 
                          select top 5 IDManufacturer, sum(totalprice) as sumpri from DIM_MODEL
                          left join FACT_TRANSACTIONS
                          on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
                          group by IDManufacturer
                          order by sum(quantity) desc) as k)

group by IDManufacturer, DIM_MODEL.IDModel
order by IDManufacturer,IDModel,avgprice



--Q5--END

--Q6--BEGIN
SELECT  CUSTOMER_NAME, AVRAGE  FROM DIM_CUSTOMER
LEFT JOIN 
(SELECT IDCUSTOMER ,YEAR,  AVG (TOTALPRICE) AS AVRAGE FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date

GROUP BY IDCustomer,YEAR ) AS P 
ON DIM_CUSTOMER.IDCustomer=P.IDCustomer
WHERE YEAR = 2009 AND AVRAGE > 500










--Q6--END
	
--Q7--BEGIN  


SELECT * FROM (
SELECT * FROM (
SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT  IDModel , SUM(QUANTITY) AS SUMQTY  FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR = 2008
GROUP BY IDModel) AS P
ON DIM_MODEL.IDModel=P.IDModel
ORDER BY SUMQTY DESC

INTERSECT

SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT  IDModel , SUM(QUANTITY) AS SUMQTY  FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR = 2009
GROUP BY IDModel) AS P
ON DIM_MODEL.IDModel=P.IDModel
ORDER BY SUMQTY DESC ) AS Y


INTERSECT 
SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT  IDModel , SUM(QUANTITY) AS SUMQTY  FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR = 2010
GROUP BY IDModel) AS P
ON DIM_MODEL.IDModel=P.IDModel
ORDER BY SUMQTY DESC ) AS K


--Q7--END	
--Q8--BEGIN

SELECT '2009' AS YEARS, Manufacturer_Name FROM (
SELECT (DENSE_RANK() OVER ( ORDER BY SUMQTY DESC)) AS RANKS ,Manufacturer_Name 
FROM 
(SELECT Manufacturer_Name, SUM(TotalPrice) AS SUMQTY FROM (
SELECT   Model_Name , Manufacturer_Name , IDModel FROM DIM_MODEL
LEFT JOIN DIM_MANUFACTURER
ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer) AS U
LEFT JOIN FACT_TRANSACTIONS
ON U.IDModel =FACT_TRANSACTIONS.IDModel
WHERE Date > '2008-12-31' AND DATE < '2010-01-01'
GROUP BY Manufacturer_Name) AS Y) AS D
WHERE RANKS =2

UNION 
 
SELECT '2010' AS YEARS, Manufacturer_Name FROM (
SELECT (DENSE_RANK() OVER ( ORDER BY SUMQTY DESC)) AS RANKS ,Manufacturer_Name 
FROM 
(SELECT Manufacturer_Name, SUM(TotalPrice) AS SUMQTY FROM (
SELECT   Model_Name , Manufacturer_Name , IDModel FROM DIM_MODEL
LEFT JOIN DIM_MANUFACTURER
ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer) AS U
LEFT JOIN FACT_TRANSACTIONS
ON U.IDModel =FACT_TRANSACTIONS.IDModel
WHERE Date > '2009-12-31' AND DATE < '2011-01-01'
GROUP BY Manufacturer_Name) AS Y) AS D
WHERE RANKS =2


--Q8--END
--Q9--BEGIN
	   SELECT DISTINCT Manufacturer_Name FROM (
	SELECT IDModel, Manufacturer_Name FROM DIM_MODEL
	LEFT JOIN DIM_MANUFACTURER
	ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer) AS D
	LEFT JOIN FACT_TRANSACTIONS
	ON D.IDModel=FACT_TRANSACTIONS.IDModel
	WHERE Date > '2009-12-31' AND DATE < '2011-01-01'


	EXCEPT


	SELECT DISTINCT Manufacturer_Name FROM (
	SELECT IDModel, Manufacturer_Name FROM DIM_MODEL
	LEFT JOIN DIM_MANUFACTURER
	ON DIM_MODEL.IDManufacturer=DIM_MANUFACTURER.IDManufacturer) AS D
	LEFT JOIN FACT_TRANSACTIONS
	ON D.IDModel=FACT_TRANSACTIONS.IDModel
	WHERE Date > '2008-12-31' AND DATE < '2010-01-01'


--Q9--END

--Q10--BEGIN
	
SELECT IDCUSTOMER ,YEARS , AVG_QTY , AVG_SPEDD , (( AVG_SPEDD - PREV)/PREV *100) AS PERCENTCHANGE
FROM 
      (
SELECT IDCustomer, YEARS,AVG_QTY , AVG_SPEDD ,
LAG(AVG_SPEDD,1) OVER(PARTITION BY IDCUSTOMER  ORDER BY IDCUSTOMER ASC , YEARS ASC) AS PREV
FROM 
(SELECT X.IDCustomer, AVG_SPEDD,AVG_QTY, YEARS FROM
       
	     ( SELECT TOP 10 IDCustomer, AVG(TotalPrice) AS AVG_SPEND FROM FACT_TRANSACTIONS
	      GROUP BY IDCustomer
	      ORDER BY AVG_SPEND DESC) AS X
          
	LEFT JOIN

	(SELECT IDCustomer , YEAR(DATE) AS YEARS  , AVG(TotalPrice) AS AVG_SPEDD , AVG(QUANTITY) AS AVG_QTY
	FROM FACT_TRANSACTIONS
	GROUP BY IDCustomer, YEAR(DATE)) 
AS Y
ON X.IDCustomer=Y.IDCustomer) AS F) AS C




--Q10--END
	