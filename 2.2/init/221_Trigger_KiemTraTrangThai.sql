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
        
        IF OLD.trang_thai_don_hang = 'Chờ xác nhận' AND NEW.trang_thai_don_hang != 'Đã xác nhận' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Chờ xác nhận" chỉ được chuyển sang "Đã xác nhận".';
            
        ELSEIF OLD.trang_thai_don_hang = 'Đã xác nhận' AND NEW.trang_thai_don_hang != 'Chờ giao hàng' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Đã xác nhận" chỉ được chuyển sang "Chờ giao hàng".';
            
        ELSEIF OLD.trang_thai_don_hang = 'Chờ giao hàng' AND NEW.trang_thai_don_hang != 'Đang giao' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Chờ giao hàng" chỉ được chuyển sang "Đang giao".';
            
        ELSEIF OLD.trang_thai_don_hang = 'Đang giao' AND NEW.trang_thai_don_hang NOT IN ('Giao thành công', 'Giao thất bại') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Từ "Đang giao" chỉ được chuyển sang "Giao thành công" hoặc "Giao thất bại".';
            
        ELSEIF OLD.trang_thai_don_hang IN ('Giao thành công', 'Giao thất bại') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Đơn hàng đã kết thúc quy trình, không thể thay đổi trạng thái nữa.';
            
        END IF;
    END IF;
END //

DELIMITER ;