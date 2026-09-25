-- ============================================================
-- Part 01 - Hotel Reservation Database
-- Builds the database from the provided relational schema, then adds a few
-- sample rows so the Part 02 operations have data to work on.
-- Typo fixes from the original diagram: ManageId -> ManagerId, SttafId -> StaffId, DaliyRate -> DailyRate.
-- Dialect: T-SQL (SQL Server)
-- ============================================================

USE master;
GO

IF DB_ID('HotelReservation') IS NOT NULL
BEGIN
    ALTER DATABASE HotelReservation SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HotelReservation;
END
GO

CREATE DATABASE HotelReservation;
GO

USE HotelReservation;
GO

-- ManagerId's FK to Staff is added after Staff exists below (circular reference: a hotel's
-- manager is a staff member, and every staff member works at one hotel).
CREATE TABLE Hotels (
    HotelId         INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    Address         NVARCHAR(250) NOT NULL,
    City            NVARCHAR(100) NOT NULL,
    StarRating      INT NOT NULL,
    ContactNumber   NVARCHAR(20) NULL,
    ManagerId       INT NULL UNIQUE,
    CONSTRAINT CK_Hotels_StarRating CHECK (StarRating BETWEEN 1 AND 5)
);

CREATE TABLE Staff (
    StaffId     INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(150) NOT NULL,
    Position    NVARCHAR(50) NOT NULL,
    Salary      DECIMAL(10, 2) NOT NULL,
    HotelId     INT NOT NULL,
    CONSTRAINT FK_Staff_Hotels FOREIGN KEY (HotelId)
        REFERENCES Hotels (HotelId)
);

ALTER TABLE Hotels
    ADD CONSTRAINT FK_Hotels_Manager FOREIGN KEY (ManagerId)
        REFERENCES Staff (StaffId);

CREATE TABLE Services (
    ServiceId       INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName     NVARCHAR(100) NOT NULL,
    Charge          DECIMAL(10, 2) NOT NULL,
    RequestDate     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    StaffId         INT NOT NULL,
    CONSTRAINT FK_Services_Staff FOREIGN KEY (StaffId)
        REFERENCES Staff (StaffId)
);

CREATE TABLE Rooms (
    RoomNumber      NVARCHAR(10) PRIMARY KEY,
    RoomType        NVARCHAR(50) NOT NULL,
    Capacity        INT NOT NULL,
    DailyRate       DECIMAL(10, 2) NOT NULL,
    Availability    NVARCHAR(50) NOT NULL,
    HotelId         INT NOT NULL,
    CONSTRAINT FK_Rooms_Hotels FOREIGN KEY (HotelId)
        REFERENCES Hotels (HotelId)
);

CREATE TABLE Amenities (
    RoomNumber  NVARCHAR(10) NOT NULL,
    Amenity     NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Amenities PRIMARY KEY (RoomNumber, Amenity),
    CONSTRAINT FK_Amenities_Rooms FOREIGN KEY (RoomNumber)
        REFERENCES Rooms (RoomNumber)
);

CREATE TABLE Reservations (
    ReservationId       INT IDENTITY(1,1) PRIMARY KEY,
    BookingDate         DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CheckInDate         DATE NOT NULL,
    CheckOutDate        DATE NOT NULL,
    ReservationStatus   NVARCHAR(50) NOT NULL,
    TotalPrice          DECIMAL(10, 2) NOT NULL,
    NumberOfAdults      INT NOT NULL,
    NumberOfChildren    INT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Reservations_Dates CHECK (CheckOutDate > CheckInDate)
);

CREATE TABLE Reservations_Rooms (
    ReservationId   INT NOT NULL,
    RoomNumber      NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_Reservations_Rooms PRIMARY KEY (ReservationId, RoomNumber),
    CONSTRAINT FK_Reservations_Rooms_Reservations FOREIGN KEY (ReservationId)
        REFERENCES Reservations (ReservationId),
    CONSTRAINT FK_Reservations_Rooms_Rooms FOREIGN KEY (RoomNumber)
        REFERENCES Rooms (RoomNumber)
);

CREATE TABLE ReservationService (
    ServiceId       INT NOT NULL,
    ReservationId   INT NOT NULL,
    CONSTRAINT PK_ReservationService PRIMARY KEY (ServiceId, ReservationId),
    CONSTRAINT FK_ReservationService_Services FOREIGN KEY (ServiceId)
        REFERENCES Services (ServiceId),
    CONSTRAINT FK_ReservationService_Reservations FOREIGN KEY (ReservationId)
        REFERENCES Reservations (ReservationId)
);

CREATE TABLE Guests (
    GuestId         INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(150) NOT NULL,
    Nationality     NVARCHAR(100) NULL,
    PassportNumber  NVARCHAR(50) NOT NULL UNIQUE,
    DateOfBirth     DATE NOT NULL
);

CREATE TABLE Guest_Contact_Details (
    GuestId INT NOT NULL,
    Detail  NVARCHAR(150) NOT NULL,
    CONSTRAINT PK_Guest_Contact_Details PRIMARY KEY (GuestId, Detail),
    CONSTRAINT FK_Guest_Contact_Details_Guests FOREIGN KEY (GuestId)
        REFERENCES Guests (GuestId)
);

CREATE TABLE Reservations_Guest (
    ReservationId   INT NOT NULL,
    GuestId         INT NOT NULL,
    CONSTRAINT PK_Reservations_Guest PRIMARY KEY (ReservationId, GuestId),
    CONSTRAINT FK_Reservations_Guest_Reservations FOREIGN KEY (ReservationId)
        REFERENCES Reservations (ReservationId),
    CONSTRAINT FK_Reservations_Guest_Guests FOREIGN KEY (GuestId)
        REFERENCES Guests (GuestId)
);

CREATE TABLE Payments (
    PaymentId           INT IDENTITY(1,1) PRIMARY KEY,
    Method              NVARCHAR(50) NOT NULL,
    Date                DATETIME2 NOT NULL,
    Amount              DECIMAL(10, 2) NOT NULL,
    ConfirmationNumber  NVARCHAR(50) NULL
);

CREATE TABLE Reservations_Payment (
    ReservationId   INT NOT NULL,
    PaymentId       INT NOT NULL,
    CONSTRAINT PK_Reservations_Payment PRIMARY KEY (ReservationId, PaymentId),
    CONSTRAINT FK_Reservations_Payment_Reservations FOREIGN KEY (ReservationId)
        REFERENCES Reservations (ReservationId),
    CONSTRAINT FK_Reservations_Payment_Payments FOREIGN KEY (PaymentId)
        REFERENCES Payments (PaymentId)
);
GO

-- ============================================================
-- Sample data
-- ============================================================

INSERT INTO Hotels (Name, Address, City, StarRating, ContactNumber) VALUES
    ('Nile Grand Hotel', '1 Corniche El Nil', 'Cairo', 5, '+20 2 2555 1000');

INSERT INTO Rooms (RoomNumber, RoomType, Capacity, DailyRate, Availability, HotelId) VALUES
    ('101', 'Standard', 2, 1200.00, 'Available', 1),
    ('102', 'Deluxe',   3, 1800.00, 'Available', 1),
    ('201', 'Suite',    4, 3500.00, 'Occupied',  1),
    ('202', 'Suite',    4, 3800.00, 'Available', 1);

-- Dates are relative to today, so the status update always finds a finished,
-- an ongoing and a future stay.
INSERT INTO Reservations (CheckInDate, CheckOutDate, ReservationStatus, TotalPrice, NumberOfAdults, NumberOfChildren) VALUES
    (CAST(DATEADD(DAY, -30, GETDATE()) AS DATE), CAST(DATEADD(DAY, -25, GETDATE()) AS DATE), 'Confirmed',  6000.00, 2, 0),
    (CAST(DATEADD(DAY,  -2, GETDATE()) AS DATE), CAST(DATEADD(DAY,   3, GETDATE()) AS DATE), 'Confirmed', 17500.00, 2, 1),
    (CAST(DATEADD(DAY,  20, GETDATE()) AS DATE), CAST(DATEADD(DAY,  24, GETDATE()) AS DATE), 'Confirmed',  7200.00, 3, 0);
GO
