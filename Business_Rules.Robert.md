# Milestone 1

## Business Rules

A list of business Rules derived from the case study:

1) There are several departments, each with one or more employee and one and only one department head.
2) The Departments are: 
    - Finance and Payroll (Assumed to be the same since the same person is in charge)
    - Marketing
    - Production
    - Distribution
3) They have multiple products and receive supplies from multiple vendors.  Each vendor supplies them with specific products, and they do not overlap.
4) Inventory System is either badly outdated or needs updating.  Need to be able to track th following for receiving:
    - Expected Delivery Date
    - Actual Delivery Date
    - (Be able to report the discrepancy)
    - Current Inventory
5) For Ordering:
    - Online Ordering System to allow distributors to order product and give the lead time for production.
    - Shipment tracking system.
6) For Employees: A time clock management system to track payroll and time punches.

### System Needs
A database showing current inventory, incoming orders, complete with expected dates and actual dates so that a comparison can be made, by vendor, showing who is consistently behind in delivering.

A database that tracks how well each type of wine is selling to distributors to track if a product is not selling as well, possibly broken down by the distributors that are buying it.

A database that tracks employee time punches and keeps a running total of hours works (and potentially labor paid).

### ERD Breakdown

# Bacchus Database

## Suppliers

### SUPPLY DELIVERY TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Invoice ID| Primary Key
| Supplier ID | Foreign Key (Supplier Table)
| Supply Type |
| Quantity Delivered |
| Expected Delivery |
| Actual Delivery |

### SUPPLIER TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Supplier ID | Primary Key
| Supplier Name |
| Supplier Category |

## Distributors

### DISTRIBUTOR ORDER TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Order ID | Primary Key
| Distributor ID | Foreign Key (Distributor Table)
| Order Date

### ITEM ORDER ID TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Order Item ID | Primary Key
| Order ID | Foreign Key (Distributor Order Table)
| Wine ID | Foreign Key (Wine Table)
| Quantity Ordered |

    This table is necessary because each order can have more than one item associated with it, so each order item is associated with the original order via foreign key.  Rather than have many Wine IDs and quantities in the Distributor Order table, a separate table allows for a cleaner approach.

### SHIPMENT TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Shipment ID | Primary Key
| Order ID | Foreign Key (Distributor Order Table)
| Shipment Date |
| Tracking Number |

### DISTRIBUTOR TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Distributor ID | Primary Key
| Distributor Name | 
| Distributor Phone | 
| Distributor Address |
| Distributor Email |

### WINE TO DISTRIBUTOR TABLE
| COLUMN | TYPE |
|:-------|:-----|
| WD_ID | Primary Key
| Wine ID | Foreign Key (Wine Table)
| Distributor ID | Foreign Key (Distributor Table)

    This table is necessary for the Many to Many relationship between the Wines and Distributors.  The WD key is auto-generated and serves only to link a wine to a distributor in the database.

## Internal

### EMPLOYEE TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Employee ID | Primary Key
| First Name |
| Last Name |
| Role |
| Department ID | Foreign Key (Department Table)

### DEPARTMENT TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Department ID | Primary Key
| Department Name |
| Manager Employee ID | Foreign Key (to Employee Table)

### HOURS TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Hours ID | Primary Key |
| Employee ID | Foreign Key (Employee Table)
| Date Worked | 
| Hours Worked | 

    This table will log every time punch, with a dynamicly generated Hours ID primary key.  This will allow us to search each employee to see how many hours they worked.

### WINE TABLE
| COLUMN | TYPE |
|:-------|:-----|
| Wine ID | Primary Key
| Wine Name |
| Wine Type |
| Year Produced |


## ERD Relationship Summary

**Department** (1 — M) **Employee**

**Employee** (1 — M) **EmployeeHours**

**Wine** (M *WineDistributor* M) **Distributor**

**Supplier** (1 — M) **SupplyDelivery**

**Distributor** (1 — M) **DistributorOrder**

**DistributorOrder** (1 — M) **OrderItem**

**OrderItem** (1 — M) **Shipment**
