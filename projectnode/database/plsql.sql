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