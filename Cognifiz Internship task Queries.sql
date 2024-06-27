SELECT TOP (1000) [Restaurant ID]
      ,[Restaurant Name]
      ,[Country Code]
      ,[City]
      ,[Address]
      ,[Locality]
      ,[Locality Verbose]
      ,[Longitude]
      ,[Latitude]
      ,[Cuisines]
      ,[Average Cost for two]
      ,[Currency]
      ,[Has Table booking]
      ,[Has Online delivery]
      ,[Is delivering now]
      ,[Switch to order menu]
      ,[Price range]
      ,[Aggregate rating]
      ,[Rating color]
      ,[Rating text]
      ,[Votes]
  FROM [Restaurant].[dbo].['Dataset $']

                                                        ---- Level 1 ----

                                                           ---TASK1 ----
-

WITH TopCuisines AS (
    SELECT TOP 3
           Cuisines,
           COUNT(*) AS CuisineCount
    FROM [Restaurant].[dbo].['Dataset $']
    GROUP BY Cuisines
    ORDER BY CuisineCount DESC
),
RestaurantCount AS (
    SELECT COUNT(*) AS TotalRestaurants
    FROM [Restaurant].[dbo].['Dataset $']
),
CuisinePercentages AS (
    SELECT tc.Cuisines,
           tc.CuisineCount,
           (tc.CuisineCount * 100.0 / rc.TotalRestaurants) AS Percentage
    FROM TopCuisines tc
    CROSS JOIN RestaurantCount rc
)

SELECT Cuisines,
       CuisineCount,
       Percentage
FROM CuisinePercentages;


------task 2 ------

;WITH CityRestaurantCount AS (
    -- Step 1: Identify the city with the highest number of restaurants
    SELECT TOP 1 WITH TIES
           City,
           COUNT(*) AS RestaurantCount
    FROM [Restaurant].[dbo].['Dataset $']  
    GROUP BY City
    ORDER BY COUNT(*) DESC
),
CityAverageRating AS (
    -- Step 2: Calculate the average rating for restaurants in each city
    SELECT City,
           AVG([Aggregate rating]) AS AverageRating
    FROM [Restaurant].[dbo].['Dataset $'] 
    GROUP BY City
)

-- Step 3: Determine the city with the highest average rating
SELECT TOP 1
       'City with Highest Number of Restaurants' AS Metric,
       City,
       RestaurantCount AS Value
FROM CityRestaurantCount

UNION ALL

SELECT TOP 1
       'City with Highest Average Rating' AS Metric,
       City,
       AverageRating AS Value
FROM CityAverageRating
ORDER BY Value DESC;  -- Order by highest average rating

-----task 3 ----

WITH PriceRangeDistribution AS (
    SELECT [Price range],
           COUNT(*) AS RestaurantCount,
           100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS Percentage
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
    GROUP BY [Price range]
)

SELECT [Price range],
       RestaurantCount,
       ROUND(Percentage, 2) AS Percentage
FROM PriceRangeDistribution
ORDER BY [Price range];

------task4---
WITH OnlineDeliveryStats AS (
    -- Step 1: Calculate the percentage of restaurants that offer online delivery
    SELECT 
        SUM(CASE WHEN [Has Online delivery] = 'Yes' THEN 1 ELSE 0 END) AS RestaurantsWithDelivery,
        COUNT(*) AS TotalRestaurants,
        100.0 * SUM(CASE WHEN [Has Online delivery] = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS PercentageWithDelivery
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
),

AverageRatings AS (
    -- Step 2: Compare the average ratings of restaurants with and without online delivery
    SELECT 
        AVG(CASE WHEN [Has Online delivery] = 'Yes' THEN [Aggregate rating] ELSE NULL END) AS AvgRatingWithDelivery,
        AVG(CASE WHEN [Has Online delivery] = 'No' THEN [Aggregate rating] ELSE NULL END) AS AvgRatingWithoutDelivery
    FROM [Restaurant].[dbo].['Dataset $']  
    WHERE [Aggregate rating] IS NOT NULL  -- Ensure ratings are not NULL
)

-- Final SELECT: Combine results from both steps
SELECT 
    RestaurantsWithDelivery,
    TotalRestaurants,
    ROUND(PercentageWithDelivery, 2) AS PercentageWithDelivery, 
    ROUND(AvgRatingWithDelivery, 2) AS AvgRatingWithDelivery,
    ROUND(AvgRatingWithoutDelivery, 2) AS AvgRatingWithoutDelivery
FROM OnlineDeliveryStats, AverageRatings;


                                                 ---------------level 2 -----------------------
-------task1---------
WITH RatingDistribution AS (
    -- Step 1: Analyze the distribution of aggregate ratings
    SELECT 
        FLOOR([Aggregate rating]) AS RatingFloor,
        COUNT(*) AS RatingCount
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
    WHERE [Aggregate rating] IS NOT NULL  -- Ensure ratings are not NULL
    GROUP BY FLOOR([Aggregate rating])
),

MostCommonRating AS (
    -- Step 2: Determine the most common rating range
    SELECT TOP 1 WITH TIES
        RatingFloor,
        RatingCount
    FROM RatingDistribution
    ORDER BY RatingCount DESC
),

AverageVotes AS (
    -- Step 3: Calculate the average number of votes received by restaurants
    SELECT 
        AVG(Votes) AS AvgVotes
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
    WHERE Votes IS NOT NULL  -- Ensure votes are not NULL
)

-- Final SELECT: Combine results from all steps
SELECT 
    'Rating Distribution' AS Metric,
    RatingFloor AS RatingRange,
    RatingCount AS Count
FROM RatingDistribution

UNION ALL

SELECT 
    'Most Common Rating Range' AS Metric,
    RatingFloor AS RatingRange,
    RatingCount AS Count
FROM MostCommonRating

UNION ALL

SELECT 
    'Average Votes Received' AS Metric,
    NULL AS RatingRange,  -- Placeholder for non-range metrics
    ROUND(AvgVotes, 2) AS Count
FROM AverageVotes;

-------task2--------
WITH CuisineCombinations AS (
    -- Step 1: Identify the most common combinations of cuisines
    SELECT 
        Cuisines,
        COUNT(*) AS CombinationCount
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
    WHERE Cuisines IS NOT NULL  -- Ensure cuisines are not NULL
    GROUP BY Cuisines
),

TopCuisineCombinations AS (
    -- Step 2: Select top combinations by count
    SELECT TOP 10
        Cuisines,
        CombinationCount
    FROM CuisineCombinations
    ORDER BY CombinationCount DESC
),

CuisineRatings AS (
    -- Step 3: Calculate the average rating for each cuisine combination
    SELECT 
        Cuisines,
        AVG([Aggregate rating]) AS AvgRating
    FROM [Restaurant].[dbo].['Dataset $']  -- Replace with your actual table name
    WHERE Cuisines IS NOT NULL  -- Ensure cuisines are not NULL
      AND [Aggregate rating] IS NOT NULL  -- Ensure ratings are not NULL
    GROUP BY Cuisines
)

-- Final SELECT: Combine results from both steps
SELECT 
    'Most Common Cuisine Combinations' AS Metric,
    tc.Cuisines AS CuisineCombination,
    tc.CombinationCount AS Count,
    cr.AvgRating AS AverageRating
FROM TopCuisineCombinations tc
LEFT JOIN CuisineRatings cr ON tc.Cuisines = cr.Cuisines

UNION ALL

SELECT 
    'Higher Ratings for Cuisine Combinations' AS Metric,
    cr.Cuisines AS CuisineCombination,
    NULL AS Count,
    ROUND(cr.AvgRating, 2) AS AverageRating
FROM CuisineRatings cr
WHERE cr.Cuisines IN (
    SELECT Cuisines
    FROM TopCuisineCombinations
)
ORDER BY Metric, AverageRating DESC;  -- Moved ORDER BY outside of the CTEs

----------task4 --------
 WITH ChainRestaurants AS (
    -- Step 1: Identify restaurant chains by grouping by Restaurant Name
    SELECT 
        [Restaurant Name] AS ChainName,
        COUNT(*) AS ChainCount,
        AVG([Aggregate rating]) AS AvgRating,
        SUM(Votes) AS TotalVotes
    FROM [Restaurant].[dbo].['Dataset $']  
    WHERE [Restaurant Name] IS NOT NULL  -- Ensure restaurant names are not NULL
    GROUP BY [Restaurant Name]
    HAVING COUNT(*) > 1  -- Adjust as needed to define what constitutes a chain (e.g., more than one location)
),

-- Step 2: Analyze ratings and popularity of different restaurant chains
ChainAnalysis AS (
    SELECT 
        ChainName,
        ChainCount,
        AvgRating,
        TotalVotes,
        ROW_NUMBER() OVER (ORDER BY AvgRating DESC) AS RatingRank,
        ROW_NUMBER() OVER (ORDER BY TotalVotes DESC) AS VotesRank
    FROM ChainRestaurants
)

-- Final SELECT: Combine results from both steps
SELECT 
    ChainName,
    ChainCount AS Locations,
    AvgRating AS AverageRating,
    TotalVotes AS TotalVotes,
    RatingRank,
    VotesRank
FROM ChainAnalysis
ORDER BY RatingRank;
