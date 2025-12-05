-- SQL script for creating the Bacchus Database

-- Delete a Database if it exists, then create a database for testing the script.
DROP DATABASE IF EXISTS BacchusWineryDB;
CREATE DATABASE BacchusWineryDB;
USE BacchusWineryDB;


-- Create a User for the Python Scripts and .env file.
DROP USER IF EXISTS 'dionysus'@'localhost';
CREATE USER 'dionysus'@'localhost' IDENTIFIED BY 'MountOlympus';
GRANT ALL PRIVILEGES ON BacchusWineryDB.* TO 'dionysus'@'localhost';
FLUSH PRIVILEGES;

-- *** Create Tables

-- ==================
-- ** Internal Tables

-- Departments Table
CREATE TABLE Department (
    DeptID INT PRIMARY KEY AUTO_INCREMENT,
    DeptName VARCHAR(75) NOT NULL,
    ManagerEmployeeID INT
);

-- Employees Table
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(50),
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- Time Punch Table
CREATE TABLE Hours (
    PunchID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    DateWorked DATE NOT NULL,
    HoursWorked DECIMAL(4, 2),
    FOREIGN KEY (EmployeeID) Employee (EmployeeID)
);

-- Wine Table
CREATE TABLE Wine (
    WineID INT PRIMARY KEY AUTO_INCREMENT,
    WineName VARCHAR(75) NOT NULL,
    WineType VARCHAR(75),
    YearProduced YEAR NOT NULL
);

-- Wine Inventory Table
CREATE TABLE WineInventory (
    WineInventoryID INT PRIMARY KEY AUTO_INCREMENT,
    WineID INT,
    Quantity INT,
    FOREIGN KEY (WineID) REFERENCES Wine (WineID)
);

-- Adds the Foreign Key of the Manager ID to the Department Table
ALTER TABLE Department
ADD CONSTRAINT fk_manager
    FOREIGN KEY (ManagerEmployeeID) REFERENCES Employee (EmployeeID);

-- ==================
-- ** Supplier Tables

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(75),
    SupplierCategory VARCHAR(100)
);

-- Supply Item Table
CREATE TABLE SupplyItem (
    SupplyItemID INT PRIMARY Key AUTO_INCREMENT,
    ItemName VARCHAR(75),
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID)
);

-- Supply Inventory Table
CREATE TABLE SupplyInventory (
    SupplyInventoryID INT PRIMARY KEY AUTO_INCREMENT,
    SupplyItemID INT,
    Quantity INT,
    FOREIGN KEY (SupplyItemID) REFERENCES SupplyItem (SupplyItemID)
);

-- Supplier Delivery Table
CREATE TABLE SupplierDelivery (
    InvoiceID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierID INT NOT NULL,
    ExpectedDelivery DATE,
    ActualDelivery DATE
);

-- Supplier Item Delivery Table
CREATE TABLE SupplierItemDelivery (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    InvoiceID INT NOT NULL,
    SupplyItemID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (SupplyItemID) REFERENCES SupplyItem (SupplyItemID),
    FOREIGN KEY (InvoiceID) REFERENCES SupplierDelivery (InvoiceID)
);

-- =====================
-- ** Distributor Tables

-- Distributor Table
CREATE TABLE Distributor (
    DistID INT PRIMARY KEY AUTO_INCREMENT,
    DistName VARCHAR(75) NOT NULL,
    DistPhone VARCHAR(10),
    DistAddress VARCHAR(75),
    DistEmail VARCHAR(75) 
);

-- ShippingService Table
CREATE TABLE ShipService (
    ShipperID INT PRIMARY KEY AUTO_INCREMENT,
    ShipperName VARCHAR(75) NOT NULL,
    ShipperPhone VARCHAR(10),
    ShipperWeb VARCHAR(100)
);

-- Shipment Table
CREATE TABLE Shipment (
    ShipmentID INT PRIMARY KEY AUTO_INCREMENT,
    ShipmentDate DATE,
    TrackingNumber VARCHAR(50),
    ShippingService INT,
    FOREIGN KEY (ShippingService) REFERENCES ShipService (ShipperID)
);

-- Distributor Order Table
CREATE TABLE DistOrder (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    DistID INT NOT NULL,
    ShipmentID INT,
    OrderDate DATE,
    FOREIGN KEY (ShipmentID) REFERENCES Shipment (ShipmentID),
    FOREIGN KEY (DistID) REFERENCES Distributor (DistID)
);

-- Item Order ID Table
CREATE TABLE DistItemOrderID (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    WineID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES DistOrder (OrderID),
    FOREIGN KEY (WineID) REFERENCES Wine (WineID)
);

-- =========================================================================
-- ** Table for the Many to Many Relationship between Wines and Distributors

CREATE TABLE WineToDist (
    WD_ID INT PRIMARY KEY AUTO_INCREMENT,
    WineID INT NOT NULL,
    DistID INT NOT NULL,
    FOREIGN KEY (WineID) REFERENCES Wine (WineID),
    FOREIGN KEY (DistID) REFERENCES Distributor (DistID)
);