# Amazon Stock Data Analysis Using SQL (1997–2024)

This project focuses on analyzing Amazon's historical stock data from 1997 to 2024 using Structured Query Language (SQL). The goal is to extract meaningful business and trading insights using SQL-based techniques and queries.

Through this analysis, we explore Amazon’s price movements, trading behavior, performance trends, and anomalies across nearly three decades of stock market activity. The dataset includes daily values for open, high, low, close prices, and volume traded — which are used to compute indicators such as yearly returns, bullish/bearish days, moving averages, and more.

The project is divided into three levels:

- ✅ Easy Level – Basic descriptive statistics and general insights

- 📈 Intermediate Level – Monthly trends, spreads, streaks, and comparisons

- 🚀 Advanced Level – Moving averages, trading gaps, and significant price drawdowns

This project demonstrates strong SQL data analysis skills, handling of time series data, and the ability to convert raw financial data into insights that can support investment decisions or financial modeling. Perfect for showcasing on resumes, GitHub portfolios, or data science project collections.


## Column Descriptions

- **Date**: The calendar date corresponding to the trading session, formatted as YYYY-MM-DD. Each entry represents a unique trading day when the stock market was open.
- **Close**: The final price at which Amazon stock was traded at the end of the trading session. This is one of the most referenced prices for daily performance analysis.
- **High**: The highest price that the stock reached during the trading session. Useful for identifying intraday volatility and price spikes.
- **Low**: The lowest price at which the stock was traded during the session. Used alongside the high price to measure trading range and volatility.
- **Open**: The price at which Amazon stock began trading at the opening of the market on the given day. Comparing open and close prices can help identify daily trends.
- **Volume**: The total number of Amazon shares that were traded during the day. Volume is a key indicator of market activity and liquidity.

This structure enables users to perform a wide range of analyses, from simple visualizations to advanced machine learning and financial modeling.

---

## Objectives

### Easy Level Objectives

1. **What was the average closing price of Amazon stock per year?**  
   *Conclusion*: 1997 has the lowest avg_closing_price which is 0.16 and 2024 has the highest avg_closing_price 184.63.

2. **On how many days did Amazon stock close higher than it opened (bullish days)?**  
   *Conclusion*: 10647 days were there when Amazon stock close higher than it opened.

3. **On how many days did Amazon stock open higher than it closed (bearish days)?**  
   *Conclusion*: 10506 days were there when Amazon stock open higher than it closed.

4. **What is the highest stock price Amazon ever closed at, and on which date?**  
   *Conclusion*: 242.06 is the highest stock price Amazon ever closed at and on 2025-02-04.

5. **Which year had the highest total trading volume?**  
   *Conclusion*: 2025 has the highest year of total trading and it was 967219456600.

6. **How many trading days are there in the dataset overall?**  
   *Conclusion*: We have the total data of 21258 and trading occurred on all 21258 days — meaning there is no single day without trading.

---

### Intermediate Level Objectives

7. **What was the monthly average closing price of Amazon stock over the years?**  
   *Conclusion*: Lowest average closing price was in 1997-06 and 1997-05 (0.08), highest was 228.02 in 2025-01.

8. **Identify the top 3 highest volume trading days for each year.**

9. **Calculate the average high-low spread (High - Low) for each year.**  
   *Conclusion*: 2022 has the highest average spread of 4.5057 and 1997 has the lowest at 0.0111.

10. **Find the longest bullish streak (consecutive days where Close > Open).**  
    *Conclusion*: The longest bullish streak was 28 days.

11. **Compare average volume on bullish (Close > Open) vs. bearish days (Open > Close).**  
    *Conclusion*: Average bullish volume was 140561123; average bearish volume was 129097418.


### Advanced Level Objectives

12. **Detect Gaps in Trading Days (Missing Dates).**  
    *Conclusion*: There are many missing trading days where trading should have occurred. Recursive CTE was not feasible due to depth limitations (Error Code: 3636).

13. **20-Day Moving Average of Closing Price.**  
    *Conclusion*: The first 20 rows return NULLs due to insufficient prior data.

14. **Calculate the yearly return for Amazon stock.**  
    *Conclusion*: 1998 had the highest return (979.83%), and 2000 had the lowest (-82.59%).

15. **Find periods where Amazon stock dropped more than 20% from its recent high and stayed down for at least 30 consecutive trading days.**  
    *Conclusion*: Longest period of such a drop was 4203 days (starting on 2025-07-16); shortest was 30 days (starting on 1998-08-28).


## 🧠 Skills & Tools Demonstrated


- SQL Aggregation & Window Functions

- Recursive CTEs

- Financial Metrics: Moving Averages, Yearly Returns

- Data Cleaning & Time-Series Analysis

- Logical Thinking & Business Insight Extraction


## Example Queries

---
```
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

```

```

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

```





## How to Use

- Load Amazon_stock_data.csv into your preferred SQL database (MySQL / PostgreSQL recommended)

- Navigate to the Amazon Stock Analysis Project file and execute the SQL scripts corresponding to each objective

- Customize filters, thresholds, or metrics based on your interests and analytical goals

- Use the insights for dashboards, reports, or further predictive modeling


## License

This project is free for educational and non-commercial use.
Feel free to fork, improve, or reuse with credits.


## 📂 Dataset Source

Click Here to Get Dataset: https://drive.google.com/file/d/1RAb5_ptv-ZefzHm_h2jpg5NLOLQWEaLJ/view?usp=drive_link


## Let's Connect!

### Ashar Aftab 

Email: asharaftab2004@gmail.com

LinkedIn: www.linkedin.com/in/ashar-aftab-b09924295

---

> If you found this project useful or insightful, consider giving it a ⭐ on GitHub!


