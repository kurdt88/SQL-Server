/********************************************************************************************
sp_index_maintenance:	This Stored Procedure pulls the index fragementation
For Standard Edition	percentage for each index from the sys.dm_db_index_physical_stats
						Database Management View.  It then compares that to the fragementation
						threshold specified by the users (defaults to 50%) and REBUILDS all
						indexes that greater than or equal to that value and RORGANIZES all 
						indexes that are less than that value.  This cuts down on the overhead
						and runtime of the maintenance job as we are only REBUILDING the indxes
						that really need it and use the less intensive REORGANIZE on the rest
						and completely skips indexes that are fragmented 10% or less. 
						 

Witten By:				Michael De Voe 
						Sr. Premier Field Engineer
			
Date:					Feb. 4th, 2014 

Recommendation:			We recommend you create an SQL Job that runs this Stored
						Procedure weekly against the Dynamics AX production 
						database.

This script is presented "AS IS" and has no warranties expressed or implied!!!
*********************************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_index_maintenance_standard]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_index_maintenance_standard]
GO

CREATE PROCEDURE sp_index_maintenance_standard

AS

DECLARE @RowThreshold INT
DECLARE @PercentThreshold DECIMAL(38,10)

/***********************************************************************************************************************************
*************SET PARAMETERS*********************************************************************************************************/

SET @RowThreshold		= 1000	--Threshold for the number of rows.  In the number of rows in the index is less that the threshold 
								--then it will skip it completely.
SET @PercentThreshold	= 50	--FOR THIS SCRIPT 50 = 50%
								--Fragmentation threshold percentage.  If greater than or equal to this amount them REBUILD the Index
								--If less than this amount REORGANIZE the index
						
/************SET PARAMETERS*********************************************************************************************************
************************************************************************************************************************************/

SET NOCOUNT ON



DECLARE @tablename SYSNAME;
DECLARE @index_name SYSNAME;
DECLARE @percentfrag DECIMAL(38,10);
DECLARE @command VARCHAR(8000);
DECLARE @command2 VARCHAR(8000);
DECLARE Index_Maint CURSOR FOR


SELECT
o.name,
i.name,
f.avg_fragmentation_in_percent
FROM SYS.DM_DB_INDEX_PHYSICAL_STATS (DB_ID(), NULL, NULL , NULL, 'LIMITED') f
JOIN sys.objects o on o.object_id = f.object_id
JOIN sys.indexes i on i.object_id = f.object_id and i.index_id = f.index_depth 
WHERE f.index_id > 0


OPEN Index_Maint

FETCH NEXT FROM Index_Maint INTO 
	  @tablename, @index_name, @percentfrag

While @@FETCH_STATUS = 0
BEGIN

	IF @percentfrag >= @PercentThreshold
		BEGIN
			SELECT @command2 = 'ALTER INDEX ' + '[' + @index_name + ']' + ' ON ' + '[' + @tablename + ']' + ' REBUILD WITH(MAXDOP=0)'; --Take advantage of parallelism
			EXEC (@command2);
			PRINT 'Executed ' + @command2;
		END; 
	ELSE
		BEGIN
			SELECT @command = 'ALTER INDEX ' + '[' + @index_name + ']' + ' ON ' + '[' + @tablename + ']' + ' REORGANIZE';
			EXEC (@command);	
			PRINT 'Executed ' + @command;
		END;			
						
FETCH NEXT FROM Index_Maint INTO 
	  @tablename, @index_name, @percentfrag
END 

CLOSE Index_Maint
DEALLOCATE Index_Maint


GO



