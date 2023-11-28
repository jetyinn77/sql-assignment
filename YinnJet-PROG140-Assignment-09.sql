--*  PROG 140           Assignment # 9	(Transactions, Locking, and Performance)    DUE DATE:  Consult course calendar
							
/*
PURPOSE:

Knowledge:

�	Describe the way locking and the transaction isolation level help to prevent concurrency problems.
�	Describe the way SQL Server manages locking in terms of granularity, lock escalation, shared locks, exclusive locks, and lock promotion.
�	Describe deadlocks and the way SQL Server handles them.
�	Describe four coding techniques that can reduce deadlocks.
�	Understand tools and techniques to optimize query performance

Skills:

�	Given a set of statements to be combined into a transaction, insert the Transact-SQL statements 
	to explicitly begin, commit, and roll back the transaction.


TASK:

    1. Download the following SQL file and rename it Xxxxx-PROG140-Assignment-09, where Xxxxx is your last and first name. 
	For example, I would rename this file FreebergCarl-PROG140-Assignment-09.sql.

		Xxxxx-PROG140-Assignment-09.sql

    2. Open the file in SQL Server Management Studio (SSMS).

    3. Add your SQL code in the space provided below each question. The questions are written as comments so they will not execute in SQL Server. 

    4. Proofread your document to make sure all questions are answered completely and that it is easy to distinguish your responses from the questions on the page.

    5. Return to this Exercise page, attach your completed file, and submit.

 

CRITERIA:

    o Answer all the questions
    o If you do not understand a question, did you ask for help from the teacher, a classmate, the Discussion board, or a tutor?
    o Your answer/query is in the right place underneath the question
    o Your answer/query is not commented out
    o Your answer/query executes without an error
    o You have renamed the file as specified above and submitted it via Canvas
    o If you cannot complete the Exercise, did you communicate with the teacher (before the due date) so that he/she/they understands your situation?

	
    You are to develop SQL statements for each task listed. You should type your SQL statements under each task.
	The fields' names are written as if a person is asking you for the report. You will need to look at the data
	and understand that list price is in the ListPrice field, for example.
	Add comments to describe your reasoning when you are in doubt about something. 


--- CHAPTER 16 - Transactions, Locking, and Performance -- 
*/

/*
1.	Write a script that includes two SQL statements coded as a transaction to delete the row 
with a customer ID of 8 from the Customers table. 

To do this, you must first delete all addresses for that customer from the Addresses table.
If these statements execute successfully, commit the changes. Otherwise, roll back the changes.
*/
USE MyGuitarShop;
DECLARE @CustomerID int;
SET @CustomerID = 8;

BEGIN TRY
	BEGIN TRAN;

	DELETE Addresses
	WHERE CustomerID = @CustomerID;

	DELETE Customers
	WHERE CustomerID = @CustomerID;

	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH;

/*
2.	Write a script that includes these statements coded as a transaction:
INSERT Orders 
VALUES (3, GETDATE(), '10.00', '0.00', NULL, 4, 
  'American Express', '378282246310005', '04/2019', 4);

SET @OrderID = @@IDENTITY;

INSERT OrderItems 
VALUES (@OrderID, 6, '415.00', '161.85', 1);

INSERT OrderItems 
VALUES (@OrderID, 1, '699.00', '209.70', 1);

Here, the @@IDENTITY variable is used to get the order ID value that�s automatically generated 
when the first INSERT statement inserts an order.
If these statements execute successfully, commit the changes. Otherwise, roll back the changes.
*/
USE MyGuitarShop;
DECLARE @OrderID int;
BEGIN TRY
	BEGIN TRAN;
		INSERT Orders
		VALUES (3, GETDATE() , '10.00', '0.00' , NULL, 4, 'American Express' , '378282246310005' , '04/2019', 4);
		SET @OrderID = @@IDENTITY;
INSERT OrderItems VALUES (@OrderID, 6, '415.00', '161.85', 1);
INSERT OrderItems VALUES (@OrderID, 1, '699.00', '209.70', 1);
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;

/*
3.
You have a colleague that is executing some work in a transaction on the 
Addresses table. She is running her transaction with an isolation level of Serializable.

You need to run a quick query for your boss that groups and counts the number of addresses in each state.

Hint: You only need to query one table.

Write the query below that will execute (and not be blocked):
*/
USE MyGuitarShop;

SELECT State, COUNT(*) AS NumAddresses
FROM Addresses WITH (NOLOCK)
GROUP BY State;


select * from Addresses


/*
Download and execute the CreateNW_2020.sql before answering this question. It is located in Week 01 Resources. This will create the NW2020 database.

4. Consider the following 4-table-join query:

USE NW2020;
GO

SELECT 
	S.ShipperID
	,S.CompanyName
	,O.OrderID
	,O.ShippedDate
	,EMP.EmployeeID
	,EMP.LastName
	,O.CustomerID
	,C.CompanyName
FROM Shippers AS S
	INNER JOIN Orders AS O
	ON O.SHIPVIA = S.ShipperID
		INNER JOIN Employees AS EMP
		ON EMP.EmployeeID = O.EmployeeID
			INNER JOIN Customers AS C
			ON C.CustomerID = O.CustomerID
ORDER BY S.ShipperID ASC, O.ShippedDate DESC;


Perform the following steps:
a)  Display an estimated execution plan (Highlight the query, go to your Query menu, select "Display Estimated Execution Plan")
b)  Study the execution plan - write it down, make a screenshot, look up what the icons mean, so that you understand this as much as you can.  
	(https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference?view=sql-server-2017)
c)  Execute the following code to create an index:
		
			CREATE NONCLUSTERED INDEX idxOrdersShipVia
				ON [dbo].[Orders] ([ShipVia])
				INCLUDE ([OrderID],[CustomerID],[EmployeeID],[ShippedDate])

d)  Do step a again, ie., display the estimated execution plan 
e)  Discuss below how the index changed (or did not change) the execution plan for the query.  Discuss whether or not you 
		think this index should be permanently implemented on the NW2020 database. 
*/
USE [NorthWind]; 


CREATE NONCLUSTERED INDEX idxOrdersShipVia
		ON [dbo].[Orders] ([ShipVia])
		INCLUDE ([OrderID], [CustomerID], [EmployeeID],[ShippedDate])
SELECT
	S.ShipperID
	,S.CompanyName
	,O.OrderID
	,O.ShippedDate
	,EMP.EmployeeID
	,EMP.LastName
	,O.CustomerID
	,C.CompanyName
FROM [dbo].[Shippers] AS S
		INNER JOIN Orders AS O
		ON O.SHIPVIA = S.ShipperID
			INNER JOIN Employees AS EMP
			ON EMP.EmployeeID = O.EmployeeID
				INNER JOIN Customers AS C
				ON C.CustomerID = O.CustomerID
ORDER BY S.ShipperID ASC, O.ShippedDate DESC;

DROP INDEX idxOrdersShipVia ON Orders

/* 
5. List 3 SQL optimization/performance tips. From the Week 9 lecture. 
*/
---1. Good Database Design
---2. Use joins instead of subqueries when possible
---3. Limit nesting of objects like views, sprocs



-- END of Assignment






