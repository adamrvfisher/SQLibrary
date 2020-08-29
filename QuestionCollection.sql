--Question selections

/*
--Question #1; Does not meet goal even with correct column names in insert statement and ; in catch block
--Alter procedure InsertProduct
ALTER PROCEDURE InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		SET XACT_ABORT ON
		BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
				VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
			THROW 51000, 'The product could not be created', 1
		END CATCH
	END
GO
*/

/*
--Question #2; Does not meet goal even with correct column names in insert statement - Throw statement does not return error number
--Alter procedure InsertProduct
ALTER PROCEDURE InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO Products (ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
				VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
				IF @@ERROR = 51000
					THROW
		END CATCH
	END
GO
*/

/*
--Question #3; Does meet goal with correct column names in insert statement 
--Throw statement returns 51000 error number and message when check/NULL/other constraint violated
--Alter procedure InsertProduct
ALTER PROCEDURE InsertProduct
	@ProductName nvarchar(100),
	@UnitPrice decimal(18, 2),
	@UnitsInStock int,
	@UnitsOnOrder int
AS 
	BEGIN 
		BEGIN TRY
			INSERT INTO Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
			VALUES(@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
		END TRY
		BEGIN CATCH
			THROW 51000, 'The product could not be created', 1
		END CATCH
	END
GO
*/

/*
--Execute InsertProduct stored producedure with @UnitsInStock param violating NULL constraint on column/table
EXEC dbo.InsertProduct 
		@ProductName = 'Nectarine', 
		@UnitPrice = 2.99, 
		@UnitsInStock = NULL, 
		@UnitsOnOrder = 7
GO
*/

/*
--Question #4; Does not meet the goal. There are two separate statements.
INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, CreatedDate)
VALUES('Yvonne', 'McKay', '1984-05-25', 9000, GETDATE())
INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, CreatedDate)
VALUES('Jossef', 'GoldBerg', '1995-07-04', 55000, GETDATE())
GO
*/
--Notes; Columns for insert must include columns with NOT NULL in CREATE TABLE.
--		 Cannot insert values for identity column,
/*
--Question #5; Does not meet the goal. There are two separate statements.
INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, TownID, CreatedDate)
VALUES('Yvonne', 'McKay', '1984-05-25', 9000, NULL, GETDATE())
INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, TownID, CreatedDate)
VALUES('Jossef', 'GoldBerg', '1995-07-04', 5500, NULL, GETDATE())
GO
*/

/*
--Question #6; Does meet the goal. There is one statement.
INSERT INTO Customers(FirstName, LastName, DateOfBirth, CreditLimit, TownID, CreatedDate)
VALUES('Yvonne', 'McKay', '1984-05-25', 9000, NULL, GETDATE()),
	  ('Jossef', 'GoldBerg', '1995-07-04', 5500, NULL, GETDATE())
GO
*/

/*
-- Question #7; Does not meet the goal. RETURN data type should be nvarchar(10) 
CREATE FUNCTION AreaCode(
	@phoneNumber nvarchar(20)
	)
RETURNS TABLE 
WITH SCHEMABINDING
AS 
RETURN (
	SELECT TOP 1 @phoneNumber AS PhoneNumber, VALUE AS AreaCode
	FROM STRING_SPLIT(@phoneNumber, '-')
	)
GO

--Execute AreaCode function; Use Select * FROM.. Since return type is a table
SELECT * FROM AreaCode('777-369-7777')
*/

/*
-- Question #8; Works, but does not meet solution for indexed view requirement, need to use WITH SCHEMABINDING
CREATE FUNCTION AreaCode(
	@phoneNumber nvarchar(20)
	)
RETURNS nvarchar(10)
AS
BEGIN
	DECLARE @areaCode nvarchar(max)
	SELECT TOP 1 @areaCode = VALUE FROM STRING_SPLIT(@phoneNumber, '-')
	RETURN @areaCode
END
GO

--Execute AreaCode function; Direct SELECT since is scalar function 
SELECT dbo.[AreaCode]('777-369-7777') AS AreaCode
*/

/*
--Question #9; Does not meet solution; need to use SELECT TOP 1
CREATE FUNCTION AreaCode(
	@phoneNumber nvarchar(20)
	)
RETURNS nvarchar(10)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @areaCode nvarchar(max)
	SELECT @areaCode = VALUE FROM STRING_SPLIT(@phoneNumber, '-')
	RETURN @areaCode
END
GO

--Execute AreaCode function
SELECT dbo.[AreaCode]('777-369-7777') AS AreaCode
*/