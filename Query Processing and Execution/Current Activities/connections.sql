SELECT hostname
	,DB_NAME(dbid) AS DBName
	,loginame AS LoginName
	,COUNT(dbid) AS NumberOfConnections
FROM sys.sysprocesses
WHERE dbid > 0
GROUP BY hostname
	,dbid
	,loginame
ORDER BY DBName,NumberOfConnections DESC
	,hostname;

-- Get a count of SQL connections by IP address
SELECT ec.client_net_address
	,es.[program_name]
	,es.[host_name]
	,es.login_name
	,COUNT(ec.session_id) AS [connection count]
FROM sys.dm_exec_sessions AS es
INNER JOIN sys.dm_exec_connections AS ec
	ON es.session_id = ec.session_id
GROUP BY ec.client_net_address
	,es.[program_name]
	,es.[host_name]
	,es.login_name
ORDER BY ec.client_net_address
	,es.[program_name];

-- Get a count of SQL connections by login_name
SELECT login_name
	,COUNT(session_id) AS [session_count]
FROM sys.dm_exec_sessions
GROUP BY login_name
ORDER BY login_name;

-- Get count running session
SELECT login_name
	,COUNT(session_id) AS [session_count]
FROM sys.dm_exec_sessions
WHERE status = 'Running'
GROUP BY login_name
ORDER BY login_name;


select * from sys.dm_exec_sessions