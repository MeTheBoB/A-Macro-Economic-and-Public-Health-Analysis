
/*
================================================================================
PROJECT: Global Health & Infrastructure Development Analysis
OBJECTIVE: Clean, shape, and engineer metrics for emerging market assessment.
================================================================================
*/

SELECT  [Country]
      ,[Code]
      ,[Year]
      ,[Under-five mortality rate %]
      ,[% of people with access to basic hygiene services]
      ,[% of people with access to basic drinking water services]
      ,[% of people with access to basic sanitation services]
      ,[GDP per capita $]
      ,[Money committed to public private partnerships for infrastructure $]
      ,[Total official flows for infrastructure $]
      ,[Government expenditure on education, total (% of GDP)]
  FROM [WorldBank].[dbo].[BasicHealthandInfr]


-- Emerging Markets Segmentation: Identify "sweet spot" countries 
-- Filtering for emerging economies (GDP < 15k) with specific hygiene infrastructure benchmarks
SELECT [Country]
      ,[Code]
      ,[Year]
      ,[Under-five mortality rate %]
      ,[% of people with access to basic hygiene services]
      ,[% of people with access to basic drinking water services]
      ,[% of people with access to basic sanitation services]
      ,[GDP per capita $]
      ,[Money committed to public private partnerships for infrastructure $]
  FROM [WorldBank].[dbo].[BasicHealthandInfr]
  WHERE [Year] BETWEEN 2015 AND 2026
  AND [GDP per capita $] IS NOT NULL
  AND [GDP per capita $] < 15000 
  AND [% of people with access to basic hygiene services] BETWEEN 40 AND 80
  ORDER BY [Country] ASC, [Year] ASC;


-- YoY Growth Calculation: Quantify modernization velocity for Bangladesh
-- Utilizing LAG() window functions to compare period-over-period performance

SELECT 
    [Country]
   ,[Year]
   ,[Money committed to public private partnerships for infrastructure $]
   ,ROUND((([Money committed to public private partnerships for infrastructure $] - [Prev Money committed]) 
       * 100.0 / NULLIF([Prev Money committed], 0)), 2) AS [YoY % Growth $ Committed]
   ,[GDP per capita $] 
   ,ROUND((([GDP per capita $] - [Prev GDP per capita $]) 
       * 100.0 / NULLIF([Prev GDP per capita $], 0)), 2) AS [YoY % Growth GDP per capita]

FROM ( 
    SELECT 
        [Country]
       ,[Year]
       ,[GDP per capita $]
       ,[Money committed to public private partnerships for infrastructure $]
       -- Removed the '0' default so the first row correctly registers as NULL
       ,LAG([Money committed to public private partnerships for infrastructure $], 1) 
            OVER(PARTITION BY [Country] ORDER BY [Year]) AS [Prev Money committed]
       ,LAG([GDP per capita $], 1) 
            OVER(PARTITION BY [Country] ORDER BY [Year]) AS [Prev GDP per capita $]
    FROM [WorldBank].[dbo].[BasicHealthandInfr]
    WHERE [Year] BETWEEN 2015 AND 2026
    AND [GDP per capita $] IS NOT NULL
    AND [GDP per capita $] < 15000 
    AND [% of people with access to basic hygiene services] BETWEEN 40 AND 80
    AND [Country] = 'Bangladesh'
) AS T1
ORDER BY [Country] ASC, [Year] ASC;

--Bangladesh	2015	323590000	NULL	5352.71	NULL
--Bangladesh	2016	181090000	-44.04	5682.54	6.16
--Bangladesh	2017	644130000	255.7	6005.71	5.69
--Bangladesh	2018	606800000	-5.8	6392.59	6.44
--Bangladesh	2019	1016970000	67.6	6838.33	6.97
--Bangladesh	2020	2948000000	189.88	7015.2	2.59
--Bangladesh	2021	NULL	NULL	7441.07	6.07
--Bangladesh	2022	NULL	NULL	7888.16	6.01
--Bangladesh	2023	NULL	NULL	8242.4	4.49


--•	Rolling Averages for Infrastructure 5-Year Moving Average

-- Long-term Trend Analysis: 5-Year Rolling Average for Infrastructure
-- Smoothing volatile year-to-year investment data using a window function
SELECT [Country]
      ,[Code]
      ,[Year]
 
      ,[Money committed to public private partnerships for infrastructure $]
	  ,ROUND(AVG([Money committed to public private partnerships for infrastructure $]) OVER (
        PARTITION BY [Country] 
        ORDER BY [Year] ASC
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ),2) AS [5_Year_Moving_Average]

  FROM [WorldBank].[dbo].[BasicHealthandInfr]
  WHERE [Year] BETWEEN 2015 AND 2026
  AND [GDP per capita $] IS NOT NULL
  AND [GDP per capita $] < 15000 
  AND [% of people with access to basic hygiene services] BETWEEN 40 AND 70
  ORDER BY [Country] ASC, [Year] ASC;



-- Market Leaderboard: Rank countries by cumulative infrastructure investment

SELECT [Country]
	  ,SUM([Money committed to public private partnerships for infrastructure $]) AS Total_Infra_Investement
	  ,DENSE_RANK() OVER(ORDER BY SUM([Money committed to public private partnerships for infrastructure $]) desc) AS Investment_Rank
      
  FROM [WorldBank].[dbo].[BasicHealthandInfr]
  WHERE [Year] BETWEEN 2015 AND 2026
  AND [GDP per capita $] IS NOT NULL
  AND [GDP per capita $] < 15000 
  AND [% of people with access to basic hygiene services] BETWEEN 40 AND 70
  GROUP BY [Country]



-- Grouping Emerging Markets into 4 Wealth Tiers (Quartiles) based on average GDP
SELECT 
    [Country],
    ROUND(AVG([GDP per capita $]), 2) AS Avg_GDP,
    NTILE(4) OVER(ORDER BY AVG([GDP per capita $]) DESC) AS Wealth_Tier
FROM [WorldBank].[dbo].[BasicHealthandInfr]
WHERE [Year] BETWEEN 2015 AND 2026
AND [GDP per capita $] < 15000 
AND [% of people with access to basic hygiene services] BETWEEN 40 AND 80
GROUP BY [Country]
ORDER BY Wealth_Tier ASC, Avg_GDP DESC;





--Does an increase in "Government expenditure on education" strongly correlate with a drop in the "Under-five mortality rate"?
WITH CorrelationData AS (
    -- Step 1: Isolate the X and Y variables and filter out NULLs
    SELECT 
        CAST([Money committed to public private partnerships for infrastructure $] AS FLOAT) AS X,
        CAST([Under-five mortality rate %] AS FLOAT) AS Y
    FROM [WorldBank].[dbo].[BasicHealthandInfr]
    WHERE [Year] BETWEEN 2015 AND 2026
      AND [GDP per capita $] IS NOT NULL
      AND [GDP per capita $] < 15000 
      AND [% of people with access to basic hygiene services] BETWEEN 40 AND 80
      AND [Country] = 'Bangladesh'
      -- Crucial: Correlation requires both data points to exist in the same year
      AND [Government expenditure on education, total (% of GDP)] IS NOT NULL
      AND [Under-five mortality rate %] IS NOT NULL
)
SELECT 
    COUNT(*) AS Data_Points,
    ROUND(
        (COUNT(*) * SUM(X * Y) - SUM(X) * SUM(Y)) 
        / 
        NULLIF(
            SQRT(
                (COUNT(*) * SUM(X * X) - POWER(SUM(X), 2)) * 
                (COUNT(*) * SUM(Y * Y) - POWER(SUM(Y), 2))
            )
        , 0)
    , 4) AS Pearson_Correlation
FROM CorrelationData;



--Benchmarking: Compare country-specific mortality vs. global annual average 
WITH benchmarking as (
SELECT [Country]
      ,[Year]
	  ,[Under-five mortality rate %]
      ,round(AVG([Under-five mortality rate %]) OVER(PARTITION BY [Year]),2) AS Global_Average_For_Year
  FROM [WorldBank].[dbo].[BasicHealthandInfr]
  WHERE [Year] BETWEEN 2015 AND 2026
  AND [GDP per capita $] IS NOT NULL
  AND [GDP per capita $] < 15000 
  AND [% of people with access to basic hygiene services] BETWEEN 40 AND 80
) 
SELECT *
       ,round(([Under-five mortality rate %] - Global_Average_For_Year),2) AS [Difference_From_Average]
       ,round((([Under-five mortality rate %] / Global_Average_For_Year) - 1) * 100,2) as [Difference_From_Average%]
	   FROM benchmarking
       ---WHERE [Country] = 'Bangladesh'