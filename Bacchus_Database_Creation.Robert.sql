-- SQL script for creating the Bacchus Database

-- Delete a Dummy Database if it exists, then create a dummy database for testing the script.
DROP DATABASE IF EXISTS DummyDB;
CREATE DATABASE DummyDB;
USE DummyDB;


-- *** Create Tables

-- ------------------
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
    DepartmentID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- Time Punch Table
CREATE TABLE Hours (
    PunchID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    DateWorked DATE NOT NULL,
    HoursWorked DECIMAL(4, 2)
);

-- Wine Table
CREATE TABLE Wine (
    WineID INT PRIMARY KEY AUTO_INCREMENT,
    WineName VARCHAR(75) NOT NULL,
    WineType VARCHAR(75),
    YearProduced YEAR NOT NULL
);

-- Adds the Foreign Key of the Manager ID to the Department Table
ALTER TABLE Department
ADD CONSTRAINT fk_manager
    FOREIGN KEY (ManagerEmployeeID) REFERENCES Employee (EmployeeID);

-- -----------------
-- ** Supplier Tables

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(75),
    SupplierCategory VARCHAR(100)
);

-- Supplier Delivery Table
CREATE TABLE SupplierDelivery (
    InvoiceID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierID INT NOT NULL,
    SupplyType VARCHAR(75),
    Quantity INT NOT NULL,
    ExpectedDelivery DATE,
    ActualDelivery DATE
);

-- ---------------------
-- ** Distributor Tables

-- Distributor Table
CREATE TABLE Dist (
    DistID INT PRIMARY KEY AUTO_INCREMENT,
    DistName VARCHAR(75) NOT NULL,
    DistPhone VARCHAR(10),
    DistAddress VARCHAR(75),
    DistEmail VARCHAR(75) 
);

-- Distributor Order Table
CREATE TABLE DistOrder (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    DistID INT NOT NULL,
    OrderDate DATE NOT NULL,
    FOREIGN KEY (DistID) REFERENCES Dist (DistID)
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
    OrderID INT NOT NULL,
    ShipmentDate DATE,
    TrackingNumber VARCHAR(50),
    ShippingService INT,
    FOREIGN KEY (OrderID) REFERENCES DistOrder (OrderID),
    FOREIGN KEY (ShippingService) REFERENCES ShipService (ShipperID)
);

-- Item Order ID Table
CREATE TABLE ItemOrderID (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    WineID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES DistOrder (OrderID),
    FOREIGN KEY (WineID) REFERENCES Wine (WineID)
);

-- -------------------------------------------------------------------------
-- ** Table for the Many to Many Relationship between Wines and Distributors

CREATE TABLE WineToDist (
    WD_ID INT PRIMARY KEY AUTO_INCREMENT,
    WineID INT NOT NULL,
    DistID INT NOT NULL,
    FOREIGN KEY (WineID) REFERENCES Wine (WineID),
    FOREIGN KEY (DistID) REFERENCES Dist (DistID)
);

SHOW Tables;
DESC Department;
DESC Employee;
DESC Hours;
DESC Wine;
DESC Supplier;
DESC SupplierDelivery;
DESC Dist;
DESC DistOrder;
DESC ShipService;
DESC Shipment;
DESC ItemOrderID;