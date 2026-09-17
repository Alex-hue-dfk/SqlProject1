SELECT 
    SUSER_NAME()                         AS LoginName,
    IS_SRVROLEMEMBER('sysadmin')         AS IsSysadmin,
    IS_SRVROLEMEMBER('dbcreator')        AS IsDbCreator,
    IS_SRVROLEMEMBER('securityadmin')    AS IsSecurityAdmin;
GO