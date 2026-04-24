DELIMITER //

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

    IF OLD.trang_thai_don_hang != 'Giao thành công' AND NEW.trang_thai_don_hang = 'Giao thành công' THEN

        SELECT IFNULL(SUM(so_luong * gia_ban), 0) INTO v_TongGiaTri
        FROM chi_tiet_don_hangs
        WHERE ma_don_hang = NEW.ma_don_hang;

        SET v_DiemCong = FLOOR(v_TongGiaTri / 10000);

        IF v_DiemCong > 0 THEN
            UPDATE khach_hangs
            SET tong_diem_tich_luy = tong_diem_tich_luy + v_DiemCong
            WHERE ma_khach_hang = NEW.ma_khach_hang;
        END IF;

    END IF;
END //

DELIMITER ;