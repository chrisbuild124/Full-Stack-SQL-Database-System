let mysql = require('mysql2')

const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit   : 10,
    host              : '',
    user              : '',
    password          : '',
    database          : '',
    multipleStatements: true
}).promise();

module.exports = pool;