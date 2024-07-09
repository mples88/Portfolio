# Main business points:

## 1) Extract information that you consider valuable for the business and represent with this at least 3 descriptive visualisations. 
#
#2) Find the total number of employees the company has and display a visualisation in Tableau showing the staff per country.
# 
#3) Find two appropriate variables from different tables and extract the information to perform a linear regression model with that data identifying possible relationship between the variables 
# (you can use Python or Excel to achieve this point). Explain the outcome and visualise the data using Tableau or Python.
# 
#4) Use an appropriate visualisation in Tableau to show the stock available per line of products.
#
#5) Use an appropriate visualisation to show the current order’s status. 
#
#6) Find out the nationalities that are buying the cars in the different offices. Visualise this in Tableau showing the proportion per nationality in each showroom.
# 
#7) Benchmarking is a common strategy in business to compare business processes and performance metrics. Use your data and try this strategy comparing the performance of this business with other car showrooms.
#
#######################################################################################################################################################################

# Introduction:

# The roots of diecast modelling go back to 1900 when the first models were made from tinplate, not long after the original cars were made, and their targeted audience was children of wealthy parents. 
# After World War I, companies such as Citroen continued to make tinplate models with the purpose of promoting their cars within 1:8 and 1:11 scales. 
# In later years, diecast companies introduced models made from zinc alloy to the market, of which production was cheaper than tinplate models.
# In the 1960s, diecast manufacturers introduced models with a scale of 1:43 by European companies, of which models became much more authentic copies of the original cars. 
# The model parts started to become more detailed as well. Some of the examples were opening doors, wheels made from rubber, or detailed interiors.
# With further development of model details, many adult collectors became interested in diecast modelling; therefore, new shops have been opened, specialising in producing car models made from resin or handmade from white metal, with the ability to make orders by mail. 
# The model scales such as 1:43 and 1:18 became the most popular due to their sizes and high degree of detail, therefore, the value of such models also started to increase significantly.


########################################################################################################################################################################

use classicmodels;

########### employees number ###############
select *
from employees;

select count(employeeNumber) as employees_number
from employees;

select *
from offices;

## employees + office (country) + job title

select e.employeeNumber, e.jobTitle, o.country
from employees e
join offices o on o.officeCode=e.officeCode;


########### stock available per line of products #####

### total number of available products
SELECT productLine, sum(quantityInStock) as quantityInStock
FROM products
GROUP BY productLine
ORDER BY quantityInStock desc;

### stock available per line of classic cars product
SELECT productName, quantityInStock
FROM products
WHERE productLine = "Classic Cars"
ORDER BY quantityInStock desc;

########### current order status - latest year 2005 #########


SELECT *
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE orderDate like "2005%";

### orders made for latest year - 2005

SELECT o.status, count(o.status) as order_status_count
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE orderDate like "2005%"
GROUP BY o.status;

### order status from 2005/04 until the latest date (2005-06-07)

SELECT o.status, count(o.status) as order_status_count
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE orderDate >= "2005-04-01"
GROUP BY o.status;


SELECT *
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE orderDate >= "2005-04-01";

######################### nationalities of buyers of classic cars


SELECT  c.country, count(c.country) as country_count_per_office
FROM customers c
JOIN offices o ON c.country = o.country
group by c.country;

SELECT  *
FROM customers c
LEFT JOIN offices o ON c.country = o.country
WHERE o.country is NULL;

SELECT  c.country, count(c.country) as country_count_per_office
FROM customers c
LEFT JOIN offices o ON c.country = o.country
WHERE o.country is NULL
group by c.country;

####

SELECT  *
FROM customers c
LEFT JOIN offices o ON c.country = o.country
JOIN orders oo ON c.customerNumber = oo.customerNumber
JOIN orderdetails od ON oo.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine like "%car%" and o.country is NULL;

### nationalities that buy any cars in different offices - all cars
SELECT  c.country, count(c.country) as country_count_per_office
FROM customers c
LEFT JOIN offices o ON c.country = o.country
JOIN orders oo ON c.customerNumber = oo.customerNumber
JOIN orderdetails od ON oo.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine like "%car%" and o.country is NULL
group by c.country;


#### nationalities who buying cars in different offices _ Classic Cars ONLY####
SELECT  c.country, count(c.country) as country_count_per_office
FROM customers c
LEFT JOIN offices o ON c.country = o.country
JOIN orders oo ON c.customerNumber = oo.customerNumber
JOIN orderdetails od ON oo.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine = "Classic Cars" and o.country is NULL
group by c.country;


SELECT  *
FROM customers c
LEFT JOIN offices o ON c.country = o.country
JOIN orders oo ON c.customerNumber = oo.customerNumber
JOIN orderdetails od ON oo.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine = "Classic Cars";

######################################################### analysis ###################


##### whole stock equity
SELECT distinct(productName), quantityInStock, buyPrice, (quantityInStock * buyPrice) as stock_investment
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode;

#### classic cars equity
SELECT distinct(productName), quantityInStock, buyPrice, (quantityInStock * buyPrice) as stock_investment
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
WHERE p.productLine = "Classic Cars";

### revenue  per country

SELECT distinct(productName),c.country, priceEach, quantityOrdered,  (quantityOrdered * priceEach) as expected_return_per_product_per_order
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber=od.orderNumber
JOIN customers c ON c.customerNumber=o.customerNumber;

### total revenue
SELECT sum(total_return_per_product) as sum_expected_return
FROM(
SELECT productName, c.country, priceEach, quantityOrdered, sum(quantityOrdered * priceEach) as total_return_per_product
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
GROUP BY productName, c.country, priceEach, quantityOrdered
) as total_earnings;

### total revenue 2003
SELECT sum(total_return_per_product) as sum_expected_return
FROM(
SELECT o.orderDate, productName, c.country, priceEach, quantityOrdered, sum(quantityOrdered * priceEach) as total_return_per_product
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE o.orderDate like "2003%"
GROUP BY productName, c.country, priceEach, quantityOrdered, o.orderDate
) as total_earnings;

### total revenue 2004
SELECT sum(total_return_per_product) as sum_expected_return
FROM(
SELECT o.orderDate, productName, c.country, priceEach, quantityOrdered, sum(quantityOrdered * priceEach) as total_return_per_product
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE o.orderDate like "2004%"
GROUP BY productName, c.country, priceEach, quantityOrdered, o.orderDate
) as total_earnings;

### total revenue 2005
SELECT sum(total_return_per_product) as sum_expected_return
FROM(
SELECT o.orderDate, productName, c.country, priceEach, quantityOrdered, sum(quantityOrdered * priceEach) as total_return_per_product
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE o.orderDate like "2005%"
GROUP BY productName, c.country, priceEach, quantityOrdered, o.orderDate
) as total_earnings;

### Equity: total
SELECT sum(stock_investment) as total_investment
FROM(
SELECT distinct(productName), quantityInStock, buyPrice, (quantityInStock * buyPrice) as stock_investment
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY productName, quantityInStock,buyPrice
) as total_investment;

### Equity - classic cars: total
SELECT sum(stock_investment) as total_investment_classic_cars
FROM(
SELECT distinct(productName), quantityInStock, buyPrice, (quantityInStock * buyPrice) as stock_investment
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
WHERE p.productLine = "Classic Cars"
GROUP BY productName, quantityInStock,buyPrice
) as total_investment;


#### earnings per country -  classic cars

SELECT distinct(productName),c.country, priceEach, quantityOrdered,  (quantityOrdered * priceEach) as expected_return_per_product_per_order
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber=od.orderNumber
JOIN customers c ON c.customerNumber=o.customerNumber
WHERE p.productLine = "Classic Cars";


## expected total return on USA customers
SELECT distinct(productName),c.country, priceEach, quantityOrdered,  (quantityOrdered * priceEach) as expected_return_per_product_per_order
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber=od.orderNumber
JOIN customers c ON c.customerNumber=o.customerNumber
WHERE c.country = "USA";

####expected USA return on classic cars

SELECT distinct(productName),productLine,c.country, priceEach, quantityOrdered,  (quantityOrdered * priceEach) as expected_return_per_product_per_order
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber=od.orderNumber
JOIN customers c ON c.customerNumber=o.customerNumber
WHERE c.country = "USA" and productLine = "Classic Cars";


###### classic cars product quantities

SELECT productName, quantityOrdered, priceEach
FROM products p
JOIN orderdetails od ON od.productCode=p.productCode
WHERE productLine = "Classic Cars";

SELECT productName,  priceEach, sum(quantityOrdered) as quantity_ordered
FROM products p
JOIN orderdetails od ON od.productCode=p.productCode
WHERE productLine = "CLassic Cars"
GROUP BY productName, priceEach;


######################### Benchmark and insights ####################################

#### regression for Ferrari 360 red: ordered quantity vs price per item
SELECT productName, quantityOrdered, priceEach
FROM products p
JOIN orderdetails od ON od.productCode=p.productCode
WHERE productLine = "Classic Cars" and productName = "1992 Ferrari 360 Spider red"
ORDER BY quantityOrdered ;

### classic cars return in USA
SELECT distinct(productName),c.country,p.productLine, quantityOrdered, (quantityOrdered * priceEach) as expected_return_per_product_per_order
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber=od.orderNumber
JOIN customers c ON c.customerNumber=o.customerNumber
WHERE c.country = "USA" and p.productLine = "Classic Cars"
ORDER BY productName;

## all classic cars
SELECt *
FROM products p
JOIN productlines pr ON p.productLine = pr.productLine
WHERE p.productLine = "Classic Cars";

## classic cars : priceeach vs MSRP
SELECt distinct(p.productName), p.productLine ,MSRP, priceEach
FROM products p
JOIN productlines pr ON p.productLine = pr.productLine
JOIN orderdetails od ON p.productCode= od.productCode
WHERE p.MSRP >= "150" and p.productLine = "Classic Cars";


SELECt *
FROM products p
JOIN productlines pr ON p.productLine = pr.productLine
JOIN orderdetails od ON p.productCode= od.productCode;

## clasic cars bought in quantities larger than 40 more than once in one order
SELECT p.productLine, p.productName, od.productCode, od.quantityOrdered, count(quantityOrdered) as how_many_times_ordered_quantity
FROM orderdetails od
JOIN products p ON p.productCode = od.productCode
WHERE p.productLine = "Classic Cars" and od.quantityOrdered > 40
GROUP BY quantityOrdered,productCode
HAVING how_many_times_ordered_quantity > 1;






