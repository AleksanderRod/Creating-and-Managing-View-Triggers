/*
Name:	Aleksander Rodriguez
Lesson:	Creating and Managing View Triggers 
Date:	8/21/2021
*/

/*
1.	CREATE the following tables –
a.	Dept_triggers – Add Identity Column (1000,1)
b.	Emp_triggers– Add Identity Column (1000,1)
c.	Emphistory
*/
CREATE TABLE	emp_triggers (
				empid Int IDENTITY(1000,1) PRIMARY KEY,
				empname varchar(50) NULL,
				deptid Int NULL
				)


CREATE TABLE	emphistory (
				empid Int NULL,
				deptid Int NULL,
				isactive Int NULL
				)

CREATE	TABLE	dept_triggers (
				deptid Int IDENTITY(1000,1)PRIMARY KEY,
				deptname Varchar(50) NULL
				)

/*
 Trigger 1 - Build a trigger on the emp table after insert that adds a record into the
emp_History table and marks IsActive column to 1
*/
CREATE OR ALTER TRIGGER trg_emp_History 
ON emp_Triggers
AFTER INSERT
AS	
DECLARE	@EmpHistory TABLE
			(EmpID INT,
			 DeptID INT
			)

INSERT INTO @EmpHistory
SELECT		i.EmpID, i.DeptID 
FROM		Inserted i
	
INSERT INTO EmpHistory
SELECT		EmpID,DeptID,1 
FROM		@EmpHistory


INSERT INTO EmpHistory VALUES (8,2, 1)
SELECT	*
FROM	EmpHistory

/*
Trigger 2 – Build a tirgger on the emp table after an update of the empname or deptid
column - It updates the subsequent empname and/or deptid in the emp_history table.
*/
CREATE OR ALTER TRIGGER trg_emp_History_Update
ON emp_Triggers
AFTER UPDATE
AS
DECLARE @EmpID INT
DECLARE	@DeptID INT

SELECT	@EmpID = i.EmpID FROM Inserted i
SELECT	@DeptID = i.DeptID FROM Inserted i

INSERT INTO emphistory 
VALUES (@Empid,@Deptid,1)

/*
Build a trigger on the emp table after delete that marks the isactive status = 0 in the
emp_History table.
*/
CREATE OR ALTER TRIGGER trg_emp_History_Delete
ON emp_Triggers
AFTER DELETE
AS
DECLARE @EmpID INT
DECLARE	@DeptID INT

SELECT	@EmpID = D.EmpID FROM Deleted D
SELECT	@DeptID = D.DeptID FROM Deleted D

INSERT INTO emphistory 
VALUES (@Empid,@Deptid,0)


/*
3.	Run this script – Results should show 10 records in the emp history table all with an active status of 0
*/
INSERT INTO Emp_Triggers
SELECT 'Ali',1000
INSERT INTO Emp_Triggers
SELECT 'Buba',1000
INSERT INTO Emp_Triggers
SELECT 'Cat',1001
INSERT INTO Emp_Triggers
SELECT 'Doggy',1001
INSERT INTO Emp_Triggers
SELECT 'Elephant',1002
INSERT INTO dbo.emp_triggers
SELECT 'Fish',1002
INSERT INTO dbo.emp_triggers
SELECT 'George',1003
INSERT INTO Emp_Triggers
SELECT 'Mike',1003
INSERT INTO Emp_Triggers
SELECT 'Anand',1004
INSERT INTO Emp_Triggers
SELECT 'Kishan',1004
DELETE FROM Emp_Triggers

/*
4. Create 5 views – Each view will use 3 tables and have 9 columns with 3 coming from each table.
	a. Create a view using 3 Human Resources Tables (Utilize the WHERE clause)
*/
SELECT	*
FROM	[HumanResources].[Employee]
SELECT	*
FROM	[HumanResources].[Department]
SELECT	*
FROM	[HumanResources].[EmployeeDepartmentHistory]

CREATE OR ALTER VIEW VW_Human_ResourcesWHERE
AS
SELECT	E.BusinessEntityID, 
		D.DepartmentID,
		DH.ShiftID,
		E.Jobtitle,
		D.Name AS DepartmentName,
		D.GroupName,
		DH.StartDate,
		DH.EndDate,
		E.Gender
FROM	HumanResources.Employee E
JOIN	HumanResources.EmployeeDepartmentHistory DH
ON		E.BusinessEntityID = DH.BusinessEntityID
JOIN	HumanResources.Department D
ON		DH.DepartmentID= D.DepartmentID
WHERE	D.GroupName = 'Manufacturing'

SELECT	*
FROM	VW_Human_ResourcesWHERE

-- Create a view using 3 Person Tables (Utilize 3 system functions)
SELECT	*
FROM	[Person].[Person]
SELECT	*
FROM	[Person].[PersonPhone]
SELECT	*
FROM	[Person].[EmailAddress]

CREATE OR ALTER VIEW VW_Person_SystemFunctions
AS
SELECT	P.BusinessEntityID,
		P.PersonType,
		ISNULL(P.Title, 0) AS NoTitle,
		P.LastName,
		SUBSTRING(PP.PhoneNumber, 0, CHARINDEX('-', PP.PhoneNumber)) As Phone#AreaCode,
		PP.PhoneNumberTypeID,
		EA.EmailAddressID,
		EA.EmailAddress,
		EA.ModifiedDate

FROM	[Person].[Person] P
JOIN	[Person].[PersonPhone] PP
ON		P.BusinessEntityID = PP.BusinessEntityID
JOIN	[Person].[EmailAddress] EA
ON		PP.BusinessEntityID =EA.BusinessEntityID

SELECT	*
FROM	VW_Person_SystemFunctions

-- Create a view using 3 Production Tables (Utilize the Group By Statement)
SELECT	*
FROM	[Production].[Product]
SELECT	*
FROM	[Production].[ProductDescription]
SELECT	*
FROM	[Production].[ProductCostHistory]

CREATE OR ALTER VIEW VW_ProductionGroupBy
AS 
SELECT	P.ProductID,
		P.Name,
		COUNT(P.Color) AS IfColorIsNull,
		p.ProductNumber,
		p.SafetyStockLevel,
		PD.ProductDescriptionID,
		PD.Description,
		PH.StartDate,
		PH.EndDate
FROM	Production.Product P 
JOIN	Production.ProductDescription PD
ON		P.ProductID = PD.ProductDescriptionID
JOIN	Production.ProductCostHistory PH
ON		PD.ProductDescriptionID = PH.ProductID
GROUP BY	P.ProductID, P.Name,p.ProductNumber,p.SafetyStockLevel,PD.ProductDescriptionID,
			PD.Description,PH.StartDate,PH.EndDate
 
SELECT	*
FROM	VW_ProductionGroupBy

-- Create a view using 3 Purchasing Tables (Utilize the HAVING clause)
SELECT	*
FROM	[Purchasing].[ShipMethod]
SELECT	*
FROM	[Purchasing].[PurchaseOrderDetail]
SELECT	*
FROM	[Purchasing].[PurchaseOrderHeader]

CREATE OR ALTER VIEW VW_Purchasing
AS 
SELECT	PD.PurchaseOrderID,
		PD.DueDate,
		SUM(PD.OrderQty) AS OderQty,
		SUM(PD.LineTotal) AS LineTotal,
		PH.EmployeeID,
		PH.ShipMethodID,
		SUM(PH.TotalDue) AS TotalDue,
		PM.Name,
		SUM(PM.Shiprate) AS ShipRate
FROM	[Purchasing].[PurchaseOrderDetail] PD
JOIN	[Purchasing].[PurchaseOrderHeader] PH
ON		PD.PurchaseOrderID = PH.PurchaseOrderID
JOIN	[Purchasing].[ShipMethod] PM
ON		PH.ShipMethodID = PM.ShipMethodID
GROUP BY	PD.PurchaseOrderID, PD.DueDate, PH.EmployeeID, PH.ShipMethodID, PM.Name
HAVING		PD.PurchaseOrderID > 30

SELECT	*
FROM	VW_Purchasing

-- Create a view using 3 Sales Tables (Utilize the CASE Statement)
SELECT	*
FROM	[Sales].[SalesTerritory]
SELECT	*
FROM	[Sales].[SalesOrderDetail]
SELECT	*
FROM	[Sales].[SalesOrderHeader]

CREATE OR ALTER VIEW VW_SalesCase
AS 
SELECT	SD.SalesOrderID,
		T.TerritoryID,
		T.Name,
		T.SalesLastYear,
		CASE WHEN T.SalesLastYear <= 3500000 THEN 'Small Sale'
			 WHEN T.SalesLastYear BETWEEN 3500001 AND 5000000 THEN 'Medium Sale'
			 WHEN T.SalesLastYear >=5000001 THEN 'Large Sale'
		ELSE 'Other'
		END AS SalesLastYearSize,
		SD.OrderQty,
		SD.ProductID,
		SH.AccountNumber,
		SH.BillToAddressID
FROM	Sales.SalesTerritory T
JOIN	Sales.SalesOrderHeader SH
ON		T.TerritoryID = SH.TerritoryID
JOIN	Sales.SalesOrderDetail SD
ON		SH.SalesOrderID = SD.SalesOrderID

SELECT	*
FROM	VW_SalesCase









