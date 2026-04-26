DELIMITER //
CREATE TRIGGER trg_KiemTraTrangThaiDonHang
BEFORE UPDATE ON don_hangs
FOR EACH ROW
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF OLD.trang_thai_don_hang != NEW.trang_thai_don_hang THEN
        
        IF OLD.trang_thai_don_hang = 'cho_xac_nhan' AND NEW.trang_thai_don_hang != 'da_xac_nhan' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Chờ xác nhận" chỉ được chuyển sang "Đã xác nhận".';
            
        ELSEIF OLD.trang_thai_don_hang = 'da_xac_nhan' AND NEW.trang_thai_don_hang != 'cho_giao_hang' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Đã xác nhận" chỉ được chuyển sang "Chờ giao hàng".';
            
        ELSEIF OLD.trang_thai_don_hang = 'cho_giao_hang' AND NEW.trang_thai_don_hang != 'dang_giao_hang' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Chờ giao hàng" chỉ được chuyển sang "Đang giao".';
            
        ELSEIF OLD.trang_thai_don_hang = 'dang_giao_hang' AND NEW.trang_thai_don_hang NOT IN ('giao_thanh_cong', 'giao_that_bai') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Đang giao" chỉ được chuyển sang "Giao thành công" hoặc "Giao thất bại".';
            
        ELSEIF OLD.trang_thai_don_hang IN ('giao_thanh_cong', 'giao_that_bai') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Đơn hàng đã kết thúc quy trình, không thể thay đổi trạng thái nữa.';
            
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //
-- Quy tắc cộng điểm cho khách hàng, 10k -> 1 điểm
CREATE TRIGGER trg_CongDiemSauGiaoHang
AFTER UPDATE ON don_hangs
FOR EACH ROW
BEGIN
    DECLARE v_TongGiaTri DECIMAL(18,2) DEFAULT 0;
    DECLARE v_DiemCong INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF OLD.trang_thai_don_hang != 'giao_thanh_cong' AND NEW.trang_thai_don_hang = 'giao_thanh_cong' THEN

        SELECT IFNULL(SUM(so_luong_mua * gia_ban), 0) INTO v_TongGiaTri
        FROM chi_tiet_don_hangs
        WHERE order_id = NEW.order_id;

        SET v_DiemCong = FLOOR(v_TongGiaTri / 10000);

        IF v_DiemCong > 0 AND EXISTS (SELECT 1 FROM khach_hangs WHERE id = NEW.user_id) THEN
            UPDATE khach_hangs
            SET tong_diem_tich_luy = tong_diem_tich_luy + v_DiemCong
            WHERE id = NEW.user_id;
        END IF;

    END IF;
END //

DELIMITER ;