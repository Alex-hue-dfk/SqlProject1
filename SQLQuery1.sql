USE [topBP];
GO

IF OBJECT_ID('dbo.FastProducts', 'U') IS NOT NULL DROP TABLE dbo.FastProducts;
IF OBJECT_ID('dbo.SlowLogs', 'U') IS NOT NULL DROP TABLE dbo.SlowLogs;
IF OBJECT_ID('dbo.ClusteredExample', 'U') IS NOT NULL DROP TABLE dbo.ClusteredExample;
IF OBJECT_ID('dbo.SalesData', 'U') IS NOT NULL DROP TABLE dbo.SalesData;
GO
PRINT '✅ Старые таблицы (если были) удалены.';
GO

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'FastTablesFG')
    ALTER DATABASE [topBP] ADD FILEGROUP [FastTablesFG];
GO
IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'SlowTablesFG')
    ALTER DATABASE [topBP] ADD FILEGROUP [SlowTablesFG];
GO
PRINT '✅ Файловые группы FastTablesFG и SlowTablesFG готовы.';
GO

IF NOT EXISTS (SELECT * FROM sys.master_files WHERE name = 'FastTablesData')
BEGIN
    ALTER DATABASE [topBP] 
    ADD FILE (
        NAME = N'FastTablesData',
        FILENAME = N'C:\SQLData\FastTablesData.ndf',
        SIZE = 10MB, MAXSIZE = UNLIMITED, FILEGROWTH = 5MB
    ) TO FILEGROUP [FastTablesFG];
END
GO

IF NOT EXISTS (SELECT * FROM sys.master_files WHERE name = 'SlowTablesData')
BEGIN
    ALTER DATABASE [topBP] 
    ADD FILE (
        NAME = N'SlowTablesData',
        FILENAME = N'C:\SQLData\SlowTablesData.ndf',
        SIZE = 10MB, MAXSIZE = UNLIMITED, FILEGROWTH = 5MB
    ) TO FILEGROUP [SlowTablesFG];
END
GO
PRINT '✅ Физические файлы (.ndf) добавлены.';
GO

CREATE TABLE dbo.FastProducts (
    ProductID INT IDENTITY(1,1) NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    CategoryID INT NOT NULL,
    CreatedDate DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_FastProducts PRIMARY KEY CLUSTERED (ProductID)
) ON [FastTablesFG];
GO

CREATE TABLE dbo.SlowLogs (
    LogID BIGINT IDENTITY(1,1) NOT NULL,
    LogMessage NVARCHAR(MAX) NOT NULL,
    LogDate DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT PK_SlowLogs PRIMARY KEY CLUSTERED (LogID)
) ON [SlowTablesFG];
GO
PRINT '✅ Таблицы FastProducts и SlowLogs созданы в своих файловых группах.';
GO

CREATE TABLE dbo.ClusteredExample (
    ID INT NOT NULL,
    DataValue NVARCHAR(50),
    CreatedDate DATETIME2
);
GO
CREATE CLUSTERED INDEX IX_ClusteredExample_CreatedDate 
ON dbo.ClusteredExample (CreatedDate);
GO
PRINT '✅ Кластерный индекс создан.';

CREATE NONCLUSTERED INDEX IX_FastProducts_ProductName 
ON dbo.FastProducts (ProductName);
GO
PRINT '✅ Некластерный индекс создан.';

CREATE NONCLUSTERED INDEX IX_FastProducts_Expensive 
ON dbo.FastProducts (Price) 
WHERE Price > 1000.00;
GO
PRINT '✅ Фильтрованный индекс создан (только Price > 1000).';

CREATE TABLE dbo.SalesData (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    Quantity INT,
    SaleAmount DECIMAL(18,2),
    SaleDate DATE
);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_SalesData_Columnstore 
ON dbo.SalesData (ProductID, Quantity, SaleAmount, SaleDate);
GO
PRINT '✅ Колоночный индекс создан.';

PRINT '';
PRINT '========== ПРОВЕРКА: ФАЙЛОВЫЕ ГРУППЫ ==========';
SELECT name AS FileGroupName, type_desc AS FileGroupType 
FROM sys.filegroups;
GO

PRINT '========== ПРОВЕРКА: ИНДЕКСЫ ==========';
SELECT 
    TableName = OBJECT_NAME(i.object_id),
    IndexName = i.name,
    IndexType = i.type_desc,
    IsFiltered = i.has_filter
FROM sys.indexes i
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
  AND OBJECT_NAME(i.object_id) IN ('FastProducts', 'SlowLogs', 'ClusteredExample', 'SalesData')
ORDER BY TableName, IndexName;
GO