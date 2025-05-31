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

-- #############################
-- DELETE StocksHasOrders
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteStocksHasOrders;

DELIMITER //
CREATE PROCEDURE sp_DeleteStocksHasOrders(IN p_stockID INT, IN p_orderID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasOrders WHERE orderID = p_orderID AND stockID = p_stockID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in StocksHasOrders for orderID: ', p_orderID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

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

-- #############################
-- DELETE StocksHasRentals
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteStocksHasRentals;

DELIMITER //
CREATE PROCEDURE sp_DeleteStocksHasRentals(IN p_stockID INT, IN p_rentalID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM StocksHasRentals WHERE rentalID = p_rentalID AND stockID = p_stockID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in StocksHasRentals for orderID: ', p_rentalID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

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
    IN gameID INT,
    IN genreID INT,
    IN p_numPlayer VARCHAR(10),
    IN gamePrice DECIMAL(19,2)
)
BEGIN
    UPDATE BoardGames
    SET
    genreID = p_genreID, 
    numPlayer = p_numPlayer,
    gamePrice = p_gamePrice
    WHERE gameID = p_gameID;
END //
DELIMITER ;

-- #############################
-- DELETE BoardGames
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteBoardGame;

DELIMITER //
CREATE PROCEDURE sp_DeleteBoardGame(IN p_gameID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
        DELETE FROM BoardGames WHERE boardGameID = p_gameID;
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in boardGame for boardGameID: ', p_gameID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;
