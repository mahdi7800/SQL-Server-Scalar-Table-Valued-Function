/*
========================================================
 File Name : Scaler_And_TVF_Exercise.sql
 Purpose   : Practice Scalar and Table-Valued Functions in SQL Server
 Database  : Northwind
 Author    : Mahdi Davoudi
 Date      : 2026/01/23
========================================================

 Notes:
 - Demonstrates how to create a Scalar Function to calculate 
   product profit for a given order and product.
 - Demonstrates how to create a Table-Valued Function (TVF) 
   to list all orders of a customer with profit per product

*/


-- Set the database context to Northwind

USE Northwind;
GO

/*
========================================================
 1️⃣ Scalar Function: dbo.fn_ProductProfit
========================================================
 Purpose: Calculate the profit of a specific product in a specific order.
 Parameters:
   @OrderID   -> ID of the order
   @ProductID -> ID of the product
 Returns:
   Profit as MONEY
 Notes:
   Profit = Quantity * UnitPrice * (1 - Discount)
*/
 
CREATE OR ALTER  FUNCTION dbo.fn_ProductProfit (@OrderID int , @ProductID int)
RETURNS  money
AS 
BEGIN 
     DECLARE @Profit money 

     SELECT @Profit = (OD.Quantity * OD.UnitPrice) * (1 - OD.Discount) 
     FROM [Order Details] AS OD 
     WHERE OrderID = @OrderID AND OD.ProductID = @ProductID

     RETURN ISNULL(@Profit , 0 )
END 
GO 


SELECT dbo.fn_ProductProfit(10248,11) AS Profit
GO 


/*
========================================================
 2️⃣ Table-Valued Function: dbo.fn_CustomerOrdersProfit
========================================================
 Purpose: Return all orders of a customer with profit per product.
 Parameters:
   @CustomerID -> ID of the customer (char(5))
 Returns:
   Table containing:
     OrderID, OrderDate, ProductID, Quantity, UnitPrice, Discount, Profit
 Notes:
   Calls dbo.fn_ProductProfit for each product in customer's orders.
*/

CREATE OR ALTER FUNCTION dbo.fn_CutomerOrdersProfit (@CutomerID char(5) )
RETURNS TABLE 
AS 
RETURN 
        
           SELECT O.OrderID , O.OrderDate , P.ProductID , OD.Quantity , OD.UnitPrice , OD.Discount , 
                  dbo.fn_ProductProfit(O.OrderID ,P.ProductID) AS Profit
           FROM Orders AS O INNER JOIN Customers AS C ON O.CustomerID = C.CustomerID
                            INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
                            INNER JOIN Products AS P ON OD.ProductID = P.ProductID
           WHERE O.CustomerID = @CutomerID    
      
GO 

SELECT *
FROM dbo.fn_CutomerOrdersProfit('ALFKI')
GO 