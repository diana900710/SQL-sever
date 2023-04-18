-- 找出和最貴的產品同類別的所有產品
select
	p.*
from  Products p
left join Categories c on p.CategoryID = c.CategoryID
where c.CategoryID in (select top 1 CategoryID 
						from Products p 
						order by p.UnitPrice desc)
-- 找出和最貴的產品同類別最便宜的產品
select top 1
	p.*
from  Products p
left join Categories c on p.CategoryID = c.CategoryID
where c.CategoryID in (select top 1 CategoryID 
						from Products p 
						order by p.UnitPrice desc)
order by p.UnitPrice
-- 計算出上面類別最貴和最便宜的兩個產品的價差
select
	MAX(p.UnitPrice) as MaxPrice, MIN(p.UnitPrice) as MinPrice,
	MAX(p.UnitPrice)-MIN(p.UnitPrice) as Spread
from  Products p
left join Categories c on p.CategoryID = c.CategoryID
where c.CategoryID in (select top 1 CategoryID 
						from Products p 
						order by p.UnitPrice desc)
-- 找出沒有訂過任何商品的客戶所在的城市的所有客戶
select
	c.CustomerID,c.City
from Customers c
where not exists(
select * from Orders
where CustomerID = c.CustomerID
)
-- 找出第 5 貴跟第 8 便宜的產品的產品類別
select
	distinct p.CategoryID
from  Products p
left join Categories c on p.CategoryID = c.CategoryID
where c.CategoryID in (select CategoryID 
						from Products
						order by UnitPrice desc
						OFFSET 4 ROWS
						FETCH NEXT 1 ROWS ONLY
						union all
						select CategoryID 
						from Products
						order by UnitPrice
						OFFSET 7 ROWS
						FETCH NEXT 1 ROWS ONLY)
-- 找出誰買過第 5 貴跟第 8 便宜的產品
select c.*
from Customers c
left join Orders o on c.CustomerID = o.CustomerID
left join [Order Details] od on o.OrderID = od.OrderID
left join Products p on od.ProductID = p.ProductID
where od.ProductID in (select ProductID
						from Products
						order by UnitPrice desc
						OFFSET 4 ROWS
						FETCH NEXT 1 ROWS ONLY
						union all
						select ProductID
						from Products
						order by UnitPrice
						OFFSET 7 ROWS
						FETCH NEXT 1 ROWS ONLY)
-- 找出誰賣過第 5 貴跟第 8 便宜的產品
select
	e.*
from Employees e
left join Orders o on e.EmployeeID = o.EmployeeID
left join [Order Details] od on o.OrderID = od.OrderID
left join Products p on od.ProductID = p.ProductID
where p.ProductID in (select ProductID
						from Products
						order by UnitPrice desc
						OFFSET 4 ROWS
						FETCH NEXT 1 ROWS ONLY
						union all
						select ProductID
						from Products
						order by UnitPrice
						OFFSET 7 ROWS
						FETCH NEXT 1 ROWS ONLY)
-- 找出 13 號星期五的訂單 (惡魔的訂單)
select *
from Orders
where OrderDate like '%13%' and DATENAME(WEEKDAY, OrderDate) = '星期五'
-- 找出誰訂了惡魔的訂單
select *
from Customers c
left join Orders o on c.CustomerID = o.CustomerID
where o.OrderDate like '%13%' and DATENAME(WEEKDAY, o.OrderDate) = '星期五'
-- 找出惡魔的訂單裡有什麼產品
select *
from Products p
left join [Order Details] od on p.ProductID = od.ProductID
left join Orders o on od.OrderID = o.OrderID
where OrderDate like '%13%' and DATENAME(WEEKDAY, OrderDate) = '星期五'
-- 列出從來沒有打折 (Discount) 出售的產品
select *
from Products p
left join [Order Details] od on p.ProductID = od.ProductID
where od.Discount !> 0
-- 列出購買非本國的產品的客戶
select *
from Customers c
left join Orders o on c.CustomerID = o.CustomerID
left join [Order Details] od on o.OrderID = od.OrderID
left join Products p on od.ProductID = p.ProductID
left join Suppliers s on p.SupplierID = s.SupplierID
where s.Country is not null
-- 列出在同個城市中有公司員工可以服務的客戶
select c.CustomerID,c.City
from Customers c
where City in(select City from Employees)
-- 列出那些產品沒有人買過
select p.ProductID
from Products p
where not exists(
select *
from [Order Details]
where ProductID = p.ProductID)
----------------------------------------------------------------------------------------

-- 列出所有在每個月月底的訂單
select *
from Orders
where OrderDate like DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDate) + 1, 0))
-- 列出每個月月底售出的產品
select o.OrderDate, p.*
from Products p
left join [Order Details] od on p.ProductID = od.ProductID
left join Orders o on  od.OrderID = o.OrderID
where o.OrderDate like DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDate)+1, 0))
-- 找出有敗過最貴的三個產品中的任何一個的前三個大客戶
select top 3 
	SUM(p.UnitPrice) as Sum_Price, c.CustomerID
from Customers c
inner join Orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
inner join Products p on od.ProductID = p.ProductID
where p.UnitPrice in (select top 3 
							UnitPrice
						from Products
						order by UnitPrice desc)
group by c.CustomerID
order by Sum_Price desc
-- 找出有敗過銷售金額前三高個產品的前三個大客戶
select top 3 
	SUM(p.UnitPrice) as Sum_Price, c.CustomerID
from Customers c
inner join Orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
inner join Products p on od.ProductID = p.ProductID
where p.ProductID in (select top 3 
							p.ProductID
						from Products p
						inner join [Order Details] od on p.ProductID = od.ProductID
						inner join Orders o on od.OrderID = od.OrderID
						group by p.ProductID
						order by SUM(p.UnitPrice) desc)
group by c.CustomerID
order by Sum_Price desc
-- 找出有敗過銷售金額前三高個產品所屬類別的前三個大客戶
select top 3 
	SUM(p.CategoryID) as Sum_Catagory, c.CustomerID
from Customers c
inner join Orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
inner join Products p on od.ProductID = p.ProductID
inner join Categories ca on p.CategoryID = ca.CategoryID
where ca.CategoryID in (select top 3 
							p.CategoryID
						from Products p
						inner join [Order Details] od on p.ProductID = od.ProductID
						inner join Orders o on od.OrderID = od.OrderID
						group by p.CategoryID
						order by SUM(p.CategoryID) desc)
group by c.CustomerID
order by Sum_Catagory desc
-- 列出消費總金額高於所有客戶平均消費總金額的客戶的名字，以及客戶的消費總金額
select 
	c.CustomerID, 
	SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as SumPrice
from Products p
left outer join [Order Details] od on p.ProductID = od.ProductID
left outer join Orders o on od.OrderID = o.OrderID
left outer join Customers c on o.CustomerID = c.CustomerID
group by c.CustomerID
having SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) > (select avg(od.UnitPrice* od.Quantity*(1-od.Discount))
														from Products p
														inner join [Order Details] od on p.ProductID = od.ProductID
														inner join Orders o on od.OrderID = o.OrderID
														inner join Customers c on o.CustomerID = c.CustomerID)
-- 列出最熱銷的產品，以及被購買的總金額
select
	p.ProductID, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as SalesAmount
from Products p
left outer join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductID
order by SalesAmount desc
-- 列出最少人買的產品
select
	p.ProductID, COUNT(p.ProductID) as ProductAmount
from Products p
left outer join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductID
order by ProductAmount
-- 列出最沒人要買的產品類別 (Categories)
select
	c.CategoryID, c.CategoryName
from Categories c
left outer join Products p on c.CategoryID = p.CategoryID
left outer join [Order Details] od on p.ProductID = od.ProductID
group by c.CategoryID, c.CategoryName
order by COUNT(c.CategoryID)
-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (含購買其它供應商的產品)
with t1 as(
select top 1
	s.SupplierID
from Suppliers s
left outer join Products p on s.SupplierID = p.SupplierID
left outer join  [Order Details] od on p.ProductID = od.ProductID
group by s.SupplierID, s.CompanyName
order by SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) desc
),t2 as(
select top 1
	c.CustomerID
from Customers c
left outer join Orders o on c.CustomerID = o.CustomerID
left outer join [Order Details] od on o.OrderID = od.OrderID
left outer join Products p on od.ProductID = p.ProductID
left outer join t1 on p.SupplierID = t1.SupplierID
group by c.CustomerID
order by SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) desc
),t3 as(
select
	c.CustomerID, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as PriceAmount
from Customers c
inner join t2 on c.CustomerID = t2.CustomerID
left outer join Orders o on c.CustomerID = o.CustomerID
left outer join [Order Details] od on o.OrderID = od.OrderID
group by c.CustomerID
)
select * from t3
-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (不含購買其它供應商的產品)
select top 1
 c.CustomerID, 
 SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as PriceAmount
from Customers c
left outer join Orders o on c.CustomerID = o.CustomerID
left outer join  [Order Details] od on o.OrderID = od.OrderID
left outer join  Products p on od.ProductID = p.ProductID
left outer join Suppliers s on p.SupplierID = s.SupplierID
where s.SupplierID in(	select top 1
							s.SupplierID
						from Suppliers s
						left outer join Products p on s.SupplierID = p.SupplierID
						left outer join  [Order Details] od on p.ProductID = od.ProductID
						group by s.SupplierID, s.CompanyName
						order by SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) desc)
group by c.CustomerID
order by PriceAmount desc
-- 列出那些產品沒有人買過
select *
from Products p
where not exists(
select * from [Order Details]
where ProductID = p.ProductID
)
-- 列出沒有傳真 (Fax) 的客戶和它的消費總金額
select
c.CustomerID , SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as PriceAmount
from Customers c
left outer join Orders o on c.CustomerID = o.CustomerID
left outer join [Order Details] od on o.OrderID = od.OrderID
where c.Fax is null
group by c.CustomerID
-- 列出每一個城市消費的產品種類數量
select
	c.City, COUNT(od.ProductID) as CountProduct
from Customers c
left outer join Orders o on c.CustomerID = o.CustomerID
left outer join [Order Details] od on o.OrderID = od.OrderID
group by c.City
-- 列出目前沒有庫存的產品在過去總共被訂購的數量
select SUM(od.Quantity) as StockAmount
from Products p
left outer join [Order Details] od on p.ProductID=od.ProductID
left outer join Orders o on od.OrderID=o.OrderID
where p.UnitsInStock = 0
-- 列出目前沒有庫存的產品在過去曾經被那些客戶訂購過
select distinct c.CustomerID
from Products p
left outer join [Order Details] od on p.ProductID=od.ProductID
left outer join Orders o on od.OrderID=o.OrderID
left outer join Customers c on o.CustomerID=c.CustomerID
where p.UnitsInStock = 0
-- 列出每位員工的下屬的業績總金額
select e.EmployeeID, e.FirstName, sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as PriceAmount
from Employees e
left outer join Orders o on e.EmployeeID=o.EmployeeID
left outer join [Order Details] od on o.OrderID=od.OrderID
group by e.EmployeeID, e.FirstName
-- 列出每家貨運公司運送最多的那一種產品類別與總數量
with 
o0 as(
select s.ShipperID, c.CategoryID
from Shippers s
left outer join Orders o on s.ShipperID=o.ShipVia
left outer join [Order Details] od on o.OrderID=od.OrderID
left outer join Products p on od.ProductID=p.ProductID
left outer join Categories c on p.CategoryID=c.CategoryID
),o1 as(
select
	ShipperID, CategoryID,
	SUM(CategoryID) as CategoryAmount
from o0
group by ShipperID,CategoryID
)
select
	distinct o1.ShipperID,
	MAX(CategoryAmount) over(partition by o1.ShipperID, o0.CategoryID) as MaxCategory
from o1
inner join o0 on o1.ShipperID=o0.ShipperID
group by o1.ShipperID, o0.CategoryID, CategoryAmount
-- 列出每一個客戶買最多的產品類別與金額
with 
p0 as(
select c.CustomerID, ca.CategoryID
from Customers c
left outer join Orders o on c.CustomerID=o.CustomerID
left outer join [Order Details] od on o.OrderID=od.OrderID
left outer join Products p on od.ProductID=p.ProductID
left outer join Categories ca on p.CategoryID=ca.CategoryID
),p1 as(
select
	CustomerID, CategoryID,
	SUM(CategoryID) as CategoryAmount
from p0
group by CustomerID,CategoryID
)
select
	distinct p1.CustomerID,
	MAX(CategoryAmount) over(partition by p1.CustomerID, p0.CategoryID) as MaxCategory
from p1
inner join p0 on p1.CustomerID=p0.CustomerID
group by p1.CustomerID, p0.CategoryID, CategoryAmount
-- 列出每一個客戶買最多的那一個產品與購買數量
select
	c.CustomerID, SUM(p.ProductID) ProductAmount
from Customers c
left outer join Orders o on c.CustomerID=o.CustomerID
left outer join [Order Details] od on o.OrderID=od.OrderID
left outer join Products p on od.ProductID=p.ProductID
group by c.CustomerID
-- 按照城市分類，找出每一個城市最近一筆訂單的送貨時間
create or alter view EmployeeRecentOrders
as
select 
	o.ShipCity, o.OrderDate
from Orders o
where o.OrderDate = (
select 
	MAX(OrderDate)
from Orders
where EmployeeID = o.EmployeeID
)
and o.ShipCity is not null
group by o.ShipCity, o.OrderDate
go

select * from EmployeeRecentOrders
-- 列出購買金額第五名與第十名的客戶，以及兩個客戶的金額差距
with tab as(
select
	distinct c.CustomerID, c.CompanyName,
	SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) over(
		partition by c.CustomerID
	) as PriceAmmount
from Customers c
left outer join Orders o on c.CustomerID=o.CustomerID
left outer join [Order Details] od on o.OrderID=od.OrderID
where c.CustomerID in(
select c.CustomerID
from Customers c
left outer join Orders o on c.CustomerID=o.CustomerID
left outer join [Order Details] od on o.OrderID=od.OrderID
group by c.CustomerID
order by SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) desc
offset 4 rows
fetch next 1 rows only
union all
select c.CustomerID
from Customers c
left outer join Orders o on c.CustomerID=o.CustomerID
left outer join [Order Details] od on o.OrderID=od.OrderID
group by c.CustomerID
order by SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) desc
offset 9 rows
fetch next 1 rows only
)
group by c.CustomerID,c.CompanyName, od.UnitPrice, od.Quantity, od.Discount
)
select *,
LAG(PriceAmmount) over( -- 和前一筆的價差
		order by PriceAmmount desc
	) - PriceAmmount as DiffPrice
from tab