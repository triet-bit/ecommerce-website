const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const router = express.Router();

// Đăng ký
router.post('/register', async (req, res) => {
    const { email, matKhau, ho, ten, soDienThoai } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(matKhau, 10);
        // Gọi bảng NguoiDung hoặc KhachHang tùy ánh xạ
        const [result] = await pool.query(
            'INSERT INTO Nguoi_Dung (Email, Mat_Khau, Ho, Ten, So_Dien_Thoai) VALUES (?, ?, ?, ?, ?)',
            [email, hashedPassword, ho, ten, soDienThoai]
        );
        res.status(201).json({ message: 'Đăng ký thành công', userId: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Đăng nhập
router.post('/login', async (req, res) => {
    const { email, matKhau } = req.body;
    try {
        const [users] = await pool.query('SELECT * FROM Nguoi_Dung WHERE Email = ?', [email]);
        if (users.length === 0) return res.status(401).json({ error: 'Email không tồn tại' });

        const user = users[0];
        const match = await bcrypt.compare(matKhau, user.Mat_Khau);
        
        if (!match) return res.status(401).json({ error: 'Mật khẩu sai' });

        const token = jwt.sign(
            { id: user.Ma_Nguoi_Dung, email: user.Email }, 
            process.env.JWT_SECRET || 'secret_key', 
            { expiresIn: '1h' }
        );
        res.json({ token });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;