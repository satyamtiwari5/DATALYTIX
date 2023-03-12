



--CREATE DATABASE REATAIL22
--USE REATAIL22
--NOW ALL THE TABLES WILL BE IMPORTED IN THE DATABASE


SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions

-------------DATE PREPARATION & UNDERSTANDING----------------------------------------------

--1
SELECT 'customer' as table_name ,COUNT(CUSTOMER_ID) as count_row FROM Customer
union
SELECT 'prod_cat_info' as table_name , COUNT(PROD_CAT_CODE) FROM prod_cat_info
union
SELECT 'transactions' as tablename, COUNT(TRANSACTION_ID) FROM Transactions

--2
SELECT COUNT(total_amt) as total_number 
FROM Transactions
WHERE Qty <0

--3
SELECT CONVERT(DATE,DOB,105) AS NEW_DOB FROM Customer
union all
SELECT CONVERT(DATE,TRAN_DATE,105) AS NEW_TRAN_DATE FROM Transactions
--all the tables will now be deleted and again imported with changed data type, as furthur ques demand changed data type for specific columns

--4

select 'Day' as Tablename, datediff(DAY,Min(tran_date),max(tran_date)) as timerange from Transactions
union all
select 'Month' as tablename , datediff(MONTH,Min(tran_date),max(tran_date)) from Transactions
union all
select 'Year' as tablename , datediff(YEAR,Min(tran_date),max(tran_date))  from Transactions


--5

select prod_cat from prod_cat_info
where prod_subcat='DIY'

---------------------------------------DATA ANALYSIS------------------------------------------------------------

--1
SELECT TOP 1 Store_type
fROM ( select store_type, COUNT(store_type) as count_1 from Transactions group by Store_type) 
as x
order by count_1 desc

--2
select gender, COUNT('m') as count_2 
from Customer
where Gender in ('m','f')
group by gender

--3
select top 1 city_code,count_3 
from 
(select  city_code , count(city_code) as count_3
from Customer
group by city_code) as Y
order by count_3 desc

--4


select count(prod_subcat) as count_4
from prod_cat_info 
where prod_cat='books'

--5

select MAX(qty) AS MAXQTY  from Transactions

--6

select  sum(convert(numeric,total_amt)) as total_revenue  
from prod_cat_info as N
left join 
Transactions  as M 
on 
n.prod_cat_code=m.prod_cat_code
and
n.prod_sub_cat_code=m.prod_subcat_code
where prod_cat in ('electronics','books')


--7

select count(cust_id) as no_of_customers
from
       (select cust_id 
       from Customer as q 
       left join Transactions as w
       on 
       q.customer_Id=w.cust_id
       where convert(int,Qty)>0
       group by cust_id
       having COUNT(cust_id) >10) as x


--8

select sum(convert(numeric,total_amt)) as total_revenue 
from prod_cat_info as N
left join 
Transactions  as M 
on 
n.prod_cat_code=m.prod_cat_code
and n.prod_sub_cat_code=m.prod_subcat_code

where prod_cat in ('electronics','clothing') 
and
Store_type='flagship store'

--9

select PROD_SUBCAT , SUM(convert(numeric,total_amt)) as total_revenue
from 
(select * from Customer
left join Transactions
on
Customer.customer_Id=Transactions.cust_id) as p
left join prod_cat_info
on
p.prod_cat_code=prod_cat_info.prod_cat_code
AND p.prod_subcat_code=prod_cat_info.prod_sub_cat_code
where 
gender ='m' and prod_cat='electronics' 
GROUP BY prod_subcat


--10


select TOP 5 p.prod_subcat,SUM(CONVERT(NUMERIC,TOTALSALES))*100/SUM(SUM(CONVERT(NUMERIC,TOTALSALES))) over() as percent_sale ,
SUM(CONVERT(NUMERIC,TOTALRETURN))*100/SUM(SUM(CONVERT(NUMERIC,TOTALRETURN))) over() as percent_RETURN 
from 
      (select  prod_subcat,SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS TOTALSALES
     
      from prod_cat_info
      left join Transactions
      on 
    prod_cat_info.prod_sub_cat_code = Transactions.prod_subcat_code
      where convert(numeric,total_amt)>0
      group by prod_subcat) as p

LEFT  join 

(select  prod_subcat,SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS TOTALRETURN
      from prod_cat_info
      left join Transactions
      on 
    prod_cat_info.prod_sub_cat_code = Transactions.prod_subcat_code
      where convert(numeric,total_amt)<0
      group by prod_subcat) as o
on
p.prod_subcat=o.prod_subcat
GROUP BY P.prod_subcat
ORDER BY percent_sale DESC




--11
select sum(convert(numeric,total_amt)) as net_total_revenue
from Customer
left join
Transactions 
on 
customer.customer_Id=Transactions.cust_id
Where DATEDIFF(year,dob,getdate())>=25 
and
DATEDIFF(year,dob,getdate())<=35
And DATEDIFF(day,tran_date,'2014-02-28') <= 30





--12
select top 1 prod_cat from(                        
                           select prod_cat , sum(convert(numeric,total_amt)) as value_of_return 
                           from prod_cat_info
                           left join Transactions 
                           on
                           prod_cat_info.prod_cat_code=Transactions.prod_cat_code
                           where DATEDIFF (month,tran_date,'2014-02-28' ) <=3 
                           and convert(numeric,Qty) <0
                           group by prod_cat) as x
 order by value_of_return


--13
select top 1 store_type from 
                             (select Store_type , 
                             sum(convert(numeric,total_amt)) as sale_amt,
                             SUM(convert(numeric,qty)) as sum_qty 
                             from Transactions
                             group by Store_type) as p

order by sale_amt desc,sum_qty desc



--14

select prod_cat from(
                        select prod_cat , AVG(convert(numeric,total_amt)) as avergae from prod_cat_info
                        left join Transactions on 
                        prod_cat_info.prod_cat_code=Transactions.prod_cat_code
                        group by prod_cat) as y

where avergae > (select avg (convert(numeric,total_amt)) from Transactions)



--15-

select prod_cat ,prod_subcat, avg(convert(numeric,total_amt)) as averageprice , 
sum(convert(numeric,total_Amt)) as totalrevenue 
from prod_cat_info
left join Transactions
on prod_cat_info.prod_cat_code=Transactions.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where prod_cat in (
                     select prod_cat from (
                     select top 5 prod_cat from prod_cat_info
                     left join Transactions
                     on prod_cat_info.prod_cat_code=Transactions.prod_cat_code
                     and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
                     group by prod_cat
                     order by sum(convert(numeric,qty)) desc) as d)
group by prod_cat,prod_subcat
order by prod_cat,prod_subcat,averageprice desc