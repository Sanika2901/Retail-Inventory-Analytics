/*
Retail Inventory & Supply Chain Analytics
Database schema for SQL Server / SSMS
*/

IF DB_ID('RetailInventoryAnalytics') IS NULL
    CREATE DATABASE RetailInventoryAnalytics;
GO

USE RetailInventoryAnalytics;
GO

DROP TABLE IF EXISTS Returns;
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Purchases;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Warehouses;
GO

CREATE TABLE Suppliers (
    Supplier_ID VARCHAR(10) PRIMARY KEY,
    Supplier_Name VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    Supplier_Rating DECIMAL(3,1),
    Standard_Lead_Days INT
);

CREATE TABLE Warehouses (
    Warehouse_ID VARCHAR(10) PRIMARY KEY,
    Warehouse_Name VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    Capacity_Units INT
);

CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name VARCHAR(150) NOT NULL,
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    Supplier_ID VARCHAR(10),
    Unit_Cost DECIMAL(18,2),
    Selling_Price DECIMAL(18,2),
    Reorder_Level INT,
    Reorder_Qty INT,
    CONSTRAINT FK_Products_Suppliers
        FOREIGN KEY (Supplier_ID) REFERENCES Suppliers(Supplier_ID)
);

CREATE TABLE Inventory (
    Snapshot_Date DATE,
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    On_Hand_Units INT,
    Reserved_Units INT,
    Available_Units INT,
    Inventory_Value DECIMAL(18,2),
    Reorder_Level INT,
    Reorder_Qty INT,
    Stock_Status VARCHAR(30),
    PRIMARY KEY (Snapshot_Date, Product_ID, Warehouse_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID)
);

CREATE TABLE Purchases (
    Purchase_ID VARCHAR(20) PRIMARY KEY,
    Purchase_Date DATE,
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Supplier_ID VARCHAR(10),
    Quantity INT,
    Unit_Cost DECIMAL(18,2),
    Purchase_Cost DECIMAL(18,2),
    Expected_Delivery_Date DATE,
    Actual_Delivery_Date DATE,
    Delivery_Status VARCHAR(30),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID),
    FOREIGN KEY (Supplier_ID) REFERENCES Suppliers(Supplier_ID)
);

CREATE TABLE Sales (
    Sales_ID VARCHAR(20) PRIMARY KEY,
    Sales_Date DATE,
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Quantity INT,
    Customer_Segment VARCHAR(50),
    Sales_Channel VARCHAR(50),
    Selling_Price DECIMAL(18,2),
    Unit_Cost DECIMAL(18,2),
    Revenue DECIMAL(18,2),
    Cost DECIMAL(18,2),
    Gross_Profit DECIMAL(18,2),
    Order_Status VARCHAR(30),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID)
);

CREATE TABLE Returns (
    Return_ID VARCHAR(20) PRIMARY KEY,
    Return_Date DATE,
    Sales_ID VARCHAR(20),
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Returned_Units INT,
    Return_Reason VARCHAR(100),
    FOREIGN KEY (Sales_ID) REFERENCES Sales(Sales_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID)
);
GO

CREATE INDEX IX_Sales_Date ON Sales(Sales_Date);
CREATE INDEX IX_Sales_Product ON Sales(Product_ID);
CREATE INDEX IX_Purchases_Date ON Purchases(Purchase_Date);
CREATE INDEX IX_Inventory_Product ON Inventory(Product_ID);
GO
