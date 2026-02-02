/*
========================================================
 File Name : Scaler_And_TVF_Exercise.sql
 Purpose   : 
 Database  : Northwind
 Author    : Mahdi Davoudi
 Date      : 2026/01/23
========================================================

 Notes:

*/



USE Northwind;
GO
 
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


--- TVF 

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