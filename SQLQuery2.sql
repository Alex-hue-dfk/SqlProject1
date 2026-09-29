IF DB_ID('topDB') IS NULL
BEGIN
    CREATE DATABASE topDB;
END;
GO

USE topDB;
GO

PRINT '=== База topDB выбрана ===';
GO

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Orders;
GO

CREATE TABLE dbo.Orders (
    OrderID     INT IDENTITY(1,1) NOT NULL,
    CustomerID  INT NOT NULL,
    OrderDate   DATE NOT NULL,
    Amount      DECIMAL(10,2) NOT NULL,
    Status      NVARCHAR(20) NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT NOT NULL
);
GO

CREATE CLUSTERED INDEX IX_Orders_OrderDate
ON dbo.Orders (OrderDate);
GO

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON dbo.Orders (CustomerID);
GO

PRINT '=== Шаг 1: кластерный и некластерный индексы созданы ===';
GO

CREATE NONCLUSTERED INDEX IX_Orders_ActiveStatus
ON dbo.Orders (OrderID)
WHERE Status = 'Active';
GO

PRINT '=== Шаг 2: фильтрованный индекс создан ===';
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Orders_Columnstore
ON dbo.Orders (ProductID, Quantity, Amount);
GO

PRINT '=== Шаг 3: колоночный индекс создан ===';
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FastFileGroup')
BEGIN
    ALTER DATABASE topDB ADD FILEGROUP FastFileGroup;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'SlowFileGroup')
BEGIN
    ALTER DATABASE topDB ADD FILEGROUP SlowFileGroup;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'topDB_FastData')
BEGIN
    ALTER DATABASE topDB
    ADD FILE (
        NAME = 'topDB_FastData',
        FILENAME = 'C:\SQLData\topDB_FastData.ndf',
        SIZE = 10MB,
        MAXSIZE = 500MB,
        FILEGROWTH = 10MB
    ) TO FILEGROUP [FastFileGroup];
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'topDB_SlowData')
BEGIN
    ALTER DATABASE topDB
    ADD FILE (
        NAME = 'topDB_SlowData',
        FILENAME = 'C:\SQLData\topDB_SlowData.ndf',
        SIZE = 10MB,
        MAXSIZE = 500MB,
        FILEGROWTH = 10MB
    ) TO FILEGROUP [SlowFileGroup];
END;
GO

PRINT '=== Шаг 4: файловые группы и файлы созданы ===';
GO

IF OBJECT_ID('dbo.FastLogs', 'U') IS NOT NULL
    DROP TABLE dbo.FastLogs;
GO

CREATE TABLE dbo.FastLogs (
    LogID    INT IDENTITY(1,1) PRIMARY KEY,
    Message  NVARCHAR(255) NOT NULL,
    LogDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME()
) ON [FastFileGroup];
GO

IF OBJECT_ID('dbo.ArchiveData', 'U') IS NOT NULL
    DROP TABLE dbo.ArchiveData;
GO

CREATE TABLE dbo.ArchiveData (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    OldData   NVARCHAR(MAX) NULL,
    AddedOn   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
) ON [SlowFileGroup];
GO

PRINT '=== Шаг 5: таблицы созданы в файловых группах ===';
GO

PRINT '--- Файловые группы в topDB ---';
SELECT name AS FileGroupName, type_desc
FROM sys.filegroups;
GO

PRINT '--- Где физически лежат таблицы ---';
SELECT 
    t.name AS TableName,
    fg.name AS FileGroupName,
    mf.physical_name AS FilePath
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
JOIN sys.database_files mf ON fg.data_space_id = mf.data_space_id
WHERE i.index_id IN (0,1);
GO

PRINT '--- Все индексы по таблице Orders ---';
SELECT name, type_desc, is_unique, filter_definition
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Orders');
GO

PRINT '=== ГОТОВО! Все шаги выполнены ===';
GO