CREATE DATABASE Amazon;
USE Amazon;
CREATE TABLE Amazon_Stock (
    Date DATE,
    Close FLOAT,
    High FLOAT,
    Low FLOAT,
    Open FLOAT,
    Volume BIGINT,
    Year INT
);
LOAD DATA LOCAL INFILE 'C:/Users/kk/Desktop/Amazon Project(SQL)/Amazon_stock_data.csv'
INTO TABLE Amazon_Stock
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Date, Close, High, Low, Open, Volume, Year)
SET Date = STR_TO_DATE(@Date, '%d-%m-%y');
SELECT COUNT(*) FROM Amazon_Stock;

UPDATE Amazon_Stock
SET Year = YEAR(Date)
WHERE Date IS NOT NULL;

--                    ----------EASY LEVEL OBJECTIVES----------	
                        
-- OBJECTIVE NO.1: What was the average closing price of Amazon stock per year?
SELECT YEAR,ROUND(AVG(Close),2) AS Avg_Closing_Price
FROM Amazon_Stock
GROUP BY YEAR
ORDER BY YEAR;
-- CONCLUSION: 1997 has the lowest avg_closing_price which is 0.16 and 2024 has the highest avg_closing_price 184.63.

-- OBJECTIVE NO.2:  On how many days did Amazon stock close higher than it opened (bullish days)?
SELECT COUNT(*) AS Bullish_Days
FROM Amazon_Stock
WHERE Close>Open;
-- CONCLUSION: 10647 days were there when Amazon stock close higher than it opened.

-- OPTIONAL OBJECTIVE:  What % of days were bullish (Close > Open)?
SELECT 
  (COUNT(CASE WHEN Close > Open THEN 1 END) * 100.0) / COUNT(*) AS Bullish_Percentage
FROM Amazon_Stock;

-- -- OBJECTIVE NO.3:  On how many days did Amazon stock open higher than it closed (bearish days)?
SELECT COUNT(*) AS Bearish_Days
FROM Amazon_Stock
WHERE Close<Open;
-- CONCLUSION: 10506 days were there when Amazon stock open higher than it closed

-- OPTIONAL OBJECTIVE:  What % of days were bearish (Close < Open)?
SELECT
	(COUNT(CASE WHEN Close < Open THEN 1 END)* 100.0) / COUNT(*) AS Bearish_Percentage
FROM Amazon_stock;

-- OPTIONAL OBJECTIVE: What % of days were level (Close = Open)?
SELECT
	(COUNT(CASE WHEN Close = Open THEN 1 END)* 100.0) / COUNT(*) AS level_Percentage
FROM Amazon_stock;

-- OBJECTIVE NO.4: What is the highest stock price Amazon ever closed at, and on which date?
SELECT Date,Close
	FROM Amazon_Stock
ORDER BY Close DESC
LIMIT 1;
-- CONCLUSION: 242.06 is the higest stock price Amazon ever closed at and on 2025-02-04.

-- OPTIONAL OBJECTIVE: What is the lowest stock price Amazon ever closed at, and on which date?
SELECT Date,Close
	FROM Amazon_Stock
ORDER BY Close ASC
LIMIT 1;

-- OBJECTIVE NO.5: Which year had the highest total trading volume?
SELECT Year, SUM(Volume) AS total_trading_volume
FROM Amazon_Stock
GROUP BY Year
ORDER BY total_trading_volume DESC
LIMIT 1;
-- CONCLUSION: 2025 has the highest year of total trading and it was 967219456600

-- OBJECTIVE NO.6: How many trading days are there in the dataset overall?
SELECT COUNT(*) AS total_trading_days
FROM Amazon_Stock;
-- CONCLUSION: We have the total data of 21258 and trading occur in all 21258 days it means that there is no single day when trading won't happened.

--                    ----------INTERMEDIATE LEVEL OBJECTIVES----------	

-- OBJECTIVE NO.7: What was the monthly average closing price of Amazon stock over the years?
SELECT
	DATE_FORMAT(Date, '%Y-%m') AS Year_Months,
    ROUND(AVG(Close),2) AS Avg_Close
FROM Amazon_Stock
GROUP BY Year_Months
ORDER BY Avg_Close DESC;

-- CONCLUSION: By the result we conclude that the lowest average closing price is in 1997_06 and 1997-05 which is 0.08 and highest is 228.02 which is in 2025-01

-- OBJECTIVE NO.8: Identify the top 3 highest volume trading days for each year.
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Year ORDER BY Volume DESC) AS volume_rank
    FROM Amazon_Stock
) AS ranked_data
WHERE volume_rank <= 3;

-- OBJECTIVE NO.9:  Calculate the average high-low spread (High - Low) for each year.
SELECT
	Year,
    ROUND(AVG(High-low),4) AS Avg_spreading
FROM Amazon_Stock
GROUP BY Year
ORDER BY Avg_spreading DESC;

-- CONCLUSION: 2022 has the highest average spreading which is 4.5057 and 1997 has the lowest which is 0.0111.

-- OBJECTIVE 10: Find the longest bullish streak (consecutive days where Close > Open).
WITH Bullish_Data AS (
    SELECT 
        Date,
        Close,
        Open,
        CASE 
            WHEN Close > Open THEN 1 
            ELSE 0 
        END AS Is_Bullish
    FROM Amazon_Stock
),
Streak_Grouped AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY Date) -
           ROW_NUMBER() OVER (PARTITION BY Is_Bullish ORDER BY Date) AS Streak_Group
    FROM Bullish_Data
),
Bullish_Streaks AS (
    SELECT 
        Streak_Group,
        COUNT(*) AS Streak_Length,
        MIN(Date) AS Start_Date,
        MAX(Date) AS End_Date
    FROM Streak_Grouped
    WHERE Is_Bullish = 1
    GROUP BY Streak_Group
)
SELECT *
FROM Bullish_Streaks
ORDER BY Streak_Length DESC
LIMIT 10;
-- CONCLUSION: The longest Bullish Streak is of 28 length.

-- OBJECTIVE NO.11: Compare average volume on bullish(Close>Open) vs. bearish days(Open>Close).
SELECT
	ROUND(AVG(CASE WHEN Close>Open Then Volume END),0) AS Avg_Bullish_Vol,
    ROUND(AVG(CASE WHEN Close<Open Then Volume END),0) AS Avg_Bearish_Vol
FROM Amazon_Stock;
-- CONCLUSION: Average Bullish volume is 140561123 and Average Bearish volume is 129097418

--                    ----------ADVANCED LEVEL OBJECTIVES----------	

-- OBJECTIVE NO.12: Detect Gaps in Trading Days (Missing Dates).

-- Generate 10,000 rows using cross join
WITH numbers AS (
  SELECT a.N + b.N * 10 + c.N * 100 + d.N * 1000 AS num
  FROM 
    (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
    (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
    (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c,
    (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) d
),

-- Generate calendar dates
calendar AS (
  SELECT DATE_ADD((SELECT MIN(Date) FROM Amazon_Stock), INTERVAL num DAY) AS cal_date
  FROM numbers
  WHERE DATE_ADD((SELECT MIN(Date) FROM Amazon_Stock), INTERVAL num DAY) <= (SELECT MAX(Date) FROM Amazon_Stock)
)

-- Find missing trading weekdays
SELECT 
  cal_date AS Missing_Trading_Date
FROM 
  calendar
LEFT JOIN 
  Amazon_Stock a ON calendar.cal_date = a.Date
WHERE 
  DAYOFWEEK(cal_date) BETWEEN 2 AND 6  -- Only Mon-Fri
  AND a.Date IS NULL
ORDER BY cal_date;

-- CONCLUSION: There are many days which are missing on which trading should be done but not happened and also could not able to use recursive function due to limitation of recursion exceeding(Error Code: 3636)

-- OBJECTIVE NO.13: Make a 20-Day Moving Average of Closing Price.
SELECT 
    Date,
    Close,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY Date) >= 20 THEN
            ROUND(AVG(Close) OVER (
                ORDER BY Date
                ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
            ), 2)
        ELSE NULL
    END AS Moving_Avg_20Day
FROM 
    Amazon_Stock;

-- CONCLUSION: The first 20 rows should be null because there are not enough data to compute average.

-- OBJECTIVE NO.14: Calculate the yearly return for Amazon stock 
WITH Yearly_Close AS (
    SELECT
        YEAR(Date) AS Year,
        FIRST_VALUE(Close) OVER (PARTITION BY YEAR(Date) ORDER BY Date) AS First_Close,
        LAST_VALUE(Close) OVER (
            PARTITION BY YEAR(Date)
            ORDER BY Date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS Last_Close
    FROM Amazon_Stock
)
SELECT
    Year,
    ROUND(AVG(First_Close), 2) AS First_Close,
    ROUND(AVG(Last_Close), 2) AS Last_Close,
    ROUND(((AVG(Last_Close) - AVG(First_Close)) / AVG(First_Close)) * 100, 2) AS Yearly_Return_Percentage
FROM Yearly_Close
GROUP BY Year
ORDER BY Yearly_Return_Percentage DESC;

-- CONCLUSION: 1998 has the highest yearly return percentage which is 979.83 and in 2000 which is -82.59.

-- OBJECTIVE NO.16: Find periods where Amazon stock dropped more than 20% from its recent high and stayed down for at least 30 consecutive trading days.
WITH Price_Track AS (
    SELECT 
        Date,
        Close,
        MAX(Close) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Recent_High,
        ROW_NUMBER() OVER (ORDER BY Date) AS rn
    FROM Amazon_Stock
),
Drawdown_Flagged AS (
    SELECT 
        *,
        CASE 
            WHEN Close <= Recent_High * 0.8 THEN 1
            ELSE 0
        END AS Is_Drawdown
    FROM Price_Track
),

Drawdown_Groups AS (
    SELECT *,
        rn - ROW_NUMBER() OVER (PARTITION BY Is_Drawdown ORDER BY rn) AS grp
    FROM Drawdown_Flagged
),

Drawdown_Periods AS (
    SELECT 
        MIN(Date) AS Start_Date,
        MAX(Date) AS End_Date,
        COUNT(*) AS Duration_Days
    FROM Drawdown_Groups
    WHERE Is_Drawdown = 1
    GROUP BY grp
    HAVING Duration_Days >= 30
)

SELECT * FROM Drawdown_Periods
ORDER BY Start_Date;

-- CONCLUSION: The highest period where Amazon stock dropped more than 20% from its recent high and stayed down for at least 30 consecutive trading day are 4203 days and date is 2025-07-16 and lowest is 30 and date is 1998-08-28.