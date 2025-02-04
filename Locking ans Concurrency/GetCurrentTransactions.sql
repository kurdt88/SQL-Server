SELECT transaction_id,
DB_NAME(database_id) AS DBName,
database_transaction_begin_time,
CASE database_transaction_type
        WHEN 1 THEN 'Read/Write'
        WHEN 2 THEN 'Read-Only'
        WHEN 3 THEN 'System'
        ELSE 'Unknown Type - ' + convert(VARCHAR(50), database_transaction_type)
    END AS TranType,
    CASE database_transaction_state
  WHEN 1 THEN 'Uninitialized'
  WHEN 3 THEN 'Not Started'
  WHEN 4 THEN 'Active'
  WHEN 5 THEN 'Prepared'
  WHEN 10 THEN 'Committed'
  WHEN 11 THEN 'Rolled Back'
  WHEN 12 THEN 'Comitting'
        ELSE 'Unknown State - ' + convert(VARCHAR(50), database_transaction_state)
    END AS TranState,
database_transaction_log_record_count AS LogRecords,
database_transaction_replicate_record_count AS ReplLogRcrds,
database_transaction_log_bytes_reserved/1024.0 AS LogResrvdKB,
database_transaction_log_bytes_used/1024.0 AS LogUsedKB,
database_transaction_log_bytes_reserved_system/1024.0 AS SysLogResrvdKB,
database_transaction_log_bytes_used_system/1024.0 AS SysLogUsedKB
FROM sys.dm_tran_database_transactions
