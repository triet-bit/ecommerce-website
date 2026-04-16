const express = require('express');
const pool = require('./db');
const authenticateJWT = require('./authMiddleware'); // Import middleware bảo vệ route
const router = express.Router();

// GET: Lấy danh sách sản phẩm (Gọi SP)
router.get('/', async (req, res) => {
    try {
        const [rows] = await pool.query('CALL sp_GetAllProducts()');
        res.json(rows[0]); // MySQL SP trả về mảng lồng nhau
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Lấy sản phẩm theo ID
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('CALL sp_GetProductById(?)', [req.params.id]);
        res.json(rows[0][0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST: Tạo sản phẩm mới (Có bảo vệ bằng JWT)
router.post('/', authenticateJWT, async (req, res) => {
    const { tenSP, moTa, giaBan, soLuongTon, maDanhMuc, toChucSX } = req.body;
    try {
        await pool.query(
            'CALL sp_CreateProduct(?, ?, ?, ?, ?, ?)', 
            [tenSP, moTa, giaBan, soLuongTon, maDanhMuc, toChucSX]
        );
        res.status(201).json({ message: 'Thêm sản phẩm thành công' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT: Cập nhật sản phẩm
router.put('/:id', authenticateJWT, async (req, res) => {
    const { tenSP, moTa, giaBan, soLuongTon } = req.body;
    try {
        await pool.query(
            'CALL sp_UpdateProduct(?, ?, ?, ?, ?)', 
            [req.params.id, tenSP, moTa, giaBan, soLuongTon]
        );
        res.json({ message: 'Cập nhật sản phẩm thành công' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE: Xóa sản phẩm
router.delete('/:id', authenticateJWT, async (req, res) => {
    try {
        await pool.query('CALL sp_DeleteProduct(?)', [req.params.id]);
        res.json({ message: 'Xóa sản phẩm thành công' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;