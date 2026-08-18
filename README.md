# Retail Inventory Analytics

## Project Overview

Retail Inventory Analytics is an end-to-end data analytics project designed to analyze inventory health, sales performance, warehouse distribution, supplier performance, and replenishment requirements.

The project transforms retail inventory data into meaningful business insights using Excel, SQL, and Power BI.

The main objective is to help businesses identify inventory risks, monitor stock levels, evaluate warehouse and supplier performance, and make better replenishment decisions.

---

## Business Problem

Retail businesses need to maintain the right inventory levels while avoiding stockouts and excess inventory.

The project addresses the following business problems

 Identifying low-stock and out-of-stock products
 Understanding inventory value by category and warehouse
 Identifying products with high inventory investment
 Monitoring sales and gross profit performance
 Evaluating supplier performance
 Monitoring purchase delivery performance
 Identifying products requiring replenishment
 Supporting warehouse and inventory optimization

---

## Project Objectives

1. Clean and organize retail inventory data.
2. Store and analyze data using SQL.
3. Calculate important inventory and business KPIs.
4. Build an interactive Power BI dashboard.
5. Identify inventory risks and replenishment requirements.
6. Provide actionable business insights for inventory management.

---

## Tools and Technologies

 Excel
 SQL Server
 Power BI
 DAX
 GitHub

---

## Project Workflow

```text
Raw Data
   
   v
Excel Data Cleaning
   
   v
SQL Database
   
   v
Business Analysis Queries
   
   v
Power BI Data Model
   
   v
DAX KPI Calculations
   
   v
Interactive Dashboard
   
   v
Business Insights
```

---

## Dataset

The dataset contains information related to

 Products
 Categories and sub-categories
 Sales
 Inventory
 Warehouses
 Suppliers
 Purchases
 Stock status
 Reorder levels
 Replenishment quantities
 Purchase delivery status

---

## Excel Analysis

Excel was used for

 Data cleaning
 Data validation
 KPI calculations
 Initial data inspection
 Preparing structured datasets for SQL and Power BI

Files

```text
01_Excel
├── Inventory_Cleaning.xlsx
└── KPI_Calculations.xlsx
```

---

## SQL Analysis

SQL Server was used to

 Create database tables
 Load the cleaned data
 Perform aggregations
 Filter business data
 Join related tables
 Analyze inventory and sales performance
 Identify low-stock products
 Analyze warehouse and supplier performance

Files

```text
02_SQL
├── Database.sql
├── Data_Load.sql
└── Business_Queries.sql
```

---

## Key SQL Analysis Areas

The SQL analysis answers questions such as

 What is the total inventory value
 Which products have the highest inventory value
 Which categories have the highest inventory
 Which products are low stock
 Which warehouses hold the most inventory
 Which suppliers have the best performance
 What is the purchase delivery performance
 Which products require replenishment

---

## Power BI Dashboard

The Power BI report contains three analytical pages.

### Page 1 Executive Overview

Provides a high-level view of business and inventory performance.

Key components

 Total Revenue
 Gross Profit
 Gross Margin %
 Inventory Value
 Low Stock Rate
 Inventory Turnover
 Revenue and Gross Profit Trend
 Inventory Health by Stock Status
 Top 10 Products by Inventory Value
 Inventory Value by Warehouse

---

### Page 2 Inventory Analysis

Focuses on inventory distribution and inventory risk.

Key components

 Inventory Value by Category
 Stock Status by Category
 Inventory Value by Sub-Category
 Inventory Risk Details
 Year filter
 Category filter
 Warehouse filter
 Stock Status filter

---

### Page 3 Operations & Replenishment

Focuses on operational and purchasing decisions.

Key components

 Units to Replenish
 Products Requiring Reorder
 Average Supplier Rating
 On-Time Delivery %
 Replenishment Requirement by Category
 Supplier Performance
 Purchase Delivery Status
 Warehouse Capacity Utilization
 Replenishment Action Required

---

## Key DAX Measures

### Total Revenue

```DAX
Total Revenue =
SUM(Sales[Revenue])
```

### Total Gross Profit

```DAX
Total Gross Profit =
SUM(Sales[Gross_Profit])
```

### Gross Margin %

```DAX
Gross Margin % =
DIVIDE(
    [Total Gross Profit],
    [Total Revenue],
    0
)
```

### Inventory Value

```DAX
Inventory Value =
SUM(Inventory[Inventory_Value])
```

### Low Stock Records

```DAX
Low Stock Records =
CALCULATE(
    COUNTROWS(Inventory),
    Inventory[Stock_Status] = Low Stock
)
```

### Low Stock Rate %

```DAX
Low Stock Rate % =
DIVIDE(
    [Low Stock Records],
    COUNTROWS(Inventory),
    0
)
```

### Inventory Turnover

```DAX
Inventory Turnover =
DIVIDE(
    [Total Cost],
    [Inventory Value],
    0
)
```

### Units to Replenish

```DAX
Units to Replenish =
SUMX(
    FILTER(
        Inventory,
        Inventory[On_Hand_Units]  Inventory[Reorder_Level]
    ),
    Inventory[Reorder_Qty]
)
```

### Products Requiring Reorder

```DAX
Products Requiring Reorder =
CALCULATE(
    DISTINCTCOUNT(Inventory[Product_ID]),
    Inventory[On_Hand_Units]  Inventory[Reorder_Level]
)
```

---

## Key Business Insights

The dashboard helps identify

 Categories with high inventory value
 Products requiring immediate replenishment
 Warehouses with high inventory concentration
 Supplier delivery performance
 Products with potential inventory risk
 Opportunities to optimize stock levels

---

## Business Recommendations

Based on the analysis, businesses can

1. Prioritize replenishment for low-stock products.
2. Monitor products with high inventory value.
3. Optimize inventory allocation across warehouses.
4. Track suppliers with delayed deliveries.
5. Maintain appropriate reorder levels.
6. Reduce excess inventory where possible.
7. Use dashboard filters to monitor inventory performance by category and warehouse.

---

## Project Structure

```text
Retail_Inventory_Analytics
│
├── 01_Excel
│   ├── Inventory_Cleaning.xlsx
│   └── KPI_Calculations.xlsx
│
├── 02_SQL
│   ├── Database.sql
│   ├── Data_Load.sql
│   └── Business_Queries.sql
│
├── 04_Power_BI
│   └── Retail_Inventory_Dashboard.pbix
│
├── 05_Documentation
│   ├── Project_Report.md
│   ├── Data_Dictionary.xlsx
│   ├── KPI_Definitions.pdf
│   └── Dashboard_Screenshots
│
└── README.md
```

---

## Project Outcome

This project demonstrates an end-to-end data analytics workflow covering

 Data cleaning
 Data preparation
 SQL database development
 SQL business analysis
 Data modeling
 DAX calculations
 Power BI dashboard development
 KPI analysis
 Inventory risk analysis
 Business recommendations

The final solution provides a centralized analytical view that can support inventory, warehouse, procurement, and replenishment decisions.

---

## Conclusion

Retail Inventory Analytics demonstrates how raw operational data can be transformed into structured analysis and interactive business intelligence.

The project combines Excel for preparation, SQL for data analysis, and Power BI for visualization and decision support.
