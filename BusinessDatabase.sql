
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
SELECT db_name()
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
				SELECT 'Servers table is populated.'
			END
		ELSE
			BEGIN
				SELECT 'Servers table is not populated - Inserting values.'
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
EXEC dbo.ServersTableInsert
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
				SELECT 'Errors table is populated.'
			END
		ELSE
			BEGIN
				SELECT 'Errors table is not populated - Inserting values.'
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
EXEC dbo.ErrorsTableInsert
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
				SELECT 'Products table is populated.'
			END
		ELSE
			BEGIN
				SELECT 'Products table is not populated - Inserting values.'
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
EXEC dbo.ProductsTableInsert
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
EXEC dbo.InsertProduct 
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
				SELECT 'Customers table is populated.'
			END
		ELSE
			BEGIN
				SELECT 'Customers table is not populated - Inserting values.'
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
EXEC dbo.CustomersTableInsert
GO

--Create Projects table
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Projects'
)
	CREATE TABLE Projects --Need to edit
		(
			ProjectID int NOT NULL PRIMARY KEY,
			ProjectName varchar(100)
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
				SELECT 'Projects table is populated.'
			END
		ELSE
			BEGIN
				SELECT 'Projects table is not populated - Inserting values.'
					INSERT INTO Projects(ProjectID, ProjectName)
					VALUES('1', 'ProjectX'),
						  ('2', 'OperationFullSend')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in Projects table insert.' 
	END CATCH
GO

--Run ProjectsErrorsTableInsert stored procedure
EXEC dbo.ProjectsTableInsert
GO

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
SELECT *  FROM BusinessDatabase.dbo.Servers
SELECT * FROM BusinessDatabase.dbo.Errors
SELECT * FROM BusinessDatabase.dbo.Products
SELECT * FROM BusinessDatabase.dbo.Customers