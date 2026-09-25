-- ============================================================
-- Part 02 - Online Retail System: Insert & Update Operations
-- Run after Part_01/OnlineRetailStore.sql.
-- ============================================================

USE OnlineRetailStore;
GO

-- ============================================================
-- 1. INSERT OPERATIONS
-- ============================================================

-- Insert a new Customer
INSERT INTO Customers (FullName, PhoneNumber, Email, ShippingAddress, RegistrationDate)
VALUES ('Nada Farouk', '+20 106 555 0006', 'nada.farouk@example.com', '45 El Orouba St, Heliopolis', GETDATE());

-- Insert 3 new Suppliers
INSERT INTO Suppliers (Name, Country, Email, Address, ContactNumber) VALUES
    ('Nile Tech Distribution', 'Egypt', 'sales@niletech.com',       '14 El Tahrir St, Cairo',    '+20 100 111 2222'),
    ('Cairo Home Supplies',    'Egypt', 'info@cairohome.com',       '8 Gesr El Suez, Cairo',     '+20 101 333 4444'),
    ('Global Gadgets Ltd',     'China', 'contact@globalgadgets.cn', '221 Huaqiang Rd, Shenzhen', '+86 755 8888 9999');

-- Insert 2 Categories
INSERT INTO Categories (Name, Description) VALUES
    ('Gaming',    'Consoles, controllers and gaming gear'),
    ('Wearables', 'Smart watches and fitness bands');

-- Insert a Product with only Name and UnitPrice
-- StockQuantity and AddedDate take their defaults; Description and CategoryId stay NULL.
INSERT INTO Products (Name, UnitPrice)
VALUES ('Wireless Charger 15W', 450.00);

-- Create ArchivedStock and fill it with every stock transaction before 2023
CREATE TABLE ArchivedStock (
    TranId          INT       PRIMARY KEY,
    ProductId       INT       NOT NULL,
    QuantityChange  INT       NOT NULL,
    TranDate        DATETIME2 NOT NULL
);

INSERT INTO ArchivedStock (TranId, ProductId, QuantityChange, TranDate)
SELECT TranId, ProductId, QuantityChange, TranDate
FROM StockTransactions
WHERE TranDate < '2023-01-01';

SELECT * FROM ArchivedStock;
GO

-- ============================================================
-- 2. UPDATE OPERATIONS
-- ============================================================

-- Increase UnitPrice by 10% for every product under 100 EGP
UPDATE Products
SET UnitPrice = UnitPrice * 1.10
WHERE UnitPrice < 100;

-- Set each order's status from its total amount
UPDATE Orders
SET Status = CASE
                 WHEN TotalAmount > 5000 THEN 'Premium'
                 ELSE 'Standard'
             END;

SELECT ProductId, Name, UnitPrice FROM Products;
SELECT OrderId, TotalAmount, Status FROM Orders;
GO
