-- #############################
-- RESET Database
-- #############################
DROP PROCEDURE IF EXISTS sp_ResetDatabase;

DELIMITER //
CREATE PROCEDURE sp_ResetDatabase()
BEGIN
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
    -- Insert 'None' genre as the very first genre
    INSERT INTO Genres (genreName, genreDescription) VALUES ('None', 'Default genre for unassigned board games.');

    -- BoardGames table: Records details about the board games.
    CREATE TABLE BoardGames (
        boardGameID INT NULL AUTO_INCREMENT,
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

    -- Insert other genres after 'None' is guaranteed to be genreID=1
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
END //
DELIMITER ;

-- CUSTOMERS
-- #############################
-- CREATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //
CREATE PROCEDURE sp_CreateCustomer(
    IN p_firstName VARCHAR(255),
    IN p_lastName VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phoneNumber VARCHAR(255),
    OUT p_customerID INT
)
BEGIN
    INSERT INTO Customers (firstName, lastName, email, phoneNumber)
    VALUES (p_firstName, p_lastName, p_email, p_phoneNumber);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() INTO p_customerID;
    -- Display the ID of the last inserted customer
    SELECT LAST_INSERT_ID() AS 'new_customer_id';
END //
DELIMITER ;

-- #############################
-- UPDATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customerID INT,
    IN p_firstName VARCHAR(255),
    IN p_lastName VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phoneNumber VARCHAR(255)
)
BEGIN
    UPDATE Customers
    SET firstName = p_firstName,
        lastName = p_lastName,
        email = p_email,
        phoneNumber = p_phoneNumber
    WHERE customerID = p_customerID;
END //
DELIMITER ;

-- #############################
-- DELETE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //
CREATE PROCEDURE sp_DeleteCustomer(IN p_customerID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasRentals WHERE rentalID IN (SELECT rentalID FROM Rentals WHERE customerID = p_customerID);
        DELETE FROM StocksHasOrders WHERE orderID IN (SELECT orderID FROM Orders WHERE customerID = p_customerID);
        DELETE FROM Rentals WHERE customerID = p_customerID;
        DELETE FROM Orders WHERE customerID = p_customerID;
        DELETE FROM Customers WHERE customerID = p_customerID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in Customers for customerID: ', p_customerID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- ORDERS
-- #############################
-- CREATE Order
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateOrder;

DELIMITER //
CREATE PROCEDURE sp_CreateOrder(
    IN p_orderDate DATE,
    IN p_customerId INT,
    OUT p_orderID INT
)
BEGIN
    INSERT INTO Orders (orderDate, customerID)
    VALUES (p_orderDate, p_customerId);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() INTO p_orderID;
    -- Display the ID of the last inserted order
    SELECT LAST_INSERT_ID() AS 'new_order_id';

END //
DELIMITER ;

-- #############################
-- UPDATE Orders
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateOrder;

DELIMITER //
CREATE PROCEDURE sp_UpdateOrder(
    IN p_orderID INT,
    IN p_orderDate DATE
)
BEGIN
    UPDATE Orders
    SET orderDate = p_orderDate
    WHERE orderID = p_orderID;
END //
DELIMITER ;

-- #############################
-- DELETE Orders
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteOrder;

DELIMITER //
CREATE PROCEDURE sp_DeleteOrder(IN p_orderID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasOrders WHERE orderID = p_orderID;
        DELETE FROM Orders WHERE orderID = p_orderID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in Orders for orderID: ', p_orderID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- RENTALS
-- #############################
-- CREATE Rental
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateRental;

DELIMITER //
CREATE PROCEDURE sp_CreateRental(
    IN p_rentalDate DATE,
    IN p_customerID INT,
    OUT p_rentalID INT
)
BEGIN
    INSERT INTO Rentals (rentalDate, customerID)
    VALUES (p_rentalDate, p_customerID);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() INTO p_rentalID;
    -- Display the ID of the last inserted rental
    SELECT LAST_INSERT_ID() AS 'new_rental_id';

    -- Add order to customer's total
    UPDATE Customers SET currentRented = currentRented + 1
    WHERE customerID = p_customerID;

    -- Decrease # rented 1, decrease stock
    UPDATE Stocks SET numItem = numItem - 1
    WHERE stockID = 
    (SELECT stockID FROM StocksHasRentals WHERE rentalID = p_rentalID);
    UPDATE Stocks SET numRented = numRented + 1
    WHERE stockID = 
    (SELECT stockID FROM StocksHasRentals WHERE rentalID = p_rentalID);

END //
DELIMITER ;

-- #############################
-- UPDATE Rentals
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateRental;

DELIMITER //
CREATE PROCEDURE sp_UpdateRental(
    IN p_rentalID INT,
    IN p_rentalDate DATE,
    IN p_returnDate DATE
)
BEGIN
    UPDATE Rentals
    SET 
    rentalDate = p_rentalDate, 
    returnDate = p_returnDate
    WHERE rentalID = p_rentalID;
END //
DELIMITER ;

-- #############################
-- DELETE Rentals
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteRental;

DELIMITER //
CREATE PROCEDURE sp_DeleteRental(IN p_rentalID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasRentals WHERE rentalID = p_rentalID;
        DELETE FROM Rentals WHERE rentalID = p_rentalID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in Orders for orderID: ', p_rentalID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- StocksHasOrders
-- #############################
-- UPDATE StocksHasOrders
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateStocksHasOrders;

DELIMITER //
CREATE PROCEDURE sp_UpdateStocksHasOrders(
    IN p_stockID INT,
    IN p_orderID INT
)
BEGIN
    UPDATE StocksHasOrders
    SET orderID = p_orderID
    WHERE stockID = p_stockID;
END //
DELIMITER ;

-- -- #############################
-- -- DELETE StocksHasOrders
-- -- #############################
-- DROP PROCEDURE IF EXISTS sp_DeleteStocksHasOrders;

-- DELIMITER //
-- CREATE PROCEDURE sp_DeleteStocksHasOrders(IN p_stockID INT, IN p_orderID INT)
-- BEGIN
--     DECLARE error_message VARCHAR(255);
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION
--     BEGIN
--         ROLLBACK;
--         RESIGNAL;
--     END;
--     START TRANSACTION;
--         DELETE FROM StocksHasOrders WHERE orderID = p_orderID AND stockID = p_stockID;
--         IF ROW_COUNT() = 0 THEN
--             SET error_message = CONCAT('No matching record found in StocksHasOrders for orderID: ', p_orderID);
--             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
--         END IF;
--     COMMIT;
-- END //
-- DELIMITER ;

-- StocksHasRentals
-- #############################
-- UPDATE StocksHasRentals
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateStocksHasRentals;

DELIMITER //
CREATE PROCEDURE sp_UpdateStocksHasRentals(
    IN p_stockID INT,
    IN p_rentalID INT
)
BEGIN
    UPDATE StocksHasRentals
    SET rentalID = p_rentalID
    WHERE stockID = p_stockID;
END //
DELIMITER ;

-- -- #############################
-- -- DELETE StocksHasRentals
-- -- #############################
-- DROP PROCEDURE IF EXISTS sp_DeleteStocksHasRentals;

-- DELIMITER //
-- CREATE PROCEDURE sp_DeleteStocksHasRentals(IN p_stockID INT, IN p_rentalID INT)
-- BEGIN
--     DECLARE error_message VARCHAR(255);
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION
--     BEGIN
--         ROLLBACK;
--         RESIGNAL;
--     END;
--     START TRANSACTION;
--         DELETE FROM StocksHasRentals WHERE rentalID = p_rentalID AND stockID = p_stockID;
--         IF ROW_COUNT() = 0 THEN
--             SET error_message = CONCAT('No matching record found in StocksHasRentals for orderID: ', p_rentalID);
--             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
--         END IF;
--     COMMIT;
-- END //
-- DELIMITER ;

-- Stocks
-- #############################
-- UPDATE Stocks
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateStock;

DELIMITER //
CREATE PROCEDURE sp_UpdateStock(
    IN p_stockID INT,
    IN p_numItem INT,
    IN p_numRented INT
)
BEGIN
    UPDATE Stocks 
    SET
    numItem = p_numItem, 
    numRented = p_numRented
    WHERE stockID = p_stockID;
END //
DELIMITER ;

-- -- #############################
-- -- DELETE Stocks
-- -- #############################
-- DROP PROCEDURE IF EXISTS sp_DeleteStock;

-- DELIMITER //
-- CREATE PROCEDURE sp_DeleteStock(p_stockID INT)
-- BEGIN
--     DECLARE error_message VARCHAR(255);
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION
--     BEGIN
--         ROLLBACK;
--         RESIGNAL;
--     END;
--     START TRANSACTION;
--         DELETE FROM Stocks WHERE stockID = p_stockID;
--         IF ROW_COUNT() = 0 THEN
--             SET error_message = CONCAT('No matching record found in stocks for stockID: ', p_stockID);
--             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
--         END IF;
--     COMMIT;
-- END //
-- DELIMITER ;

-- BOARD GAMES
-- #############################
-- CREATE Board Game
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateBoardGame;

DELIMITER //
CREATE PROCEDURE sp_CreateBoardGame(
    IN p_gameName VARCHAR(200),
    IN p_genreID INT,
    IN p_numPlayer VARCHAR(10),
    IN p_gamePrice DECIMAL(19,2),
    OUT p_gameID INT
)
BEGIN
    INSERT INTO BoardGames (gameName, genreID, numPlayer, gamePrice)
    VALUES (p_gameName, p_genreID, p_numPlayer, p_gamePrice);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() INTO p_gameID;

    INSERT INTO Stocks (boardGameID, numItem, numRented)
    VALUES (p_gameID, 0, 0);

    -- Display the ID of the last inserted rental
    SELECT LAST_INSERT_ID() AS 'new_board_game_id';

END //
DELIMITER ;

-- #############################
-- UPDATE BoardGame
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateBoardGame;

DELIMITER //
CREATE PROCEDURE sp_UpdateBoardGame(
    IN p_boardGameID INT,
    IN p_genreID INT,
    IN p_numPlayer VARCHAR(10),
    IN p_gamePrice DECIMAL(19,2)
)
BEGIN
    UPDATE BoardGames
    SET
    genreID = p_genreID, 
    numPlayer = p_numPlayer,
    gamePrice = p_gamePrice
    WHERE boardGameID = p_boardGameID;
END //
DELIMITER ;

-- #############################
-- DELETE BoardGames
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteBoardGame;

DELIMITER //
CREATE PROCEDURE sp_DeleteBoardGame(IN p_boardGameID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasOrders WHERE stockID = (SELECT stockID FROM Stocks WHERE boardGameID = p_boardGameID);
        DELETE FROM StocksHasRentals WHERE stockID = (SELECT stockID FROM Stocks WHERE boardGameID = p_boardGameID);
        DELETE FROM Stocks WHERE stockID = (SELECT stockID FROM Stocks WHERE boardGameID = p_boardGameID);
        DELETE FROM BoardGames WHERE boardGameID = p_boardGameID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in boardGame for boardGameID: ', p_boardGameID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- GENRES
-- #############################
-- CREATE Genres
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateGenres;

DELIMITER //
CREATE PROCEDURE sp_CreateGenres(
    IN p_genreName VARCHAR(45),
    IN p_genreDescription VARCHAR(600)
)
BEGIN
    INSERT INTO Genres (genreName, genreDescription)
    VALUES (p_genreName, p_genreDescription);
END //
DELIMITER ;

-- #############################
-- UPDATE Genres
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateGenres;

DELIMITER //
CREATE PROCEDURE sp_UpdateGenres(
    IN p_genreID INT,
    IN p_genreName VARCHAR(45),
    IN p_genreDescription VARCHAR(600)
)
BEGIN
    UPDATE Genres
    SET
    genreDescription = p_genreDescription,
    genreName = p_genreName
    WHERE genreID = p_genreID;
END //
DELIMITER ;

-- #############################
-- DELETE Genre
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteGenre;

DELIMITER //
CREATE PROCEDURE sp_DeleteGenre(IN p_genreID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE none_genre_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM Genres WHERE genreName = 'None') THEN
            INSERT INTO Genres (genreName, genreDescription) VALUES ('None', 'Default genre for unassigned board games.');
        END IF;
        SELECT genreID INTO none_genre_id FROM Genres WHERE genreName = 'None' LIMIT 1;
        UPDATE BoardGames SET genreID = none_genre_id WHERE genreID = p_genreID;
        DELETE FROM Genres WHERE genreID = p_genreID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in genre for genreID: ', p_genreID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;
