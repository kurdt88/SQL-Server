/*============================================================================
  File:     10a_Forcing.sql

  SQL Server Versions: 2016+, Azure SQL
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


/*
	Start with a clean copy of WWI
*/
USE [master];
GO
RESTORE DATABASE [WideWorldImporters] 
FROM  DISK = N'C:\Backups\WideWorldImportersEnlarged.bak' 
WITH  FILE = 1,  
MOVE N'WWI_Primary' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
MOVE N'WWI_UserData' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
MOVE N'WWI_Log' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
MOVE N'WWI_InMemory_Data_1' 
	TO N'C:\Databases\WideWorldImporters\WideWorldImporters_InMemory_Data_1',  
NOUNLOAD, 
REPLACE, 
STATS = 5;
GO


/*
	Enable Query Store with settings we want
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), 
	DATA_FLUSH_INTERVAL_SECONDS = 60,  
	INTERVAL_LENGTH_MINUTES = 10, 
	MAX_STORAGE_SIZE_MB = 100, 
	QUERY_CAPTURE_MODE = ALL, 
	SIZE_BASED_CLEANUP_MODE = AUTO, 
	MAX_PLANS_PER_QUERY = 200)
GO

/*
	Clear out any old data, just in case
*/
ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE CLEAR;
GO


/*
	Create a procedure for testing
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_GetFullProductInfo];
GO

CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]
	@StockItemID INT
AS	

	SELECT 
		[o].[CustomerID], 
		[o].[OrderDate], 
		[ol].[StockItemID], 
		[ol].[Quantity],
		[ol].[UnitPrice]
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	ORDER BY [o].[OrderDate] DESC;

	SELECT
		[o].[CustomerID], 
		SUM([ol].[Quantity]*[ol].[UnitPrice])
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	GROUP BY [o].[CustomerID]
	ORDER BY [o].[CustomerID] ASC;
GO

/*
	Enable actual plan and STATISTICS IO
	Execute the stored procecdure
*/
SET STATISTICS IO ON;
GO

EXEC [Sales].[usp_GetFullProductInfo] 90 WITH RECOMPILE;
GO

EXEC [Sales].[usp_GetFullProductInfo] 224 WITH RECOMPILE;
GO

SET STATISTICS IO OFF;
GO

/*
	Add some data...as may happen during a normal day
*/
INSERT INTO [Sales].[OrderLines]
	([OrderLineID], [OrderID], [StockItemID], 
	[Description], [PackageTypeID], [Quantity], 
	[UnitPrice], [TaxRate], [PickedQuantity], 
	[PickingCompletedWhen], [LastEditedBy], 
	[LastEditedWhen])
SELECT 
	[OrderLineID] + 800000, [OrderID], [StockItemID], 
	[Description], [PackageTypeID], [Quantity] + 2, 
	[UnitPrice], [TaxRate], [PickedQuantity], 
	NULL, [LastEditedBy], SYSDATETIME() 
FROM [WideWorldImporters].[Sales].[OrderLines]
WHERE [OrderID] > 54999;
GO


/*
	Re-run the stored procedures
*/	
SET STATISTICS IO ON;
GO

EXEC [Sales].[usp_GetFullProductInfo] 90 WITH RECOMPILE;
GO

EXEC [Sales].[usp_GetFullProductInfo] 224 WITH RECOMPILE;
GO

SET STATISTICS IO OFF;
GO


/*
	What do we see in Query Store UI
	for usp_GetFullProductInfo?
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[rs].[count_executions],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo');
GO



/*
	Force the plan in QS, or with SP
	sp_query_store_force_plan (query_id, plan_id)
*/
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 3;
GO

/*
	Re-run the stored procedures
	*Reminder: WITH RECOMPILE is not a good thing here
*/	
EXEC [Sales].[usp_GetFullProductInfo] 90 WITH RECOMPILE;
GO

EXEC [Sales].[usp_GetFullProductInfo] 224 WITH RECOMPILE;
GO



/*
	Run it with another value...and no RECOMPILE
	How do we know if a forced plan is being used?
*/
EXEC [Sales].[usp_GetFullProductInfo] 220;
GO


/*
	What's in cache?
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT 
	[qs].execution_count, 
	[s].[text], 
	[qs].[query_hash], 
	[qs].[query_plan_hash], 
	[cp].[size_in_bytes]/1024 AS [PlanSizeKB], 
	[qp].[query_plan], 
	[qs].[plan_handle]
FROM [sys].[dm_exec_query_stats] AS [qs]
CROSS APPLY [sys].[dm_exec_query_plan] ([qs].[plan_handle]) AS [qp]
CROSS APPLY [sys].[dm_exec_sql_text]([qs].[plan_handle]) AS [s]
INNER JOIN [sys].[dm_exec_cached_plans] AS [cp] 
	ON [qs].[plan_handle] = [cp].[plan_handle]
WHERE [s].[text] LIKE '%usp_GetFullProductInfo%';
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


/*
	What about an individual query?
	Run each query separately
*/
SET STATISTICS IO ON;
GO

SELECT 
	[o].[CustomerID], 
	[o].[OrderDate], 
	[ol].[StockItemID], 
	[ol].[Quantity],
	[ol].[UnitPrice]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = 220
ORDER BY [o].[OrderDate] DESC;
GO

SELECT 
	[o].[CustomerID], 
	[o].[OrderDate], 
	[ol].[StockItemID], 
	[ol].[Quantity],
	[ol].[UnitPrice]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = 130
ORDER BY [o].[OrderDate] DESC;
GO

SET STATISTICS IO OFF;
GO


/*
	What do we see in Query Store?
*/

/*
	No way to force a plan for all variations of 
	this query because there are literal values.
	What about other query hints?
*/

/*
	OPTIMIZE FOR UNKNOWN
	This works, but I'm changing 
	the query syntax
*/
SELECT 
	[o].[CustomerID], 
	[o].[OrderDate], 
	[ol].[StockItemID], 
	[ol].[Quantity],
	[ol].[UnitPrice]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = 123
ORDER BY [o].[OrderDate] DESC
OPTION (OPTIMIZE FOR UNKNOWN);
GO

/*
	What about using variables?
	This works, but I'm changing the code
	(could be implemented as a variable
	with a forced plan, or with OPTIMIZE FOR)
*/
DECLARE @StockItemID INT;
SET @StockItemID = 123;

SELECT 
	[o].[CustomerID], 
	[o].[OrderDate], 
	[ol].[StockItemID], 
	[ol].[Quantity],
	[ol].[UnitPrice]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = @StockItemID
ORDER BY [o].[OrderDate] DESC

GO