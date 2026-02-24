/*
CS 340 – Introduction to Databases
Project Step 4 Draft – Database Connection Module
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

Creates a MySQL connection using mysql2. Adapted from:
- CS340 Node.js starter application (Activity 2: Connect Web App to Database)
- mysql2 documentation: https://www.npmjs.com/package/mysql2

Modified to use environment variables for security.
*/

require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = pool.promise();