
	SELECT 
    t.name AS TableName,
    SUM(p.reserved_page_count) * 8 / 1024 AS SizeMB
FROM 
    sys.dm_db_partition_stats AS p
INNER JOIN 
    sys.tables AS t ON p.object_id = t.object_id
WHERE 
    t.name in ('TABLe','TABL2')
    AND p.index_id IN (0, 1)
GROUP BY 
    t.name;
