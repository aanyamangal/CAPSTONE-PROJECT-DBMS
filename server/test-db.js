const { adminPool } = require('./db');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

(async () => {
  const [rows] = await adminPool.query('SELECT COUNT(*) AS users FROM users');
  console.log('Connected. Users in database:', rows[0].users);
  process.exit();
})().catch(e => { console.error('FAILED:', e.message); process.exit(1); });