-- ============================================================
-- Part 01 - Online Retail Store Database
-- Builds the database from the provided relational schema, then adds a few
-- sample rows so the Part 02 operations have data to work on.
-- Dialect: T-SQL (SQL Server)
-- ============================================================

USE master;
GO

IF DB_ID('OnlineRetailStore') IS NOT NULL
BEGIN
    ALTER DATABASE OnlineRetailStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OnlineRetailStore;
END
GO

CREATE DATABASE OnlineRetailStore;
GO

USE OnlineRetailStore;
GO

-- MainCategory is self-referencing, for subcategories (e.g. "Laptops" under "Electronics").
CREATE TABLE Categories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500) NULL,
    MainCategory    INT NULL,
    CONSTRAINT FK_Categories_MainCategory FOREIGN KEY (MainCategory)
        REFERENCES Categories (CategoryId)
);

CREATE TABLE Suppliers (
    SupplierId      INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    Country         NVARCHAR(100) NULL,
    Email           NVARCHAR(150) NULL,
    Address         NVARCHAR(250) NULL,
    ContactNumber   NVARCHAR(20) NULL
);

-- CategoryId allows NULL so a product can be added before it is assigned a category.
CREATE TABLE Products (
    ProductId       INT IDENTITY(1,1) PRIMARY KEY,
    StockQuantity   INT NOT NULL DEFAULT 0,
    Name            NVARCHAR(150) NOT NULL,
    AddedDate       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Description     NVARCHAR(1000) NULL,
    UnitPrice       DECIMAL(10, 2) NOT NULL,
    CategoryId      INT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId)
        REFERENCES Categories (CategoryId)
);

CREATE TABLE Products_Suppliers (
    SupplierId  INT NOT NULL,
    ProductId   INT NOT NULL,
    CONSTRAINT PK_Products_Suppliers PRIMARY KEY (SupplierId, ProductId),
    CONSTRAINT FK_Products_Suppliers_Suppliers FOREIGN KEY (SupplierId)
        REFERENCES Suppliers (SupplierId),
    CONSTRAINT FK_Products_Suppliers_Products FOREIGN KEY (ProductId)
        REFERENCES Products (ProductId)
);

CREATE TABLE StockTransactions (
    TranId          INT IDENTITY(1,1) PRIMARY KEY,
    TranDate        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    QuantityChange  INT NOT NULL,
    Type            NVARCHAR(3) NOT NULL,
    Reference       INT NULL,
    ProductId       INT NOT NULL,
    CONSTRAINT FK_StockTransactions_Products FOREIGN KEY (ProductId)
        REFERENCES Products (ProductId),
    CONSTRAINT CK_StockTransactions_Type CHECK (Type IN ('in', 'out'))
);

CREATE TABLE Customers (
    CustomerId          INT IDENTITY(1,1) PRIMARY KEY,
    FullName            NVARCHAR(150) NOT NULL,
    PhoneNumber         NVARCHAR(20) NULL,
    Email               NVARCHAR(150) NOT NULL UNIQUE,
    ShippingAddress     NVARCHAR(250) NULL,
    RegistrationDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE Orders (
    OrderId     INT IDENTITY(1,1) PRIMARY KEY,
    Status      NVARCHAR(50) NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    OrderDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CustomerId  INT NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId)
        REFERENCES Customers (CustomerId)
);

CREATE TABLE OrderItems (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(10, 2) NOT NULL,
    ProductId   INT NOT NULL,
    OrderId     INT NOT NULL,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products (ProductId),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId)
);

CREATE TABLE Reviews (
    ReviewId    INT IDENTITY(1,1) PRIMARY KEY,
    Rating      INT NOT NULL,
    Date        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Comment     NVARCHAR(1000) NULL,
    ProductId   INT NOT NULL,
    CustomerId  INT NOT NULL,
    CONSTRAINT FK_Reviews_Products FOREIGN KEY (ProductId)
        REFERENCES Products (ProductId),
    CONSTRAINT FK_Reviews_Customers FOREIGN KEY (CustomerId)
        REFERENCES Customers (CustomerId),
    CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5)
);

CREATE TABLE Payments (
    PaymentId   INT IDENTITY(1,1) PRIMARY KEY,
    PaymentDate DATETIME2 NOT NULL,
    Amount      DECIMAL(10, 2) NOT NULL,
    Status      NVARCHAR(50) NOT NULL,
    Method      NVARCHAR(50) NOT NULL
);

CREATE TABLE Orders_Payments (
    OrderId     INT NOT NULL,
    PaymentId   INT NOT NULL,
    CONSTRAINT PK_Orders_Payments PRIMARY KEY (OrderId, PaymentId),
    CONSTRAINT FK_Orders_Payments_Orders FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId),
    CONSTRAINT FK_Orders_Payments_Payments FOREIGN KEY (PaymentId)
        REFERENCES Payments (PaymentId)
);

CREATE TABLE Shipments (
    ShipmentId      INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Status          NVARCHAR(50) NOT NULL,
    DeliveryDate    DATETIME2 NULL,
    CarrierName     NVARCHAR(100) NOT NULL,
    TrackingNumber  NVARCHAR(100) NULL,
    OrderId         INT NOT NULL,
    CONSTRAINT FK_Shipments_Orders FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId)
);
GO

-- ============================================================
-- Sample data
-- ============================================================

INSERT INTO Categories (Name, Description, MainCategory) VALUES
    ('Electronics', 'Phones, laptops and other devices', NULL),
    ('Accessories', 'Cables, stands and other add-ons',  NULL);

INSERT INTO Products (Name, UnitPrice, StockQuantity, Description, CategoryId) VALUES
    ('Dell Inspiron 15',   18500.00,  25, '15.6" laptop, 16GB RAM, 512GB SSD', 1),
    ('Samsung Galaxy A54',  9500.00,  40, '6.4" AMOLED, 128GB',                1),
    ('USB-C Cable',           85.00, 200, 'Braided 1m charging cable',         2),
    ('Phone Stand',           60.00, 150, 'Adjustable aluminium stand',        2),
    ('Laptop Sleeve 15"',    320.00,  45, 'Water resistant sleeve',            2);

-- Two movements before 2023 and two after, for the ArchivedStock operation.
INSERT INTO StockTransactions (TranDate, QuantityChange, Type, Reference, ProductId) VALUES
    ('2021-05-10',  50, 'in',  1001, 1),
    ('2022-11-01', -10, 'out', 1002, 2),
    ('2023-04-20', 100, 'in',  1003, 3),
    ('2024-01-12',  -5, 'out', 1004, 4);

INSERT INTO Customers (FullName, PhoneNumber, Email, ShippingAddress, RegistrationDate) VALUES
    ('Ahmed Hassan', '+20 100 555 0001', 'ahmed.hassan@example.com', '12 Nasr Rd, Cairo',      '2022-01-15'),
    ('Mona Adel',    '+20 101 555 0002', 'mona.adel@example.com',    '5 Corniche, Alexandria', '2023-06-02');

-- Totals on both sides of 5000, for the Premium / Standard update.
INSERT INTO Orders (Status, TotalAmount, OrderDate, CustomerId) VALUES
    ('Pending', 18500.00, '2024-03-01', 1),
    ('Pending',   145.00, '2024-05-11', 1),
    ('Pending',  9500.00, '2025-01-20', 2),
    ('Pending',   320.00, '2025-02-14', 2);
GO
