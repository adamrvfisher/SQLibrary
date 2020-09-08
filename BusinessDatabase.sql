--Business Database
--Written in SQL Server Management Studio

--Delete Database
IF EXISTS
(
	SELECT name
	FROM sys.databases
	WHERE name = N'BusinessDatabase'
)
USE master;
DROP DATABASE BusinessDatabase
GO

--Create database
IF NOT EXISTS
(
	SELECT name
	FROM sys.databases
	WHERE name = N'BusinessDatabase'
)
CREATE DATABASE BusinessDatabase;
GO

USE BusinessDatabase;
GO

--Database name
SELECT db_name() AS DatabaseName
GO

--Create Servers table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Servers'
)
	CREATE TABLE BusinessDatabase.dbo.Servers
		(
			ServerID int NOT NULL PRIMARY KEY, 
			DNS nvarchar(100)
		)

--Clear ServersTableInsert stored procedure
IF OBJECT_ID('dbo.ServersTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ServersTableInsert
GO

--Create ServersTableInsert stored procedure
CREATE PROCEDURE dbo.ServersTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Servers)
			BEGIN
				SELECT 'Servers table is populated.' AS ServersTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Servers table is not populated - Inserting values.' AS ServersTableStatus
				INSERT INTO BusinessDatabase.dbo.Servers(ServerID, DNS)
				VALUES(1, '192.404.1.1'),
					  (2, '192.405.1.1')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Servers table insert.' 
	END CATCH
GO

--Run ServersTableInsert stored procedure
EXECUTE dbo.ServersTableInsert
GO

--Create Errors table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Errors'
)
	CREATE TABLE BusinessDatabase.dbo.Errors
		(
			ErrorID int NOT NULL PRIMARY KEY,
			ServerID int,
			Occurrences int,
			LogMessage nvarchar(max)
		)

--Clear ErrorsTableInsert stored procedure
IF OBJECT_ID('dbo.ErrorsTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ErrorsTableInsert
GO

--Create ErrorsTableInsert stored procedure
CREATE PROCEDURE dbo.ErrorsTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Errors)
			BEGIN
				SELECT 'Errors table is populated.' AS ErrorsTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Errors table is not populated - Inserting values.' AS ErrorsTableStatus
				INSERT INTO BusinessDatabase.dbo.Errors(ErrorID, ServerID, Occurrences, LogMessage)
				VALUES(1,1,5,'Error1'),
					  (2,1,10,'Error2'),
					  (3,2,15,'Error3'),
					  (4,2,20,'Error4'),
					  (5,1,25,'Error5'),
					  (6,1,30,'Error6'),
					  (7,2,35,'Error7'),
					  (8,2,45,'Error8')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Errors table insert.' 
	END CATCH
GO

--Run ErrorsTableInsert stored procedure
EXECUTE dbo.ErrorsTableInsert
GO

--Create Products table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Products'
)
	CREATE TABLE BusinessDatabase.dbo.Products
		(
			ProductID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			ProductName nvarchar(100) NULL,
			UnitPrice decimal(18, 2) NOT NULL,
			UnitsInStock int NOT NULL,
			UnitsOnOrder int NULL CHECK (UnitsOnOrder < 100)
		)

--Clear ProductsTableInsert stored procedure
IF OBJECT_ID('dbo.ProductsTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ProductsTableInsert
GO

--Create ErrorsTableInsert stored procedure
CREATE PROCEDURE dbo.ProductsTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Products)
			BEGIN
				SELECT 'Products table is populated.' AS ProductsTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Products table is not populated - Inserting values.' AS ProductsTableStatus
				INSERT INTO BusinessDatabase.dbo.Products(
					ProductName, UnitPrice, UnitsInStock, UnitsOnOrder
					)
				VALUES('Mango', .99, 11, 22),
					  ('Pineapple', 1.99, 5, 14),
					  ('Nectarine', 1.59, 0, 0),
					  ('PricelessTreasure', 9.95, 1, NULL)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Products table insert.' 
	END CATCH
GO

--Run ProductsTableInsert stored procedure
EXECUTE dbo.ProductsTableInsert
GO

--Clear InsertProduct stored procedure
IF OBJECT_ID('dbo.InsertProduct', 'P') IS NOT NULL
	DROP PROCEDURE dbo.InsertProduct
GO

--Create InsertProduct stored procedure
CREATE PROCEDURE dbo.InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		INSERT INTO BusinessDatabase.dbo.Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
		VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
	END
GO

--Alter procedure InsertProduct
ALTER PROCEDURE dbo.InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		BEGIN TRY
			INSERT INTO BusinessDatabase.dbo.Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
			VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
		END TRY
		BEGIN CATCH
			THROW 51000, 'The product could not be created', 1
		END CATCH
	END
GO

/*
--Execute InsertProduct stored procedure
EXECUTE dbo.InsertProduct 
		@ProductName = 'Nectarine', 
		@UnitPrice = 2.99, 
		@UnitsInStock = 2, 
		@UnitsOnOrder = 7
GO
*/

--Create Customers table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Customers'
)
	CREATE TABLE BusinessDatabase.dbo.Customers
		(
			CustomerID int IDENTITY(1, 1) PRIMARY KEY,
			FirstName varchar(50) NULL,
			LastName varchar(50) NOT NULL,
			DateOfBirth date NOT NULL,
			CreditLimit money CHECK(CreditLimit < 10000),
			CompanyName nvarchar(50),
			TownID int NULL, --REFERENCES dbo.Town(TownID),
			CreatedDate datetime DEFAULT(GETDATE()),
			PostalCityID int,
			DeliveryCityID int,
			IsOnCreditHold bit,
			StandardDiscountPercentage int NOT NULL CHECK(StandardDiscountPercentage <= 4)
		)

--Clear CustomersTableInsert stored procedure
IF OBJECT_ID('dbo.CustomersTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.CustomersTableInsert
GO

--Create CustomersTableInsert stored procedure
CREATE PROCEDURE dbo.CustomersTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Customers)
			BEGIN
				SELECT 'Customers table is populated.' AS CustomersTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Customers table is not populated - Inserting values.' AS CustomersTableStatus
					INSERT INTO BusinessDatabase.dbo.Customers(FirstName, LastName, DateOfBirth, CreditLimit, CompanyName, 
						    TownID, CreatedDate, PostalCityID, DeliveryCityID, IsOnCreditHold, StandardDiscountPercentage)
					VALUES('Yvonne', 'McKay', '1984-05-25', 9000, NULL, NULL, '2009-05-20', 1, 3, 0, 4),
						  ('Jossef', 'Basmati', '1995-07-04', 5500, NULL, NULL, '2018-08-13', 2, 1, 0, 2),
						  ('Ana', 'Nguyen', '1991-08-17', 7500, NULL, NULL, '2019-07-19', 3, 2, 1 , 0)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Customers table insert.' 
	END CATCH
GO

--Run CustomersTableInsert stored procedure
EXECUTE dbo.CustomersTableInsert
GO

--Clear ModifyCompanyName stored procedure
IF OBJECT_ID('dbo.ModifyCompanyName', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ModifyCompanyName
GO


--Create ModifyCompanyName stored procedure
CREATE PROCEDURE dbo.ModifyCompanyName @custID int, @NewName nvarchar(40)
AS
	IF EXISTS(
		SELECT CustomerID FROM BusinessDatabase.dbo.Customers 
		WHERE CustomerID = @custID
		)
		UPDATE BusinessDatabase.dbo.Customers
		SET CompanyName = @NewName
		WHERE CustomerID = @custID
	IF NOT EXISTS(
		SELECT CustomerID FROM BusinessDatabase.dbo.Customers 
		WHERE CustomerID = @custID
		)
		THROW 55555, 'The customer ID does not exist', 1 
GO

--Execute ModifyCompanyName stored procedure with parameters
EXECUTE dbo.ModifyCompanyName @custID = 1, @NewName = 'Origin'
GO
EXECUTE dbo.ModifyCompanyName @custID = 2, @NewName = 'Meddel'
GO

/*
--Execute ModifyCompanyName stored procedure with error to test THROW
EXECUTE dbo.ModifyCompanyName @custID = 3, @NewName = 'Theend'
GO
*/

--Create CustomersAudit table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'CustomersAudit'
)
	CREATE TABLE BusinessDatabase.dbo.CustomersAudit
		(
			CustomerID int PRIMARY KEY,
			DateChanged datetime DEFAULT GETDATE(),
			OldCreditLimit money,
			NewCreditLimit money,
			ChangedBy varchar(100) DEFAULT SYSTEM_USER
		)

--Update Customers table where CustomerID = 3, change CreditLimit to 1000
--Record change to CustomersAudit table
UPDATE BusinessDatabase.dbo.Customers
SET CreditLimit = 1000
OUTPUT inserted.CustomerID, deleted.CreditLimit, inserted.CreditLimit
INTO BusinessDatabase.dbo.CustomersAudit(CustomerID, OldCreditLimit, NewCreditLimit)
WHERE CustomerID = 3

--Create Projects table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Projects'
)
	CREATE TABLE BusinessDatabase.dbo.Projects
		(
			ProjectID int NOT NULL PRIMARY KEY,
			ProjectName varchar(100),
			StartTime datetime2(7),
			EndTime datetime2(7), 
			UserID int
		)

--Clear ProjectsTableInsert stored procedure
IF OBJECT_ID('dbo.ProjectsTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ProjectsTableInsert
GO

--Create ProjectsTableInsert stored procedure
CREATE PROCEDURE dbo.ProjectsTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Projects)
			BEGIN
				SELECT 'Projects table is populated.' AS ProjectsTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Projects table is not populated - Inserting values.' AS ProjectsTableStatus
					INSERT INTO BusinessDatabase.dbo.Projects(ProjectID, ProjectName, StartTime, EndTime, UserID)
					VALUES('1', 'ProjectX', '2020-02-20', '2020-07-14' , 10001),
						  ('2', 'OperationFullSend', '2020-05-25', NULL, 10002)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Projects table insert.' 
	END CATCH
GO

--Run ProjectsErrorsTableInsert stored procedure
EXECUTE dbo.ProjectsTableInsert
GO

--Create Tasks table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Tasks'
)
	CREATE TABLE BusinessDatabase.dbo.Tasks
		(
			TaskID int NOT NULL PRIMARY KEY,
			TaskName varchar(100),
			ParentTaskID int, 
			ProjectID int,
			StartTime datetime2(7),
			EndTime datetime2(7), 
			UserID int
		)

--Clear TasksTableInsert stored procedure
IF OBJECT_ID('dbo.TasksTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.TasksTableInsert
GO

--Create TasksTableInsert stored procedure
CREATE PROCEDURE dbo.TasksTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Tasks)
			BEGIN
				SELECT 'Tasks table is populated.' AS TasksTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Tasks table is not populated - Inserting values.' AS TasksTableStatus
					INSERT INTO BusinessDatabase.dbo.Tasks(TaskID, TaskName, ParentTaskID, ProjectID, StartTime, EndTime, UserID)
					VALUES('1', 'SetMeeting', NULL, 1, '2020-03-12', NULL, 20001),
						  ('2', 'UpdateSchedule', 1, 1, '2020-03-20', '2020-03-25', 20001),
						  ('3', 'CancelMeeting', NULL, 2, '2020-05-29', '2020-05-30', 20002),
						  ('4', 'DropClient', 3, 2, '2020-06-20', NULL, 20002),
						  ('5', 'ReassignAccount', NULL, 2, NULL, NULL, 20002),
						  ('6', 'DeliverGoods', NULL, NULL, NULL, NULL, 20002),
						  ('7', 'SendInvoice', NULL, NULL, NULL, NULL, NULL)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Tasks table insert.' 
	END CATCH
GO

--Run TasksErrorsTableInsert stored procedure
EXECUTE dbo.TasksTableInsert
GO

--Update NULL Tasks EndTime values with Projects EndTimes values
UPDATE T SET T.EndTime = P.EndTime
FROM Tasks AS T
INNER JOIN Projects P ON T.ProjectID = T.ProjectID
WHERE P.EndTime IS NOT NULL AND T.EndTime IS NULL
GO

--Create Employee table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Employees'
)
	CREATE TABLE Employees
		(
			EmployeeID int NOT NULL PRIMARY KEY,
			FirstName varchar(50) NOT NULL,
			LastName varchar(50) NOT NULL,
			HireDate datetime2(7),
			HourlyPay money,
			IsDeleted int DEFAULT 0,
			Title varchar(50),
			City varchar(50),
			MgrID int
		)

--Clear EmployeesTableInsert stored procedure
IF OBJECT_ID('dbo.EmployeesTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.EmployeesTableInsert
GO

--Create EmployeesTableInsert stored procedure
CREATE PROCEDURE dbo.EmployeesTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Employees)
			BEGIN
				SELECT 'Employees table is populated.' AS EmployeesTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Employees table is not populated - Inserting values.' AS EmployeesTableStatus
					INSERT INTO Employees(EmployeeID, FirstName, LastName, HireDate, HourlyPay, Title, City, MgrID)
					VALUES('1', 'Blanche', 'Guzman', '2019-07-14', 106, 'Sales Manager' , 'Los Angeles', NULL),
						  ('2', 'Jarrod', 'Booth', '2020-01-25', 55, 'Sales Representative' , 'Seattle', 1),
						  ('3', 'Jared', 'Broth', '2020-05-15', 35, 'Sales Representative' , 'Portland', 1)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Employees table insert.' 
	END CATCH
GO

--Run EmployeesErrorsTableInsert stored procedure
EXECUTE dbo.EmployeesTableInsert
GO

--Update Employees table to change title to Customer Representative
--for all Employees in Seattle and has title Sales Representative 
--If there is no manager defined, do not update
UPDATE BusinessDatabase.dbo.Employees
SET Title = 'Customer Representative'
WHERE Title = 'Sales Representative' AND
	  City = 'Seattle' AND MgrID IS NOT NULL

--Create UserLogin table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'UserLogin'
)
	CREATE TABLE UserLogin
		(
			EmployeeID int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
			UserName varchar(100),
			PassCode varchar(100),
			IsDeleted int DEFAULT 0
		)

--Clear ProjectsTableInsert stored procedure
IF OBJECT_ID('dbo.UserLoginTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.UserLoginTableInsert
GO

--Create UserLoginInsert stored procedure
CREATE PROCEDURE dbo.UserLoginTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.UserLogin)
			BEGIN
				SELECT 'UserLogin table is populated.' AS UserLoginTableStatus
			END
		ELSE
			BEGIN
				SELECT 'UserLogin table is not populated - Inserting values.' AS UserLoginTableStatus
					INSERT INTO BusinessDatabase.dbo.UserLogin(UserName, PassCode)
					VALUES('BlancheGuzman', '$$$iWorkAllDay$$$'),
						  ('JarrodBooth', 'ReallyBadPassword'),
						  ('JaredBroth', 'WorsePassword')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in UserLogin table insert.' 
	END CATCH
GO

--Run UserLoginTableInsert stored procedure
EXECUTE dbo.UserLoginTableInsert
GO

--Update IsDeleted in UserLogin table if EmployeeID = 1 in UserLogin
--If there is an error with UserLogin update, update IsDeleted in Employees if EmployeeID = 1 in Employees
--If there is an error with Employee update, raise custom error
BEGIN TRY
	UPDATE BusinessDatabase.dbo.UserLogin
	SET IsDeleted = 1
	WHERE EmployeeID = 1
END TRY
BEGIN CATCH
	BEGIN TRY
		UPDATE BusinessDatabase.dbo.Employees
		SET IsDeleted = 1
		WHERE EmployeeID = 1
	END TRY
	BEGIN CATCH
		RAISERROR('No tables updated.', 16, 1)
	END CATCH
END CATCH
GO

--Create Orders table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Orders'
)
	CREATE TABLE Orders
		(
			OrderID int IDENTITY(1, 1) PRIMARY KEY,
			CustomerID int,
			OrderDate datetime2(7),
			ShippedDate date NULL,
			Item nvarchar(50)
		)
GO

--Clear OrdersTableInsert stored procedure
IF OBJECT_ID('dbo.OrdersTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.OrdersTableInsert
GO

--Create OrdersTableInsert stored procedure
CREATE PROCEDURE dbo.OrdersTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Orders)
			BEGIN
				SELECT 'Orders table is populated.' AS OrderTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Orders table is not populated - Inserting values.' AS OrdersTableStatus
					INSERT INTO BusinessDatabase.dbo.Orders(CustomerID, OrderDate, ShippedDate, Item)
					VALUES('1', '2010-03-22', NULL, 'UnshippableHat'),
						  ('1', '2010-04-11', '2010-04-15', 'OldHat'),
						  ('1', '2020-05-18', '2020-05-20', 'BlackHat'),
						  ('1', '2020-06-16', '2020-06-17', 'GreyHat'),
						  ('2', '2020-07-28', '2020-07-29', 'WhiteHat')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Orders table insert.' 
	END CATCH
GO

--Run OrdersTableInsert stored procedure
EXECUTE dbo.OrdersTableInsert
GO

--Delete Orders placed before 2012-01-01 AND that have been shipped
DELETE FROM BusinessDatabase.dbo.Orders
WHERE OrderDate < '20120101' AND 
	  ShippedDate IS NOT NULL

--Create Cities table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Cities'
)
	CREATE TABLE Cities
		(
			CityID int IDENTITY(1, 1) PRIMARY KEY,
			CityName nvarchar(50),
			LatestRecordedPopulation int
		)
GO

--Clear CitiesTableInsert stored procedure
IF OBJECT_ID('dbo.CitiesTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.CitiesTableInsert
GO

--Create CitiesTableInsert stored procedure
CREATE PROCEDURE dbo.CitiesTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Cities)
			BEGIN
				SELECT 'Cities table is populated.' AS CitiesTableStatus
			END
		ELSE
			BEGIN
				SELECT 'Cities table is not populated - Inserting values.' AS CitiesTableStatus
					INSERT INTO BusinessDatabase.dbo.Cities(CityName, LatestRecordedPopulation)
					VALUES('MegaMetropolis', 7500000),
						  ('VoluminousVillage', 350000),
						  ('TinyTown', 2500)
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Cities table insert.' 
	END CATCH
GO

--Run CitiesTableInsert stored procedure
EXECUTE dbo.CitiesTableInsert
GO

--Create CustomerCategories table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'CustomerCategories'
)
	CREATE TABLE CustomerCategories
		(
			CustomerCategoryID int IDENTITY(1, 1) PRIMARY KEY,
			CustomerCategoryName nvarchar(50) NOT NULL
		)
GO

--Clear CustomerCategoriesTableInsert stored procedure
IF OBJECT_ID('dbo.CustomerCategoriesTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.CustomerCategoriesTableInsert
GO

--Create CustomerCategoriesTableInsert stored procedure
CREATE PROCEDURE dbo.CustomerCategoriesTableInsert
	AS
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM BusinessDatabase.dbo.CustomerCategories)
			BEGIN
				SELECT 'CustomerCategories table is populated.' AS CustomerCategoriesTableStatus
			END
		ELSE
			BEGIN
				SELECT 'CustomerCategories table is not populated - Inserting values.' AS CustomerCategoriesTableStatus
					INSERT INTO BusinessDatabase.dbo.CustomerCategories(CustomerCategoryName)
					VALUES('DayOnes'),
						  ('Veterans'),
						  ('Prospects')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in CustomerCategories table insert.' 
	END CATCH
GO

--Run CustomerCategoriesTableInsert stored procedure
EXECUTE dbo.CustomerCategoriesTableInsert
GO

--Create Log1 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log1'
)
	CREATE TABLE Log1
		(
			Log1ID int IDENTITY(1, 1) PRIMARY KEY,
			Code varchar(100),
			ApplicationID int, 
			Info varchar(100)
		)

--Create Log2 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log2'
)
	CREATE TABLE Log2
		(
			Log2ID int IDENTITY(1, 1) PRIMARY KEY,
			Code varchar(100),
			ApplicationID int, 
			Info varchar(100)
		)

--Create Log3 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log3'
)
	CREATE TABLE Log3
		(
			Log3ID int IDENTITY(1, 1) PRIMARY KEY,
			Code varchar(100),
			ApplicationID int, 
			Info varchar(100)
		)

--Create Log4 table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Log4'
)
	CREATE TABLE Log4
		(
			Log4ID int IDENTITY(1, 1) PRIMARY KEY,
			Code varchar(100),
			ApplicationID int, 
			Info varchar(100)
		)
GO

--Clear UpdateLogs stored procedure
IF OBJECT_ID('dbo.UpdateLogs', 'P') IS NOT NULL
	DROP PROCEDURE dbo.UpdateLogs
GO

--Create procedure to update log tables
CREATE PROCEDURE dbo.UpdateLogs @Code char(5), @ApplicationID int, @Info varchar(1000)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO dbo.Log1 VALUES(@Code, @ApplicationID, @Info)
			IF @Code = 'C2323' AND @ApplicationID = 1
				RAISERROR('C2323 Code from HR application!', 16, 1)
			ELSE
				INSERT INTO dbo.Log2 VALUES(@Code, @ApplicationID, @Info)
				INSERT INTO dbo.Log3 VALUES(@Code, @ApplicationID, @Info)
				BEGIN TRANSACTION
					IF @Code = 'C2323'
						ROLLBACK TRANSACTION
					ELSE
						INSERT INTO dbo.Log4 VALUES(@Code, @ApplicationID, @Info)
						COMMIT TRANSACTION
						IF @@TRANCOUNT > 0 
							COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() != 0
			ROLLBACK TRANSACTION
	END CATCH
END
GO	

EXECUTE dbo.UpdateLogs 'C2323', 1, 'Employee records are updated.'
EXECUTE dbo.UpdateLogs 'C2323', 10, 'Sales process started.'
EXECUTE dbo.UpdateLogs 'A7777', 77, 'Nothing to report.'

--Clear AreaCode Function
IF OBJECT_ID('dbo.AreaCode') IS NOT NULL
	DROP FUNCTION dbo.AreaCode
GO

--Create AreaCode user defined function; for use in indexed view
CREATE FUNCTION dbo.AreaCode(
	@phoneNumber nvarchar(20)
	)
RETURNS nvarchar(10)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @areaCode nvarchar(max)
	SELECT TOP 1 @areaCode = VALUE FROM STRING_SPLIT(@phoneNumber, '-')
	RETURN @areaCode
END
GO

--Tables
SELECT * FROM sys.tables

--Procedures
SELECT * FROM sys.procedures

--Functions
SELECT * FROM sys.objects 
WHERE TYPE IN('FN','IF','TF', 'FS', 'FT')

--Schemas
SELECT * FROM sys.schemas

--Queries
SELECT * FROM BusinessDatabase.dbo.Servers
SELECT * FROM BusinessDatabase.dbo.Errors
SELECT * FROM BusinessDatabase.dbo.Products
SELECT * FROM BusinessDatabase.dbo.Customers
SELECT * FROM BusinessDatabase.dbo.Projects
SELECT * FROM BusinessDatabase.dbo.Tasks
SELECT * FROM BusinessDatabase.dbo.Employees
SELECT * FROM BusinessDatabase.dbo.UserLogin
SELECT * FROM BusinessDatabase.dbo.Orders
SELECT * FROM BusinessDatabase.dbo.CustomersAudit
SELECT * FROM BusinessDatabase.dbo.Cities
SELECT * FROM BusinessDatabase.dbo.CustomerCategories


--Check logs for updates
SELECT * FROM BusinessDatabase.dbo.Log1
SELECT * FROM BusinessDatabase.dbo.Log2
SELECT * FROM BusinessDatabase.dbo.Log3
SELECT * FROM BusinessDatabase.dbo.Log4

--Query to return each task's owner. If no task owner, return project's owner. If no project and no task owner, return -1
SELECT T.TaskID, T.TaskName, COALESCE(T.UserID, P.UserID, -1) AS OwnerUserID
FROM BusinessDatabase.dbo.Tasks T
LEFT JOIN Projects P
ON T.ProjectID = P.ProjectID
GO

--CTE to determine the task level for each task in the hierarchy
WITH TaskWithLevel(ParentTaskID, TaskID, TaskName, TaskLevel)
AS(
	SELECT CAST(NULL AS int) AS ParentTaskID, T.TaskID, T.TaskName, 0 AS TaskLevel
	FROM Tasks T
	WHERE T.ParentTaskID IS NULL

	UNION ALL

	SELECT R.TaskID AS ParentTaskID, T.TaskID, T.TaskName, R.TaskLevel + 1 AS TaskLevel
	FROM BusinessDatabase.dbo.Tasks T INNER JOIN TaskWithLevel R ON T.ParentTaskID = R.TaskID
  )
SELECT * FROM TaskWithLevel
GO

--Retrieve name and average price of product
--Exclude items with no stock
--Exclude items with a value of 0 for UnitsOnOrder
SELECT ProductName, AVG(UnitPrice)
FROM BusinessDatabase.dbo.Products
WHERE UnitsOnOrder IS NOT NULL AND
	  UnitsInStock <> 0 
GROUP BY ProductName
GO

--Execute AreaCode function
SELECT dbo.[AreaCode]('777-369-7777') AS AreaCode

--Create a list of all CustomerID and the date of the last order customer places.
--If never ordered, return date '1900-01-01'
SELECT C.CustomerID AS CustomerID, COALESCE(MAX(O.OrderDate), '1900-01-01') AS LastOrder
FROM BusinessDatabase.dbo.Customers C LEFT OUTER JOIN BusinessDatabase.dbo.Orders O 
ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID

--Create list of all customerID, order ID of last order placed, date of last order placed
--If no orders by customer, sub 0 for order ID and '19000101' for order date
SELECT C.CustomerID, ISNULL(MAX(O.OrderID), 0) AS OrderID, ISNULL(MAX(OrderDate), '') AS LastOrderDate
FROM BusinessDatabase.dbo.Customers AS C 
LEFT JOIN BusinessDatabase.dbo.Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY C.CustomerID 

--For each PostalCityID return first CreatedDate and CityID/PostalCity ID from Customers
SELECT CityID, MIN(CreatedDate) AS FirstAccountDate,
	DENSE_RANK() OVER (ORDER BY MIN(CreatedDate) DESC) AS Ranking
FROM BusinessDatabase.dbo.Cities
INNER JOIN BusinessDatabase.dbo.Customers ON CityID = PostalCityID
GROUP BY CityID
ORDER BY MIN(CreatedDate) DESC

--Return CustomerID and population for city based on IsOnCreditHold. 0 return DeliveryCityID population, 1 return PostalCityID population
SELECT CustomerID, LatestRecordedPopulation 
FROM BusinessDatabase.dbo.Customers
CROSS JOIN BusinessDatabase.dbo.Cities 
WHERE (IsOnCreditHold = 0 AND DeliveryCityID = CityID) OR 
	  (IsOnCreditHold = 1 AND PostalCityID = CityID)

/*
--Return CustomerID and population for city based on IsOnCreditHold. 0 return DeliveryCityID population, 1 return PostalCityID population
SELECT CustomerID, LatestRecordedPopulation 
FROM BusinessDatabase.dbo.Customers
INNER JOIN BusinessDatabase.dbo.Cities 
ON CityID = IIF(IsOnCreditHold = 0, DeliveryCityID, PostalCityID)
*/

--Return average credit limit per standard discount percentage from customers
--Column 1 is standard discount percentage 
--Column 2 average credit limit 
SELECT [0], [1], [2], [3], [4] FROM(
	SELECT StandardDiscountPercentage, CreditLimit
	FROM BusinessDatabase.dbo.Customers
	) AS SourceTable
PIVOT(
	AVG(CreditLimit) 
	FOR StandardDiscountPercentage IN([0], [1], [2], [3], [4]) 
	)AS CreditLimitTable

--Return customers that live in cities with populations over 10k and that are not on credit hold
SELECT CustomerID 
FROM BusinessDatabase.dbo.Customers
WHERE PostalCityID IN(
	SELECT CityID FROM BusinessDatabase.dbo.Cities
	WHERE LatestRecordedPopulation > 10000
	) AND IsOnCreditHold = 0