USE WideWorldImporters
GO

-- 1 --
SELECT P.FullName, P.FaxNumber, P.PhoneNumber,S.FaxNumber as CompanyFax, S.PhoneNumber as CompanyNumber
FROM Application.People P
LEFT JOIN Purchasing.Suppliers S
ON P.PersonID = S.PrimaryContactPersonID
-- 2 --
SELECT S.CustomerName
FROM Sales.Customers S
LEFT JOIN Application.People P
ON S.PrimaryContactPersonID = P.PersonID
WHERE S.PhoneNumber = P.PhoneNumber

-- 3 --

SELECT d.CustomerID
FROM Sales.Orders d
INNER JOIN 
(SELECT O.CustomerID 
FROM Sales.Orders O
WHERE O.OrderDate < '2016-01-01'
GROUP BY O.CustomerID
HAVING COUNT(OrderDate)> 0 ) AS C
ON d.CustomerID = C.CustomerID
WHERE d.OrderDate >= '2016-01-01'
GROUP BY d.CustomerID
HAVING COUNT(d.OrderDate) = 0

-- 4 --

SELECT W.StockItemID, W.StockItemName,PO.OrderDate,
		SUM(IL.Quantity) AS Total_Quantity
FROM Purchasing.PurchaseOrderLines OL 
INNER JOIN Purchasing.PurchaseOrders PO
ON OL.PurchaseOrderID = PO.PurchaseOrderID 
INNER JOIN
	(SELECT StockItemID,StockItemName
	FROM Warehouse.StockItems
	UNION
	SELECT StockItemID,StockItemName
	FROM Warehouse.StockItems_Archive) AS W
ON W.StockItemID = OL.StockItemID
INNER JOIN Sales.InvoiceLines IL
ON IL.StockItemID = W.StockItemID
WHERE PO.OrderDate = '2013'
GROUP BY W.[StockItemID], W.StockItemName,PO.OrderDate
ORDER BY W.StockItemID;

-- 5 --

SELECT StockItemID, StockItemName Description 
FROM Warehouse.StockItems 
WHERE len(StockItemName) >= 10
UNION
SELECT StockItemID, StockItemName Description 
FROM Warehouse.StockItems_Archive 
WHERE len(StockItemName) >= 10;

-- 6 --

SELECT W.StockItemID, W.StockItemName, SO.OrderDate, c.CityName, sp.StateProvinceName
FROM Warehouse.StockItems W
INNER JOIN Sales.OrderLines sol
ON W.StockItemID = sol. StockItemID
INNER JOIN Sales.Orders SO
ON sol.OrderID = SO.OrderID
INNER JOIN Application.Cities c
ON so.LastEditedBy = c.LastEditedBy
INNER JOIN Application.StateProvinces sp
ON c.StateProvinceID = sp.StateProvinceID
WHERE sp.StateProvinceName != ('ALABAMA''GEORGIA') AND YEAR (so.OrderDate) != '2014'
ORDER BY StateProvinceName;


-- 7 --

SELECT StateProvinceName, OrderDate , 
DateDiff(Day, OrderDate, ExpectedDeliveryDate) Average_DeliveryDate
FROM Sales.Orders 
INNER JOIN Sales.Customers 
ON Sales.Orders.CustomerID = Sales.Customers.CustomerID
INNER JOIN Application.StateProvinces 
ON Sales.Orders.LastEditedBY = Application.StateProvinces.LastEditedBY;

-- 8 --

SELECT DISTINCT StateProvinceName, DateDiff(MONTH, OrderDate, ExpectedDeliveryDate) Average_DeliveryMonth
FROM Sales.Orders 
INNER JOIN Sales.Customers 
ON Sales.Orders.CustomerID = Sales.Customers.CustomerID
INNER JOIN Application.StateProvinces 
ON Sales.Orders.LastEditedBY = Application.StateProvinces.LastEditedBY
ORDER BY StateProvinceName ASC;

-- 9 --

SELECT Warehouse.StockItems.StockItemName, Warehouse.StockItemTransactions.Quantity, Warehouse.StockItemHoldings.LastStocktakeQuantity
FROM Warehouse.StockItems
INNER JOIN Warehouse.StockItemTransactions
ON Warehouse.StockItems.StockItemID=Warehouse.StockItemTransactions.StockItemID
INNER JOIN Warehouse.StockItemHoldings
ON Warehouse.StockItemTransactions.StockItemID=Warehouse.StockItemHoldings.StockItemID
WHERE YEAR(TransactionOccurredWhen)='2015'

-- 10 --

SELECT SC.CustomerName, sc.PhoneNumber,A.FullName Primay_Contact
FROM Sales.Customers SC
INNER JOIN Application.People A
ON SC.PrimaryContactPersonID= A.PersonID
INNER JOIN Warehouse.StockItems W
ON W.LastEditedBy= A.LastEditedBy
RIGHT JOIN Warehouse.StockItemTransactions T
ON T.StockItemID= W.StockItemID
WHERE W.StockItemName  LIKE '%mug%'
AND W.QuantityPerOuter <=10
AND YEAR(TransactionOccurredWhen)='2016';

-- 11 --

SELECT Application.Cities.CityName
FROM Application.Cities
WHERE ValidFrom > '2015-01-01'

-- 12 --

SELECT
	ws.StockItemName, si.DeliveryInstructions, ac.CityName, asp.StateProvinceName, act.CountryName, 
    sc.CustomerName, ap.FullName, sc.PhoneNumber, OL.Quantity
FROM
	Sales.Orders S
LEFT JOIN Sales.OrderLines OL
ON S.OrderID = OL.OrderID
LEFT JOIN Sales.Invoices SI
ON S.CustomerID = SI.CustomerID
LEFT JOIN Sales.Customers SC
ON S.CustomerID = SC.CustomerID
LEFT JOIN Warehouse.StockItems WS
ON OL.StockItemID = WS.StockItemID
LEFT JOIN Application.People AP
ON S.ContactPersonID = AP.PersonID
LEFT JOIN Application.Cities AC
ON SC.DeliveryCityID = AC.CityID
LEFT JOIN Application.StateProvinces ASP
ON AC.StateProvinceID = ASP.StateProvinceID
LEFT JOIN Application.Countries ACT
ON ASP.CountryID = ACT.CountryID
WHERE S.OrderDate = '2014-07-01';

-- 13 --

SELECT b.StockGroupName, b.purchased_qty, s.sold_qty, b.purchased_qty - s.sold_qty stock 
FROM
	(SELECT SUM(sit.Quantity) purchased_qty, sg.StockGroupName 
	FROM Warehouse.StockItemTransactions sit 
	JOIN Warehouse.StockItemStockGroups sisg 
	ON sisg.StockItemID = sit.StockItemID 
	JOIN Warehouse.StockGroups sg 
	ON sg.StockGroupID = sisg.StockGroupID 
	WHERE sit.TransactionTypeID ='11' 
	GROUP BY sg.StockGroupName) b
JOIN
	(SELECT sg.StockGroupName, SUM(-sit_out.Quantity) sold_qty 
	FROM Warehouse.StockItems si 
	JOIN Warehouse.StockItemStockGroups sisg 
	ON sisg.StockItemID = si.StockItemID 
	JOIN Warehouse.StockGroups sg 
	ON sg.StockGroupID = sisg.StockGroupID 
	JOIN Warehouse.StockItemTransactions sit_out 
	ON si.StockItemID = sit_out.StockItemID
	WHERE sit_out.TransactionTypeID = '10'
	GROUP BY sg.StockGroupName) s
ON b.StockGroupName = s.StockGroupName
GROUP BY b.StockGroupName;


-- 14 --

SELECT D.CityID, D.CityName, iif(StockItemID is null, 'No Sales', cast(StockItemID as varchar)) StockItemID, iif(dvy_qty is null, 'No Sales', cast(dvy_qty as varchar)) dvy_qty 
FROM (SELECT cty.CityID, cty.CityName, dvy.StockItemID, dvy.dvy_qty, 
	RANK() OVER (PARTITION by cty.CityID,cty.CityName ORDER BY dvy.dvy_qty DESC) rk 
	FROM 
	(SELECT ct.CityID, ct.CityName, c2.CountryID, c2.CountryName 
	FROM Application.Cities ct 
	JOIN Application.StateProvinces sp 
	ON sp.StateProvinceID = ct.StateProvinceID 
	JOIN Application.Countries c2 
	ON c2.CountryID = sp.CountryID) cty  
	LEFT JOIN (SELECT c.DeliveryCityID, il.StockItemID, SUM(il.Quantity) dvy_qty 
			FROM Sales.Orders o 
			JOIN sales.OrderLines ol 
			ON ol.OrderID = o.OrderID 
			JOIN Sales.Customers c 
			ON o.CustomerID = c.CustomerID 
			JOIN Sales.Invoices i 
			ON i.OrderID = o.OrderID 
			JOIN Sales.InvoiceLines il 
			ON il.InvoiceID = i.InvoiceID AND il.StockItemID  = ol.StockItemID 
			JOIN  Application.Cities c2 
			ON c.DeliveryCityID = c2.CityID 
			JOIN Application.StateProvinces sp 
			ON sp.StateProvinceID = c2.StateProvinceID 
			JOIN Application.Countries c3 
			ON c3.CountryID = sp.CountryID
			WHERE c3.CountryID = 230 AND YEAR(i.ConfirmedDeliveryTime) = '2016'
			GROUP BY c.DeliveryCityID, il.StockItemID) dvy
	ON dvy.DeliveryCityID = cty.CityID)D
 WHERE rk = 1

 -- 15 --

SELECT 
	OrderID, JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Event') Delivery_Attempt
FROM
	Sales.Invoices SI
WHERE OrderID IN (
	SELECT OrderID
	FROM Sales.Invoices
	GROUP BY OrderID
	HAVING COUNT(OrderID) > 1
)
ORDER BY SI.OrderID;


-- 16 --

SELECT WS.StockItemID, WS.StockItemName
FROM Warehouse.StockItems WS
WHERE ISJSON(CustomFields)>0
AND JSON_VALUE(CustomFields,'$.CountryOfManufacture')like '%china%';

-- 17 --

SELECT JSON_value(si.CustomFields, '$.CountryOfManufacture') as origin_country, SUM(ol.Quantity) sold_qty
FROM Warehouse.StockItems si 
JOIN Sales.OrderLines ol 
ON ol.StockItemID = si.StockItemID 
JOIN Sales.Orders o 
ON o.OrderID = ol.OrderID
WHERE year(o.OrderDate) = '2015'
GROUP BY JSON_value(si.CustomFields, '$.CountryOfManufacture');

-- 18 --
CREATE VIEW Sales.vStkGrpSldbyYr



-- 19 --
CREATE VIEW Sales.vStkGrpSldbyName


-- 20 --

CREATE FUNCTION  ORDERCHECK(@orderid int)
returns int
AS
BEGIN
	declare @ret int;
	select @ret = sum(ol.Quantity * ol.UnitPrice) from Sales.OrderLines ol where ol.OrderID = @orderid;
	if (@ret is null)
		set @ret = 0;
	return @ret;
END;

SELECT ORDERCHECK(10)



-- 21 -- 
CREATE SCHEMA ods;

CREATE TABLE ods.Orders (
	OrderID int,
	OrderDate date,
	order_total money,
	CutomerID int);

CREATE PROCEDURE ods.uspOrders
	@OrderDate date
AS
BEGIN
-- 22 --


SELECT [StockItemID], [StockItemName], [SupplierID], [ColorID], [UnitPackageID], [OuterPackageID], [Brand], [Size], [LeadTimeDays], [QuantityPerOuter],
	[IsChillerStock], [Barcode], [TaxRate], [UnitPrice], [RecommendedRetailPrice], [TypicalWeightPerUnit], [MarketingComments], [InternalComments],
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS [CountryOfManufacture], JSON_VALUE(CustomFields, '$.Range') AS [Range],
	JSON_VALUE(CustomFields, '$.ShelfLife') AS [ShelfLife]
INTO
	obs.StockItems
FROM
	Warehouse.StockItems ;

SELECT *
FROM obs.StockItems;

-- 23 --

-- 24 --
declare @json nvarchar(max)
set @json = N'{"PurchaseOrders":[{"StockItemName":"Panzer Video Game","Supplier":"7","UnitPackageId":"1","OuterPackageId":[6,7],"Brand":"EA Sports","LeadTimeDays":"5","QuantityPerOuter":"1","TaxRate":"6","UnitPrice":"59.99","RecommendedRetailPrice":"69.99","TypicalWeightPerUnit":"0.5","CountryOfManufacture":"Canada","Range":"Adult","OrderDate":"2018-01-01","DeliveryMethod":"Post","ExpectedDeliveryDate":"2018-02-02","SupplierReference":"WWI2308"},{"StockItemName":"Panzer Video Game","Supplier":"5","UnitPackageId":"1","OuterPackageId":"7","Brand":"EA Sports","LeadTimeDays":"5","QuantityPerOuter":"1","TaxRate":"6","UnitPrice":"59.99","RecommendedRetailPrice":"69.99","TypicalWeightPerUnit":"0.5","CountryOfManufacture":"Canada","Range":"Adult","OrderDate":"2018-01-025","DeliveryMethod":"Post","ExpectedDeliveryDate":"2018-02-02","SupplierReference":"269622390"}]}'


-- 25 --

