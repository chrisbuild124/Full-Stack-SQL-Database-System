-- get all Genres to populate the Genre dropdown
SELECT genreID, genreName FROM Genres;

-- get all Board Games and their Genre for the List Board Games page
SELECT BoardGames.boardGameID AS id, gameName, numPlayer, gamePrice, Genres.genreName AS genre \
FROM BoardGames \
INNER JOIN Genres ON BoardGames.genreID = Genres.genreID;

-- get a single Board Game's data for the Update Board Game form
SELECT boardGameID AS id, gameName, genreID, numPlayer, gamePrice FROM BoardGames WHERE boardGameID = :boardGameID;

-- get all Board Games to populate a dropdown for associating with a Stock
SELECT boardGameID AS id, gameName FROM BoardGames;

-- get all Stocks and their associated Board Games for the List Stocks page
SELECT Stocks.stockID, BoardGames.gameName, Stocks.numItem, Stocks.numRented \
FROM Stocks \
INNER JOIN BoardGames ON Stocks.boardGameID = BoardGames.boardGameID;

-- add a new Board Game
INSERT INTO BoardGames (gameName, genreID, numPlayer, gamePrice) VALUES (:gameName, :genreID, :numPlayer, :gamePrice);

-- update a Board Game's data based on submission of the Update Board Game form
UPDATE BoardGames SET genreID = :genreID, numPlayer = :numPlayer, gamePrice = :gamePrice WHERE boardGameID = :boardGameID;

-- delete a Board Game
DELETE FROM BoardGames WHERE boardGameID = :boardGameID;

-- add a new Stock
INSERT INTO Stocks (boardGameID, numItem, numRented) VALUES (:boardGameID, :numItem, :numRented);

-- update a Stock's data based on submission of the Update Stock form
UPDATE Stocks SET numItem = :numItem, numRented = :numRented WHERE stockID = :stockID;

-- delete a Stock
DELETE FROM Stocks WHERE stockID = :stockID;

-- get all Customers for the List Customers page
SELECT customerID, firstName, lastName, email, phoneNumber FROM Customers;

-- get a single Customer's data for the Update Customer form
SELECT customerID, firstName, lastName, email, phoneNumber FROM Customers WHERE customerID = :customerID;

-- add a new Customer
INSERT INTO Customers (firstName, lastName, email, phoneNumber) VALUES (:firstName, :lastName, :email, :phoneNumber);

-- update a Customer's data based on submission of the Update Customer form
UPDATE Customers SET firstName = :firstName, lastName = :lastName, email = :email, phoneNumber = :phoneNumber WHERE customerID = :customerID;

-- delete a Customer
DELETE FROM Customers WHERE customerID = :customerID;

-- get all Orders and their associated Customers for the List Orders page
SELECT Orders.orderID, orderDate, CONCAT(Customers.firstName, ' ', Customers.lastName) AS customerName, Customers.email AS customerEmail \
FROM Orders \
INNER JOIN Customers ON Orders.customerID = Customers.customerID;

-- get a single Order's data for the Update Order form
SELECT orderID, orderDate, customerID FROM Orders WHERE orderID = :orderID;

-- add a new Order
INSERT INTO Orders (orderDate, customerID) VALUES (:orderDate, :customerID);

-- update an Order's data based on submission of the Update Order form
UPDATE Orders SET orderDate = :orderDate, customerID = :customerID WHERE orderID = :orderID;

-- delete an Order
DELETE FROM Orders WHERE orderID = :orderID;

-- get all Rentals and their associated Customers for the List Rentals page
SELECT Rentals.rentalID, rentalDate, returnDate, CONCAT(Customers.firstName, ' ', Customers.lastName) AS customerName, Customers.email AS customerEmail \
FROM Rentals \
INNER JOIN Customers ON Rentals.customerID = Customers.customerID;

-- get a single Rental's data for the Update Rental form
SELECT rentalID, rentalDate, returnDate, customerID FROM Rentals WHERE rentalID = :rentalID;

-- add a new Rental
INSERT INTO Rentals (rentalDate, returnDate, customerID) VALUES (:rentalDate, :returnDate, :customerID);

-- update a Rental's data based on submission of the Update Rental form
UPDATE Rentals SET rentalDate = :rentalDate, returnDate = :returnDate, customerID = :customerID WHERE rentalID = :rentalID;

-- delete a Rental
DELETE FROM Rentals WHERE rentalID = :rentalID;