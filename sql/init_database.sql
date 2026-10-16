-- 1. إنشاء قاعدة بيانات تجريبية باسم SalesDB والتأكد من استخدامها
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SalesDB')
BEGIN
    CREATE DATABASE SalesDB;
END;
GO

USE SalesDB;
GO

-- 2. إنشاء جدول الطلبات (Orders) بعد حذفه إن كان موجوداً مسبقاً
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Orders;
END;
GO

CREATE TABLE dbo.Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod VARCHAR(20) NOT NULL
);
GO

-- 3. إدخال بيانات الاختبار
INSERT INTO dbo.Orders (OrderID, CustomerName, Amount, PaymentMethod)
VALUES 
    (101, 'Ahmed', 1500.00, 'Visa'),
    (102, 'Sara', 450.00, 'Visa'),
    (103, 'Mohamed', 250.00, 'Cash'),
    (104, 'Mona', 1200.00, 'Cash'),
    (105, 'Ali', 80.00, 'Wallet');
GO

-- 4. فحص البيانات للتأكد من نزولها بشكل صحيح
SELECT 
    OrderID, 
    CustomerName, 
    Amount, 
    PaymentMethod 
FROM dbo.Orders;
GO

USE SalesDB;
GO

INSERT INTO dbo.Orders (OrderID, CustomerName, Amount, PaymentMethod)
VALUES 
    (106, 'Kareem', 2200.00, 'Visa'),     -- VIP (مبلغ عالي + فيزا)
    (107, 'Nour', 950.00, 'Visa'),        -- Visa Orders (مبلغ أقل من 1000 + فيزا)
    (108, 'Youssef', 1100.00, 'Mastercard'), -- VIP (مبلغ عالي + ماستركارد)
    (109, 'Heba', 300.00, 'Cash'),        -- Regular Orders (كاش عادي)
    (110, 'Tarek', 1000.00, 'Wallet'),    -- VIP (بالظبط 1000 = شرط >= 1000)
    (111, 'Salma', 150.00, 'Visa'),       -- Visa Orders (فيزا عادية)
    (112, 'Omar', 820.00, 'Mastercard'),  -- Regular Orders (ماستركارد أقل من 1000)
    (113, 'Dina', 3400.00, 'Cash'),       -- VIP (كاش بس مبلغ ضخم)
    (114, 'Mahmoud', 50.00, 'Fawry'),     -- Regular Orders (فوري)
    (115, 'Aya', 700.00, 'Visa'),         -- Visa Orders (فيزا)
    (116, 'Mostafa', 1300.00, 'Visa'),    -- VIP (فيزا بس هيخرج في VIP الأول)
    (117, 'Layla', 600.00, 'Wallet'),     -- Regular Orders (محفظة أقل من 1000)
    (118, 'Hassan', 400.00, 'Visa'),      -- Visa Orders
    (119, 'Reem', 1050.00, 'Fawry'),      -- VIP (فوري ومبلغ عالي)
    (120, 'Ziad', 999.00, 'Visa');        -- Visa Orders (أقل من 1000 بجنيه واحد)
GO

-- التأكد من إجمالي عدد الصفوف (الآن 20 صفاً)
SELECT COUNT(*) AS TotalOrders FROM dbo.Orders;