-- See http://www.sqlskills.com/blogs/paul/determine-causes-particular-wait-type/

-- Make sure you have symbol files as in:
-- http://www.sqlskills.com/blogs/paul/how-to-download-a-sqlservr-pdb-symbol-file/

-- Figure out the wait type that we need
SELECT
    [map_key]
FROM sys.dm_xe_map_values
WHERE [name] = N'wait_types'
    AND [map_value] = N'WRITE_COMPLETION';
GO

-- Drop the session if it exists.
IF EXISTS (
    SELECT * FROM sys.server_event_sessions
        WHERE [name] = N'InvestigateWaits')
    DROP EVENT SESSION [InvestigateWaits] ON SERVER
GO

-- Drop the test database if it exists
IF DATABASEPROPERTYEX (N'production', N'Version') > 0
BEGIN
	ALTER DATABASE [production] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [production];
END
GO

-- Create the event session
CREATE EVENT SESSION [InvestigateWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
(
    ACTION ([package0].[callstack])
    WHERE [wait_type] = 643 -- WRITE_COMPLETION only
    AND [opcode] = 1 -- Just the end wait events
    --AND [duration] > X-milliseconds
)
ADD TARGET [package0].[asynchronous_bucketizer]
(
    SET filtering_event_name = N'sqlos.wait_info',
    source_type = 1, -- source_type = 1 is an action
    source = N'package0.callstack' -- bucketize on the callstack
)
WITH
(
    MAX_MEMORY = 50 MB,
    MAX_DISPATCH_LATENCY = 5 SECONDS)
GO

-- Start the session
ALTER EVENT SESSION [InvestigateWaits] ON SERVER
STATE = START;
GO

-- TF to allow call stack resolution
DBCC TRACEON (3656, -1);
GO

-- Do the workload
CREATE DATABASE [Production];
GO

-- Second test for ASYNC_IO_COMPLETION
-- BACKUP DATABASE [Production] TO DISK = 'c:\SQLskills\test.bak' WITH INIT;

-- Get the callstacks from the bucketizer target
SELECT
    [event_session_address],
    [target_name],
    [execution_count],
    CAST ([target_data] AS XML)
FROM sys.dm_xe_session_targets [xst]
INNER JOIN sys.dm_xe_sessions [xs]
    ON [xst].[event_session_address] = [xs].[address]
WHERE [xs].[name] = N'InvestigateWaits';
GO

-- Stop the event session
ALTER EVENT SESSION [InvestigateWaits] ON SERVER
STATE = STOP;
GO
