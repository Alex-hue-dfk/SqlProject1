USE topDB;
GO

IF OBJECT_ID('dbo.TableNull', 'U') IS NOT NULL DROP TABLE dbo.TableNull;
GO
CREATE TABLE dbo.TableNull (
    id INT NULL,
    Name NVARCHAR(100) NULL,
    Description NVARCHAR(255) NULL
);
GO

IF OBJECT_ID('dbo.TablePK', 'U') IS NOT NULL DROP TABLE dbo.TablePK;
GO
CREATE TABLE dbo.TablePK (
    id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    CONSTRAINT PK_TablePK PRIMARY KEY (id)
);
GO

INSERT INTO dbo.TableNull (id, Name, Description)
VALUES 
    (1, N'Record1', N'Description1'),
    (2, N'Record2', N'Description2'),
    (3, N'Record3', N'Description3');
GO

INSERT INTO dbo.TablePK (Name, Description)
SELECT Name, Description FROM dbo.TableNull;
GO