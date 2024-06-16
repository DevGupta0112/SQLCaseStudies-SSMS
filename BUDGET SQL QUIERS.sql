
-----------Total Sales by Year
SELECT YEAR(OrderDate) AS Year, SUM(SalesAmount) AS TotalSales
FROM Sales
GROUP BY YEAR(OrderDate);

-----------Total Sales by Product
SELECT P.ProductName, SUM(S.SalesAmount) AS TotalSales
FROM Sales S
JOIN Product P ON S.ProductKey = P.ProductKey
GROUP BY P.ProductName;

-----------Customer Information
SELECT CustomerKey, FirstName, LastName, YearlyIncome, TotalChildren, NumberCarsOwned
FROM Customers;

-----------Sales by Customer Demographics
SELECT C.Gender, C.Education, SUM(S.SalesAmount) AS TotalSales
FROM Sales S
JOIN Customers C ON S.CustomerKey = C.CustomerKey
GROUP BY C.Gender, C.Education;

-----------Sales Distribution by Order Quantity
SELECT 
    OrderQuantity,
    COUNT(*) AS NumberOfOrders,
    SUM(SalesAmount) AS TotalSalesAmount
FROM Sales
GROUP BY OrderQuantity
ORDER BY OrderQuantity;