--Business Database
--Written in SQL Server Management Studio

--Delete Database
USE master;
DROP DATABASE BusinessDatabase

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
	CREATE TABLE Servers
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
	CREATE TABLE Errors
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
	CREATE TABLE Products
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
					  ('Pineapple', 1.99, 5, 14)
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
CREATE PROCEDURE InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		INSERT INTO Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
		VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
	END
GO

--Alter procedure InsertProduct
ALTER PROCEDURE InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		BEGIN TRY
			INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
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
	CREATE TABLE Customers
		(
			CustomerID int IDENTITY(1, 1) PRIMARY KEY,
			FirstName varchar(50) NULL,
			LastName varchar(50) NOT NULL,
			DateOfBirth date NOT NULL,
			CreditLimit money CHECK (CreditLimit < 10000),
			TownID int NULL, --REFERENCES dbo.Town(TownID),
			CreatedDate datetime DEFAULT(GETDATE())
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
					INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, TownID, CreatedDate)
					VALUES('Yvonne', 'McKay', '1984-05-25', 9000, NULL, GETDATE()),
						  ('Jossef', 'GoldBerg', '1995-07-04', 5500, NULL, GETDATE())
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Customers table insert.' 
	END CATCH
GO

--Run CustomersErrorsTableInsert stored procedure
EXECUTE dbo.CustomersTableInsert
GO

--Create Projects table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Projects'
)
	CREATE TABLE Projects
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
					INSERT INTO Projects(ProjectID, ProjectName, StartTime, EndTime, UserID)
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
	CREATE TABLE Tasks
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

--Create ProjectsTableInsert stored procedure
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
					INSERT INTO Tasks(TaskID, TaskName, ParentTaskID, ProjectID, StartTime, EndTime, UserID)
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

--Update tasks with NULL StartTime; return count of updated tasks not associated with a project
DECLARE @startedTasks TABLE(TaskID int, ProjectID int)
UPDATE BusinessDatabase.dbo.Tasks SET StartTime = GETDATE()
OUTPUT deleted.TaskID, deleted.ProjectID INTO @startedTasks
WHERE StartTime is NULL
SELECT COUNT(*) AS NumberOfProjectsWithNoStartTimeAndNoProjectID 
FROM @startedTasks
WHERE ProjectID IS NULL

--Update NULL Tasks EndTime values with Projects EndTimes values
UPDATE T SET T.EndTime = P.EndTime
FROM Tasks AS T
INNER JOIN Projects P ON T.ProjectID = T.ProjectID
WHERE P.EndTime IS NOT NULL AND T.EndTime IS NULL
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
	DROP FUNCTION AreaCode
GO

--Create AreaCode user defined function; for use in indexed view
CREATE FUNCTION AreaCode(
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

--Execute AreaCode function
SELECT dbo.[AreaCode]('777-369-7777') AS AreaCode

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