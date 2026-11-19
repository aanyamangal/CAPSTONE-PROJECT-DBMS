require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });const mysql = require('mysql2/promise');

const base = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
};

const adminPool = mysql.createPool({ ...base, user: process.env.DB_ADMIN_USER, password: process.env.DB_ADMIN_PASSWORD });
const studentPool = mysql.createPool({ ...base, user: process.env.DB_STUDENT_USER, password: process.env.DB_STUDENT_PASSWORD });

module.exports = { adminPool, studentPool };