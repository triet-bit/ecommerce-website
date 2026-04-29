const express = require('express')
const pool = require('./db')
const authenticateJWT = require('./authMiddleware');
const router = express.Router();

// GET /api/orders - Lấy đơn hàng của khách hàng (cần JWT)
router.get('/', authenticateJWT, async (req, res) => {
    try {
        const user_id = req.user.id;
        const trang_thai = req.query.trang_thai || null;
        const [rows] = await pool.query('CALL sp_lay_don_hang_theo_khach(?, ?)', [user_id, trang_thai]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/orders/seller - Lấy đơn hàng của người bán (P1/P8) & Admin
// Admin thấy TẤT CẢ đơn hàng. Seller thấy đơn của họ.
router.get('/seller', authenticateJWT, async (req, res) => {
    try {
        const userId = req.user.id;
        const role = req.user.role;
        const trang_thai = req.query.trang_thai || null;
        
        let rows;
        if (role === 'admin') {
            const query = `
                SELECT 
                    dh.order_id, 
                    dh.thoi_gian_giao_dich, 
                    dh.phuong_thuc_thanh_toan,
                    dh.trang_thai_don_hang, 
                    dh.trang_thai_thanh_toan,
                    ctdh.so_luong_mua, 
                    ctdh.gia_ban AS gia_ban_luc_mua,
                    sp.product_id,
                    sp.ten_san_pham,
                    nd.ho, nd.dem, nd.ten AS ten_khach_hang,
                    nd.so_dien_thoai AS sdt_khach,
                    dc.so_nha, dc.phuong_xa, dc.tinh_thanh
                FROM don_hangs dh
                JOIN chi_tiet_don_hangs ctdh ON dh.order_id = ctdh.order_id
                JOIN san_phams sp ON ctdh.order_detail_id = sp.product_id
                JOIN nguoi_dungs nd ON dh.user_id = nd.id
                LEFT JOIN dia_chi_giao_hangs dc ON dh.address_id = dc.address_id
                WHERE (? IS NULL OR dh.trang_thai_don_hang = ?)
                ORDER BY dh.thoi_gian_giao_dich DESC
            `;
            [rows] = await pool.query(query, [trang_thai, trang_thai]);
        } else {
            [rows] = await pool.query('CALL sp_lay_don_hang_theo_nguoi_ban(?, ?)', [userId, trang_thai]);
            rows = rows[0];
        }
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT /api/orders/:id/status - Cập nhật trạng thái đơn hàng (P8 - Seller duyệt đơn)
router.put('/:id/status', authenticateJWT, async (req, res) => {
    try {
        const { trang_thai } = req.body;
        const [rows] = await pool.query('CALL sp_cap_nhat_trang_thai_don_hang(?, ?)', [req.params.id, trang_thai]);
        res.json({ message: rows[0][0].message });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST /api/orders - Đặt hàng mới
router.post('/', authenticateJWT, async (req, res) => {
    let conn;
    try {
        const {
            address_id,
            voucher_id,
            user_id,
            thoi_gian_giao_dich,
            phuong_thuc_thanh_toan,
            trang_thai_thanh_toan,
            chi_tiet_don_hangs
        } = req.body;
        conn = await pool.getConnection();
        await conn.beginTransaction();
        const [orderResult] = await conn.query(
            'INSERT INTO don_hangs (address_id,voucher_id,user_id,thoi_gian_giao_dich,phuong_thuc_thanh_toan,trang_thai_thanh_toan) VALUES (?, ?, ?, ?, ?, ?)',
            [address_id, voucher_id || null, user_id, thoi_gian_giao_dich, phuong_thuc_thanh_toan, trang_thai_thanh_toan || 'chua_thanh_toan']
        );

        const newOrderId = orderResult.insertId;
        if (chi_tiet_don_hangs && chi_tiet_don_hangs.length > 0) {
            for (const item of chi_tiet_don_hangs) {
                await conn.query(
                    `INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua) VALUES (?,?,?,?)`,
                    [newOrderId, item.order_detail_id, item.gia_ban, item.so_luong_mua]
                );
            }
        }

        await conn.commit();
        res.status(201).json({ message: 'Thêm đơn hàng thành công', orderId: newOrderId });
    } catch (error) {
        if (conn) await conn.rollback();
        res.status(500).json({ error: error.message });
    } finally {
        if (conn) conn.release();
    }
});

module.exports = router;