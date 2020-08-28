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
				VALUES (@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
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
				INSERT INTO Products(ProductName, UnitPrice, UnitsInStock, UnitsOnOrder)
				VALUES (@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
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
			VALUES (@ProductName, @UnitPrice, @UnitsInStock, @UnitsOnOrder)
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