# Stock Analysis using SQL

## Table of Contents

- [Introduction](#introduction)
- [Preparation of Data](#preparation-of-data)
- [Main Analysis](#main-analysis)
  - [Volatility Comparison](#q1-find-the-volatility-of-all-the-companies-and-compare-them)
  - [Drawdown Analysis](#q2-which-stock-fell-the-least-during-the-covid-times-drawdown)
  - [Recovery Days Calculation](#q3-how-many-days-did-it-take-for-the-stock-price-to-rise-to-its-pre-covid-levels-recovery-days)
  - [Strength Measurement](#q4-number-of-days-the-stock-price-closed-above-its-previous-day-close-price-strength)
  - [CAGR Calculation](#q5-cagr-calculation)
- [Final Score Calculation](#final-score-calculation)
- [Final Score Table](#final-score-table)

## Introduction

This project aims to compare and grade different companies based on various financial metrics such as volatility, drawdown percentage, recovery days, strength, and Compound Annual Growth Rate (CAGR). The analysis is performed on three Indian companies: HDFC Bank, Oil and Natural Gas Corporation (ONGC), and Tata Consultancy Services (TCS) of National Stock Exchange (NSE), using historical stock market data obtained from [Kaggle](https://www.kaggle.com/datasets/rohanrao/nifty50-stock-market-data).

### Data Source

The datasets for HDFC Bank, ONGC, and TCS cover the time period from April 1, 2010, to April 30, 2021, and include attributes such as Date, Symbol, Open, High, Low, Close, VWAP, Volume, and Deliverable Volume.

## Preparation of Data

Before conducting the main analysis, the data underwent through some cleaning, preparation and some basic analysis, including adding a new date column without the time and finding the month with the highest volume for each stock.

Note: The database created for this project is called "PortfolioProject", which will be quoted throughout the documentation.

### Adding a New Date Column

```sql
-- Adding a new date column to the HDFCBANK table
ALTER TABLE PortfolioProject..HDFCBANK
ADD New_Date nvarchar(400)
```

This statement adds a new column named "New_Date" to the "HDFCBANK" table in the "PortfolioProject" database. The data type of the new column is set to `nvarchar(400)`, which allows storing variable-length Unicode character data with a maximum length of 400 characters.

```sql
-- Updating the New_Date column with formatted dates from the existing Date column
UPDATE PortfolioProject..HDFCBANK
SET New_Date = CONVERT(nvarchar(400), [Date], 23)
```

This statement updates the values in the "New_Date" column by converting the existing values from the "Date" column to a specific format. Here, the `CONVERT` function is used to convert the "Date" values to `nvarchar` data type with format 23, which represents the "YYYY-MM-DD" format. The converted dates are then stored in the "New_Date" column.

---

This code effectively extends the schema of the "HDFCBANK" table by adding a new column to store date values in a specific format, facilitating further analysis and querying based on dates in the desired format. _The same process is followed for the "ONGC" table, and "TCS" table_.


### Identifying the Month with the Highest Volume

This SQL code segment is designed to identify the month with the highest trading volume for each stock, specifically focusing on the "HDFCBANK" stock in this instance. Here's a breakdown of the code:

```sql
/*HDFCBANK*/
SELECT TOP (1) Symbol, Year(New_Date) AS Year, Month(New_Date) AS Month, MAX(Volume) AS Max_Volume
FROM PortfolioProject..HDFCBANK
GROUP BY Symbol, Year(New_Date), Month(New_Date)
ORDER BY MAX(Volume) DESC;
```

- **SELECT TOP (1)**: This clause ensures that only the top (or first) record is returned by the query, which corresponds to the month with the highest trading volume.

- **FROM PortfolioProject..HDFCBANK**: Specifies the table from which the data is being queried, in this case, the "HDFCBANK" table within the "PortfolioProject" database.

- **GROUP BY Symbol, Year(New_Date), Month(New_Date)**: Groups the data by the stock symbol, year, and month, allowing the calculation of maximum volume within each unique month.

- **ORDER BY MAX(Volume) DESC**: Orders the results by maximum volume in descending order, ensuring that the month with the highest volume appears first.

---

This code segment effectively retrieves information about the month with the highest trading volume for the HDFC Bank stock, providing insights into the stock's performance during periods of high trading activity. The same process is followed for the "ONGC" table, and "TCS" table.


***Further analysis like <ins> 50 days moving average </ins> and <ins> percentage delivery </ins> is calculated inorder to further understand the datasets. For that, please go to [Financial Data Analysis Project](Portfolio/Financial Data Analysis Project.sql) file***
<br>  </br>
## Main Analysis

### Q1. Find the Volatility of all the companies and compare them

Volatility is calculated as the average difference between the daily high and low prices for each stock.

The SQL code here calculates the volatility of each company's stock prices and compares them.

1. **Creating the Volatility View**: 
    - The code creates a view named `Volatility` using the `CREATE VIEW` statement.
    - The view is formed by combining the high and low prices of each company's stock (HDFCBANK, ONGC, and TCS) using the `UNION` operator.
    - The `SELECT` statement selects the `Symbol`, `High`, and `Low` columns from each company's table and combines them into a single view.

2. **Calculating Average Volatility and Ranking**:
    - The code calculates the average volatility for each company by subtracting the low price from the high price and taking the average for each company's stock prices.
    - The `ROUND` function is used to round the average volatility to two decimal places.
    - The `DENSE_RANK()` function is applied to rank the companies based on their average volatility in ascending order.

3. **Result**:
    - After executing the SQL code, the result will display the average volatility for each company, along with their rankings.
    - Based on the result, it indicates that ONGC has the least volatility, while TCS has the most volatility.


### Q2. Which stock fell the least during the Covid times? (Drawdown)

Drawdown percentage during the major covid period February 20, 2020, to March 31, 2020 is calculated for each stock.

1. **DECLARE**: This keyword is used to declare variables like `@pre_covid_price_hdfcbank` and `@post_covid_price_hdfcbank` to store the pre-COVID and post-COVID stock prices, respectively.

2. **SET**: These statements assign values to the declared variables. The first `SET` statement retrieves the closing price of the HDFCBANK stock on February 20, 2020 (pre-COVID period), while the second `SET` statement retrieves the closing price on March 31, 2020 (post-COVID period).

3. **SELECT**: This query calculates the drawdown percentage for the HDFCBANK stock during the COVID-19 period. It subtracts the pre-COVID price from the post-COVID price, divides the result by the pre-COVID price, and then multiplies by 100 to express the drawdown as a percentage.

---

The final output of this code snippet provides the drawdown percentage, indicating how much the HDFCBANK stock price declined during the COVID-19 period, offering insights into its performance during this significant market event.


### Q3. How many days did it take for the stock price to rise to its pre-Covid levels? (Recovery Days)

Recovery days represent the number of days it took for each stock's price to surpass its pre-COVID levels.

```sql
-- Recovery Days Calculation. Eg.,
DECLARE @pre_covid_price_hdfcbank float, @date_close_more_than_pre_covid_hdfcbank date;

SET @pre_covid_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK 
WHERE New_Date = '2020-02-20');

SET @date_close_more_than_pre_covid_hdfcbank =
	(SELECT New_Date FROM (
		SELECT New_Date, [Close], ROW_NUMBER () OVER (ORDER BY New_Date) As rank_based_on_new_date 
		FROM PortfolioProject..HDFCBANK
		WHERE New_Date BETWEEN '2020-03-31' AND '2021-04-30' AND [Close] >= @pre_covid_price_hdfcbank
	) AS A1
WHERE rank_based_on_new_date = 1);

SELECT @date_close_more_than_pre_covid_hdfcbank AS RECOVERY_DAYS

SELECT DATEDIFF (day, '2020-03-31', @date_close_more_than_pre_covid_hdfcbank)
 AS days_req_by_hdfcbank_stock_price_to_close_above_its_pre_covid_level;

-- Number of days it took for HDFCBANK to close above the pre-covid close price level is 192 days
```

### Q4. Number of days the stock price closed above its previous day close price (Strength)

Strength of each stock is measured by the total number of days its price closed above the previous day's closing price.

```sql
-- Strength Measurement
CREATE VIEW Strength AS (
	SELECT Symbol, New_Date, [Close] FROM PortfolioProject..HDFCBANK
	 UNION
	SELECT Symbol, New_Date, [Close] FROM PortfolioProject..ONGC
	 UNION
	SELECT Symbol, New_Date, [Close] FROM PortfolioProject..TCS);

SELECT *
FROM Strength

SELECT Symbol, SUM(IIF(([CLOSE] > prev_day_cc), 1, 0)) AS number_of_days_close_is_above_prev_day_close, DENSE_RANK() OVER(ORDER BY
 SUM(IIF(([CLOSE] > prev_day_cc), 1, 0)) DESC) AS [rank]
FROM
	(SELECT Symbol, New_Date, [Close], LAG([Close]) OVER(PARTITION BY Symbol ORDER BY New_Date) AS prev_day_cc
	 FROM Strength) AS xyz
GROUP BY Symbol;

-- Total number of days when the stock price closed above its previous day closing price (to measure the strength of the stock): TCS	= 1448 days, HDFCBANK = 1441 days, ONGC = 1385 days
```

### Q5. CAGR Calculation

Compound Annual Growth Rate (CAGR) is calculated to measure the annualized growth rate of each stock's price over the given time period.

```sql
-- CAGR Calculation, Eg.,
DECLARE @beginning_price_hdfcbank float, @ending_price_hdfcbank float, @no_of_years_hdfcbank float;

SET @beginning_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK WHERE New_Date = '2010-01-04');
SET @ending_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK WHERE New_Date = '2021-04-30');

SET @no_of_years_hdfcbank = (SELECT ROUND (DATEDIFF (day, '2010-01-04', '2021-04-30') / 365, 3));

SELECT ROUND((POWER((@ending_price_hdfcbank/@beginning_price_hdfcbank), 1/@no_of_years_hdfcbank) - 1) * 100, 4) AS HDFCBANK_CAGR;

-- CAGR of HDFCBANK = -1.7013

```

## Final Score Calculation

Based on the analysis conducted for each metric, a final score is calculated for each stock, considering predefined weightages for each metric.

## Final Score Table

The final score table provides an overview of how each stock performs based on the analyzed metrics. Please refer to the 'Financial Data Analysis Project.sql' file for further understanding.

This SQL code is creating two tables, `Score_Table` and `Weightage_Table`, and then performing operations to calculate the final score for each symbol based on certain metrics and their corresponding weightages.

1. The `Score_Table` is created with columns `Symbol`, `Description`, and `Score`. This table will hold the scores assigned to each symbol for different metrics such as volatility, drawdown, recovery, strength, and CAGR.

2. The `Weightage_Table` is created with columns `Description` and `Weightage`. This table contains the weightages assigned to each metric.

3. Next, data is inserted into both tables. For `Score_Table`, the scores for each symbol (`HDFCBANK`, `ONGC`, `TCS`) are assigned for each metric. For example, `HDFCBANK` has a score of 2 for volatility, lower drawdown, faster recovery, and CAGR, and a score of 2 for strength. Similarly, other symbols are assigned scores for each metric.

4. The `Weightage_Table` is populated with weightages for each metric. Each metric is assigned a weightage of 0.2, meaning they contribute equally to the final score.

5. Then, a SELECT statement is used to join `Score_Table` and `Weightage_Table` on the `Description` column to retrieve the scores and weightages for each symbol and metric.

6. Finally, the final score for each symbol is calculated by multiplying the score for each metric by its corresponding weightage, summing up the products, and grouping the results by symbol. This gives the weighted sum of scores for each symbol, providing an overall assessment of their performance across the metrics. The symbols are ordered in descending order of their final scores.

# Conclusion
This readme file provides an overview of the analysis conducted on the stock market data for HDFC Bank, ONGC, and TCS, including the main analysis questions, preparation of data, and the calculation of final scores for each stock.
