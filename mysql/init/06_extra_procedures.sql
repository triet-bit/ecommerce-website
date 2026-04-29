USE ecommerce;

-- 1. SP lấy danh sách đơn hàng cho người bán
DROP PROCEDURE IF EXISTS sp_lay_don_hang_theo_nguoi_ban;
DELIMITER $$
CREATE PROCEDURE sp_lay_don_hang_theo_nguoi_ban(
    IN p_seller_id INT,
    IN p_trang_thai VARCHAR(50)
)
BEGIN
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
    WHERE sp.seller_id = p_seller_id
      AND (p_trang_thai IS NULL OR p_trang_thai = '' OR dh.trang_thai_don_hang = p_trang_thai)
    ORDER BY dh.thoi_gian_giao_dich DESC;
END $$
DELIMITER ;

-- 2. SP cập nhật trạng thái đơn hàng
DROP PROCEDURE IF EXISTS sp_cap_nhat_trang_thai_don_hang;
DELIMITER $$
CREATE PROCEDURE sp_cap_nhat_trang_thai_don_hang(
    IN p_order_id INT,
    IN p_trang_thai_moi VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM don_hangs WHERE order_id = p_order_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Don hang khong ton tai';
    END IF;

    UPDATE don_hangs 
    SET trang_thai_don_hang = p_trang_thai_moi
    WHERE order_id = p_order_id;
    
    SELECT 'Cap nhat trang thai thanh cong' AS message;
END $$
DELIMITER ;
