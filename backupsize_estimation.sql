/* This SQL code performs a query on a Microsoft SQL Server database that retrieves disk space information and other details for each database on the server, excluding the system database tempdb.

The code first checks if a temporary table named #FreeSpace exists and drops it if it does. Then, it creates the temporary table with two columns: [database] and amount.

Next, the code declares a variable @sqlCommand and sets its value using the USE statement, a subquery, and the INSERT INTO statement. It then executes the stored procedure sp_MSforeachdb passing in @sqlCommand to retrieve disk space information for each database on the server.

The code then selects specific columns from various system tables and joins, using subqueries to calculate the data and log size in MB, free space in MB, compressed backup size in MB, and other database details. It orders the results by database name.

Finally, the code drops the temporary table #FreeSpace. /*

IF OBJECT_ID('tempdb..#FreeSpace') IS NOT NULL DROP TABLE #FreeSpace
 
CREATE TABLE #FreeSpace([database] VARCHAR(64) NOT NULL,amount INT NOT NULL)
 
DECLARE @sqlCommand varchar(2048)
 
SELECT @sqlCommand = 'USE [?]
           DECLARE @freeSpace INT
           SELECT @freeSpace = SUM(size/128 -(FILEPROPERTY(name, ''SpaceUsed'')/128)) FROM sys.master_files
           INSERT INTO #FreeSpace VALUES(''?'', @freeSpace)
          '
 
EXEC sp_MSforeachdb @sqlCommand
 
SELECT DISTINCT
          d.name AS 'DatabaseName',
          (SELECT CONVERT( DECIMAL(10,2),SUM(size)*8.0/1024) 
           FROM sys.master_files 
           WHERE type_desc = 'ROWS' 
             AND database_id = mf.database_id 
           GROUP BY database_id) AS 'DataSizeInMB',
          (SELECT CONVERT(DECIMAL(10,2),SUM(size)*8.0/1024) 
           FROM sys.master_files 
           WHERE type_desc = 'LOG' 
              AND database_id = mf.database_id 
           GROUP BY database_id) AS 'LogSizeInMB',
          (SELECT amount 
           FROM #FreeSpace 
           WHERE [database] = d.name) AS 'FreeSpaceInMB',
          CONVERT(DECIMAL(10,2),b.compressed_backup_size/1024.0/1024.0) AS CompressedBackupSizeInMB,
          d.state_desc AS 'State',
          suser_sname(d.owner_sid) AS 'Owner',
          d.compatibility_level AS 'CompatibilityLevel',
          d.create_date AS 'DBCreatedDate'
FROM      sys.databases d
JOIN      sys.master_files mf ON d.database_id = mf.database_id
LEFT JOIN (
         SELECT bs.compressed_backup_size,bs.database_name
         FROM msdb.dbo.backupset bs
         WHERE bs.backup_set_id IN (SELECT backup_set_id FROM msdb.dbo.backupset WHERE backup_start_date = (SELECT MAX(backup_start_date) FROM msdb.dbo.backupset WHERE database_name = bs.database_name))
        ) AS b ON b.database_name = d.name
WHERE     d.name NOT IN ('tempdb')
ORDER BY  d.name
 
DROP TABLE #FreeSpace
