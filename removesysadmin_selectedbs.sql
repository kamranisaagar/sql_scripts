-- Script to Change Selected Logins to db_owner Role for Selected Databases and Remove sysadmin
-- This script assigns the db_owner role to one or more specified logins for a list of selected databases and then removes the sysadmin role from those logins.

-- Define the logins you want to assign to the db_owner role and remove from sysadmin role
DECLARE @LoginsToAssign TABLE (LoginName SYSNAME);
INSERT INTO @LoginsToAssign (LoginName) VALUES 
    ('Login1'), 
    ('Login2'); -- Add more logins as needed

-- Define the databases you want to assign the db_owner role in
DECLARE @DatabasesToAssign TABLE (DatabaseName SYSNAME);
INSERT INTO @DatabasesToAssign (DatabaseName) VALUES 
    ('YourDatabase1'), 
    ('YourDatabase2'); -- Add more databases as needed

-- Declare variables for dynamic SQL
DECLARE @DatabaseName SYSNAME;
DECLARE @SQLCommand NVARCHAR(MAX);

-- Cursor to iterate through selected databases
DECLARE db_cursor CURSOR FOR
SELECT DatabaseName 
FROM @DatabasesToAssign;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Loop through databases
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Loop through logins to assign db_owner role in each selected database
    DECLARE @LoginName SYSNAME;
    DECLARE login_cursor CURSOR FOR SELECT LoginName FROM @LoginsToAssign;

    OPEN login_cursor;
    FETCH NEXT FROM login_cursor INTO @LoginName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construct the dynamic SQL for adding logins to db_owner role
        SET @SQLCommand = N'USE [' + @DatabaseName + ']; ' +
                          'IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @LoginName + ''')
                          BEGIN
                            CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];
                          END;
                          EXEC sp_addrolemember ''db_owner'', ''' + @LoginName + ''';';

        -- Execute the dynamic SQL to assign db_owner role
        EXEC sp_executesql @SQLCommand;

        FETCH NEXT FROM login_cursor INTO @LoginName;
    END;

    CLOSE login_cursor;
    DEALLOCATE login_cursor;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Remove sysadmin role from the specified logins
DECLARE @RemoveSysadminCmd NVARCHAR(MAX);
DECLARE remove_cursor CURSOR FOR SELECT LoginName FROM @LoginsToAssign;

OPEN remove_cursor;
FETCH NEXT FROM remove_cursor INTO @LoginName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct the dynamic SQL for removing sysadmin role
    SET @RemoveSysadminCmd = 'EXEC sp_dropsrvrolemember @loginame = ''' + @LoginName + ''', @rolename = ''sysadmin'';';
    
    -- Execute the command to remove sysadmin role
    EXEC sp_executesql @RemoveSysadminCmd;
    
    FETCH NEXT FROM remove_cursor INTO @LoginName;
END;

CLOSE remove_cursor;
DEALLOCATE remove_cursor;
