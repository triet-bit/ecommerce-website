const pool = require('../backend/db');

async function testConnection() {
    try {
        const conn = await pool.getConnection();
        console.log("Kết nối thành công")
        const [rows] = await conn.query("SELECT * FROM ")
        console.log(rows)
        conn.release()

    } catch(error){
        console.error("Lỗi kết nối DB", error.message)
    } finally {
        process.exit()
    }
}

testConnection()