create database coffee_shop_sales_db;
select * from coffee_shop_sales;
describe coffee_shop_sales;

update coffee_shop_sales set transaction_date =str_to_date(transaction_date, '%d-%m-%Y');     #to convert transaction_date date format ie dd-mm-yyyy

alter table coffee_shop_sales modify column transaction_time time;          #to convert transaction_time datatype to time format from string
alter table coffee_shop_sales modify column transaction_date date;   

alter table coffee_shop_sales change column ï»¿transaction_id transaction_id int;           #to change the field name as their was an error in field name ie ï»¿transaction_id to transaction_id

select  month(transaction_date) as month_number,round(sum(unit_price * transaction_qty)) as total_sales from coffee_shop_sales group by month_number;         #to find total sales KPI requirement(business case)

-- selected month /current month = 5/may   previous month = 4/april    for second business case ie month by month diffrence
SELECT MONTH(transaction_date) AS month,                                                     #number of month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,                                 #total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)           # month sales difference lag used to go back base on input ie here 1 (sum(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)     #division by previous month sales   over = partition
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage                 #converting into percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    SELECT MONTH (transaction_date) as month_number, COUNT(transaction_id) as Total_Orders FROM coffee_shop_sales group by month_number ;   -- total order for month

SELECT MONTH(transaction_date) AS month,                                 #order difference month by month
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
select sum(transaction_qty) as total_quantity_sold from coffee_shop_sales WHERE MONTH(transaction_date) = 5;     #total quantity sold by month 

SELECT MONTH(transaction_date) AS month,                                           # sales difference month by month
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

SELECT                                                                            #kpi for total quantity sold, total sales,total order per day
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';          

SELECT                                                                           #to roundoff the above output
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; 

#weekend = Saturday, sunday
#weekdays = mon, tue,wed ,thur ,fri
# in sql days are consider in following sequence :- sun=1 ,mon=2 ,tue=3 ,wed=4 ,.... sat=7

SELECT                                                         #sales by weekday and weekend
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
  concat(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') AS total_sales
FROM coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 2  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;
    
SELECT store_location,
	concat(round(sum(unit_price * transaction_qty)/1000,2), 'k') as Total_Sales             #concat used to round off the value and k is value ie thousandS
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC;

#sales trend over period

SELECT concat(round(AVG(total_sales)/1000,1),'K') AS average_sales        #total_sales = it is outer query comes from inner query 
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales                      #it is internal query
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;


SELECT                                                           #DAILY SALES FOR MONTH SELECTED
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);


SELECT                                                  #COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    

SELECT                                                     #sales by product category
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT                                                      #top 10 product by sales
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;


SELECT                                                                      #sales by day/ hour
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5);
    
    
    SELECT                                                          #TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

    SELECT                                                                   #sales by hours
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);

    







    


