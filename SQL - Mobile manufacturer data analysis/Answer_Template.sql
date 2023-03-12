--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

--Q1--BEGIN 

select 
distinct state from

(select  State, date 
from DIM_LOCATION

left join FACT_TRANSACTIONS
on
dim_location.idlocation = FACT_TRANSACTIONS.IDLocation )
as a
left join dim_date
on 
a.date = dim_date.date
where year>=2005







--Q1--END

--Q2--BEGIN
--------- What state in the US is buying the most 'Samsung' cell phones? 

select * from dim_location
select * from DIM_MODEL
select * from FACT_TRANSACTIONS
select * from DIM_MANUFACTURER

select top 1 state, sum(quantity) as total_quantity from (
select Manufacturer_Name,Quantity,IDLocation from
(
select Manufacturer_Name,IDModel from DIM_MANUFACTURER
left join DIM_MODEL
on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer) as a
left join fact_transactions
on a.idmodel = fact_transactions.idmodel) as b
left join dim_location
on b.idlocation = dim_location.IDLocation
where country = 'us' and Manufacturer_Name = 'samsung'
group by state
order by total_quantity desc




 

  




--Q2--END

--Q3--BEGIN    
select [State],City,IDModel,ZipCode,
count (date) as maxm_transaction   from DIM_LOCATION
left join FACT_TRANSACTIONS
on DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
group by [state], city, IDModel,ZipCode





--Q3--END

--Q4--BEGIN

select top 1 Model_Name, Unit_price from dim_model
order by unit_price




--Q4--END

--Q5--BEGIN
-- Find out the average price for each model in the top5 manufacturers in
--------terms of sales quantity and order by average price.


select IDManufacturer,DIM_MODEL.IDModel,
avg(totalprice)as avg_price
from dim_model
left join FACT_TRANSACTIONS
on dim_model .idmodel = FACT_TRANSACTIONS.idmodel
where idmanufacturer in(

select idmanufacturer from

  ( select top 5 IDManufacturer, sum (totalprice) as sum_price 
    from dim_model
     left join FACT_TRANSACTIONS
     on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
     group by  idmanufacturer
      order by sum(quantity)desc)as b)

group by idmanufacturer, DIM_MODEL.idmodel
order by idmanufacturer,idmodel, avg_price










--Q5--END

--Q6--BEGIN
--- List the names of the customers and the average amount spent in 2009,
---where the average is higher than 500 .


select Customer_Name , total_price from DIM_CUSTOMER
left join(

select year,IDCustomer,
avg(totalprice) as total_price from DIM_DATE
left join FACT_TRANSACTIONS
on DIM_date.DATE = FACT_TRANSACTIONS.date
group by year,IDCustomer) as a

on DIM_CUSTOMER.IDCustomer = a.IDCustomer
where year = 2009 and total_price > 500  













--Q6--END
	
--Q7--BEGIN  

select * from (
select * from(
select top 5 model_name from DIM_MODEL
left join (
select idmodel,sum(quantity) as sumqty from dim_date
left join FACT_TRANSACTIONS
on DIM_DATE.date = FACT_TRANSACTIONS.date
where year = 2008
group by IDModel) as p
on DIM_MODEL.IDModel = p.IDModel
order by sumqty desc

intersect

select top 5 model_name from DIM_MODEL
left join (
select idmodel , sum(quantity) as sumqty from DIM_DATE
left join FACT_TRANSACTIONS
on DIM_DATE.date = FACT_TRANSACTIONS.date
where year = 2009
group by IDModel) as p
on dim_model.IDModel = p.IDModel
order by sumqty desc) as y

intersect

select top 5 model_name from DIM_MODEL
left join (
select idmodel, sum(quantity) as sumqty from dim_date
left join fact_transactions
on dim_date.date = fact_transactions.date
where year = 2010
group by idmodel)as p
on dim_model.idmodel = p.idmodel
order by sumqty desc ) as a

















--Q7--END	
--Q8--BEGIN

---Show the manufacturer with the 2nd top sales in the year of 2009 and the
--manufacturer with the 2nd top sales in the year of 2010.



select top 1 *from
(select manufacturer_name, totalprice from DIM_MODEL 
 join DIM_MANUFACTURER
on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer 
join FACT_TRANSACTIONS 
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
where year(date) = 2009
group by Manufacturer_Name,TotalPrice
order by TotalPrice desc offset 1 row 
) as a

union
select top 1 *from
(select manufacturer_name, totalprice from DIM_MODEL 
 join DIM_MANUFACTURER
on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer 
join FACT_TRANSACTIONS 
on DIM_MODEL.IDModel = FACT_TRANSACTIONS.IDModel
where year(date) = 2010
group by Manufacturer_Name,TotalPrice
order by TotalPrice desc offset 1 row 
) as b





--Q8--END
--Q9--BEGIN
	--- Show the manufacturers that sold cellphones in 2010 but did not in 2009


select  manufacturer_name,year from 
( select [date],Manufacturer_Name from
	  
(select  manufacturer_name, idmodel from DIM_MANUFACTURER
left join dim_model
on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer) as a
 left join FACT_TRANSACTIONS
 on a.IDModel = FACT_TRANSACTIONS.IDModel) as b

 left join DIM_DATE
 on b.Date = dim_date .DATE
 where year = 2010

 except 

 select manufacturer_name,year from (

 select [date],manufacturer_name  from
( select Manufacturer_Name,IDModel from DIM_MANUFACTURER
 left join DIM_MODEL
 on DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer) as a
 left join FACT_TRANSACTIONS
 on a.IDModel = FACT_TRANSACTIONS.idmodel) as b

left join dim_date 
on b. date = dim_date.date
where year = 2009

 












--Q9--END

--Q10--BEGIN
	


















--Q10--END
	