// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 40586;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/board-games', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT BoardGames.boardGameID AS id, gameName, numPlayer, gamePrice, Genres.genreName AS genre \
            FROM BoardGames \
            INNER JOIN Genres ON BoardGames.genreID = Genres.genreID;`;
        const query2 = 'SELECT genreID AS id, genreName AS name FROM Genres;';
        const [boardGames] = await db.query(query1);
        const [genres] = await db.query(query2);

        // Render the board-games.hbs file, and also send the renderer
        // an object that contains our boardGames and genres information
        res.render('board-games', { boardGames: boardGames, genres: genres });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/customers', async function (req, res) {
    try {
        const query = `
            SELECT 
                Customers.customerID, 
                Customers.firstName, 
                Customers.lastName, 
                Customers.email, 
                Customers.phoneNumber, 
                IFNULL(COUNT(Rentals.rentalID), 0) AS currentlyRenting
            FROM Customers
            LEFT JOIN Rentals ON Customers.customerID = Rentals.customerID AND Rentals.returnDate IS NULL
            GROUP BY Customers.customerID;
        `;
        const [customers] = await db.query(query);
        res.render('customers', { customers });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.get('/orders', async function (req, res) {
    try {
        const ordersQuery = 'SELECT Orders.orderID, orderDate, CONCAT(Customers.firstName, " ", Customers.lastName) AS customerName, Customers.email AS customerEmail FROM Orders INNER JOIN Customers ON Orders.customerID = Customers.customerID;';
        const customersQuery = 'SELECT customerID, firstName, lastName FROM Customers;';

        const [orders] = await db.query(ordersQuery);
        const [customers] = await db.query(customersQuery);

        res.render('orders', { orders, customers });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.get('/rentals', async function (req, res) {
    try {
        const rentalsQuery = 'SELECT Rentals.rentalID, rentalDate, returnDate, CONCAT(Customers.firstName, " ", Customers.lastName) AS customerName, Customers.email AS customerEmail FROM Rentals INNER JOIN Customers ON Rentals.customerID = Customers.customerID;';
        const customersQuery = 'SELECT customerID AS id, CONCAT(firstName, " ", lastName) AS name FROM Customers;';

        const [rentals] = await db.query(rentalsQuery);
        const [customers] = await db.query(customersQuery);

        res.render('rentals', { rentals, customers });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.get('/stocks', async function (req, res) {
    try {
        const stocksQuery = 'SELECT Stocks.stockID, BoardGames.gameName, Stocks.numItem, Stocks.numRented FROM Stocks INNER JOIN BoardGames ON Stocks.boardGameID = BoardGames.boardGameID;';
        const boardGamesQuery = 'SELECT boardGameID AS id, gameName FROM BoardGames;';

        const [stocks] = await db.query(stocksQuery);
        const [boardGames] = await db.query(boardGamesQuery);

        res.render('stocks', { stocks, boardGames });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.get('/genres', async function (req, res) {
    try {
        const query = 'SELECT genreID, genreName, genreDescription FROM Genres;';
        const [genres] = await db.query(query);
        res.render('genres', { genres });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

// CRUD operations for StocksHasRentals
app.get('/stocks-has-rentals', async function (req, res) {
    try {
        const stocksHasRentalsQuery = 'SELECT stockID, rentalID FROM StocksHasRentals;';
        const stocksQuery = 'SELECT stockID FROM Stocks;';
        const rentalsQuery = 'SELECT rentalID FROM Rentals;';

        const [stocksHasRentals] = await db.query(stocksHasRentalsQuery);
        const [stocks] = await db.query(stocksQuery);
        const [rentals] = await db.query(rentalsQuery);

        res.render('stocks-has-rentals', { stocksHasRentals, stocks, rentals });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.post('/stocks-has-rentals/update', async (req, res) => {
    try {
        const { update_stock_id, update_rental_id } = req.body;
        const query = 'UPDATE StocksHasRentals SET rentalID = ? WHERE stockID = ?';
        await db.query(query, [update_rental_id, update_stock_id]);
        res.redirect('/stocks-has-rentals');
    } catch (error) {
        console.error('Error updating StocksHasRentals:', error);
        res.status(500).send('An error occurred while updating the StocksHasRentals.');
    }
});

app.post('/stocks-has-rentals/delete', async (req, res) => {
    try {
        const { delete_stock_id, delete_rental_id } = req.body;
        const query = 'DELETE FROM StocksHasRentals WHERE stockID = ? AND rentalID = ?';
        await db.query(query, [delete_stock_id, delete_rental_id]);
        res.redirect('/stocks-has-rentals');
    } catch (error) {
        console.error('Error deleting StocksHasRentals:', error);
        res.status(500).send('An error occurred while deleting the StocksHasRentals.');
    }
});

// CRUD operations for StocksHasOrders
app.get('/stocks-has-orders', async function (req, res) {
    try {
        const stocksHasOrdersQuery = 'SELECT stockID, orderID FROM StocksHasOrders;';
        const stocksQuery = 'SELECT stockID FROM Stocks;';
        const ordersQuery = 'SELECT orderID FROM Orders;';

        const [stocksHasOrders] = await db.query(stocksHasOrdersQuery);
        const [stocks] = await db.query(stocksQuery);
        const [orders] = await db.query(ordersQuery);

        res.render('stocks-has-orders', { stocksHasOrders, stocks, orders });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while executing the database query.');
    }
});

app.post('/stocks-has-orders/update', async (req, res) => {
    try {
        const { update_stock_id, update_order_id } = req.body;
        const query = 'UPDATE StocksHasOrders SET orderID = ? WHERE stockID = ?';
        await db.query(query, [update_order_id, update_stock_id]);
        res.redirect('/stocks-has-orders');
    } catch (error) {
        console.error('Error updating StocksHasOrders:', error);
        res.status(500).send('An error occurred while updating the StocksHasOrders.');
    }
});

app.post('/stocks-has-orders/delete', async (req, res) => {
    try {
        const { delete_stock_id, delete_order_id } = req.body;
        const query = 'DELETE FROM StocksHasOrders WHERE stockID = ? AND orderID = ?';
        await db.query(query, [delete_stock_id, delete_order_id]);
        res.redirect('/stocks-has-orders');
    } catch (error) {
        console.error('Error deleting StocksHasOrders:', error);
        res.status(500).send('An error occurred while deleting the StocksHasOrders.');
    }
});

// CRUD operations for Genres
app.post('/genres/create', async (req, res) => {
    try {
        const { create_genre_name, create_genre_description } = req.body;
        const query = 'INSERT INTO Genres (genreName, genreDescription) VALUES (?, ?)';
        await db.query(query, [create_genre_name, create_genre_description]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error creating genre:', error);
        res.status(500).send('An error occurred while creating the genre.');
    }
});

app.post('/genres/update', async (req, res) => {
    try {
        const { update_genre_id, update_genre_name, update_genre_description } = req.body;
        const query = 'UPDATE Genres SET genreName = ?, genreDescription = ? WHERE genreID = ?';
        await db.query(query, [update_genre_name, update_genre_description, update_genre_id]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error updating genre:', error);
        res.status(500).send('An error occurred while updating the genre.');
    }
});

app.post('/genres/delete', async (req, res) => {
    try {
        const { delete_genre_id } = req.body;
        const query = 'DELETE FROM Genres WHERE genreID = ?';
        await db.query(query, [delete_genre_id]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error deleting genre:', error);
        res.status(500).send('An error occurred while deleting the genre.');
    }
});

// CRUD operations for Customers
app.post('/customers/create', async (req, res) => {
    try {
        const { create_customer_firstName, create_customer_lastName, create_customer_email, create_customer_phoneNumber } = req.body;
        const query = 'INSERT INTO Customers (firstName, lastName, email, phoneNumber) VALUES (?, ?, ?, ?)';
        await db.query(query, [create_customer_firstName, create_customer_lastName, create_customer_email, create_customer_phoneNumber]);
        res.redirect('/customers');
    } catch (error) {
        console.error('Error creating customer:', error);
        res.status(500).send('An error occurred while creating the customer.');
    }
});

app.post('/customers/update', async (req, res) => {
    try {
        const { update_customer_id, update_customer_firstName, update_customer_lastName, update_customer_email, update_customer_phoneNumber } = req.body;
        const query = 'UPDATE Customers SET firstName = ?, lastName = ?, email = ?, phoneNumber = ? WHERE customerID = ?';
        await db.query(query, [update_customer_firstName, update_customer_lastName, update_customer_email, update_customer_phoneNumber, update_customer_id]);
        res.redirect('/customers');
    } catch (error) {
        console.error('Error updating customer:', error);
        res.status(500).send('An error occurred while updating the customer.');
    }
});

app.post('/customers/delete', async (req, res) => {
    try {
        const { delete_customer_id } = req.body;
        const query = 'DELETE FROM Customers WHERE customerID = ?';
        await db.query(query, [delete_customer_id]);
        res.redirect('/customers');
    } catch (error) {
        console.error('Error deleting customer:', error);
        res.status(500).send('An error occurred while deleting the customer.');
    }
});

// CRUD operations for Orders
app.post('/orders/create', async (req, res) => {
    try {
        const { create_order_date, create_order_customer } = req.body;
        const query = 'INSERT INTO Orders (orderDate, customerID) VALUES (?, ?)';
        await db.query(query, [create_order_date, create_order_customer]);
        res.redirect('/orders');
    } catch (error) {
        console.error('Error creating order:', error);
        res.status(500).send('An error occurred while creating the order.');
    }
});

app.post('/orders/update', async (req, res) => {
    try {
        const { update_order_id, update_order_date, update_order_customer } = req.body;
        const query = 'UPDATE Orders SET orderDate = ?, customerID = ? WHERE orderID = ?';
        await db.query(query, [update_order_date, update_order_customer, update_order_id]);
        res.redirect('/orders');
    } catch (error) {
        console.error('Error updating order:', error);
        res.status(500).send('An error occurred while updating the order.');
    }
});

app.post('/orders/delete', async (req, res) => {
    try {
        const { delete_order_id } = req.body;
        const query = 'DELETE FROM Orders WHERE orderID = ?';
        await db.query(query, [delete_order_id]);
        res.redirect('/orders');
    } catch (error) {
        console.error('Error deleting order:', error);
        res.status(500).send('An error occurred while deleting the order.');
    }
});

// CRUD operations for Rentals
app.post('/rentals/create', async (req, res) => {
    try {
        const { create_rental_date, create_return_date, create_rental_customer } = req.body;
        const query = 'INSERT INTO Rentals (rentalDate, returnDate, customerID) VALUES (?, ?, ?)';
        await db.query(query, [create_rental_date, create_return_date, create_rental_customer]);
        res.redirect('/rentals');
    } catch (error) {
        console.error('Error creating rental:', error);
        res.status(500).send('An error occurred while creating the rental.');
    }
});

app.post('/rentals/update', async (req, res) => {
    try {
        const { update_rental_id, update_rental_date, update_return_date, update_rental_customer } = req.body;
        const query = 'UPDATE Rentals SET rentalDate = ?, returnDate = ?, customerID = ? WHERE rentalID = ?';
        await db.query(query, [update_rental_date, update_return_date, update_rental_customer, update_rental_id]);
        res.redirect('/rentals');
    } catch (error) {
        console.error('Error updating rental:', error);
        res.status(500).send('An error occurred while updating the rental.');
    }
});

app.post('/rentals/delete', async (req, res) => {
    try {
        const { delete_rental_id } = req.body;
        const query = 'DELETE FROM Rentals WHERE rentalID = ?';
        await db.query(query, [delete_rental_id]);
        res.redirect('/rentals');
    } catch (error) {
        console.error('Error deleting rental:', error);
        res.status(500).send('An error occurred while deleting the rental.');
    }
});

// CRUD operations for Board Games
app.post('/board-games/create', async (req, res) => {
    try {
        const { create_game_name, create_game_genre, create_game_numPlayer, create_game_price } = req.body;
        const query = 'INSERT INTO BoardGames (gameName, genreID, numPlayer, gamePrice) VALUES (?, ?, ?, ?)';
        await db.query(query, [create_game_name, create_game_genre, create_game_numPlayer, create_game_price]);
        res.redirect('/board-games');
    } catch (error) {
        console.error('Error creating board game:', error);
        res.status(500).send('An error occurred while creating the board game.');
    }
});

app.post('/board-games/update', async (req, res) => {
    try {
        const { update_game_id, update_game_genre, update_game_numPlayer, update_game_price } = req.body;
        const query = 'UPDATE BoardGames SET genreID = ?, numPlayer = ?, gamePrice = ? WHERE boardGameID = ?';
        await db.query(query, [update_game_genre, update_game_numPlayer, update_game_price, update_game_id]);
        res.redirect('/board-games');
    } catch (error) {
        console.error('Error updating board game:', error);
        res.status(500).send('An error occurred while updating the board game.');
    }
});

app.post('/board-games/delete', async (req, res) => {
    try {
        const { delete_game_id } = req.body;
        const query = 'DELETE FROM BoardGames WHERE boardGameID = ?';
        await db.query(query, [delete_game_id]);
        res.redirect('/board-games');
    } catch (error) {
        console.error('Error deleting board game:', error);
        res.status(500).send('An error occurred while deleting the board game.');
    }
});

// CRUD operations for Stocks
app.post('/stocks/create', async (req, res) => {
    try {
        const { create_stock_game, create_stock_numItem, create_stock_numRented } = req.body;
        const query = 'INSERT INTO Stocks (boardGameID, numItem, numRented) VALUES (?, ?, ?)';
        await db.query(query, [create_stock_game, create_stock_numItem, create_stock_numRented]);
        res.redirect('/stocks');
    } catch (error) {
        console.error('Error creating stock:', error);
        res.status(500).send('An error occurred while creating the stock.');
    }
});

app.post('/stocks/update', async (req, res) => {
    try {
        const { update_stock_id, update_stock_numItem, update_stock_numRented } = req.body;
        const query = 'UPDATE Stocks SET numItem = ?, numRented = ? WHERE stockID = ?';
        await db.query(query, [update_stock_numItem, update_stock_numRented, update_stock_id]);
        res.redirect('/stocks');
    } catch (error) {
        console.error('Error updating stock:', error);
        res.status(500).send('An error occurred while updating the stock.');
    }
});

app.post('/stocks/delete', async (req, res) => {
    try {
        const { delete_stock_id } = req.body;
        const query = 'DELETE FROM Stocks WHERE stockID = ?';
        await db.query(query, [delete_stock_id]);
        res.redirect('/stocks');
    } catch (error) {
        console.error('Error deleting stock:', error);
        res.status(500).send('An error occurred while deleting the stock.');
    }
});

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});