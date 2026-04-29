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

DELIMITER //
CREATE TRIGGER trg_kiem_tra_ton_kho
BEFORE INSERT ON them_vao_gio
FOR EACH ROW
BEGIN
    DECLARE v_so_luong_ton_kho INT;

    SELECT so_luong_ton_kho INTO v_so_luong_ton_kho
    FROM san_phams sp
    WHERE sp.product_id = NEW.product_id;

    IF v_so_luong_ton_kho < NEW.so_luong_dinh_mua THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: so luong ton kho khong du';
    END IF;

END // 
DELIMITER ; 

DELIMITER //
DROP TRIGGER IF EXISTS trg_cho_phep_danh_gia //
CREATE TRIGGER trg_cho_phep_danh_gia
BEFORE INSERT ON danh_gia_san_phams
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM don_hangs dh
        WHERE dh.order_id = NEW.order_id
        AND dh.trang_thai_don_hang = 'giao_thanh_cong'
        AND (
            dh.phuong_thuc_thanh_toan != 'COD'
            OR dh.trang_thai_thanh_toan = 'da_thanh_toan'
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi: khong duoc phep danh gia san pham';
    END IF;
END //
DELIMITER ;

DELIMITER // 
DROP TRIGGER IF EXISTS trg_kiem_tra_danh_muc // 
CREATE TRIGGER trg_kiem_tra_danh_muc
BEFORE UPDATE ON danh_muc_san_phams
FOR EACH ROW
BEGIN 
    DECLARE is_cycle INT DEFAULT 0; 
    IF NEW.parent_category_id = NEW.category_id THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Category cannot be its parent (Cycle detected)'; 
    END IF; 
    IF NEW.parent_category_id IS NOT NULL THEN 
        WITH RECURSIVE category_tree AS (
            SELECT category_id, parent_category_id
            FROM danh_muc_san_phams
            WHERE category_id = NEW.parent_category_id

            UNION ALL 

            SELECT d.category_id, d.parent_category_id
            FROM danh_muc_san_phams d 
            INNER JOIN category_tree ct ON d.category_id = ct.parent_category_id
        )
        SELECT 1 INTO is_cycle
        FROM category_tree 
        WHERE category_id = NEW.category_id
        LIMIT 1; 

        IF is_cycle = 1 THEN 
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: Category cannot be its parent (Cycle detected)'; 
        END IF; 
    END IF; 
END // 
DELIMITER ; 