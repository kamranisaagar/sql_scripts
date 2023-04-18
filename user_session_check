/* This SQL code selects specific columns from the "sys.dm_exec_sessions" table to retrieve information about user sessions in the current SQL Server instance.
The selected columns are session_id, login_name, host_name, program_name,
status, and last_request_start_time.
The WHERE clause is used to filter the results by the login name of the user
in question. Replace 'user_in_question' with the actual login name to retrieve
information about that user's session.
This code can be useful for troubleshooting and monitoring user sessions in
SQL Server instances, particularly in cases where there are issues with the
performance or behavior of a specific user's session. */

SELECT 
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    last_request_start_time
FROM 
    sys.dm_exec_sessions
WHERE 
    login_name = 'user_in_question';
