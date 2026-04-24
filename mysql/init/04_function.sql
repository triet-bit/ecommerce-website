-- Ham 1: fn_tinh_tong_tien_don_hang(order_id):
--  Dùng CURSOR duyệt từng dòng chi_tiet_don_hangs, cộng dồn thành tiền, 
-- trừ voucher nếu có, dùng IF để làm tròn về 0 nếu âm.
--  Kiểm tra order_id hợp lệ trước khi xử lý.	

DELIMITER $$

CREATE FUNCTION fn_tinh_tong_tien_don_hang(p_order_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    
    DECLARE v_so_luong INT;
    DECLARE v_gia DECIMAL(12,2);
    
    DECLARE tong_tien DECIMAL(12,2) DEFAULT 0;
    DECLARE v_muc_giam DECIMAL(12,2) DEFAULT 0;
    DECLARE v_voucher_id INT;
    
    -- kiểm tra order tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM don_hangs WHERE order_id = p_order_id
    ) THEN
        RETURN -1; -- báo lỗi (order không tồn tại)
    END IF;

    -- CURSOR lấy chi tiết đơn hàng
    DECLARE cur_ctdh CURSOR FOR
        SELECT so_luong_mua, gia_ban
        FROM chi_tiet_don_hangs
        WHERE order_id = p_order_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_ctdh;

    read_loop: LOOP
        FETCH cur_ctdh INTO v_so_luong, v_gia;
        
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET tong_tien = tong_tien + (v_so_luong * v_gia);

    END LOOP;

    CLOSE cur_ctdh;

    -- lấy voucher nếu có
    SELECT voucher_id INTO v_voucher_id
    FROM don_hangs
    WHERE order_id = p_order_id;

    IF v_voucher_id IS NOT NULL THEN
        SELECT muc_giam_gia INTO v_muc_giam
        FROM vouchers
        WHERE voucher_id = v_voucher_id;

        SET tong_tien = tong_tien - v_muc_giam;
    END IF;

    -- nếu âm thì trả về 0
    IF tong_tien < 0 THEN
        SET tong_tien = 0;
    END IF;

    RETURN tong_tien;

END$$

DELIMITER ;


-- Ham 2: fn_xep_hang_khach_hang(user_id): Dùng CURSOR + LOOP + IF 
-- để phân loại khách hàng theo hạng (Đồng / Bạc / Vàng / Kim cương) dựa trên tong_diem_tich_luy. 
-- Kiểm tra user_id tồn tại trước khi xử lý.	


DELIMITER $$

CREATE FUNCTION fn_xep_hang_khach_hang(p_user_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_diem INT;
    DECLARE v_hang VARCHAR(20);

    -- kiểm tra user tồn tại trong bảng khách hàng
    IF NOT EXISTS (
        SELECT 1 FROM khach_hangs WHERE id = p_user_id
    ) THEN
        RETURN 'KHONG_TON_TAI';
    END IF;

    -- CURSOR lấy điểm tích lũy
    DECLARE cur_kh CURSOR FOR
        SELECT tong_diem_tich_luy
        FROM khach_hangs
        WHERE id = p_user_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_kh;

    read_loop: LOOP
        FETCH cur_kh INTO v_diem;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- phân loại hạng bằng IF
        IF v_diem < 1000 THEN
            SET v_hang = 'Dong';
        ELSEIF v_diem < 5000 THEN
            SET v_hang = 'Bac';
        ELSEIF v_diem < 10000 THEN
            SET v_hang = 'Vang';
        ELSE
            SET v_hang = 'Kim cuong';
        END IF;

    END LOOP;

    CLOSE cur_kh;

    RETURN v_hang;

END$$

DELIMITER ;