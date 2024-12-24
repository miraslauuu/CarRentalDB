

--------------------------------CREATING DATABASE----------------------------------------------

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CarRentalDB')
BEGIN
    DROP DATABASE CarRentalDB;
END
GO

CREATE DATABASE CarRentalDB
COLLATE Polish_CS_AS;
GO

USE master;
ALTER DATABASE CarRentalDB SET RECOVERY FULL;

USE CarRentalDB;
GO

/* 

-- IN ORDER TO EXECUTE BACKUP AS SA RUN THE FOLLOWING SCRIPT:
RESTORE DATABASE CarRentalDB
FROM DISK = 'C:\'                                              -- PATH TO CarRentalDB_FULL.bak
WITH MOVE 'CarRentalDB_Data' TO 'C:\SQLData\CarRentalDB.mdf',  -- CONFIGURE ACCORDINGLY TO YOUR SERVER
     MOVE 'CarRentalDB_Log' TO 'C:\SQLData\CarRentalDB.ldf',   -- CONFIGURE ACCORDINGLY TO YOUR SERVER
     REPLACE;
GO

*/
--------------------------------CREATING TABLES----------------------------------------------

CREATE TABLE Branches (
    BranchID INT IDENTITY(1,1) PRIMARY KEY, 
    BranchName NVARCHAR(100) NOT NULL UNIQUE, 
    Address NVARCHAR(255) NOT NULL, 
    PhoneNumber NVARCHAR(15) NOT NULL UNIQUE, 
    Email NVARCHAR(100) UNIQUE, 
    CreatedDate DATETIME2 DEFAULT GETDATE(),
	ModifiedDate datetime DEFAULT (GETDATE())
);
GO

CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY, 
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255),
	ModifiedDate datetime DEFAULT (GETDATE())

);
GO

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL, 
    Position NVARCHAR(50) NOT NULL, 
    RoleID INT NOT NULL, 
    PhoneNumber NVARCHAR(15) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    HireDate DATETIME2 DEFAULT GETDATE(), 
    Salary DECIMAL(10, 2) CHECK (Salary > 0), 
    BranchID INT NOT NULL, 
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Employees_Branches FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    CONSTRAINT FK_Employees_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

CREATE TABLE VehicleType (
    VehicleTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255),
	ModifiedDate datetime DEFAULT (GETDATE())

);
GO

CREATE TABLE Vehicles (
    VehicleID INT IDENTITY(1,1) PRIMARY KEY, 
    RegistrationNumber NVARCHAR(20) NOT NULL UNIQUE,
    Make NVARCHAR(50) NOT NULL, 
    Model NVARCHAR(50) NOT NULL,
    YearOfProduction INT CHECK (YearOfProduction >= 2000 AND YearOfProduction <= YEAR(GETDATE())), 
    VehicleTypeID INT NOT NULL, 
    BranchID INT NOT NULL, 
    IsAvailable BIT DEFAULT 1, 
    CreatedDate DATETIME2 DEFAULT GETDATE(),
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Vehicles_VehicleType FOREIGN KEY (VehicleTypeID) REFERENCES VehicleType(VehicleTypeID),
    CONSTRAINT FK_Vehicles_Branches FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
GO

CREATE TABLE Insurance (
    InsuranceID INT IDENTITY(1,1) PRIMARY KEY, 
    VehicleID INT NOT NULL,
    InsuranceProvider NVARCHAR(100) NOT NULL,
    PolicyNumber NVARCHAR(50) NOT NULL UNIQUE,
    StartDate DATETIME2 NOT NULL, 
    EndDate DATETIME2 NOT NULL, 
    PremiumAmount DECIMAL(10, 2) NOT NULL CHECK (PremiumAmount > 0),
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Insurance_Vehicles FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);
GO

CREATE TABLE Services (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY, 
    VehicleID INT NOT NULL,
    ServiceDate DATETIME2 NOT NULL, 
    Description NVARCHAR(255), 
    Cost DECIMAL(10, 2) NOT NULL CHECK (Cost > 0), 
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Services_Vehicles FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);
GO

CREATE TABLE VehicleInspection (
    InspectionID INT IDENTITY(1,1) PRIMARY KEY, 
    VehicleID INT NOT NULL,
    InspectionDate DATETIME2 NOT NULL, 
    Inspector NVARCHAR(100) NOT NULL,
    Passed BIT NOT NULL, 
    Remarks NVARCHAR(255), 
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_VehicleInspection_Vehicles FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Address NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
	ModifiedDate datetime DEFAULT (GETDATE())

);
GO

CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY, 
    CustomerID INT NOT NULL, 
    VehicleID INT NOT NULL,
    ReservationDate DATETIME2 DEFAULT GETDATE(),
    StartDate DATETIME2 NOT NULL, 
    EndDate DATETIME2 NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL CHECK (TotalAmount > 0),
    ReservationStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (ReservationStatus IN ('Pending', 'Confirmed', 'Cancelled')),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Reservations_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Reservations_Vehicles FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);
GO

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY, 
    ReservationID INT NOT NULL, 
    PaymentDate DATETIME2 DEFAULT GETDATE(), 
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    PaymentMethod NVARCHAR(20) NOT NULL, 
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_Payments_Reservations FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);
GO

CREATE TABLE CustomerHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ReservationID INT NOT NULL,
    ActionDate DATETIME2 DEFAULT GETDATE(),
    ActionDescription NVARCHAR(255) NOT NULL, 
	ModifiedDate datetime DEFAULT (GETDATE()),
    CONSTRAINT FK_CustomerHistory_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_CustomerHistory_Reservations FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    UserGUID UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    Rowguid UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE
);
GO

CREATE TABLE Logs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserGUID UNIQUEIDENTIFIER NOT NULL, 
    Password NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(255) NOT NULL, 
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    Rowguid UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE 
);
GO

ALTER TABLE Logs
ADD CONSTRAINT FK_Logs_Users FOREIGN KEY (UserGUID) REFERENCES Users(UserGUID);
GO

ALTER TABLE Customers
ADD Rowguid UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE;
GO

ALTER TABLE Vehicles
ADD Rowguid UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE;
GO

ALTER TABLE Reservations
ADD Rowguid UNIQUEIDENTIFIER DEFAULT NEWID() UNIQUE;
GO

--------------------------------ADDING NONCLUSTERED INDEXES----------------------------------------------

CREATE NONCLUSTERED INDEX IX_Employees_BranchID ON Employees(BranchID);
CREATE NONCLUSTERED INDEX IX_Employees_RoleID ON Employees(RoleID);
CREATE NONCLUSTERED INDEX IX_Vehicles_BranchID ON Vehicles(BranchID);
CREATE NONCLUSTERED INDEX IX_Vehicles_VehicleTypeID ON Vehicles(VehicleTypeID);
CREATE NONCLUSTERED INDEX IX_Insurance_VehicleID ON Insurance(VehicleID);
CREATE NONCLUSTERED INDEX IX_Services_VehicleID ON Services(VehicleID);
CREATE NONCLUSTERED INDEX IX_VehicleInspection_VehicleID ON VehicleInspection(VehicleID);
CREATE NONCLUSTERED INDEX IX_Reservations_CustomerID ON Reservations(CustomerID);
CREATE NONCLUSTERED INDEX IX_Reservations_VehicleID ON Reservations(VehicleID);
CREATE NONCLUSTERED INDEX IX_Payments_ReservationID ON Payments(ReservationID);
CREATE NONCLUSTERED INDEX IX_CustomerHistory_CustomerID ON CustomerHistory(CustomerID);
CREATE NONCLUSTERED INDEX IX_CustomerHistory_ReservationID ON CustomerHistory(ReservationID);
GO


--------------------------------CREATING TRIGGERS----------------------------------------------

DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Branches;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_CustomerHistory;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Customers;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Employees;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Insurance;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Payments;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Reservations;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Roles;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Services;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_VehicleInspection;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_Vehicles;
DROP TRIGGER IF EXISTS trg_UpdateModifiedDate_VehicleType;
DROP TRIGGER IF EXISTS trg_LogInsert;
DROP TRIGGER IF EXISTS trg_LogUpdate;
DROP TRIGGER IF EXISTS trg_UserInsert;
DROP TRIGGER IF EXISTS trg_UserUpdate;
DROP TRIGGER IF EXISTS trg_CheckEndDate;
DROP TRIGGER IF EXISTS trg_UserDelete;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Branches
ON Branches
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Branches
    SET ModifiedDate = GETDATE()
    FROM Branches
    INNER JOIN inserted ON Branches.BranchID = inserted.BranchID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_CustomerHistory
ON CustomerHistory
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE CustomerHistory
    SET ModifiedDate = GETDATE()
    FROM CustomerHistory
    INNER JOIN inserted ON CustomerHistory.HistoryID = inserted.HistoryID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Customers
    SET ModifiedDate = GETDATE()
    FROM Customers
    INNER JOIN inserted ON Customers.CustomerID = inserted.CustomerID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Employees
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Employees
    SET ModifiedDate = GETDATE()
    FROM Employees
    INNER JOIN inserted ON Employees.EmployeeID = inserted.EmployeeID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Insurance
ON Insurance
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Insurance
    SET ModifiedDate = GETDATE()
    FROM Insurance
    INNER JOIN inserted ON Insurance.InsuranceID = inserted.InsuranceID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Payments
ON Payments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Payments
    SET ModifiedDate = GETDATE()
    FROM Payments
    INNER JOIN inserted ON Payments.PaymentID = inserted.PaymentID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Reservations
ON Reservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Reservations
    SET ModifiedDate = GETDATE()
    FROM Reservations
    INNER JOIN inserted ON Reservations.ReservationID = inserted.ReservationID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Roles
ON Roles
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Roles
    SET ModifiedDate = GETDATE()
    FROM Roles
    INNER JOIN inserted ON Roles.RoleID = inserted.RoleID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Services
ON Services
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Services
    SET ModifiedDate = GETDATE()
    FROM Services
    INNER JOIN inserted ON Services.ServiceID = inserted.ServiceID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_VehicleInspection
ON VehicleInspection
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE VehicleInspection
    SET ModifiedDate = GETDATE()
    FROM VehicleInspection
    INNER JOIN inserted ON VehicleInspection.InspectionID = inserted.InspectionID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_Vehicles
ON Vehicles
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Vehicles
    SET ModifiedDate = GETDATE()
    FROM Vehicles
    INNER JOIN inserted ON Vehicles.VehicleID = inserted.VehicleID;
END;
GO

CREATE TRIGGER trg_UpdateModifiedDate_VehicleType
ON VehicleType
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE VehicleType
    SET ModifiedDate = GETDATE()
    FROM VehicleType
    INNER JOIN inserted ON VehicleType.VehicleTypeID = inserted.VehicleTypeID;
END;
GO

CREATE TRIGGER trg_LogInsert
ON Logs
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Logs
    SET ModifiedDate = GETDATE()
    WHERE LogID IN (SELECT LogID FROM inserted);
END;
GO

CREATE TRIGGER trg_LogUpdate
ON Logs
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Logs
    SET ModifiedDate = GETDATE()
    WHERE LogID IN (SELECT LogID FROM inserted);
END;
GO

CREATE TRIGGER trg_UserInsert
ON Users
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Logs (UserGUID, Password, Salt, ModifiedDate)
    SELECT UserGUID, Password, Salt, GETDATE()
    FROM inserted;
END;
GO

CREATE TRIGGER trg_UserUpdate
ON Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET ModifiedDate = GETDATE()
    WHERE UserID IN (SELECT UserID FROM inserted);

    INSERT INTO Logs (UserGUID, Password, Salt, ModifiedDate)
    SELECT UserGUID, Password, Salt, GETDATE()
    FROM inserted;
END;
GO

CREATE TRIGGER trg_UserDelete
ON Users
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Logs (UserGUID, Password, Salt, ModifiedDate)
    SELECT UserGUID, 'DELETED', 'DELETED', GETDATE()
    FROM deleted;
END;
GO

CREATE TRIGGER trg_CheckEndDate
ON Insurance
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE StartDate >= EndDate
    )
    BEGIN
        RAISERROR ('EndDate must be later than StartDate.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

--------------------------------CREATING PROCEDURES----------------------------------------------

CREATE PROCEDURE InsertBranch
    @BranchName NVARCHAR(100),
    @Address NVARCHAR(255),
    @PhoneNumber NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Branches (BranchName, Address, PhoneNumber, Email)
        VALUES (@BranchName, @Address, @PhoneNumber, @Email);
        PRINT 'Branch inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting branch.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @PhoneNumber NVARCHAR(15),
    @Email NVARCHAR(100),
    @Address NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Customers (FirstName, LastName, PhoneNumber, Email, Address)
        VALUES (@FirstName, @LastName, @PhoneNumber, @Email, @Address);
        PRINT 'Customer inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting customer.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertVehicle
    @RegistrationNumber NVARCHAR(20),
    @Make NVARCHAR(50),
    @Model NVARCHAR(50),
    @YearOfProduction INT,
    @VehicleTypeID INT,
    @BranchID INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Vehicles (RegistrationNumber, Make, Model, YearOfProduction, VehicleTypeID, BranchID)
        VALUES (@RegistrationNumber, @Make, @Model, @YearOfProduction, @VehicleTypeID, @BranchID);
        PRINT 'Vehicle inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting vehicle.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertReservation
    @CustomerID INT,
    @VehicleID INT,
    @StartDate DATETIME2,
    @EndDate DATETIME2,
    @TotalAmount DECIMAL(10, 2),
    @ReservationStatus NVARCHAR(20) = 'Pending'
AS
BEGIN
    BEGIN TRY
        INSERT INTO Reservations (CustomerID, VehicleID, StartDate, EndDate, TotalAmount, ReservationStatus)
        VALUES (@CustomerID, @VehicleID, @StartDate, @EndDate, @TotalAmount, @ReservationStatus);
        PRINT 'Reservation inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting reservation.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertPayment
    @ReservationID INT,
    @Amount DECIMAL(10, 2),
    @PaymentMethod NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Payments (ReservationID, Amount, PaymentMethod)
        VALUES (@ReservationID, @Amount, @PaymentMethod);
        PRINT 'Payment inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting payment.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertLog
    @UserGUID UNIQUEIDENTIFIER,
    @Password NVARCHAR(255),
    @Salt NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Logs (UserGUID, Password, Salt)
        VALUES (@UserGUID, @Password, @Salt);
        PRINT 'Log inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting log.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertRole
    @RoleName NVARCHAR(50),
    @Description NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Roles (RoleName, Description)
        VALUES (@RoleName, @Description);
        PRINT 'Role inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting role.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Position NVARCHAR(50),
    @RoleID INT,
    @PhoneNumber NVARCHAR(15),
    @Email NVARCHAR(100),
    @Salary DECIMAL(10, 2),
    @BranchID INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Employees (FirstName, LastName, Position, RoleID, PhoneNumber, Email, Salary, BranchID)
        VALUES (@FirstName, @LastName, @Position, @RoleID, @PhoneNumber, @Email, @Salary, @BranchID);
        PRINT 'Employee inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting employee.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertVehicleType
    @TypeName NVARCHAR(50),
    @Description NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO VehicleType (TypeName, Description)
        VALUES (@TypeName, @Description);
        PRINT 'VehicleType inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting vehicle type.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertInsurance
    @VehicleID INT,
    @InsuranceProvider NVARCHAR(100),
    @PolicyNumber NVARCHAR(50),
    @StartDate DATETIME2,
    @EndDate DATETIME2,
    @PremiumAmount DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Insurance (VehicleID, InsuranceProvider, PolicyNumber, StartDate, EndDate, PremiumAmount)
        VALUES (@VehicleID, @InsuranceProvider, @PolicyNumber, @StartDate, @EndDate, @PremiumAmount);
        PRINT 'Insurance inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting insurance.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertService
    @VehicleID INT,
    @ServiceDate DATETIME2,
    @Description NVARCHAR(255),
    @Cost DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Services (VehicleID, ServiceDate, Description, Cost)
        VALUES (@VehicleID, @ServiceDate, @Description, @Cost);
        PRINT 'Service inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting service.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertVehicleInspection
    @VehicleID INT,
    @InspectionDate DATETIME2,
    @Inspector NVARCHAR(100),
    @Passed BIT,
    @Remarks NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO VehicleInspection (VehicleID, InspectionDate, Inspector, Passed, Remarks)
        VALUES (@VehicleID, @InspectionDate, @Inspector, @Passed, @Remarks);
        PRINT 'VehicleInspection inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting vehicle inspection.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertCustomerHistory
    @CustomerID INT,
    @ReservationID INT,
    @ActionDescription NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO CustomerHistory (CustomerID, ReservationID, ActionDescription)
        VALUES (@CustomerID, @ReservationID, @ActionDescription);
        PRINT 'CustomerHistory inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting customer history.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE InsertUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    DECLARE @Salt NVARCHAR(50);
    DECLARE @HashedPassword NVARCHAR(255);

    BEGIN TRY
        SET @Salt = CAST(NEWID() AS NVARCHAR(50));

        SET @HashedPassword = CAST(HASHBYTES('SHA2_256', @Password + @Salt) AS NVARCHAR(255));

        INSERT INTO Users (Username, Salt, Password)
        VALUES (@Username, @Salt, @HashedPassword);

        PRINT 'User inserted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while inserting user.';
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE ValidateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    DECLARE @Salt NVARCHAR(50);
    DECLARE @StoredHashedPassword NVARCHAR(255);
    DECLARE @ProvidedHashedPassword NVARCHAR(255);

    BEGIN TRY
        SELECT @Salt = Salt, @StoredHashedPassword = Password
        FROM Users
        WHERE Username = @Username;

        IF @Salt IS NULL
        BEGIN
            PRINT 'Invalid username.';
            RETURN;
        END

        SET @ProvidedHashedPassword = CAST(HASHBYTES('SHA2_256', @Password + @Salt) AS NVARCHAR(255));

        IF @StoredHashedPassword = @ProvidedHashedPassword
        BEGIN
            PRINT 'Login successful.';
        END
        ELSE
        BEGIN
            PRINT 'Invalid password.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred during login.';
        THROW;
    END CATCH
END;
GO

--------------------------------CREATING ROLES AND ASSIGNING PERMISSIONS----------------------------------------------

CREATE LOGIN AdminLogin WITH PASSWORD = 'Admin123!';
CREATE LOGIN EmployeeLogin WITH PASSWORD = 'Employee123!';
CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager123!';
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminUser')
    DROP USER AdminUser;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'EmployeeUser')
    DROP USER EmployeeUser;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ManagerUser')
    DROP USER ManagerUser;
GO

USE CarRentalDB;
CREATE USER AdminUser FOR LOGIN AdminLogin;
CREATE USER EmployeeUser FOR LOGIN EmployeeLogin;
CREATE USER ManagerUser FOR LOGIN ManagerLogin;
GO

CREATE ROLE AdministratorRole;
CREATE ROLE EmployeeRole;
CREATE ROLE ManagerRole;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON Branches TO AdministratorRole;
GRANT SELECT, INSERT, UPDATE ON Reservations TO EmployeeRole;
GRANT SELECT ON Vehicles TO EmployeeRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO ManagerRole;
GO

EXEC sp_addrolemember 'AdministratorRole', 'AdminUser';
EXEC sp_addrolemember 'EmployeeRole', 'EmployeeUser';
EXEC sp_addrolemember 'ManagerRole', 'ManagerUser';
GO


--------------------------------INSERTING DATA----------------------------------------------

EXEC InsertBranch @BranchName = 'Oddział Główny', @Address = 'Warszawa, ul. Marszałkowska 1', @PhoneNumber = '123456789', @Email = 'kontakt@oddzialglowny.pl';
EXEC InsertBranch @BranchName = 'Oddział Kraków', @Address = 'Kraków, ul. Floriańska 5', @PhoneNumber = '987654321', @Email = 'kontakt@oddzialkrakow.pl';
EXEC InsertBranch @BranchName = 'Oddział Wrocław', @Address = 'Wrocław, ul. Rynek 8', @PhoneNumber = '567890123', @Email = 'kontakt@oddzialwroclaw.pl';

EXEC InsertRole @RoleName = 'Administrator', @Description = 'Pełny dostęp do systemu';
EXEC InsertRole @RoleName = 'Pracownik', @Description = 'Obsługa klientów i rezerwacji';
EXEC InsertRole @RoleName = 'Manager', @Description = 'Zarządzanie oddziałami i raporty';

EXEC InsertEmployee @FirstName = 'Jan', @LastName = 'Kowalski', @Position = 'Manager', @RoleID = 3, @PhoneNumber = '501234567', @Email = 'jan.kowalski@example.com', @Salary = 5000.00, @BranchID = 1;
EXEC InsertEmployee @FirstName = 'Anna', @LastName = 'Nowak', @Position = 'Pracownik', @RoleID = 2, @PhoneNumber = '601987654', @Email = 'anna.nowak@example.com', @Salary = 3500.00, @BranchID = 2;
EXEC InsertEmployee @FirstName = 'Tomasz', @LastName = 'Wiśniewski', @Position = 'Administrator', @RoleID = 1, @PhoneNumber = '701654321', @Email = 'tomasz.wisniewski@example.com', @Salary = 6000.00, @BranchID = 1;

EXEC InsertVehicleType @TypeName = 'Sedan', @Description = 'Samochód osobowy';
EXEC InsertVehicleType @TypeName = 'SUV', @Description = 'Samochód terenowy';
EXEC InsertVehicleType @TypeName = 'Kombi', @Description = 'Samochód rodzinny';

EXEC InsertVehicle @RegistrationNumber = 'KR12345', @Make = 'Toyota', @Model = 'Corolla', @YearOfProduction = 2020, @VehicleTypeID = 1, @BranchID = 1;
EXEC InsertVehicle @RegistrationNumber = 'WA67890', @Make = 'Ford', @Model = 'Focus', @YearOfProduction = 2019, @VehicleTypeID = 2, @BranchID = 2;
EXEC InsertVehicle @RegistrationNumber = 'GD54321', @Make = 'Volkswagen', @Model = 'Passat', @YearOfProduction = 2018, @VehicleTypeID = 3, @BranchID = 3;

EXEC InsertInsurance @VehicleID = 1, @InsuranceProvider = 'PZU', @PolicyNumber = 'INS001', @StartDate = '2024-01-01', @EndDate = '2025-01-01', @PremiumAmount = 1200.00;
EXEC InsertInsurance @VehicleID = 2, @InsuranceProvider = 'Allianz', @PolicyNumber = 'INS002', @StartDate = '2024-02-01', @EndDate = '2025-02-01', @PremiumAmount = 1500.00;
EXEC InsertInsurance @VehicleID = 3, @InsuranceProvider = 'Warta', @PolicyNumber = 'INS003', @StartDate = '2024-03-01', @EndDate = '2025-03-01', @PremiumAmount = 1300.00;

EXEC InsertService @VehicleID = 1, @ServiceDate = '2024-05-01', @Description = 'Wymiana oleju', @Cost = 300.00;
EXEC InsertService @VehicleID = 2, @ServiceDate = '2024-06-01', @Description = 'Przegląd techniczny', @Cost = 500.00;
EXEC InsertService @VehicleID = 3, @ServiceDate = '2024-07-01', @Description = 'Wymiana klocków hamulcowych', @Cost = 400.00;

EXEC InsertVehicleInspection @VehicleID = 1, @InspectionDate = '2024-04-01', @Inspector = 'Jan Kowalski', @Passed = 1, @Remarks = 'Brak uwag';
EXEC InsertVehicleInspection @VehicleID = 2, @InspectionDate = '2024-04-15', @Inspector = 'Anna Nowak', @Passed = 1, @Remarks = 'Brak uwag';
EXEC InsertVehicleInspection @VehicleID = 3, @InspectionDate = '2024-04-20', @Inspector = 'Tomasz Wiśniewski', @Passed = 0, @Remarks = 'Problemy z hamulcami';

EXEC InsertCustomer @FirstName = 'Jan', @LastName = 'Kowalski', @PhoneNumber = '501234567', @Email = 'jan.kowalski@example.com', @Address = 'Warszawa, ul. Marszałkowska 10';
EXEC InsertCustomer @FirstName = 'Anna', @LastName = 'Nowak', @PhoneNumber = '601987654', @Email = 'anna.nowak@example.com', @Address = 'Kraków, ul. Floriańska 5';
EXEC InsertCustomer @FirstName = 'Tomasz', @LastName = 'Wiśniewski', @PhoneNumber = '701654321', @Email = 'tomasz.wisniewski@example.com', @Address = 'Wrocław, ul. Rynek 8';

EXEC InsertReservation @CustomerID = 1, @VehicleID = 1, @StartDate = '2024-01-15', @EndDate = '2024-01-20', @TotalAmount = 500, @ReservationStatus = 'Confirmed';
EXEC InsertReservation @CustomerID = 2, @VehicleID = 2, @StartDate = '2024-02-10', @EndDate = '2024-02-15', @TotalAmount = 700, @ReservationStatus = 'Pending';
EXEC InsertReservation @CustomerID = 3, @VehicleID = 3, @StartDate = '2024-03-01', @EndDate = '2024-03-05', @TotalAmount = 600, @ReservationStatus = 'Cancelled';

EXEC InsertPayment @ReservationID = 1, @Amount = 500, @PaymentMethod = 'Karta kredytowa';
EXEC InsertPayment @ReservationID = 2, @Amount = 700, @PaymentMethod = 'Gotówka';
EXEC InsertPayment @ReservationID = 3, @Amount = 600, @PaymentMethod = 'Przelew bankowy';

EXEC InsertCustomerHistory @CustomerID = 1, @ReservationID = 1, @ActionDescription = 'Nowa rezerwacja';
EXEC InsertCustomerHistory @CustomerID = 2, @ReservationID = 2, @ActionDescription = 'Nowa rezerwacja';
EXEC InsertCustomerHistory @CustomerID = 3, @ReservationID = 3, @ActionDescription = 'Anulowanie rezerwacji';

EXEC InsertUser @Username = 'admin', @Password = 'Admin123!';
EXEC InsertUser @Username = 'pracownik', @Password = 'Employee123!';
EXEC InsertUser @Username = 'manager', @Password = 'Manager123!';

--------------------------------EXAMPLE USE CASES----------------------------------------------



			-- LIST OF ALL AVAILABLE VEHICLES IN A GIVEN BRANCH --


SELECT 
    V.VehicleID, 
    V.RegistrationNumber, 
    V.Make, 
    V.Model, 
    VT.TypeName AS VehicleType, 
    B.BranchName
FROM Vehicles V
JOIN VehicleType VT ON V.VehicleTypeID = VT.VehicleTypeID
JOIN Branches B ON V.BranchID = B.BranchID
WHERE V.IsAvailable = 1 AND B.BranchName = 'Oddział Główny';


						-- CUSTOMER BOOKING HISTORY --


SELECT 
    C.FirstName, 
    C.LastName, 
    R.ReservationID, 
    R.StartDate, 
    R.EndDate, 
    R.TotalAmount, 
    R.ReservationStatus
FROM Reservations R
JOIN Customers C ON R.CustomerID = C.CustomerID
WHERE C.FirstName = 'Jan' AND C.LastName = 'Kowalski';


					-- REPORT: NUMBER OF BOOKINGS PER BRANCH --


SELECT 
    B.BranchName, 
    COUNT(R.ReservationID) AS TotalReservations
FROM Reservations R
JOIN Vehicles V ON R.VehicleID = V.VehicleID
JOIN Branches B ON V.BranchID = B.BranchID
GROUP BY B.BranchName
ORDER BY TotalReservations DESC;


				--  VEHICLES SERVICED DURING THE SPECIFIED PERIOD --


SELECT 
    V.RegistrationNumber, 
    S.ServiceDate, 
    S.Description, 
    S.Cost
FROM Services S
JOIN Vehicles V ON S.VehicleID = V.VehicleID
WHERE S.ServiceDate BETWEEN '2024-01-01' AND '2024-12-31';


					-- LIST OF CARS ASSIGNED TO A SPECIFIC TYPE OF VEHICLE --


SELECT 
    VT.TypeName, 
    V.RegistrationNumber, 
    V.Make, 
    V.Model
FROM Vehicles V
JOIN VehicleType VT ON V.VehicleTypeID = VT.VehicleTypeID
WHERE VT.TypeName = 'SUV';


								-- RESERVATIONS WITH CANCELED STATUS --


SELECT 
    R.ReservationID, 
    C.FirstName, 
    C.LastName, 
    R.StartDate, 
    R.EndDate, 
    R.TotalAmount
FROM Reservations R
JOIN Customers C ON R.CustomerID = C.CustomerID
WHERE R.ReservationStatus = 'Cancelled';


								--  USERS IN THE SYSTEM AND ASSIGNED ROLES --


SELECT 
    U.Username, 
    R.RoleName,
	U.Password
FROM Users U
JOIN Roles R ON U.UserID = R.RoleID;


									-- LISTA REZERWACJI Z PŁATNOŚCIAMI --


SELECT 
    R.ReservationID, 
    C.FirstName, 
    C.LastName, 
    P.Amount, 
    P.PaymentMethod, 
    R.TotalAmount
FROM Payments P
JOIN Reservations R ON P.ReservationID = R.ReservationID
JOIN Customers C ON R.CustomerID = C.CustomerID;

