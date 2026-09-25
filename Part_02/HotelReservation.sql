-- ============================================================
-- Part 02 - Hotel System: Insert & Update Operations
-- Run after Part_01/HotelReservation.sql.
-- ============================================================

USE HotelReservation;
GO

-- ============================================================
-- 1. INSERT OPERATIONS
-- ============================================================

-- Insert a Guest
INSERT INTO Guests (FullName, Nationality, PassportNumber, DateOfBirth)
VALUES ('John Smith', 'American', 'US1234567', '1985-04-12');

-- Insert multiple Guests in one statement
INSERT INTO Guests (FullName, Nationality, PassportNumber, DateOfBirth) VALUES
    ('Maria Garcia', 'Spanish',  'ES9988776', '1990-11-03'),
    ('Ali Mansour',  'Egyptian', 'EG5544332', '1978-07-22'),
    ('Chen Wei',     'Chinese',  'CN7766554', '1995-01-30');

SELECT GuestId, FullName, Nationality, PassportNumber, DateOfBirth FROM Guests;
GO

-- ============================================================
-- 2. UPDATE OPERATIONS
-- ============================================================

-- Increase DailyRate by 15% for all suites
UPDATE Rooms
SET DailyRate = DailyRate * 1.15
WHERE RoomType = 'Suite';

-- Set each reservation's status from its dates
UPDATE Reservations
SET ReservationStatus = CASE
                            WHEN CheckOutDate < GETDATE() THEN 'Completed'
                            WHEN CheckInDate  > GETDATE() THEN 'Upcoming'
                            ELSE 'Active'
                        END;

SELECT RoomNumber, RoomType, DailyRate FROM Rooms;
SELECT ReservationId, CheckInDate, CheckOutDate, ReservationStatus FROM Reservations;
GO
