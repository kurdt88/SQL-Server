select * from sys.configurations
where name like '%ad hoc%'
go
SELECT S.CacheType, S.Avg_Use, S.Avg_Multi_Use,
       S.Total_Plan_3orMore_Use, S.Total_Plan_2_Use, S.Total_Plan_1_Use, S.Total_Plan,
       CAST( (S.Total_Plan_1_Use * 1.0 / S.Total_Plan) as Decimal(18,2) )[Pct_Plan_1_Use],
       S.Total_MB_1_Use,   S.Total_MB,
       CAST( (S.Total_MB_1_Use   * 1.0 / S.Total_MB  ) as Decimal(18,2) )[Pct_MB_1_Use]
  FROM
  (
    SELECT CP.objtype[CacheType],
           COUNT(*)[Total_Plan],
           SUM(CASE WHEN CP.usecounts > 2 THEN 1 ELSE 0 END)[Total_Plan_3orMore_Use],
           SUM(CASE WHEN CP.usecounts = 2 THEN 1 ELSE 0 END)[Total_Plan_2_Use],
           SUM(CASE WHEN CP.usecounts = 1 THEN 1 ELSE 0 END)[Total_Plan_1_Use],
           CAST((SUM(CP.size_in_bytes * 1.0) / 1024 / 1024) as Decimal(12,2) )[Total_MB],
           CAST((SUM(CASE WHEN CP.usecounts = 1 THEN (CP.size_in_bytes * 1.0) ELSE 0 END)
                      / 1024 / 1024) as Decimal(18,2) )[Total_MB_1_Use],
           CAST(AVG(CP.usecounts * 1.0) as Decimal(12,2))[Avg_Use],
           CAST(AVG(CASE WHEN CP.usecounts > 1 THEN (CP.usecounts * 1.0)
                         ELSE NULL END) as Decimal(12,2))[Avg_Multi_Use]
      FROM sys.dm_exec_cached_plans as CP
     GROUP BY CP.objtype
  ) AS S
where CacheType = 'Adhoc'
ORDER BY S.CacheType

:connect cvga11r\ax01p
go
select * from DBA_log..t_plan_cache
where CacheType = 'Adhoc'

