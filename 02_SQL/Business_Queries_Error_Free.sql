/*
Business_Queries_Error_Free.sql
Corrected SQL Server / SSMS version for RetailInventoryAnalytics.

Run Database.sql first, then Data_Load.sql, then this file.
The confirmed ambiguous Product_ID error has been fixed.
*/

/*
Business_Queries.sql
Retail Inventory & Supply Chain Analytics
SQL Server / SSMS
*/

USE RetailInventoryAnalytics;
GO

/* =========================================================
1. EXECUTIVE KPIs
========================================================= */

-- 1.1 Total inventory value
SELECT
    SUM(Inventory_Value) AS Total_Inventory_Value
FROM Inventory;

-- 1.2 Total units and available units
SELECT
    SUM(On_Hand_Units) AS Total_On_Hand_Units,
    SUM(Available_Units) AS Total_Available_Units,
    SUM(Reserved_Units) AS Total_Reserved_Units
FROM Inventory;

-- 1.3 Revenue, cost and gross profit from completed orders
SELECT
    SUM(Revenue) AS Revenue,
    SUM(Cost) AS COGS,
    SUM(Gross_Profit) AS Gross_Profit,
    CAST(100.0 * SUM(Gross_Profit) / NULLIF(SUM(Revenue),0) AS DECIMAL(10,2)) AS Gross_Margin_Pct
FROM Sales
WHERE Order_Status = 'Completed';


/* =========================================================
2. INVENTORY HEALTH
========================================================= */

-- 2.1 Low-stock product/warehouse records
SELECT
    i.Product_ID,
    p.Product_Name,
    p.Category,
    i.Warehouse_ID,
    i.Available_Units,
    i.Reorder_Level,
    i.Reorder_Qty
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
WHERE i.Available_Units <= i.Reorder_Level
ORDER BY i.Available_Units ASC;

-- 2.2 Overstocked products
SELECT
    i.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(i.On_Hand_Units) AS On_Hand_Units,
    SUM(i.Inventory_Value) AS Inventory_Value
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
WHERE i.Stock_Status = 'Overstock'
GROUP BY i.Product_ID, p.Product_Name, p.Category
ORDER BY Inventory_Value DESC;

-- 2.3 Inventory value by category
SELECT
    p.Category,
    SUM(i.Inventory_Value) AS Inventory_Value,
    SUM(i.On_Hand_Units) AS Units
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Inventory_Value DESC;

-- 2.4 Products requiring reorder
SELECT
    i.Product_ID,
    p.Product_Name,
    p.Category,
    i.Warehouse_ID,
    i.Available_Units,
    i.Reorder_Level,
    i.Reorder_Qty,
    CASE
        WHEN i.Available_Units = 0 THEN 'Critical'
        WHEN i.Available_Units <= i.Reorder_Level THEN 'Reorder'
        ELSE 'Monitor'
    END AS Reorder_Priority
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
WHERE i.Available_Units <= i.Reorder_Level
ORDER BY
    CASE WHEN i.Available_Units = 0 THEN 1 ELSE 2 END,
    i.Available_Units;


/* =========================================================
3. PRODUCT PERFORMANCE
========================================================= */

-- 3.1 Top 10 products by revenue
SELECT TOP 10
    p.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Revenue) AS Revenue,
    SUM(s.Gross_Profit) AS Gross_Profit
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
WHERE s.Order_Status = 'Completed'
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Revenue DESC;

-- 3.2 Bottom 10 products by revenue
SELECT TOP 10
    p.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(s.Revenue) AS Revenue,
    SUM(s.Quantity) AS Units_Sold
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
WHERE s.Order_Status = 'Completed'
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Revenue ASC;

-- 3.3 Top products by gross margin
SELECT TOP 15
    p.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(s.Revenue) AS Revenue,
    SUM(s.Gross_Profit) AS Gross_Profit,
    CAST(100.0 * SUM(s.Gross_Profit) / NULLIF(SUM(s.Revenue),0) AS DECIMAL(10,2)) AS Gross_Margin_Pct
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
WHERE s.Order_Status = 'Completed'
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Gross_Margin_Pct DESC;


/* =========================================================
4. CATEGORY ANALYSIS
========================================================= */

-- 4.1 Category revenue and profitability
SELECT
    p.Category,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Revenue) AS Revenue,
    SUM(s.Gross_Profit) AS Gross_Profit,
    CAST(100.0 * SUM(s.Gross_Profit) / NULLIF(SUM(s.Revenue),0) AS DECIMAL(10,2)) AS Gross_Margin_Pct
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
WHERE s.Order_Status = 'Completed'
GROUP BY p.Category
ORDER BY Revenue DESC;

-- 4.2 Category inventory versus sales
SELECT
    p.Category,
    SUM(i.Inventory_Value) AS Inventory_Value,
    SUM(s.Revenue) AS Revenue
FROM Products p
JOIN Inventory i ON p.Product_ID = i.Product_ID
LEFT JOIN Sales s
    ON p.Product_ID = s.Product_ID
    AND s.Order_Status = 'Completed'
GROUP BY p.Category
ORDER BY Inventory_Value DESC;


/* =========================================================
5. WAREHOUSE PERFORMANCE
========================================================= */

-- 5.1 Inventory value by warehouse
SELECT
    w.Warehouse_ID,
    w.Warehouse_Name,
    w.City,
    SUM(i.Inventory_Value) AS Inventory_Value,
    SUM(i.On_Hand_Units) AS On_Hand_Units,
    SUM(i.Available_Units) AS Available_Units
FROM Warehouses w
JOIN Inventory i ON w.Warehouse_ID = i.Warehouse_ID
GROUP BY w.Warehouse_ID, w.Warehouse_Name, w.City
ORDER BY Inventory_Value DESC;

-- 5.2 Warehouse availability %
SELECT
    w.Warehouse_Name,
    CAST(
        100.0 * SUM(i.Available_Units) /
        NULLIF(SUM(i.On_Hand_Units),0)
        AS DECIMAL(10,2)
    ) AS Availability_Pct
FROM Warehouses w
JOIN Inventory i ON w.Warehouse_ID = i.Warehouse_ID
GROUP BY w.Warehouse_Name
ORDER BY Availability_Pct DESC;

-- 5.3 Warehouse sales performance
SELECT
    w.Warehouse_Name,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Revenue) AS Revenue,
    SUM(s.Gross_Profit) AS Gross_Profit
FROM Sales s
JOIN Warehouses w ON s.Warehouse_ID = w.Warehouse_ID
WHERE s.Order_Status = 'Completed'
GROUP BY w.Warehouse_Name
ORDER BY Revenue DESC;


/* =========================================================
6. SUPPLIER PERFORMANCE
========================================================= */

-- 6.1 Supplier performance
SELECT
    sp.Supplier_ID,
    sp.Supplier_Name,
    COUNT(*) AS Purchase_Orders,
    SUM(p.Quantity) AS Purchased_Units,
    SUM(p.Purchase_Cost) AS Purchase_Cost,
    AVG(CAST(DATEDIFF(DAY, p.Purchase_Date, p.Actual_Delivery_Date) AS DECIMAL(10,2))) AS Avg_Lead_Time_Days,
    CAST(
        100.0 * SUM(CASE WHEN p.Delivery_Status = 'On Time' THEN 1 ELSE 0 END) /
        NULLIF(COUNT(*),0)
        AS DECIMAL(10,2)
    ) AS On_Time_Delivery_Pct
FROM Purchases p
JOIN Suppliers sp ON p.Supplier_ID = sp.Supplier_ID
GROUP BY sp.Supplier_ID, sp.Supplier_Name
ORDER BY On_Time_Delivery_Pct ASC;

-- 6.2 Suppliers with poor on-time performance
WITH SupplierKPIs AS (
    SELECT
        Supplier_ID,
        COUNT(*) AS Total_Orders,
        SUM(CASE WHEN Delivery_Status = 'On Time' THEN 1 ELSE 0 END) AS On_Time_Orders
    FROM Purchases
    GROUP BY Supplier_ID
)
SELECT
    sk.Supplier_ID,
    sp.Supplier_Name,
    sk.Total_Orders,
    CAST(100.0 * sk.On_Time_Orders / NULLIF(sk.Total_Orders,0) AS DECIMAL(10,2)) AS On_Time_Pct
FROM SupplierKPIs sk
JOIN Suppliers sp ON sk.Supplier_ID = sp.Supplier_ID
WHERE 100.0 * sk.On_Time_Orders / NULLIF(sk.Total_Orders,0) < 80
ORDER BY On_Time_Pct;


/* =========================================================
7. SALES TRENDS
========================================================= */

-- 7.1 Monthly revenue and profit
SELECT
    YEAR(Sales_Date) AS Sales_Year,
    MONTH(Sales_Date) AS Sales_Month,
    SUM(Quantity) AS Units_Sold,
    SUM(Revenue) AS Revenue,
    SUM(Gross_Profit) AS Gross_Profit
FROM Sales
WHERE Order_Status = 'Completed'
GROUP BY YEAR(Sales_Date), MONTH(Sales_Date)
ORDER BY Sales_Year, Sales_Month;

-- 7.2 Revenue by sales channel
SELECT
    Sales_Channel,
    SUM(Revenue) AS Revenue,
    SUM(Quantity) AS Units_Sold,
    COUNT(DISTINCT Sales_ID) AS Orders
FROM Sales
WHERE Order_Status = 'Completed'
GROUP BY Sales_Channel
ORDER BY Revenue DESC;

-- 7.3 Revenue by customer segment
SELECT
    Customer_Segment,
    SUM(Revenue) AS Revenue,
    SUM(Gross_Profit) AS Gross_Profit,
    COUNT(DISTINCT Sales_ID) AS Orders
FROM Sales
WHERE Order_Status = 'Completed'
GROUP BY Customer_Segment
ORDER BY Revenue DESC;


/* =========================================================
8. RETURNS
========================================================= */

-- 8.1 Return reasons
SELECT
    Return_Reason,
    SUM(Returned_Units) AS Returned_Units,
    COUNT(*) AS Return_Transactions
FROM Returns
GROUP BY Return_Reason
ORDER BY Returned_Units DESC;

-- 8.2 Return rate by product
WITH ReturnSummary AS (
    SELECT
        Product_ID,
        SUM(Returned_Units) AS Returned_Units
    FROM Returns
    GROUP BY Product_ID
),
SalesSummary AS (
    SELECT
        Product_ID,
        SUM(Quantity) AS Sold_Units
    FROM Sales
    WHERE Order_Status = 'Completed'
    GROUP BY Product_ID
)
SELECT
    p.Product_ID,
    p.Product_Name,
    COALESCE(r.Returned_Units, 0) AS Returned_Units,
    COALESCE(s.Sold_Units, 0) AS Sold_Units,
    CAST(
        100.0 * COALESCE(r.Returned_Units, 0) /
        NULLIF(s.Sold_Units, 0)
        AS DECIMAL(10,2)
    ) AS Return_Rate_Pct
FROM Products AS p
LEFT JOIN ReturnSummary AS r
    ON p.Product_ID = r.Product_ID
LEFT JOIN SalesSummary AS s
    ON p.Product_ID = s.Product_ID
WHERE COALESCE(r.Returned_Units, 0) > 0
ORDER BY Return_Rate_Pct DESC;


/* =========================================================
9. ADVANCED ANALYTICS
========================================================= */

-- 9.1 Rank products by revenue within category
WITH ProductRevenue AS (
    SELECT
        p.Category,
        p.Product_ID,
        p.Product_Name,
        SUM(s.Revenue) AS Revenue
    FROM Sales s
    JOIN Products p ON s.Product_ID = p.Product_ID
    WHERE s.Order_Status = 'Completed'
    GROUP BY p.Category, p.Product_ID, p.Product_Name
)
SELECT
    Category,
    Product_ID,
    Product_Name,
    Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS Category_Revenue_Rank
FROM ProductRevenue
ORDER BY Category, Category_Revenue_Rank;

-- 9.2 Monthly revenue with previous month comparison
WITH MonthlySales AS (
    SELECT
        DATEFROMPARTS(YEAR(Sales_Date), MONTH(Sales_Date), 1) AS Month_Start,
        SUM(Revenue) AS Revenue
    FROM Sales
    WHERE Order_Status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(Sales_Date), MONTH(Sales_Date), 1)
)
SELECT
    Month_Start,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Month_Start) AS Previous_Month_Revenue,
    CAST(
        100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY Month_Start)) /
        NULLIF(LAG(Revenue) OVER (ORDER BY Month_Start),0)
        AS DECIMAL(10,2)
    ) AS MoM_Growth_Pct
FROM MonthlySales
ORDER BY Month_Start;

-- 9.3 Inventory turnover by category
WITH SalesCost AS (
    SELECT
        p.Category,
        SUM(s.Cost) AS COGS
    FROM Sales s
    JOIN Products p ON s.Product_ID = p.Product_ID
    WHERE s.Order_Status = 'Completed'
    GROUP BY p.Category
),
InventoryValue AS (
    SELECT
        p.Category,
        SUM(i.Inventory_Value) AS Inventory_Value
    FROM Inventory i
    JOIN Products p ON i.Product_ID = p.Product_ID
    GROUP BY p.Category
)
SELECT
    sv.Category,
    sv.COGS,
    iv.Inventory_Value,
    CAST(sv.COGS / NULLIF(iv.Inventory_Value,0) AS DECIMAL(10,2)) AS Inventory_Turnover
FROM SalesCost sv
JOIN InventoryValue iv ON sv.Category = iv.Category
ORDER BY Inventory_Turnover DESC;

-- 9.4 Products with high inventory value but low sales
WITH ProductMetrics AS (
    SELECT
        p.Product_ID,
        p.Product_Name,
        p.Category,
        SUM(i.Inventory_Value) AS Inventory_Value,
        COALESCE(SUM(s.Revenue),0) AS Revenue
    FROM Products p
    LEFT JOIN Inventory i ON p.Product_ID = i.Product_ID
    LEFT JOIN Sales s
        ON p.Product_ID = s.Product_ID
        AND s.Order_Status = 'Completed'
    GROUP BY p.Product_ID, p.Product_Name, p.Category
)
SELECT TOP 20
    Product_ID,
    Product_Name,
    Category,
    Inventory_Value,
    Revenue
FROM ProductMetrics
WHERE Inventory_Value > 0
ORDER BY Inventory_Value DESC, Revenue ASC;

-- 9.5 Reorder priority using stock coverage proxy
SELECT
    i.Product_ID,
    p.Product_Name,
    p.Category,
    i.Warehouse_ID,
    i.Available_Units,
    i.Reorder_Level,
    p.Reorder_Qty,
    CASE
        WHEN i.Available_Units = 0 THEN 'Critical'
        WHEN i.Available_Units <= i.Reorder_Level THEN 'High'
        WHEN i.Available_Units <= i.Reorder_Level * 2 THEN 'Medium'
        ELSE 'Low'
    END AS Priority
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
ORDER BY
    CASE
        WHEN i.Available_Units = 0 THEN 1
        WHEN i.Available_Units <= i.Reorder_Level THEN 2
        WHEN i.Available_Units <= i.Reorder_Level * 2 THEN 3
        ELSE 4
    END,
    i.Available_Units;


/* =========================================================
10. DATA QUALITY CHECKS
========================================================= */

-- Duplicate sales IDs
SELECT Sales_ID, COUNT(*) AS Duplicate_Count
FROM Sales
GROUP BY Sales_ID
HAVING COUNT(*) > 1;

-- Negative / invalid sales values
SELECT *
FROM Sales
WHERE Quantity < 0
   OR Revenue < 0
   OR Cost < 0;

-- Purchases delivered before purchase date
SELECT *
FROM Purchases
WHERE Actual_Delivery_Date < Purchase_Date;

-- Inventory calculation validation
SELECT TOP 50
    i.Product_ID,
    i.Warehouse_ID,
    i.On_Hand_Units,
    p.Unit_Cost,
    i.Inventory_Value,
    ROUND(i.On_Hand_Units * p.Unit_Cost, 2) AS Expected_Inventory_Value
FROM Inventory AS i
INNER JOIN Products AS p
    ON i.Product_ID = p.Product_ID
WHERE ABS(i.Inventory_Value - ROUND(i.On_Hand_Units * p.Unit_Cost, 2)) > 0.01;
GO
