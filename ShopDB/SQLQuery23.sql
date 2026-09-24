USE ShopDB;
GO

SELECT name AS FileGroupName FROM sys.filegroups;
GO

SELECT t.name AS TableName, fg.name AS FileGroupName
FROM sys.tables t
JOIN sys.indexes   i  ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE i.index_id <= 1 AND t.name <> 'sysdiagrams'
ORDER BY fg.name, t.name;
GO

SELECT 'Categories' AS T, COUNT(*) AS Rows_ FROM Categories
UNION ALL SELECT 'Suppliers',   COUNT(*) FROM Suppliers
UNION ALL SELECT 'Products',    COUNT(*) FROM Products
UNION ALL SELECT 'Customers',   COUNT(*) FROM Customers
UNION ALL SELECT 'Orders',      COUNT(*) FROM Orders
UNION ALL SELECT 'OrderItems',  COUNT(*) FROM OrderItems;
GO