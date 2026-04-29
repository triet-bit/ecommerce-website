const express = require('express')
const pool = require('./db')
const authenticateJWT = require('./authMiddleware');
const router = express.Router();

// GET /api/stats/revenue?seller_id=&tu_ngay=&den_ngay=
// Thống kê doanh thu theo người bán (dành cho seller/admin)
router.get('/revenue', authenticateJWT, async (req, res) => {
    try {
        const role = req.user.role;
        const seller_id = role === 'admin' ? null : req.user.id;
        const tu_ngay = req.query.tu_ngay;
        const den_ngay = req.query.den_ngay;

        let rows;
        if (role === 'admin') {
            const query = `
                SELECT 
                    sp.product_id,
                    sp.ten_san_pham,
                    COUNT(DISTINCT dh.order_id) AS so_don_hang,
                    SUM(ctdh.so_luong_mua) AS tong_so_luong_ban,
                    SUM(ctdh.so_luong_mua * ctdh.gia_ban) AS doanh_thu
                FROM san_phams sp
                JOIN chi_tiet_don_hangs ctdh ON sp.product_id = ctdh.order_detail_id
                JOIN don_hangs dh ON dh.order_id = ctdh.order_id
                WHERE dh.thoi_gian_giao_dich BETWEEN ? AND ?
                  AND dh.trang_thai_thanh_toan = 'da_thanh_toan'
                  AND dh.trang_thai_don_hang = 'giao_thanh_cong'
                GROUP BY sp.product_id, sp.ten_san_pham
                HAVING doanh_thu > 0
                ORDER BY doanh_thu DESC
            `;
            [rows] = await pool.query(query, [tu_ngay, den_ngay]);
        } else {
            [rows] = await pool.query('call sp_thong_ke_doanh_thu_nguoi_ban(?, ?, ?)', [seller_id, tu_ngay, den_ngay]);
            rows = rows[0];
        }
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/stats/rank?user_id=
// Xếp hạng 1 khách hàng theo điểm tích lũy (dùng function)
router.get('/rank', authenticateJWT, async (req, res) => {
    try {
        const user_id = req.query.user_id
        const [rows] = await pool.query('SELECT fn_xep_hang_khach_hang(?) AS hang_khach_hang', [user_id]);
        res.json({ rank: rows[0].hang_khach_hang });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/stats/customers?top=10
// Xếp hạng top khách hàng theo chi tiêu + hạng thành viên (P2)
router.get('/customers', authenticateJWT, async (req, res) => {
    try {
        const top = parseInt(req.query.top) || 10;
        const [rows] = await pool.query('CALL sp_thong_ke_khach_hang_ranking(?)', [top]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;