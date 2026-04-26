const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const router = express.Router();

// Đăng ký
router.post('/register', async (req, res) => {
    const {
        ho, 
        dem, 
        ten, 
        email,
        mat_khau, 
        so_dien_thoai,
        role,
        quyen_han,
        dia_chi,
        so_tai_khoan,
        ten_ngan_hang,
        ten_chu_tai_khoan,
        giay_phep_kinh_doanh,
        ten_gian_hang,
        dia_chi_lay_hang,
        trang_thai_hoat_dong,
    } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(mat_khau, 10);
        // Gọi bảng NguoiDung hoặc KhachHang tùy ánh xạ
        const [result] = await pool.query(
            'INSERT INTO nguoi_dungs (email, mat_khau, ho,dem, ten, so_dien_thoai) VALUES (?, ?, ?, ?, ?, ?)',
            [email, hashedPassword, ho, dem, ten, so_dien_thoai]
        );
        res.status(201).json({ message: 'Đăng ký thành công', userId: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Đăng nhập
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await pool.query('SELECT * FROM nguoi_dungs WHERE email = ?', [email]);
        if (users.length === 0) return res.status(401).json({ error: 'Email không tồn tại' });

        const user = users[0];
        const match = await bcrypt.compare(password, user.mat_khau);
        
        if (!match) return res.status(401).json({ error: 'Mật khẩu sai' });

        const token = jwt.sign(
            { id: user.id, email: user.email }, 
            process.env.JWT_SECRET || 'secret_key', 
            { expiresIn: '1h' }
        );
        res.json({ token, user });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;