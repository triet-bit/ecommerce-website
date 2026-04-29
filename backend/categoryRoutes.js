// file: backend/categoryRoutes.js (hoặc file tương ứng của bạn)
const express = require('express');
const pool = require('./db');
const authenticateJWT = require('./authMiddleware');
const router = express.Router();

// GET /api/categories - Lấy tất cả danh mục
router.get('/', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM danh_muc_san_phams');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT /api/categories/:id - Cập nhật danh mục
router.put('/:id', authenticateJWT, async (req, res) => {
    try {
        const categoryId = req.params.id;
        const { ten_danh_muc, mo_ta_danh_muc, url_hinh_anh_dai_dien, parent_category_id } = req.body;
        
        await pool.query(
            `UPDATE danh_muc_san_phams 
             SET ten_danh_muc = ?, mo_ta_danh_muc = ?, url_hinh_anh_dai_dien = ?, parent_category_id = ? 
             WHERE category_id = ?`,
            [ten_danh_muc, mo_ta_danh_muc, url_hinh_anh_dai_dien, parent_category_id || null, categoryId]
        );
        
        res.json({ message: 'Cập nhật danh mục thành công' });
    } catch (error) {
        // Bắt lỗi từ TRIGGER của MySQL (SQLSTATE 45000)
        if (error.sqlState === '45000') {
            // Gửi thẳng error.message ('Lỗi: Thư mục cha mới...') về frontend
            return res.status(400).json({ error: error.message }); 
        }
        
        // Bắt các lỗi hệ thống khác
        res.status(500).json({ error: 'Lỗi server: ' + error.message });
    }
});

module.exports = router;
