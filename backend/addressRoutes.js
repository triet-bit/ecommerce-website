const express = require('express')
const pool = require('./db')

const authenticateJWT = require('./authMiddleware'); // Import middleware bảo vệ route
const router = express.Router();

//lấy đại chi giao hàng của khách
router.get('/addresses',authenticateJWT, async (req, res) => {
    `
    address_id INT AUTO_INCREMENT,          -- FIX: AUTO_INCREMENT + PK độc lập để don_hangs có thể FK đúng
    user_id INT NOT NULL, 
    phuong_xa varchar(50) NOT NULL, 
    tinh_thanh varchar(50) NOT NULL, 
    so_nha varchar(64) NOT NULL, 
    `
    try {
        const user_id = req.query.user_id; 
        const [rows] = await pool.query('SELECT * from dia_chi_giao_hangs where user_id = (?)', [user_id]); 
        res.json(rows); 
    } catch (error) {
        res.status(500).json({ error: error.message });  
    }
}); 

router.post('/addresses', authenticateJWT, async (req, res) => {
    try {
        const { user_id, phuong_xa, tinh_thanh, so_nha } = req.body;

        if (!user_id || !phuong_xa || !tinh_thanh || !so_nha) {
            return res.status(400).json({ error: "Vui lòng nhập đầy đủ thông tin địa chỉ" });
        }

        const [result] = await pool.query(
            'INSERT INTO dia_chi_giao_hangs (user_id, phuong_xa, tinh_thanh, so_nha) VALUES (?, ?, ?, ?)',
            [user_id, phuong_xa, tinh_thanh, so_nha]
        );

        res.status(201).json({ 
            message: 'Thêm địa chỉ thành công', 
            address_id: result.insertId 
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
