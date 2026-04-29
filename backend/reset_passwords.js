const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function resetPasswords() {
    const password = '123456';
    const hash = await bcrypt.hash(password, 10);
    
    const connection = await mysql.createConnection({
        host: process.env.MYSQL_HOST || '127.0.0.1',
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE
    });

    console.log(`Updating all passwords to: ${password}`);
    console.log(`Hash: ${hash}`);

    const [result] = await connection.execute('UPDATE nguoi_dungs SET mat_khau = ?', [hash]);
    console.log(`Updated ${result.affectedRows} users.`);
    
    await connection.end();
}

resetPasswords().catch(console.error);
