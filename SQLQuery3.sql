USE topDB;
GO

PRINT '=== База topDB выбрана ===';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Persons')
    EXEC('CREATE SCHEMA Persons');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Products')
    EXEC('CREATE SCHEMA Products');
GO

PRINT '=== Шаг 1: схемы Persons и Products созданы ===';
GO

IF OBJECT_ID('Persons.Clients', 'U') IS NOT NULL
    DROP TABLE Persons.Clients;
GO

CREATE TABLE Persons.Clients (
    id        INT NULL,              -- пока NULL, потом исправим
    FirstName NVARCHAR(50) NOT NULL,
    LastName  NVARCHAR(50) NOT NULL,
    Email     NVARCHAR(100) NULL,
    Phone     NVARCHAR(20) NULL
);
GO

IF OBJECT_ID('Persons.Employees', 'U') IS NOT NULL
    DROP TABLE Persons.Employees;
GO

CREATE TABLE Persons.Employees (
    id         INT NULL,             -- пока NULL
    FullName   NVARCHAR(100) NOT NULL,
    Position   NVARCHAR(50) NOT NULL,
    Salary     DECIMAL(10,2) NULL,
    HireDate   DATE NULL
);
GO

PRINT '=== Шаг 2: таблицы Persons.Clients и Persons.Employees созданы ===';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Persons.Clients') AND name = 'id')
BEGIN
    ALTER TABLE Persons.Clients DROP COLUMN id;
END;
GO

ALTER TABLE Persons.Clients
ADD id INT IDENTITY(1,1) NOT NULL;
GO

ALTER TABLE Persons.Clients
ADD CONSTRAINT PK_Clients PRIMARY KEY (id);
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Persons.Employees') AND name = 'id')
BEGIN
    ALTER TABLE Persons.Employees DROP COLUMN id;
END;
GO

ALTER TABLE Persons.Employees
ADD id INT IDENTITY(1,1) NOT NULL;
GO

ALTER TABLE Persons.Employees
ADD CONSTRAINT PK_Employees PRIMARY KEY (id);
GO

PRINT '=== Шаг 3: id исправлены на PRIMARY KEY IDENTITY ===';
GO

IF OBJECT_ID('Products.Goods', 'U') IS NOT NULL
    DROP TABLE Products.Goods;
GO

CREATE TABLE Products.Goods (
    id       INT IDENTITY(1,1) NOT NULL,
    Name     NVARCHAR(100) NOT NULL,
    Price    DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Goods PRIMARY KEY (id)
);
GO

IF OBJECT_ID('Products.Categories', 'U') IS NOT NULL
    DROP TABLE Products.Categories;
GO

CREATE TABLE Products.Categories (
    id       INT IDENTITY(1,1) NOT NULL,
    Title    NVARCHAR(100) NOT NULL,
    Descr    NVARCHAR(255) NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (id)
);
GO

PRINT '=== Шаг 4: таблицы Products.Goods и Products.Categories созданы ===';
GO

INSERT INTO Products.Goods (Name, Price) VALUES
    (N'Ноутбук', 75000.00),
    (N'Мышь',     1500.00),
    (N'Клавиатура', 3200.00);
GO

INSERT INTO Products.Categories (Title, Descr) VALUES
    (N'Электроника', N'Техника и гаджеты'),
    (N'Аксессуары',  N'Периферия и доп. устройства');
GO

ALTER SCHEMA Persons TRANSFER Products.Goods;
GO

ALTER SCHEMA Persons TRANSFER Products.Categories;
GO

PRINT '=== Шаг 5: таблицы перенесены в схему Persons ===';
GO

PRINT '--- Список схем ---';
SELECT name AS SchemaName FROM sys.schemas
WHERE name IN ('Persons','Products');
GO

PRINT '--- Таблицы в схеме Persons ---';
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.is_nullable,
    c.is_identity
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE s.name = 'Persons'
ORDER BY t.name, c.column_id;
GO

PRINT '--- Данные в перенесённых таблицах ---';
SELECT * FROM Persons.Goods;
SELECT * FROM Persons.Categories;
GO

PRINT '=== ГОТОВО! Все шаги выполнены ===';
GO