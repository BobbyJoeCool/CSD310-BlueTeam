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
    Name VARCHAR(75) NOT NULL
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
    StartShift DATETIME NOT NULL,
    EndShift DATETIME NOT NULL,
    HoursWorked DECIMAL(4, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
);

-- Wine Table
CREATE TABLE Wine (
    WineID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(75) NOT NULL,
    Type VARCHAR(75),
    YearProduced YEAR NOT NULL
);

-- Wine Inventory Table
CREATE TABLE WineInventory (
    WineInventoryID INT PRIMARY KEY AUTO_INCREMENT,
    WineID INT,
    Quantity INT,
    FOREIGN KEY (WineID) REFERENCES Wine (WineID)
);

-- ==================
-- ** Supplier Tables

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(75),
    Category VARCHAR(100)
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
    ActualDelivery DATE,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
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
    Name VARCHAR(75) NOT NULL,
    Phone VARCHAR(10),
    Address VARCHAR(75),
    Email VARCHAR(75) 
);

-- ShippingService Table
CREATE TABLE ShipService (
    ShipperID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(75) NOT NULL,
    Phone VARCHAR(10),
    Web VARCHAR(100)
);

-- Shipment Table
CREATE TABLE Shipment (
    ShipmentID INT PRIMARY KEY AUTO_INCREMENT,
    ShipmentDate DATE,
    TrackingNumber VARCHAR(50),
    ShipperID INT,
    FOREIGN KEY (ShipperID) REFERENCES ShipService (ShipperID)
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
CREATE TABLE DistItemOrder (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    WineID INT NOT NULL,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES DistOrder (OrderID),
    FOREIGN KEY (WineID) REFERENCES Wine (WineID)
);

-- =========================================================================
-- Adds data to the Bacchus Database

-- ===============
-- Internal Tables

-- Departments
INSERT INTO Department (Name)
VALUES
    ('Finance & Payroll'),
    ('Marketing'),
    ('Production'),
    ('Distribution'),
    ('Executive');

-- Twenty employees for the production department created by ChatGPT asked to follow the format ('FirstName', 'LastName', 'Role', 3).  It was asked to use GrecoRoman hero names.
INSERT INTO Employee (FirstName, LastName, Role, DeptID)
VALUES
    ('Stan', 'Bacchus', 'Owner', 5),
    ('Davis', 'Bacchus', 'Owner', 5),
    ('Janet', 'Collins', 'Manager', 1),
    ('Roz', 'Murphy', 'Manager', 2),
    ('Henry', 'Doyle', 'Manager', 3),
    ('Maria', 'Costanza', 'Manager', 4),
    ('Bob', 'Ulrich', 'Assistant', 2),
    ('Achilles', 'Myrmidon', 'Winemaker', 3),
    ('Hercules', 'Alcides', 'Vineyard Worker', 3),
    ('Odysseus', 'Ithaca', 'Fermentation Specialist', 3),
    ('Aeneas', 'Trojan', 'Barrel Master', 3),
    ('Perseus', 'Danae', 'Bottling Specialist', 3),
    ('Theseus', 'Athens', 'Cellar Worker', 3),
    ('Jason', 'Argonaut', 'Quality Inspector', 3),
    ('Orpheus', 'Thrace', 'Label Designer', 3),
    ('Hector', 'Troy', 'Logistics Assistant', 3),
    ('Romulus', 'Rome', 'Stock Manager', 3),
    ('Remus', 'Rome', 'Packaging Worker', 3),
    ('Diomedes', 'Argos', 'Grape Picker', 3),
    ('Bellerophon', 'Corinth', 'Maintenance', 3),
    ('Ajax', 'Salamis', 'Wine Taster', 3),
    ('Castor', 'Sparta', 'Warehouse Worker', 3),
    ('Pollux', 'Sparta', 'Fermentation Assistant', 3),
    ('Ariadne', 'Crete', 'Assistant Winemaker', 3),
    ('Meleager', 'Calydon', 'Vineyard Assistant', 3),
    ('Atalanta', 'Arcadia', 'Barrel Assistant', 3);

-- The Inserting of the Hours into the database was removed because a Python Script was created to dynamically add random shifts over a period of time that can be set so that 4 months of data did not need to be uploaded.

INSERT INTO Wine (Name, Type, YearProduced)
VALUES
    ('Merlot', 'Red', 2023),
    ('Cabernet', 'Red', 2023),
    ('Chablis', 'White', 2023),
    ('Chardonnay', 'White', 2023),
    ('Merlot', 'Red', 2024),
    ('Cabernet', 'Red', 2024),
    ('Chablis', 'White', 2024),
    ('Chardonnay', 'White', 2024),
    ('Merlot', 'Red', 2025),
    ('Cabernet', 'Red', 2025),
    ('Chablis', 'White', 2025),
    ('Chardonnay', 'White', 2025);

INSERT INTO WineInventory (WineID, Quantity)
VALUES
    (1, 258),
    (2, 490),
    (3, 687),
    (4, 810),
    (5, 960),
    (6, 774),
    (7, 978),
    (8, 853),
    (9, 1190),
    (10, 2860),
    (11, 2696),
    (12, 2985);

-- Suppliers
INSERT INTO Supplier (Name, Category)
VALUES
    ('Dionysus Bottlery', 'Bottling Supplies'),
    ('Hermes Labels & Co', 'Shipping Supplies'),
    ('Vulcan Vats & Tubing', 'Production Supplies');

INSERT INTO SupplyItem (Name, SupplierID)
VALUES
    ("Bottles", 1),
    ("Corks", 1),
    ("Labels", 2),
    ("Boxes", 2),
    ("Vats", 3),
    ("Tubing (by ft)", 3),
    ("Merlot Grapes (lbs)", NULL),
    ("Cabernet Grapes (lbs)", NULL),
    ("Chablis/Chardonnay Grapes (lbs)", NULL);

INSERT INTO SupplyInventory (SupplyItemID, Quantity)
VALUES
    (1, 4258),
    (2, 16490),
    (3, 52687),
    (4, 530),
    (5, 15),
    (6, 671),
    (7, 7030),
    (8, 9041),
    (9, 14101);

INSERT INTO SupplierDelivery (SupplierID, ExpectedDelivery, ActualDelivery)
VALUES
    -- Q4 2025
    (1, '2025-10-01', '2025-10-01'),
    (1, '2025-10-01', '2025-10-01'),
    (1, '2025-11-01', '2025-11-03'),
    (2, '2025-10-03', '2025-10-02'),
    (2, '2025-10-03', '2025-10-02'),
    (2, '2025-11-05', '2025-11-03'), 
    (3, '2025-10-05', '2025-10-20'),
    (3, '2025-10-05', '2025-10-25'),
    (3, '2025-11-08', '2025-11-15'),

    -- Q1 2025
    (1, '2025-01-15', '2025-01-16'),  -- 1 day late
    (2, '2025-02-10', '2025-02-09'),  -- 1 day early
    (3, '2025-03-05', '2025-03-10'),  -- 5 days late

    -- Q2 2025
    (1, '2025-04-12', '2025-04-12'),  -- on time
    (2, '2025-05-01', '2025-05-03'),  -- 2 days late
    (3, '2025-06-18', '2025-06-17'),  -- 1 day early

    -- Q3 2025
    (1, '2025-07-07', '2025-07-10'),  -- 3 days late
    (2, '2025-08-21', '2025-08-21'),  -- on time
    (3, '2025-09-02', '2025-09-01');  -- 1 day early

INSERT INTO SupplierItemDelivery (InvoiceID, SupplyItemID, Quantity)
VALUES
    (1, 1, 500), (1, 2, 500),  -- Order of 500 Bottles and 500 Corks
    (2, 1, 1000), -- Order of 1000 Bottles
    (3, 1, 1000), (3, 2, 1000), -- Order of 1000 Bottles and Corks
    (4, 3, 50000), (4, 4, 500), -- Order of 100,000 Labels and 500 Boxes
    (5, 4, 500), -- Order of 500 Boxes
    (6, 4, 500), -- Order of 500 Boxes
    (7, 5, 1), (7, 6, 1000), -- Order of 1 Vat and 1000 feet of tubing
    (8, 6, 500), -- Order of 500 feet of tubing
    (9, 5, 1), (9, 6, 1000); -- Order of 1 Vat and 1000 feet of tubing

-- Distributors
INSERT INTO Distributor (Name, Phone, Address, Email)
VALUES
    ('Olympus Spirits', '5551010101', '1 Mount Olympus Ave', 'contact@olympusspirits.com'),
    ('Centaur Wines', '5552020202', '42 Labyrinth Lane', 'sales@centaurwines.com'),
    ('Apollo Imports', '5553030303', '7 Sun Chariot Blvd', 'info@apolloimports.com'),
    ('Poseidon Beverage Co', '5554040404', '12 Trident Way', 'orders@poseidonbev.com'),
    ('Minerva Distributors', '5555050505', '88 Athena Court', 'support@minervadistributors.com'),
    ('Vulcan Trade Ltd', '5556060606', '99 Forge Street', 'contact@vulcantrade.com');

INSERT INTO ShipService (Name, Phone, Web)
VALUES
    ('Hermes Express', '5551111111', 'www.hermesexpress.com'),
    ('Mercury Couriers', '5552222222', 'www.mercurycouriers.com'),
    ('Pegasus Delivery', '5553333333', 'www.pegasusdelivery.com'), 
    ('Argus Logistics', '5554444444', 'www.arguslogistics.com'),
    ('Icarus Freight', '5555555555', 'www.icarusfreight.com'),
    ('Apollo Air', '5556666666', 'www.apolloair.com');  

INSERT INTO Shipment (ShipmentDate, TrackingNumber, ShipperID)
VALUES
    ('2025-11-08', 'TRACK-1001', 1),
    ('2025-11-09', 'TRACK-1002', 2),
    ('2025-11-10', 'TRACK-1003', 3),
    ('2025-11-11', 'TRACK-1004', 4),
    ('2025-11-12', 'TRACK-1005', 5),
    ('2025-11-13', 'TRACK-1006', 6);

INSERT INTO DistOrder (DistID, OrderDate)
VALUES
    (1, '2025-11-07'), -- Order 1, Shipment 4
    (2, '2025-11-08'), -- Order 2, Shipment 2
    (3, '2025-11-09'), -- Order 3, Shipment 5
    (4, '2025-11-10'), -- Order 4, Shipment 10
    (5, '2025-11-11'), -- Order 5, Shipment 6
    (6, '2025-11-12'), -- Order 6, Shipment 1
    (1, '2025-11-13'), -- Order 7, NOT SHIPPED
    (2, '2025-11-14'), -- Order 8, Shipment 2 
    (3, '2025-11-15'), -- Order 9, NOT SHIPPED
    (4, '2025-11-16'), -- Order 10, Shipment 3
    (5, '2025-11-17'), -- Order 11, NOT SHIPPED
    (6, '2025-11-18'); -- Order 12, Shipment 1

-- Add the Orders to the corresponding Shipments
UPDATE DistOrder SET SHipmentID = 1 WHERE OrderID IN (6,12);
UPDATE DistOrder SET SHipmentID = 2 WHERE OrderID IN (2,8);
UPDATE DistOrder SET SHipmentID = 3 WHERE OrderID IN (4,10);
UPDATE DistOrder SET SHipmentID = 4 WHERE OrderID = 1;
UPDATE DistOrder SET SHipmentID = 5 WHERE OrderID = 3;
UPDATE DistOrder SET SHipmentID = 6 WHERE OrderID = 5;

INSERT INTO DistItemOrder (OrderID, WineID, Quantity)
VALUES
    -- Order 1 (Olympus Spirits)
    (1, 1, 50), (1, 2, 50), (1, 3, 50), (1, 4, 50),
    -- Order 2 (Centaur Wines)
    (2, 2, 30), (2, 3, 30), (2, 4, 30),
    -- Order 3 (Apollo Imports)
    (3, 2, 40), (3, 4, 40), (3, 6, 40),
    -- Order 4 (Poseidon Beverage Co)
    (4, 1, 25), (4, 2, 25), (4, 5, 25),
    -- Order 5 (Minerva Distributors)
    (5, 1, 60), (5, 2, 60), (5, 3, 60), (5, 4, 60),
    -- Order 6 (Vulcan Trade Ltd)
    (6, 5, 45), (6, 6, 45), (6, 9, 45), (6, 10, 45);
