-- Group 113 Shane Bliss & Chris Sexton --

SET FOREIGN_KEY_CHECKS = 1;  -- Used so delete can properly delete


-- Board Games Web Page (CRUD)
INSERT INTO BoardGames (gameName, genreID, numPlayer, gamePrice) VALUES (:gameName, :genreID, :numPlayer, :gamePrice);  -- For creating a board game
SELECT BoardGames.boardGameID AS id, gameName, numPlayer, gamePrice, Genres.genreName AS genre \
FROM BoardGames \
INNER JOIN Genres ON BoardGames.genreID = Genres.genreID;  -- For the Board Game Table
SELECT boardGameID AS id, gameName, genreID, numPlayer, gamePrice FROM BoardGames WHERE boardGameID = :boardGameID;  -- For Update Board Game form
UPDATE BoardGames SET genreID = :genreID, numPlayer = :numPlayer, gamePrice = :gamePrice WHERE boardGameID = :boardGameID;  -- Update Board Game
DELETE FROM BoardGames WHERE boardGameID = :boardGameID;  -- Delete a boardgame button


-- Genres Web Page (CRUD)
INSERT INTO Genres (genreName, genreDescription) VALUES (:genreName, :genreDescription);  -- For creating a genre
SELECT Genres.genreID AS id, genreName, genreDescription from Genres;  -- For the Genres Table
SELECT genreID, genreName FROM Genres;  -- For Update Genres form
SELECT genreID AS id, genreName, genreDescription FROM Genres WHERE genreID = :genreID;  -- For Update Genre form
UPDATE Genres SET genreName = :genreName, genreDescription = :genreDescription WHERE genreID = :genreID;  -- Update Genre
DELETE FROM Genres WHERE genreID = :genreID;  -- Delete a genre button


-- Customers Web Page (CRUD)
INSERT INTO Customers (firstName, lastName, email, phoneNumber) VALUES (:firstName, :lastName, :email, :phoneNumber);  -- For creating a customer
SELECT customerID, firstName, lastName, email, phoneNumber FROM Customers;  -- For the Customers Table
SELECT customerID, firstName, lastName, email, phoneNumber FROM Customers WHERE customerID = :customerID;  -- For Update Customer form
UPDATE Customers SET firstName = :firstName, lastName = :lastName, email = :email, phoneNumber = :phoneNumber WHERE customerID = :customerID;  -- Update Customer
DELETE FROM Customers WHERE customerID = :customerID;  -- Delete a Customer button


-- Orders Web Page (CRUD)
INSERT INTO Orders (orderDate, customerID) VALUES (:orderDate, :customerID);  -- For creating an Order
SELECT Orders.orderID, orderDate, CONCAT(Customers.firstName, ' ', Customers.lastName) AS customerName, Customers.email AS customerEmail \
FROM Orders \
INNER JOIN Customers ON Orders.customerID = Customers.customerID;  -- For the List Orders Table
SELECT orderID, orderDate, customerID FROM Orders WHERE orderID = :orderID;  -- For Update Order's form
UPDATE Orders SET orderDate = :orderDate, customerID = :customerID WHERE orderID = :orderID;  -- Update Order
DELETE FROM Orders WHERE orderID = :orderID;  -- Delete an Order button


-- Rentals Web Page (CRUD)
INSERT INTO Rentals (rentalDate, returnDate, customerID) VALUES (:rentalDate, :returnDate, :customerID);  -- For creating a Rental
SELECT Rentals.rentalID, rentalDate, returnDate, CONCAT(Customers.firstName, ' ', Customers.lastName) AS customerName, Customers.email AS customerEmail \
FROM Rentals \
INNER JOIN Customers ON Rentals.customerID = Customers.customerID;  -- For the Rentals Table
SELECT rentalID, rentalDate, returnDate, customerID FROM Rentals WHERE rentalID = :rentalID;  -- For Update Rental's form
UPDATE Rentals SET rentalDate = :rentalDate, returnDate = :returnDate, customerID = :customerID WHERE rentalID = :rentalID;  -- Update Rentals
DELETE FROM Rentals WHERE rentalID = :rentalID;  -- Delete a Rental button


-- Stocks Web Page (CRUD)
INSERT INTO Stocks (boardGameID, numItem, numRented) VALUES (:boardGameID, :numItem, :numRented);  -- For creating a Stock
SELECT Stocks.stockID, BoardGames.gameName, Stocks.numItem, Stocks.numRented \
FROM Stocks \
INNER JOIN BoardGames ON Stocks.boardGameID = BoardGames.boardGameID;  -- For the Stocks Table
SELECT boardGameID AS id, gameName FROM BoardGames;  -- For Update boardGame form
UPDATE Stocks SET numItem = :numItem, numRented = :numRented WHERE stockID = :stockID;  -- Update Stocks
DELETE FROM Stocks WHERE stockID = :stockID;  -- Delete a stock button


-- Stocks Has Orders Web Page (RUD)
SELECT stockID, orderID FROM StocksHasOrders;  -- For the Stocks Has Orders Table
SELECT stockID AS id FROM StocksHasOrders;  -- For Update Stock Has Orders form
SELECT orderID AS id FROM StocksHasOrders;  -- For Update Stock Has Orders form
UPDATE StocksHasOrders SET stockID = :stockID, orderID = :orderID WHERE stockID = :stockID;  -- Update Stocks Has Orders
DELETE FROM StocksHasOrders WHERE stockID = :stockID AND orderID = :orderID;  -- Delete a Stocks Has Orders button


-- Stocks Has Rentals Web Page (RUD)
SELECT stockID, rentalID FROM StocksHasRentals;  -- For the Stocks Has Rentals Table
SELECT stockID AS id FROM StocksHasRentals;  -- For Update Stock Has Rentals form
SELECT rentalID AS id FROM StocksHasRentals;  -- For Update Stock Has Rentals form
UPDATE StocksHasRentals SET stockID = :stockID, rentalID = :rentalID WHERE stockID = :stockID;  -- Update Stocks Has Rentals
DELETE FROM StocksHasRentals WHERE stockID = :stockID AND rentalID = :rentalID;  -- Delete a Stocks Has Orders button

SET FOREIGN_KEY_CHECKS = 1; -- Reset to checking foreign keys after program is run