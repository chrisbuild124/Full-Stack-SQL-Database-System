-- Group 113: Chris Sexton & Shane Bliss

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS StocksHasRentals;
DROP TABLE IF EXISTS StocksHasOrders;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Stocks;
DROP TABLE IF EXISTS BoardGames;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Genres;

-- Genres table: The genre of a board game (e.g., strategy, card game)
CREATE TABLE Genres (
    genreID INT NOT NULL AUTO_INCREMENT,
    genreName VARCHAR(45) NOT NULL UNIQUE,
    genreDescription VARCHAR(600),
    PRIMARY KEY (genreID)
);

-- BoardGames table: Records details about the board games.
CREATE TABLE BoardGames (
    boardGameID INT NOT NULL AUTO_INCREMENT,
    genreID INT NOT NULL,
    gameName VARCHAR(200) NOT NULL,
    numPlayer VARCHAR(10) NOT NULL,
    gamePrice DECIMAL(19,2),
    PRIMARY KEY (boardGameID),
    FOREIGN KEY (genreID) REFERENCES Genres (genreID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Customers table: Records details about customers of the store.
CREATE TABLE Customers (
    customerID INT NOT NULL AUTO_INCREMENT,
    firstName VARCHAR(45) NOT NULL,
    lastName VARCHAR(45) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phoneNumber VARCHAR(30),
    currentRented INT NOT NULL DEFAULT 0,
    PRIMARY KEY (customerID)
);

-- Orders table: Records details about orders made by customers.
CREATE TABLE Orders (
    orderID INT NOT NULL AUTO_INCREMENT,
    orderDate DATE NOT NULL,
    customerID INT NOT NULL,
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID) REFERENCES Customers (customerID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Rentals table: Records details about rentals made by customers.
CREATE TABLE Rentals (
    rentalID INT NOT NULL AUTO_INCREMENT,
    rentalDate DATE NOT NULL,
    returnDate DATE,
    customerID INT NOT NULL,
    PRIMARY KEY (rentalID),
    FOREIGN KEY (customerID) REFERENCES Customers (customerID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Stocks table: Records the details corresponding to items within the store's stock.
CREATE TABLE Stocks (
    stockID INT NOT NULL AUTO_INCREMENT,
    boardGameID INT NOT NULL,
    numItem INT,
    numRented INT,
    PRIMARY KEY (stockID),
    FOREIGN KEY (boardGameID) REFERENCES BoardGames (boardGameID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- StocksHasRentals table: Links stocks to their rentals.
CREATE TABLE StocksHasRentals (
    stockID INT NOT NULL,
    rentalID INT NOT NULL,
    FOREIGN KEY (stockID) REFERENCES Stocks (stockID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (rentalID) REFERENCES Rentals (rentalID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- StocksHasOrders table: Links stocks to their orders.
CREATE TABLE StocksHasOrders (
    stockID INT NOT NULL,
    orderID INT NOT NULL,
    FOREIGN KEY (stockID) REFERENCES Stocks (stockID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (orderID) REFERENCES Orders (orderID) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Test values are being inserted here in the next queries. 
INSERT INTO Customers 
    (firstName, lastName, email, phoneNumber, currentRented)
VALUES
    ('Shane', 'Bliss', 'shaneB@gmail.com', '1-428-733-5028', 0),
    ('Chris', 'Sexton', 'chrSexton@gmail.com', '593-343-7490', 1),
    ('Michael', 'Curry', 'mCurry@gmail.com', NULL, 0),
    ('Danielle', 'Safonte', 'dSafonte@oregonstate.edu', '58', 1);

INSERT INTO Orders
    (orderDate, customerID)
VALUES
    ('2025-04-21', (SELECT customerID FROM Customers WHERE email = 'shaneB@gmail.com')),
    ('2025-04-22', (SELECT customerID FROM Customers WHERE email = 'chrSexton@gmail.com')),
    ('2025-04-23', (SELECT customerID FROM Customers WHERE email = 'mCurry@gmail.com')),
    ('2025-04-24', (SELECT customerID FROM Customers WHERE email = 'dSafonte@oregonstate.edu')),
    ('2025-04-29', (SELECT customerID FROM Customers WHERE email = 'mCurry@gmail.com'));

INSERT INTO Rentals
    (rentalDate, returnDate, customerID)
VALUES
    ('2025-04-21', '2025-04-24', (SELECT customerID FROM Customers WHERE email = 'shaneB@gmail.com')),
    ('2025-04-22', NULL, (SELECT customerID FROM Customers WHERE email = 'chrSexton@gmail.com')),
    ('2025-04-23',  '2025-04-23', (SELECT customerID FROM Customers WHERE email = 'chrSexton@gmail.com')),
    ('2025-04-25', NULL, (SELECT customerID FROM Customers WHERE email = 'dSafonte@oregonstate.edu'));

INSERT INTO Genres
    (genreName, genreDescription)
VALUES
    ('Strategy', "A strategy game is a game in which the players' decision-making skills have a high significance
    in determining the outcome. Strategy games often require decision tree analysis, or probabilistic estimation 
    in the case of games with chance elements. Strategy games include abstract games, with artificial rules 
    and little or no theme, and simulations (including wargames), with rules designed to emulate and 
    reproduce a real or fictional scenario."),
    ('Thematic', 'Thematic Games contain a strong theme which drives the overall game experience, creating 
    a dramatic story ("narrative") similar to a book or action movie. This type of game often features player 
    to player direct conflict (with the chance of elimination), dice rolling, and plastic miniatures.'),
    ('Family', 'Family games are often created with a varied demographic in mind, so anyone aged 8-80 can play. 
    The themes of these games can vary, but overall they tend to have a simple game play structure with clear 
    and easy to understand rules that can be learnt and explained in a short amount of time. They allow 
    everyone to join in for a fun game night.'),
    ('Dexterity', "Dexterity games often compete players' physical reflexes and co-ordination as 
    a determinant of overall success."),
    ('Cards', 'Card Games use cards as its sole or central component. There are stand-alone card games, 
    in which all the cards necessary for gameplay are purchased at once.');

INSERT INTO BoardGames
    (genreID, gameName, numPlayer, gamePrice)
VALUES
    ((SELECT genreID FROM Genres WHERE genreName = 'Strategy'), 'Brass: Birmingham', '2-4', 69.99),
    ((SELECT genreID FROM Genres WHERE genreName = 'Thematic'), 'Pandemic Legacy: Season 1', '2-4', 71.99),
    ((SELECT genreID FROM Genres WHERE genreName = 'Dexterity'), 'KLASK', '2', 59.99),
    ((SELECT genreID FROM Genres WHERE genreName = 'Strategy'), 'Wingspan', '1-5', 59.99);

INSERT INTO Stocks
    (boardGameID, numItem, numRented)
VALUES
    ((SELECT boardGameID FROM BoardGames WHERE boardGameID = 1), 50, 21),
    ((SELECT boardGameID FROM BoardGames WHERE boardGameID = 2), 32, 10),
    ((SELECT boardGameID FROM BoardGames WHERE boardGameID = 3), 79, 5),
    ((SELECT boardGameID FROM BoardGames WHERE boardGameID = 4), 12, 12);

INSERT INTO StocksHasRentals
    (stockID, rentalID)
VALUES
    ((SELECT stockID FROM Stocks WHERE stockID = 1), (SELECT rentalID from Rentals WHERE rentalID = 1)),
    ((SELECT stockID FROM Stocks WHERE stockID = 2), (SELECT rentalID from Rentals WHERE rentalID = 2)),
    ((SELECT stockID FROM Stocks WHERE stockID = 1), (SELECT rentalID from Rentals WHERE rentalID = 3)),
    ((SELECT stockID FROM Stocks WHERE stockID = 4), (SELECT rentalID from Rentals WHERE rentalID = 4));

INSERT INTO StocksHasOrders
    (stockID, orderID)
VALUES
    ((SELECT stockID FROM Stocks WHERE stockID = 3), (SELECT orderID from Orders WHERE orderID = 1)),
    ((SELECT stockID FROM Stocks WHERE stockID = 4), (SELECT orderID from Orders WHERE orderID = 2)),
    ((SELECT stockID FROM Stocks WHERE stockID = 1), (SELECT orderID from Orders WHERE orderID = 3)),
    ((SELECT stockID FROM Stocks WHERE stockID = 2), (SELECT orderID from Orders WHERE orderID = 4)),
    ((SELECT stockID FROM Stocks WHERE stockID = 3), (SELECT orderID from Orders WHERE orderID = 5));

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;