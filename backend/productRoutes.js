const express = require('express');
const pool = require('./db');
const authenticateJWT = require('./authMiddleware');
const router = express.Router();
const jwt = require('jsonwebtoken');

// GET: Lấy danh sách sản phẩm (Public)
// - Bất kỳ ai (buyer, guest, seller) vào trang public đều thấy tất cả sản phẩm
router.get('/', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM san_phams');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Lấy danh sách sản phẩm để quản lý (Admin/Seller)
// - Admin thấy tất cả
// - Seller chỉ thấy sản phẩm của mình
router.get('/manage', authenticateJWT, async (req, res) => {
    try {
        const role = req.user.role;
        const userId = req.user.id;
        let rows;

        if (role === 'admin') {
            [rows] = await pool.query('SELECT * FROM san_phams');
        } else if (role === 'seller') {
            [rows] = await pool.query('SELECT * FROM san_phams WHERE seller_id = ?', [userId]);
        } else {
            rows = [];
        }
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Lấy sản phẩm theo ID
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM san_phams WHERE product_id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST: Tạo sản phẩm mới - gọi sp_them_san_pham (P1: CRUD đúng SP)
router.post('/', authenticateJWT, async (req, res) => {
    const { ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, trang_thai, url_hinh_anh } = req.body;
    const seller_id = req.user.id;
    try {
        const [rows] = await pool.query(
            'CALL sp_them_san_pham(?, ?, ?, ?, ?, ?, ?, ?, ?)', 
            [ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, seller_id, trang_thai, url_hinh_anh || null]
        );
        res.status(201).json(rows[0][0]);
    } catch (error) {
        // Trả lại đúng message lỗi từ SIGNAL SQLSTATE trong SP
        res.status(500).json({ error: error.message });
    }
});

// PUT: Cập nhật sản phẩm - gọi sp_cap_nhat_san_pham (P1: CRUD đúng SP)
router.put('/:id', authenticateJWT, async (req, res) => {
    const { ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, trang_thai } = req.body;
    try {
        await pool.query(
            'CALL sp_cap_nhat_san_pham(?, ?, ?, ?, ?, ?, ?, ?)',
            [req.params.id, ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, trang_thai]
        );
        res.json({ message: 'Cập nhật sản phẩm thành công' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE: Xóa sản phẩm - gọi sp_xoa_san_pham (P1: CRUD đúng SP)
// SP tự xử lý: nếu có đơn đang chờ → chuyển ngung_ban, không thì xóa hẳn
router.delete('/:id', authenticateJWT, async (req, res) => {
    try {
        const [rows] = await pool.query('CALL sp_xoa_san_pham(?)', [req.params.id]);
        res.json({ message: rows[0][0].message });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;