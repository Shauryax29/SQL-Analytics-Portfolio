use creditcard;

-- Count NULLs in columns
SELECT 
    SUM(CASE WHEN 'Id' IS NULL THEN 1 ELSE 0 END) AS index_null_count,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_null_count,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS date_null_count,
    SUM(CASE WHEN Card_Type IS NULL THEN 1 ELSE 0 END) AS card_null_count,
    SUM(CASE WHEN Exp_Type IS NULL THEN 1 ELSE 0 END) AS exp_null_count,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS gender_null_count,
    SUM(CASE WHEN Amount IS NULL THEN 1 ELSE 0 END) AS Amt_null_count
FROM transactions;  

-- Get the last date in the dataset
SELECT  MAX(Date) 
	FROM transactions;-- 26-may-2015 is the last date of dataset

SELECT MIN(Date)
	FROM transactions;  --  04-oct-2013  is the first date of dataset
			
-- Count Total records
select count(1) from transactions; -- total 26051 records

-- Frequency usage by city
SELECT City, COUNT(*) AS Frequency_Usage
FROM transactions
GROUP BY City
ORDER BY Frequency_Usage DESC;

-- Transaction frequency by Gender and Card Type
SELECT Gender, Card_Type, COUNT(*) AS Frequency_Usage
FROM transactions
GROUP BY Gender, Card_Type
ORDER BY Frequency_Usage DESC;              -- Females do more credit card transactions as compared to males.

-- Show me the transaction frequency by Gender and credit card type
SELECT Gender, Card_Type, COUNT(1) AS Total_users
FROM credit_card_transactions
GROUP BY Gender, Card_Type
ORDER BY Total_users DESC;

-- Show me the transactions frequency by Expense type and Gender
SELECT Gender, Exp_Type, COUNT(1) AS Frequency_Usage
FROM credit_card_transactions
GROUP BY Gender, Exp_Type
ORDER BY Frequency_Usage DESC; 

-- Show me Amount spent by Gender and Card Type
SELECT Gender, Card_Type, SUM(Amount) AS SpendingAmt_byExptype
FROM credit_card_transactions
GROUP BY Gender, Card_Type
ORDER BY SpendingAmt_byExptype DESC;


-- 1. write a query to print top 5 cities with highest spends 
--   and their percentage contribution of total credit card spends?
SELECT 
    City,
    SUM(Amount) AS Total_Spend,
    SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER () AS Percent_Contribution
FROM transactions
GROUP BY City
ORDER BY Total_Spend DESC
LIMIT 5;

-- 2.  write a query to print highest spend month and amount spent in that month for each card type
WITH rankedspends as(
SELECT card_type, date_format(date,'%Y-%m') as monthyear , SUM(AMOUNT) AS TotalMonthlySpend , ROW_NUMBER() OVER (
            PARTITION BY CARD_TYPE
            ORDER BY SUM(AMOUNT) DESC
        ) AS rn
    FROM
        transactions
    GROUP BY
        MonthYear, CARD_TYPE 
)
SELECT CARD_TYPE, MonthYear, TotalMonthlySpend
FROM RankedSpends WHERE rn = 1 
ORDER BY TotalMonthlySpend DESC;
 
  
-- 3. write a query to print the transaction details(all columns from the table) for each card type
--    when it reaches a cumulative of 10,00,000 total spends(We should have 4 rows in the o/p one for each card type)
WITH cumlative_card_spend as(
SELECT *, SUM(AMOUNT) OVER( PARTITION BY card_type ORDER BY `DATE`, ID) AS total_spend
from transactions)
SELECT * FROM (
				SELECT *, RANK() OVER(PARTITION BY CARD_TYPE ORDER BY total_spend) 
                as rn FROM cumlative_card_spend 
			WHERE TOTAL_SPEND >= 1000000 )
            AS A WHERE A.RN = 1 ;
            
-- 4. write a query to find city which had lowest percentage spend for gold card type
WITH CityCardStats AS (
    SELECT 
        City, 
        Card_Type, 
        SUM(Amount) as total_card_spend
    FROM transactions
    GROUP BY City, Card_Type
),
CityTotalStats AS (
    SELECT 
        City,
        Card_Type,
        total_card_spend,
        SUM(total_card_spend) OVER(PARTITION BY City) as total_city_spend,
        (total_card_spend * 100.0 / SUM(total_card_spend) OVER(PARTITION BY City)) as card_contribution
    FROM CityCardStats
)
SELECT City, card_contribution 
FROM CityTotalStats
WHERE Card_Type = 'Gold'
ORDER BY card_contribution ASC
LIMIT 1;

-- 5. write a query to print 3 columns: city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
WITH ranked AS (
    SELECT 
        city,
        exp_type,
        SUM(amount) AS total_amt,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(amount) DESC) AS rn_high,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(amount) ASC) AS rn_low
    FROM transactions
    GROUP BY city, exp_type
)
SELECT
    city,
    MAX(CASE WHEN rn_high = 1 THEN exp_type END) AS highest_expense_type,
    MAX(CASE WHEN rn_low  = 1 THEN exp_type END) AS lowest_expense_type
FROM ranked
GROUP BY city
ORDER BY city;

-- 6. write a query to find percentage contribution of spends by females for each expense type
select exp_type,
       sum(case when gender = 'F' then amount else 0 end)*1.0/sum(amount) as percentage_female_contribution
from transactions
group by exp_type
order by percentage_female_contribution desc;


-- 7. during weekends which city has highest total spend to total no of transactions ratio 
-- MySQL: use DAYOFWEEK (1=Sunday, 7=Saturday)
SELECT
    city,
    SUM(amount) * 1.0 / COUNT(*) AS ratio
FROM transactions
WHERE DAYOFWEEK(`date`) IN (1,7)
GROUP BY city
ORDER BY ratio DESC
LIMIT 1;
-- 8. which city took least number of days to reach its 500th transaction after first transaction in that city

WITH rn AS (
  SELECT
    `CITY`,
    `DATE`,
    ROW_NUMBER() OVER (PARTITION BY `CITY` ORDER BY `DATE`, `ID`) AS rn
  FROM `transactions`
)
SELECT
  `CITY`,
  DATEDIFF(
    MIN(CASE WHEN rn = 500 THEN `DATE` END),
    MIN(CASE WHEN rn = 1   THEN `DATE` END)
  ) AS days_to_500
FROM rn
GROUP BY `CITY`
HAVING MIN(CASE WHEN rn = 500 THEN `DATE` END) IS NOT NULL
ORDER BY days_to_500
LIMIT 1;




