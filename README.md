# Stock Analysis using SQL

## Table of Contents

- [Introduction](#introduction)
- [Preparation of Data](#preparation-of-data)
- [Main Analysis](#main-analysis)
  - [Volatility Comparison](#q1-find-the-volatility-of-all-the-companies-and-compare-them)
  - [Drawdown Analysis](#q2-which-stock-fell-the-least-during-the-covid-times-drawdown-time-period---20022020---31032020)
  - [Recovery Days Calculation](#q3-how-many-days-did-it-take-for-the-stock-price-to-rise-to-its-pre-covid-levels-recovery-days)
  - [Strength Measurement](#q4-number-of-days-the-stock-price-closed-above-its-previous-day-close-price-to-check-the-strength-of-the-stock)
  - [CAGR Calculation](#q5-cagr-calculation)
- [Final Score Calculation](#final-score-calculation)
- [Final Score Table](#final-score-table)

## Introduction

This project aims to compare and grade different companies based on various financial metrics such as volatility, drawdown percentage, recovery days, strength, and Compound Annual Growth Rate (CAGR). The analysis is performed on three companies: HDFC Bank, Oil and Natural Gas Corporation (ONGC), and Tata Consultancy Services (TCS) using historical stock market data obtained from Kaggle.

### Data Source

The datasets for HDFC Bank, ONGC, and TCS cover the time period from April 1, 2010, to April 30, 2021, and include attributes such as Date, Symbol, Open, High, Low, Close, VWAP, Volume, and Deliverable Volume.

## Preparation of Data

Before conducting the main analysis, the data undergoes preparation steps, including adding a new date column without the time and finding the month with the highest volume for each stock.

```sql
-- Preparation steps

-- Adding a new date column without showing the time, in all the tables. Eg.,

-- ALTER TABLE PortfolioProject..HDFCBANK
ADD New_Date nvarchar(400)
UPDATE PortfolioProject..HDFCBANK
SET New_Date = CONVERT(nvarchar(400), [Date], 23)

-- Find the month with highest volume for each stock. Eg.,
-- SELECT TOP (1) Symbol, Year(New_Date) AS Year, Month(New_Date) AS Month, MAX(Volume) AS Max_Volume
FROM PortfolioProject..HDFCBANK
GROUP BY Symbol, Year(New_Date), Month(New_Date)
ORDER BY MAX(Volume) DESC;
```

## Main Analysis

### Q1. Find the Volatility of all the companies and compare them

Volatility is calculated as the average difference between the daily high and low prices for each stock.

```sql
-- Volatility Comparison
-- Code for volatility analysis goes here...
```

### Q2. Which stock fell the least during the Covid times? (Drawdown)

Drawdown percentage during the COVID-19 period (February 20, 2020, to March 31, 2020) is calculated for each stock.

```sql
-- Drawdown Analysis
-- Code for drawdown analysis goes here...
```

### Q3. How many days did it take for the stock price to rise to its pre-Covid levels? (Recovery Days)

Recovery days represent the number of days it took for each stock's price to surpass its pre-COVID levels.

```sql
-- Recovery Days Calculation
-- Code for recovery days calculation goes here...
```

### Q4. Number of days the stock price closed above its previous day close price (Strength)

Strength of each stock is measured by the total number of days its price closed above the previous day's closing price.

```sql
-- Strength Measurement
-- Code for strength measurement goes here...
```

### Q5. CAGR Calculation

Compound Annual Growth Rate (CAGR) is calculated to measure the annualized growth rate of each stock's price over the given time period.

```sql
-- CAGR Calculation
-- Code for CAGR calculation goes here...
```

## Final Score Calculation

Based on the analysis conducted for each metric, a final score is calculated for each stock, considering predefined weightages for each metric.

```sql
-- Final Score Calculation
-- Code for final score calculation goes here...
```

## Final Score Table

The final score table provides an overview of how each stock performs based on the analyzed metrics.

```sql
-- Final Score Table
-- Code for generating the final score table goes here...
```

This readme file provides an overview of the analysis conducted on the stock market data for HDFC Bank, ONGC, and TCS, including the main analysis questions, preparation of data, and the calculation of final scores for each stock.
