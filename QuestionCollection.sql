--Question Collection
--Written in SQL Server Management Studio
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

/*
--Create correct AreaCode user defined function; for use in indexed view
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
*/

/*
--Question #10; B.
--Update tasks with NULL StartTime; return count of updated tasks not associated with a project
DECLARE @startedTasks TABLE(TaskID int, ProjectID int)
UPDATE BusinessDatabase.dbo.Tasks SET StartTime = GETDATE()
OUTPUT deleted.TaskID, deleted.ProjectID INTO @startedTasks
WHERE StartTime is NULL
SELECT COUNT(*) AS NumberOfProjectsWithNoStartTimeAndNoProjectID 
FROM @startedTasks
WHERE ProjectID IS NULL
*/

/*
--Question #11; COALESCE; T.UserID, P.UserID, -1; LEFT JOIN
--Return each task's owner. If no task owner, return project's owner, If no project owner and no task owner, return -1
SELECT T.TaskID, T.TaskName, COALESCE(T.UserID, P.UserID, -1) AS OwnerUserID
FROM Tasks T
LEFT JOIN Projects P 
ON T.ProjectID = P.ProjectID
*/

/*
--Question #12; CTE for task hierarchy
--CTE to etermine the task level for each task in the hierarchy
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
*/

/*
--Question #13
--Update NULL Tasks EndTime values with Projects EndTimes values
UPDATE T SET T.EndTime = P.EndTime
FROM Tasks AS T
INNER JOIN Projects P ON T.ProjectID = T.ProjectID
WHERE P.EndTime IS NOT NULL AND T.EndTime IS NULL
*/

/*
--Question #15; All transactions are rolled back; All transactions are rolled back; 
--Nested ROLLBACK rolls back all inner transactions to the outer most transaction.
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

*/

/*
--Question 18
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

--Execute ModifyCompanyName stored procedure with error to test THROW
EXECUTE dbo.ModifyCompanyName @custID = 3, @NewName = 'Theend'
GO
*/

/*
--Question 19; Update IsDeleted in UserLogin table if EmployeeID = 1 in UserLogin
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
*/

/*
--Question 20
SELECT AVG(NormalizedReading), NearestMountain(SensorID)
FROM GroundSensors 
WHERE NormalizedReading IS NOT NULL AND 
	  Tremor <> 0 
GROUP BY NearestMountain(SensorID)
*/

/*
--Question 23; Create a list of all CustomerID and the date of the last order customer places.
--If never ordered, return date '1900-01-01'
SELECT c.CustomerID AS CustomerID, COALESCE(MAX(o.OrderDate), '1900-01-01')
FROM BusinessDatabase.dbo.Customers c LEFT OUTER JOIN BusinessDatabase.dbo.Orders o 
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
*/

/*
--Question 25;
--Delete Orders placed before 2012-01-01 AND that have been shipped
DELETE FROM BusinessDatabase.dbo.Orders
WHERE OrderDate < '20120101' AND 
	  ShippedDate IS NOT NULL
*/

/*
--Question 26; Lowest performing sales persons
--Column named FullName that includes first name + space + last name and SalesYTD column 
--Display 3 sales people with LOWEST SalesYTD
--Exlude sales person with no value for TerritoryID
SELECT TOP(3) P.FirstName + ' ' + P.LastName AS FullName, SalesYTD
FROM Person AS P INNER JOIN SalesPerson AS S
ON P.PersonID = S.SalesPersonID
WHERE TerritoyID IS NOT NULL
ORDER BY SalesYTD
*/

/*
Question 27; List all complaints, and name of person handling complaint
SELECT Complaints.ComplaintID, Persons.Name
FROM Complaints
LEFT JOIN Contacts ON Complaints.ComplaintID = Contacts.ComplaintID
LEFT JOIN Persons ON Contacts.PersonID = Persons.PersonID
*/

/*
--Question 28
--Create list of all customers, order ID of last order placed, date of last order placed
--If no orders by customer, sub 0 for order ID and '19000101' for order date
SELECT C.CustomerID, ISNULL(MAX(O.OrderID), 0) AS OrderID, ISNULL(MAX(OrderDate), '') AS LastOrderDate
FROM BusinessDatabase.dbo.Customers AS C 
LEFT JOIN BusinessDatabase.dbo.Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY C.CustomerID
*/

/*
Question 29
--Update Customers table where CustomerID = 3, change CreditLimit to 1000
--Record change to CustomersAudit table
UPDATE BusinessDatabase.dbo.Customers
SET CreditLimit = 1000
OUTPUT inserted.CustomerID, deleted.CreditLimit, inserted.CreditLimit
INTO BusinessDatabase.dbo.CustomersAudit(CustomerID, OldCreditLimit, NewCreditLimit)
WHERE CustomerID = 3
*/

/*
--Question 30; Return data for chart; List the first date an account was opened in each CityID, order by min(acctopened) DESC
--For each PostalCityID return first CreatedDate and CityID/PostalCity ID from Customers
SELECT CityID, MIN(CreatedDate) AS FirstAccountDate,
	DENSE_RANK() OVER (ORDER BY MIN(CreatedDate) DESC) AS Ranking
FROM BusinessDatabase.dbo.Cities
INNER JOIN BusinessDatabase.dbo.Customers ON CityID = PostalCityID
GROUP BY CityID
ORDER BY MIN(CreatedDate) DESC
*/

/*
--Question 31; Return CustomerID and population for city based on IsOnCreditHold. 0 return DeliveryCityID population, 1 return PostalCityID population
SELECT CustomerID, LatestRecordedPopulation 
FROM BusinessDatabase.dbo.Customers
CROSS JOIN BusinessDatabase.dbo.Cities 
WHERE (IsOnCreditHold = 0 AND DeliveryCityID = CityID) OR 
	  (IsOnCreditHold = 1 AND PostalCityID = CityID)

--Same query as above
SELECT CustomerID, LatestRecordedPopulation 
FROM BusinessDatabase.dbo.Customers
INNER JOIN BusinessDatabase.dbo.Cities 
ON CityID = IIF(IsOnCreditHold = 0, DeliveryCityID, PostalCityID)
*/

/*
--Question 34; Return average credit limit per standard discount percentage from customers
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
*/

/*
--Question 35; Return customers that live in cities with populations over 10k and that are not on credit hold
SELECT CustomerID 
FROM BusinessDatabase.dbo.Customers
WHERE PostalCityID IN(
	SELECT CityID FROM BusinessDatabase.dbo.Cities
	WHERE LatestRecordedPopulation > 10000
	) AND IsOnCreditHold = 0
*/

/*
--Question 41; Return all Error Log messages and server where error occurs most often
SELECT DISTINCT ServerID, LogMessage FROM Errors as e1
WHERE Occurrences > ALL(
	SELECT e2.Occurrences FROM Errors AS e2
	WHERE e2.LogMessage = e1.LogMessage AND e2.ServerID <> e1.ServerID
	)
*/

/*
--Question 42; Return three most common errors per server
SELECT svr.ServerID, errs.LogMessage
FROM BusinessDatabase.dbo.Servers AS svr
CROSS APPLY
(
	SELECT TOP(3) LogMessage
	FROM Errors
	WHERE ServerID = svr.ServerID
	ORDER BY Occurrences DESC
) AS errs
*/

/*
--Question 43; Count active users in each role, if no active users display 0
SELECT R.RoleName, COUNT(U.UserID) AS ActiveUserCount
FROM BusinessDatabase.dbo.SecondaryRoles AS R
LEFT JOIN (SELECT UserID, RoleID 
		   FROM BusinessDatabase.dbo.SecondaryUsers 
		   WHERE IsActive = 1) U ON U.RoleID = R.RoleID
GROUP BY R.RoleID, R.RoleName
*/

/*
--Question 44; Make a survery report that has columns: CityID, QuestionID, and RawCount from survery table.
SELECT CityID, QuestionID, RawCount
FROM BusinessDatabase.dbo.RawSurvey AS t1
UNPIVOT(RawCount FOR CityName IN(Tokyo, Boston, London, NewYork)) AS t2
JOIN BusinessDatabase.dbo.Cities C
ON C.CityName = t2.CityName
*/

/*
Question 46; Return customers from CustomerCRMSystem table that do not appear in CustomerHRsystem table
SELECT CustomerCode, CustomerName
FROM BusinessDatabase.dbo.CustomerCRMSystem
EXCEPT
SELECT CustomerCode, CustomerName
FROM BusinessDatabase.dbo.CustomerHRSystem
*/

/*
Question 47; Return customers who appear in both tables and have a proper CustomerCode
SELECT C.CustomerCode, C.CustomerName, H.CustomerCode, H.CustomerName
FROM BusinessDatabase.dbo.CustomerCRMSystem C
INNER JOIN BusinessDatabase.dbo.CustomerHRSystem H
ON C.CustomerCode = H.CustomerCode AND C.CustomerName = H.CustomerName
*/

/*
Question 48; --Cartesean product
SELECT C.CustomerCode, C.CustomerName, H.CustomerCode, H.CustomerName
FROM BusinessDatabase.dbo.CustomerCRMSystem C
CROSS JOIN BusinessDatabase.dbo.CustomerHRSystem H
*/

/*
Question 49; --Return unique customers that appear in either table
SELECT CustomerCode, CustomerName
FROM BusinessDatabase.dbo.CustomerCRMSystem
UNION
SELECT CustomerCode, CustomerName
FROM BusinessDatabase.dbo.CustomerHRSystem
*/

/*
Question 50; Create function to retrieve customer information
--Create GetCustomerInformation user defined function
CREATE FUNCTION dbo.GetCustomerInformation(
	@CustomerID int
	)
RETURNS TABLE
AS
RETURN(
	SELECT C.FirstName, C.PhoneNumber, C.CreatedDate, C.StandardDiscountPercentage, 
	C.CreditLimit, C.IsOnCreditHold, COUNT(O.OrderID) AS TotalNumberOfOrders
	FROM BusinessDatabase.dbo.Customers C
	INNER JOIN BusinessDatabase.dbo.Orders O
	ON C.CustomerID = O.CustomerID
	WHERE C.CustomerID = @CustomerID
	GROUP BY C.FirstName, C.PhoneNumber, C.CreatedDate, C.StandardDiscountPercentage, C.CreditLimit, C.IsOnCreditHold
)
GO

--Execute AreaCode function
SELECT * FROM dbo.[GetCustomerInformation](1) AS GetCustomerInformation
*/

/*
--Question 77; Total sales by manager
WITH CTE AS
(
SELECT E.MgrID, E.EmployeeID, E.EmployeeCode, E.Title, SS.SalesAmount
FROM BusinessDatabase.dbo.Employees E
INNER JOIN BusinessDatabase.dbo.SalesSummary SS
ON E.EmployeeCode = SS.EmployeeCode
WHERE Title = 'Sales Representative'
--WHERE MgrId IS NULL

UNION ALL

SELECT E.MgrID, E.EmployeeID, E.EmployeeCode, E.Title, CTE.SalesAmount
FROM BusinessDatabase.dbo.Employees E
INNER JOIN CTE
ON E.MgrID = E.EmployeeID
)
SELECT MgrID, EmployeeID, EmployeeCode, Title, SUM(SalesAmount)
FROM CTE
GROUP BY MgrID, EmployeeID, EmployeeCode, Title
*/

/*
--Question 79; Return count of active users per role 
SELECT R.RoleName, COUNT(UserID) AS ActiveUserCount
FROM BusinessDatabase.dbo.SecondaryRoles R
LEFT JOIN (SELECT UserID, RoleID FROM BusinessDatabase.dbo.SecondaryUsers WHERE IsActive = 1) U
ON U.RoleId = R.RoleId
GROUP BY R.RoleId, R.RoleName
*/

/*
--Question 80; Return number of customers with deposit or loan accounts but not both 
SELECT COUNT(DISTINCT COALESCE(D. CustomerNumber, L.CustomerNumber))
FROM BusinessDatabase.dbo.DepositAccounts D
FULL JOIN BusinessDatabase.dbo.LoanAccounts L
ON D.CustomerNumber = L.CustomerNumber
WHERE D.CustomerNumber IS NULL OR L.CustomerNumber IS NULL
*/

/*
--Question 82 modified; Return Customers with both accounts
SELECT DISTINCT D.CustomerNumber
FROM BusinessDatabase.dbo.DepositAccounts D, BusinessDatabase.dbo.LoanAccounts L
WHERE D.CustomerNumber = L.CustomerNumber
*/

/**/
/**/
/**/
/**/
/**/
/**/