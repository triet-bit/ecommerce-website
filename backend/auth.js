const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const router = express.Router();

// Đăng ký
router.post('/register', async (req, res) => {
    const {
        role,
        ho,
        dem,
        ten,
        so_dien_thoai,
        email,
        mat_khau,

        quyen_han,

        ten_gian_hang,
        dia_chi_lay_hang,
        trang_thai_hoat_dong,
        giay_phep_kinh_doanh,

    } = req.body;
    const conn = await pool.getConnection();
    await conn.beginTransaction();
    try {
        const hashedPassword = await bcrypt.hash(mat_khau, 10);
        const [result] = await conn.query(
            'INSERT INTO nguoi_dungs (email, mat_khau, ho, dem, ten, so_dien_thoai) VALUES (?, ?, ?, ?, ?, ?)',
            [email, hashedPassword, ho, dem, ten, so_dien_thoai]
        );
        const newUserId = result.insertId;
        if (role == 'seller') {
            await conn.query(
                'INSERT INTO nguoi_bans (id,ten_gian_hang,dia_chi_lay_hang,trang_thai_hoat_dong,giay_phep_kinh_doanh) values (?,?,?,?,?)',
                [newUserId, ten_gian_hang, dia_chi_lay_hang, trang_thai_hoat_dong, giay_phep_kinh_doanh]
            );
        }
        else if (role == 'buyer') {
            await conn.query(
                'INSERT INTO khach_hangs (id) values (?)',
                [newUserId]
            );
        }
        else {
            await conn.query(
                'insert into quan_tri_viens (id,quyen_han) values (?,?)',
                [newUserId, quyen_han]
            );
        }
        await conn.commit();
        res.status(201).json({ message: 'Đăng ký thành công', userId: newUserId });
    } catch (error) {
        await conn.rollback();
        res.status(500).json({ error: error.message });
    } finally {
        conn.release();
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

        // Xác định vai trò (role) dựa trên bảng liên kết
        let role = 'buyer'; // mặc định là khách hàng
        const [sellerCheck] = await pool.query('SELECT 1 FROM nguoi_bans WHERE id = ?', [user.id]);

        if (sellerCheck.length > 0) {
            role = 'seller';
        } else {
            const [adminCheck] = await pool.query('SELECT 1 FROM quan_tri_viens WHERE id = ?', [user.id]);
            if (adminCheck.length > 0) {
                role = 'admin';
            }
        }

        // Gán role vào thông tin user trả về
        user.role = role;
        
        // Sau khi đã có biến role...
        const [kh] = await pool.query('SELECT so_du_vi_dien_tu, tong_diem_tich_luy FROM khach_hangs WHERE id = ?', [user.id]);
        if (kh.length > 0) {
            user.so_du_vi_dien_tu = kh[0].so_du_vi_dien_tu;
            user.tong_diem_tich_luy = kh[0].tong_diem_tich_luy;
        } else {
            // Nếu không phải khách hàng (ví dụ admin), ta cho bằng 0
            user.so_du_vi_dien_tu = 0;
            user.tong_diem_tich_luy = 0;
        }




        // Ký token chứa cả role để phân quyền Frontend
        const token = jwt.sign(
            { id: user.id, email: user.email, role: role },
            process.env.JWT_SECRET || 'secret_key',
            { expiresIn: '1h' }
        );
        res.json({ token, user });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;