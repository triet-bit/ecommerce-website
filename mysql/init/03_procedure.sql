DELIMITER $$

CREATE PROCEDURE sp_thong_ke_doanh_thu_nguoi_ban(
    IN p_seller_id INT,
    IN p_tu_ngay DATETIME,
    IN p_den_ngay DATETIME
)
BEGIN
    SELECT 
        sp.product_id,
        sp.ten_san_pham,
        
        COUNT(DISTINCT dh.order_id) AS so_don_hang,
        SUM(ctdh.so_luong_mua) AS tong_so_luong_ban,
        SUM(ctdh.so_luong_mua * ctdh.gia_ban) AS doanh_thu

    FROM san_phams sp
    
    JOIN chi_tiet_don_hangs ctdh 
        ON sp.product_id = ctdh.order_detail_id
        
    JOIN don_hangs dh 
        ON dh.order_id = ctdh.order_id

    WHERE 
        sp.seller_id = p_seller_id
        AND dh.thoi_gian_giao_dich BETWEEN p_tu_ngay AND p_den_ngay
        AND dh.trang_thai_thanh_toan = 'da_thanh_toan'   -- chỉ tính đơn đã trả tiền

    GROUP BY 
        sp.product_id, sp.ten_san_pham

    HAVING 
        doanh_thu > 0   -- lọc sau khi GROUP

    ORDER BY 
        doanh_thu DESC;

END$$

DELIMITER ;