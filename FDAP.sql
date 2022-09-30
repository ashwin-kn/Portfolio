SELECT *
FROM PortfolioProject..HDFCBANK

SELECT *
FROM PortfolioProject..ONGC

SELECT *
FROM PortfolioProject..TCS


/*Adding a new date column without showing the time, in all the tables*/

/*SELECT *, CONVERT (nvarchar, Date, 23)
FROM HDFCBANK*/

ALTER TABLE PortfolioProject..HDFCBANK
ADD New_Date nvarchar(400)

UPDATE PortfolioProject..HDFCBANK
SET New_Date = CONVERT(nvarchar(400), [Date], 23)

ALTER TABLE PortfolioProject..ONGC
ADD New_Date nvarchar(400)

UPDATE PortfolioProject..ONGC
SET New_Date = CONVERT(nvarchar(400), [Date], 23)

ALTER TABLE PortfolioProject..TCS
ADD New_Date nvarchar(400)

UPDATE PortfolioProject..TCS
SET New_Date = CONVERT(nvarchar(400), [Date], 23)


/* Find the month with highest volume for each stock */

/*HDFCBANK*/

SELECT TOP (1) Symbol, Year(New_Date) AS Year, Month(New_Date) AS Month, MAX(Volume) AS Max_Volume
FROM PortfolioProject..HDFCBANK
GROUP BY Symbol, Year(New_Date), Month(New_Date)
ORDER BY MAX(Volume) DESC;

/*ONGC*/

SELECT TOP (1) Symbol, Year(New_Date) AS Year, Month(New_Date) AS Month, MAX(Volume) AS Max_Volume
FROM PortfolioProject..ONGC
GROUP BY Symbol, Year(New_Date), Month(New_Date)
ORDER BY MAX(Volume) DESC;

/*TCS*/

SELECT TOP (1) Symbol, Year(New_Date) AS Year, Month(New_Date) AS Month, MAX(Volume) AS Max_Volume
FROM PortfolioProject..TCS
GROUP BY Symbol, Year(New_Date), Month(New_Date)
ORDER BY MAX(Volume) DESC;


CREATE TABLE max_volume (
    Symbol varchar(255),
	[Year] SMALLINT,
	[Month] SMALLINT,
    Max_Volume float);

INSERT INTO max_volume (Symbol, [Year], [Month], Max_Volume)
VALUES 
	('HDFCBANK', 2017, 2, 100564990), 
	('ONGC', 2020, 3, 178593486), 
	('TCS', 2018, 3, 44033577);

SELECT *, DENSE_RANK() OVER(ORDER BY Max_Volume DESC) AS Max_Volume_Ranking
FROM max_volume;

/* The month and year with Max Volume:
ONGC = March 2020
HDFCBANK = February 2017
TCS = March 2018 */


/* Percentage(%) Delivery */

SELECT Symbol, ROUND((AVG([Deliverable Volume]/Volume)*100), 3) AS Average_Percentage_Deliverable_HDFCBANK
FROM PortfolioProject..HDFCBANK
GROUP BY Symbol;

SELECT Symbol, ROUND((AVG([Deliverable Volume]/Volume)*100), 3) AS Average_Percentage_Deliverable_ONGC
FROM PortfolioProject..ONGC
GROUP BY Symbol;

SELECT Symbol, ROUND((AVG([Deliverable Volume]/Volume)*100), 3) AS Average_Percentage_Deliverable_TCS
FROM PortfolioProject..TCS
GROUP BY Symbol;


CREATE TABLE [%delivery] (
    Symbol varchar(255),
    Average_Percentage_Deliverable float);

INSERT INTO [%delivery] (Symbol, Average_Percentage_Deliverable)
VALUES 
	('HDFCBANK', 58.622), 
	('ONGC', 54.617), 
	('TCS', 57.356);

SELECT *, DENSE_RANK() OVER(ORDER BY Average_Percentage_Deliverable DESC) AS [Rank]
FROM [%delivery];


/* 50 days Moving Average */

SELECT Symbol, [Close], New_Date, AVG([Close]) OVER (ORDER BY New_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS [50_Day_Moving_Average_HDFCBANK]
FROM PortfolioProject..HDFCBANK
ORDER BY New_Date;

SELECT Symbol, [Close], New_Date, AVG([Close]) OVER (ORDER BY New_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS [50_Day_Moving_Average_ONGC]
FROM PortfolioProject..ONGC
ORDER BY New_Date;

SELECT Symbol, [Close], New_Date, AVG([Close]) OVER (ORDER BY New_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS [50_Day_Moving_Average_TCS]
FROM PortfolioProject..TCS
ORDER BY New_Date;


/* MAIN ANALYSIS */
/* Q.1 Find the Volatility of all the companies and compare them */

GO

CREATE VIEW Volatility AS (SELECT Symbol, [High], [Low] FROM HDFCBANK
UNION
SELECT Symbol, [High], [Low] FROM ONGC
UNION
SELECT Symbol, [High], [Low] FROM TCS);

SELECT * FROM Volatility

SELECT Symbol, ROUND(AVG(High-Low), 2) AS Average_Volatility, DENSE_RANK() OVER(ORDER BY AVG(High-Low)) AS Ranking
FROM Volatility
GROUP BY Symbol;

/*Result - ONGC is the least Volatile and TCS is the most Volatile*/


/* Q.2 Which stock fell the least during the Covid times? (Drawdown) (Time period - 20.02.2020 - 31.03.2020)*/

/*Find the fall in stock price of HDFC Bank*/

DECLARE @pre_covid_price_hdfcbank float
DECLARE @post_covid_price_hdfcbank float

SET @pre_covid_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK 
WHERE New_Date = '2020-02-20');

SET @post_covid_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK
WHERE New_Date = '2020-03-31');

--SELECT @pre_covid_price_hdfcbank; /*1217.1*/
--SELECT @post_covid_price_hdfcbank; /*861.9*/

SELECT ROUND(((-@pre_covid_price_hdfcbank+@post_covid_price_hdfcbank)/@pre_covid_price_hdfcbank), 4) * 100
  AS hdfcbank_drawdown;

/*The stock price of HDFC Bank fell by 29.18% during the COVID fall*/

/*Find the fall in stock price of ONGC*/

DECLARE @pre_covid_price_ongc AS float
DECLARE @post_covid_price_ongc AS float

SET @pre_covid_price_ongc = (SELECT [Close] FROM PortfolioProject..ONGC 
WHERE New_Date = '2020-02-20');

SET @post_covid_price_ongc = (SELECT [Close] FROM PortfolioProject..ONGC
WHERE New_Date = '2020-03-31');

--SELECT @pre_covid_price_ongc; /*102.8*/
--SELECT @post_covid_price_ongc; /*68.3*/

SELECT ROUND(((-@pre_covid_price_ongc+@post_covid_price_ongc)/@pre_covid_price_ongc), 4) * 100
  AS ongc_drawdown;

/*The stock price of ONGC fell by 33.56% during the COVID fall*/

/*Find the fall in stock price of TCS*/

DECLARE @pre_covid_price_tcs AS float
DECLARE @post_covid_price_tcs AS float

SET @pre_covid_price_tcs = (SELECT [Close] FROM PortfolioProject..TCS 
WHERE New_Date = '2020-02-20');

SET @post_covid_price_tcs = (SELECT [Close] FROM PortfolioProject..TCS
WHERE New_Date = '2020-03-31');

--SELECT @pre_covid_price_tcs; /*2156.8*/
--SELECT @post_covid_price_tcs; /*1826.1*/

SELECT ROUND(((-@pre_covid_price_tcs+@post_covid_price_tcs)/@pre_covid_price_tcs), 4) * 100
  AS tcs_drawdown;

/*The stock price of TCS fell by 15.33% during the COVID fall*/

/* The drawdown of the stocks are as mentioned below:
HDFCBANK: -29.18%
ONGC: -33.56%
TCS: -15.33% */


CREATE TABLE covid_fall_percentage (
    Symbol varchar(255),
    percentage_fall float);

INSERT INTO covid_fall_percentage (Symbol, percentage_fall)
VALUES ('HDFCBANK', -29.18), ('ONGC', -33.56), ('TCS', -15.33);

SELECT *, DENSE_RANK() OVER(ORDER BY percentage_fall DESC) AS Ranking
FROM covid_fall_percentage

/*Result: TCS' stock price fell the least (least drawdown) while ONGC's stock price fell the most (most drawdown)*/


/* Q.3 How many days did it take for the stock price to rise to its pre-Covid levels? (Recovery Days) */

/*HDFC BANK*/

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


/*ONGC*/

DECLARE @pre_covid_price_ongc float, @date_close_more_than_pre_covid_ongc date;

SET @pre_covid_price_ongc = (SELECT [Close] FROM PortfolioProject..ONGC 
WHERE New_Date = '2020-02-20');

SET @date_close_more_than_pre_covid_ongc =
	(SELECT New_Date FROM (
		SELECT New_Date, [Close], ROW_NUMBER () OVER (ORDER BY New_Date) As rank_based_on_new_date 
		FROM PortfolioProject..ONGC
		WHERE New_Date BETWEEN '2020-03-31' AND '2021-04-30' AND [Close] >= @pre_covid_price_ongc
	) AS A2
WHERE rank_based_on_new_date = 1);

SELECT @date_close_more_than_pre_covid_ongc AS RECOVERY_DAYS

SELECT DATEDIFF (day, '2020-03-31', @date_close_more_than_pre_covid_ongc)
 AS days_req_by_ongc_stock_price_to_close_above_its_pre_covid_level;


/*TCS*/

DECLARE @pre_covid_price_tcs float, @date_close_more_than_pre_covid_tcs date;

SET @pre_covid_price_tcs = (SELECT [Close] FROM PortfolioProject..TCS 
WHERE New_Date = '2020-02-20');

SET @date_close_more_than_pre_covid_tcs =
	(SELECT New_Date FROM (
		SELECT New_Date, [Close], ROW_NUMBER () OVER (ORDER BY New_Date) As rank_based_on_new_date 
		FROM PortfolioProject..TCS
		WHERE New_Date BETWEEN '2020-03-31' AND '2021-04-30' AND [Close] >= @pre_covid_price_tcs
	) AS A3
WHERE rank_based_on_new_date = 1);

SELECT @date_close_more_than_pre_covid_tcs AS RECOVERY_DAYS

SELECT DATEDIFF (day, '2020-03-31', @date_close_more_than_pre_covid_tcs)
 AS days_req_by_ongc_stock_price_to_close_above_its_pre_covid_level;

/*Number of days took for each stock to close above the pre-covid close price level:
	HDFCBANK = 192 days
	ONGC = 260 days
	TCS = 93 days */


CREATE TABLE recovery_days (
    Symbol varchar(255),
    recovery_days_pre_covid_levels int);

INSERT INTO recovery_days (Symbol, recovery_days_pre_covid_levels)
VALUES ('HDFCBANK', 192), ('ONGC', 260), ('TCS', 93);

SELECT *, DENSE_RANK() OVER(ORDER BY recovery_days_pre_covid_levels) AS Ranking
FROM recovery_days

/*TCS had the fastest recovery while ONGC had the slowest*/


/* Q.4 Number of days the stock price closed above its previous day close price (To check the Strength of the stock) */

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

/*Total number of days when the stock price closed above its previous day closing price (to measure the strength of the stock):
	TCS	= 1448 days
	HDFCBANK = 1441 days
	ONGC = 1385 days */


/* Q.5 CAGR Calculation */

/*HDFCBANK_CAGR*/

DECLARE @beginning_price_hdfcbank float, @ending_price_hdfcbank float, @no_of_years_hdfcbank float;

SET @beginning_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK WHERE New_Date = '2010-01-04');
SET @ending_price_hdfcbank = (SELECT [Close] FROM PortfolioProject..HDFCBANK WHERE New_Date = '2021-04-30');

SET @no_of_years_hdfcbank = (SELECT ROUND (DATEDIFF (day, '2010-01-04', '2021-04-30') / 365, 3));

--SELECT @beginning_price_hdfcbank /*Price as on 2010-01-04 = 1705.7*/
--SELECT @ending_price_hdfcbank /*Price as on 2021-04-30 = 1412.3*/

--SELECT @no_of_years_hdfcbank /*Total number of years = 11*/

SELECT ROUND((POWER((@ending_price_hdfcbank/@beginning_price_hdfcbank), 1/@no_of_years_hdfcbank) - 1) * 100, 4) AS HDFCBANK_CAGR;


/*ONGC_CAGR*/

DECLARE @beginning_price_ongc float, @ending_price_ongc float, @no_of_years_ongc float;

SET @beginning_price_ongc = (SELECT [Close] FROM PortfolioProject..ONGC WHERE New_Date = '2010-01-04');
SET @ending_price_ongc = (SELECT [Close] FROM PortfolioProject..ONGC WHERE New_Date = '2021-04-30');

SET @no_of_years_ongc = (SELECT ROUND (DATEDIFF (day, '2010-01-04', '2021-04-30') / 365, 3));

--SELECT @beginning_price_ongc /*Price as on 2010-01-04 = 1187.45*/
--SELECT @ending_price_ongc /*Price as on 2021-04-30 = 108.15*/

--SELECT @no_of_years_ongc /*Total number of years = 11*/

SELECT ROUND((POWER((@ending_price_ongc/@beginning_price_ongc), 1/@no_of_years_ongc) - 1) * 100, 4) AS ONGC_CAGR;


/*TCS_CAGR*/

DECLARE @beginning_price_tcs float, @ending_price_tcs float, @no_of_years_tcs float;

SET @beginning_price_tcs = (SELECT [Close] FROM PortfolioProject..TCS WHERE New_Date = '2010-01-04');
SET @ending_price_tcs = (SELECT [Close] FROM PortfolioProject..TCS WHERE New_Date = '2021-04-30');

SET @no_of_years_tcs = (SELECT ROUND (DATEDIFF (day, '2010-01-04', '2021-04-30') / 365, 3));

--SELECT @beginning_price_tcs /*Price as on 2010-01-04 = 751.65*/
--SELECT @ending_price_tcs /*Price as on 2021-04-30 = 3035.65*/

--SELECT @no_of_years_tcs /*Total number of years = 11*/

SELECT ROUND((POWER((@ending_price_tcs/@beginning_price_tcs), 1/@no_of_years_tcs) - 1) * 100, 4) AS TCS_CAGR;

/*CAGR of all the companies:
	HDFCBANK = -1.7013
	ONGC = -19.5732
	TCS = 13.5305 */


CREATE TABLE cagr (
    Symbol varchar(255),
    CAGR float);

INSERT INTO cagr (Symbol, CAGR)
VALUES ('HDFCBANK', -1.7013), ('ONGC', -19.5732), ('TCS', 13.5305);

SELECT *, DENSE_RANK() OVER(ORDER BY CAGR DESC) AS CAGR_Ranking
FROM cagr


/* 
FINAL SCORING OF THE STOCKS BASED ON THE PARAMETERS THAT WE HAVE DISCUSSED ABOVE

1. VOLATILITY

Average volatility of all the stocks are as mentioned below:
	ONGC = 8.97
	HDFCBANK = 26.3
	TCS = 44.52
From analysis, we can understand that ONGC is the least volatile stock and TCS is the most volatile stock.

Hence, scores based on Volatiltiy are:
	ONGC - 3
	HDFCBANK - 2
	TCS - 1

2. DRAWDOWN (Fall during Covid period)

The drawdown of the stocks are as mentioned below:
	HDFCBANK = -29.18%
	ONGC = -33.56%
	TCS = -15.33% 
ONGC's stock price dropped the most (most drawdown), whereas TCS' stock price dropped the least (had the smallest drawdown).

Hence, scores based on Drawdown are:
	TCS - 3
	HDFCBANK - 2
	ONGC - 1

3. RECOVERY DAYS

Number of days it took for each stock to close above the pre-covid close price level is:
	HDFCBANK = 192 days
	ONGC = 260 days
	TCS = 93 days
TCS had the fastest recovery while ONGC had the slowest.

Hence, scores based on Recovery days are:
	TCS - 3
	HDFCBANK - 2
	ONGC - 1

4. NUMBER OF DAYS THE STOCK PRICE CLOSED ABOVE ITS PREVIOUS DAY CLOSE PRICE (STRENGTH):

Total number of days when the stock price closed above its previous day closing price (to measure the strength of the stock):
	TCS	= 1448 days
	HDFCBANK = 1441 days
	ONGC = 1385 days 
From the above analysis we can say that TCS has the most strength while ONGC had the least.

Hence, scores based on Strength are:
	TCS - 3
	HDFCBANK - 2
	ONGC - 1

5. CAGR RETURNS

	HDFCBANK = -1.7013
	ONGC = -19.5732
	TCS = 13.5305 
TCS has the highest CAGR while ONGC has the lowest.

Hence, scores based on Strength are:
	TCS - 3
	HDFCBANK - 2
	ONGC - 1
*/


CREATE TABLE Score_Table (Symbol varchar(100), [Description] varchar(100), Score int);

INSERT INTO Score_Table (Symbol,[Description], Score)
VALUES
('HDFCBANK', 'Volatility', 2), ('ONGC', 'Volatility', 3), ('TCS', 'Volatility', 1),
('HDFCBANK', 'Lower_Drawdown', 2), ('ONGC', 'Lower_Drawdown', 1), ('TCS', 'Lower_Drawdown', 3),
('HDFCBANK', 'Faster_Recovery', 2), ('ONGC', 'Faster_Recovery', 1), ('TCS', 'Faster_Recovery', 3),
('HDFCBANK', 'Strength', 2), ('ONGC', 'Strength', 1), ('TCS', 'Strength', 3),
('HDFCBANK', 'CAGR', 2), ('ONGC', 'CAGR', 1), ('TCS', 'CAGR', 3);

--SELECT * FROM Score_Table

CREATE TABLE Weightage_Table ([Description] varchar(100), Weightage decimal(2,2));

INSERT INTO Weightage_Table ([Description] , Weightage)
VALUES
('Volatility', 0.2), ('Lower_Drawdown', 0.2), ('Faster_Recovery', 0.2), ('Strength', 0.2), ('CAGR', 0.2);

--SELECT * FROM Weightage_Table

SELECT Symbol, ST.[Description], Score, Weightage
FROM Score_Table AS ST
INNER JOIN Weightage_Table AS WT ON ST.[Description] = WT.[Description];

/*Calculalting the Final Score*/

SELECT Symbol, SUM (SCORE*WEIGHTAGE) AS Final_Score
FROM Score_Table AS ST
INNER JOIN Weightage_Table AS WT ON ST.[Description] = WT.[Description]
GROUP BY Symbol
ORDER BY Final_Score DESC;