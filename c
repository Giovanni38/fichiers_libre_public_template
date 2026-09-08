DECLARE @sql nvarchar(max) = N'';

SELECT @sql = @sql + '
USE ' + QUOTENAME(name) + ';

SELECT
    DB_NAME() AS DatabaseName,
    o.name AS ObjectName,
    o.type_desc,
    m.definition
FROM sys.sql_modules m
JOIN sys.objects o
    ON o.object_id = m.object_id
WHERE
       m.definition LIKE ''%ACE.OLEDB%''
    OR m.definition LIKE ''%OPENROWSET%''
    OR m.definition LIKE ''%OPENDATASOURCE%'';
'
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND database_id > 4;

EXEC sp_executesql @sql;


--Powershell

  Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" |
Select DeviceID,
@{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}},
@{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}}


  Get-ChildItem Env:TEMP
Get-ChildItem Env:TMP

  

