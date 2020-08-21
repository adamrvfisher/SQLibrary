
--Clean up
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

--Database
SELECT db_name()
GO

--Create and populate tables
--Servers
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Servers'
)
	CREATE TABLE Servers
		(
			ServerID int, 
			DNS nvarchar(100)
		)

IF OBJECT_ID('dbo.ServersTableInsert', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ServersTableInsert
GO

IF OBJECT_ID('dbo.ServersTableCheck', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ServersTableCheck
GO

CREATE PROCEDURE dbo.ServersTableCheck
	AS
	BEGIN TRY
		SELECT
			CASE WHEN EXISTS(SELECT 1 FROM BusinessDatabase.dbo.Servers)
				 THEN (SELECT 'Servers Table already populated.')
				 ELSE (SELECT 'Servers Table not populated.')
			END
	END TRY
	BEGIN CATCH
		SELECT 'Error in table check.' --This code never runs; error occurs and sent to error handler
	END CATCH;
GO

IF OBJECT_ID('dbo.ServersTableCheckErrorHandler', 'P') IS NOT NULL
	DROP PROCEDURE dbo.ServersTableCheckErrorHandler
GO

CREATE PROCEDURE dbo.ServersTableCheckErrorHandler
	AS 
	BEGIN TRY
		EXEC dbo.ServersTableCheck
		SELECT 'No Error in handler.'
	END TRY
	BEGIN CATCH
		SELECT 'Error in handler.' 
		INSERT INTO BusinessDatabase.dbo.Servers(ServerID, DNS)
		VALUES (1, '192.404.1.1'),
			   (2, '192.405.1.1')
	END CATCH
GO

EXEC dbo.ServersTableCheckErrorHandler 

SELECT * FROM BusinessDatabase.dbo.Servers

/*
--Errors
IF NOT EXISTS
(
	SELECT * 
	FROM sys.tables	
	WHERE name = N'Errors'
)
	CREATE TABLE Errors
		(
			ErrorID int,
			ServerID int,
			Occurrences int,
			LogMessage nvarchar(max)
		)

INSERT INTO BusinessDatabase.dbo.Errors(ErrorID, ServerID, Occurrences, LogMessage)
VALUES (1,1,5,'Error1'),
		(2,1,10,'Error2'),
		(3,2,15,'Error3'),
		(4,2,20,'Error4'),
		(5,1,25,'Error5'),
		(6,1,30,'Error6'),
		(7,2,35,'Error7'),
		(8,2,45,'Error8')
GO

--Tables
SELECT * FROM sys.tables

--Queries
SELECT *  FROM BusinessDatabase.dbo.Servers
SELECT * FROM BusinessDatabase.dbo.Errors


--Procedures
SELECT * FROM sys.procedures

*/