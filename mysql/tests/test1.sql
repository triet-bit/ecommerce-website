
USE ecommerce;


SELECT '--- sp_them_san_pham ---' AS '';

SELECT 'TEST 1.1: Them san pham hop le → EXPECT: thanh cong' AS test;
CALL sp_them_san_pham(
    'Bút Lông Dầu Thiên Long',
    'Bút lông dầu không phai màu, thích hợp viết bảng trắng',
    'Bảo hành 6 tháng',
    'Thiên Long',
    35000.00,
    200,
    12,
    'dang_ban'
);
SELECT product_id, ten_san_pham, gia_ban, so_luong_ton_kho, seller_id, trang_thai
FROM san_phams ORDER BY product_id DESC LIMIT 1;

SELECT 'TEST: ten_san_pham rong → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_them_san_pham('', 'Mo ta', 'BH 1 nam', 'Hang A', 50000, 10, 11, 'dang_ban');
ROLLBACK;

SELECT 'TEST: gia_ban am → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_them_san_pham('San pham test', 'Mo ta', 'BH 1 nam', 'Hang A', -100, 10, 11, 'dang_ban');
ROLLBACK;

SELECT 'TEST: so_luong_ton_kho am → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_them_san_pham('San pham test', 'Mo ta', 'BH 1 nam', 'Hang A', 50000, -5, 11, 'dang_ban');
ROLLBACK;

SELECT 'TEST: seller_id khong ton tai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_them_san_pham('San pham test', 'Mo ta', 'BH 1 nam', 'Hang A', 50000, 10, 9999, 'dang_ban');
ROLLBACK;

SELECT 'TEST: trang_thai sai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_them_san_pham('San pham test', 'Mo ta', 'BH 1 nam', 'Hang A', 50000, 10, 11, 'sai_trang_thai');
ROLLBACK;



SELECT '--- sp_cap_nhat_san_pham ---' AS '';

SELECT 'TEST: Cap nhat gia ban hop le → EXPECT: thanh cong' AS test;
SELECT product_id, ten_san_pham, gia_ban FROM san_phams WHERE product_id = 9;
CALL sp_cap_nhat_san_pham(9, NULL, NULL, NULL, NULL, 299000.00, NULL, NULL);
SELECT product_id, ten_san_pham, gia_ban FROM san_phams WHERE product_id = 9;


SELECT 'TEST: product_id khong ton tai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_cap_nhat_san_pham(9999, 'Ten moi', NULL, NULL, NULL, NULL, NULL, NULL);
ROLLBACK;

SELECT 'TEST: gia_ban am → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_cap_nhat_san_pham(9, NULL, NULL, NULL, NULL, -500, NULL, NULL);
ROLLBACK;

SELECT 'TEST: so luong ton kho don hang bi sai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_cap_nhat_san_pham(10, NULL, NULL, NULL, NULL, null, 0, NULL);
ROLLBACK;

SELECT 'TEST: Cap nhat trang_thai hop le → EXPECT: thanh cong' AS test;
SELECT product_id, trang_thai FROM san_phams WHERE product_id = 9;
CALL sp_cap_nhat_san_pham(9, NULL, NULL, NULL, NULL, NULL, NULL, 'het_hang');
SELECT product_id, trang_thai FROM san_phams WHERE product_id = 9;
CALL sp_cap_nhat_san_pham(9, NULL, NULL, NULL, NULL, NULL, NULL, 'dang_ban');


SELECT '--- sp_xoa_san_pham ---' AS '';

SELECT 'TEST: Xoa san pham co don active → EXPECT: chuyen ngung_ban' AS test;
CALL sp_them_san_pham('San pham test xoa', 'Mo ta test', 'BH 1 thang', 'Hang test', 10000, 5, 11, 'dang_ban');
SET @test_product_id = LAST_INSERT_ID();
INSERT INTO don_hangs (address_id, user_id, phuong_thuc_thanh_toan, trang_thai_don_hang)
VALUES (1, 1, 'COD', 'cho_xac_nhan');
SET @test_order_id = LAST_INSERT_ID();
INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua)
VALUES (@test_order_id, @test_product_id, 10000, 1);

CALL sp_xoa_san_pham(@test_product_id);
SELECT product_id, ten_san_pham, trang_thai FROM san_phams WHERE product_id = @test_product_id;

DELETE FROM don_hangs WHERE order_id = @test_order_id;
DELETE FROM san_phams WHERE product_id = @test_product_id;

SELECT 'TEST: Xoa san pham khong co don hang → EXPECT: xoa han' AS test;
CALL sp_them_san_pham('San pham xoa that', 'Mo ta', 'BH 1 thang', 'Hang test', 5000, 10, 13, 'dang_ban');
SET @del_id = LAST_INSERT_ID();
SELECT CONCAT('Truoc khi xoa: product_id = ', @del_id) AS info;
CALL sp_xoa_san_pham(@del_id);
SELECT COUNT(*) AS con_ton_tai FROM san_phams WHERE product_id = @del_id;

SELECT 'TEST: Xoa product_id khong ton tai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_xoa_san_pham(99999);
ROLLBACK;


SELECT '--- sp_thong_ke_doanh_thu_nguoi_ban ---' AS '';

SELECT 'TEST: Thong ke doanh thu seller 11 thang 1/2026 → EXPECT: co data' AS test;
CALL sp_thong_ke_doanh_thu_nguoi_ban(11, '2026-01-01 00:00:00', '2026-01-31 23:59:59');

SELECT 'TEST: Thong ke doanh thu seller 12 ca nam 2026' AS test;
CALL sp_thong_ke_doanh_thu_nguoi_ban(12, '2026-01-01 00:00:00', '2026-12-31 23:59:59');

SELECT 'TEST: seller_id khong ton tai → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_thong_ke_doanh_thu_nguoi_ban(9999, '2026-01-01', '2026-12-31');
ROLLBACK;

SELECT 'TEST: tu_ngay > den_ngay → EXPECT: ERROR' AS test;
BEGIN;
    CALL sp_thong_ke_doanh_thu_nguoi_ban(11, '2026-12-31', '2026-01-01');
ROLLBACK;




SELECT 'TEST: Don hang 1 co voucher → EXPECT: tong tien sau giam gia' AS test;
SELECT
    1 AS order_id,
    fn_tinh_tong_tien_don_hang(1) AS tong_tien_sau_giam,
    (SELECT SUM(so_luong_mua * gia_ban) FROM chi_tiet_don_hangs WHERE order_id = 1) AS tong_truoc_giam,
    (SELECT muc_giam_gia FROM vouchers v JOIN don_hangs d ON d.voucher_id = v.voucher_id WHERE d.order_id = 1) AS muc_giam;

SELECT 'TEST: Don hang 10 khong co voucher' AS test;
SELECT
    10 AS order_id,
    fn_tinh_tong_tien_don_hang(10) AS tong_tien,
    (SELECT SUM(so_luong_mua * gia_ban) FROM chi_tiet_don_hangs WHERE order_id = 10) AS kiem_tra_thu_cong;

SELECT 'TEST: Tong tien nhieu don hang' AS test;
SELECT
    dh.order_id,
    dh.trang_thai_don_hang,
    dh.voucher_id,
    fn_tinh_tong_tien_don_hang(dh.order_id) AS tong_tien_tinh_duoc
FROM don_hangs dh
WHERE dh.order_id BETWEEN 1 AND 10
ORDER BY dh.order_id;

-- TEST 5.4: order_id không tồn tại → expect: -1
SELECT 'TEST: order_id khong ton tai → EXPECT: -1' AS test;
SELECT fn_tinh_tong_tien_don_hang(99999) AS ket_qua;

SELECT 'TEST: Kiem tra khong am - them don hang voi voucher lon → EXPECT: 0' AS test;
INSERT INTO vouchers (so_lan_su_dung_toi_da, muc_giam_gia, dieu_kien_su_dung, ten_chien_dich_km, thoi_gian_bat_dau, thoi_gian_ket_thuc)
VALUES (1, 9999999, 'Khong dieu kien', 'Test voucher lon', '2026-01-01', '2026-12-31');
SET @big_voucher_id = LAST_INSERT_ID();
INSERT INTO don_hangs (address_id, user_id, voucher_id, phuong_thuc_thanh_toan)
VALUES (1, 1, @big_voucher_id, 'COD');
SET @big_order_id = LAST_INSERT_ID();
INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua)
VALUES (@big_order_id, 1, 1000, 1);
SELECT fn_tinh_tong_tien_don_hang(@big_order_id) AS ket_qua_expect_0;
DELETE FROM don_hangs WHERE order_id = @big_order_id;
DELETE FROM vouchers WHERE voucher_id = @big_voucher_id;


SELECT 'TEST: Xep hang tat ca khach hang' AS test;
SELECT
    kh.id,
    nd.ho, nd.ten,
    kh.tong_diem_tich_luy,
    fn_xep_hang_khach_hang(kh.id) AS hang_khach_hang,
    CASE
        WHEN kh.tong_diem_tich_luy < 1000  THEN 'Dong'
        WHEN kh.tong_diem_tich_luy < 5000  THEN 'Bac'
        WHEN kh.tong_diem_tich_luy < 10000 THEN 'Vang'
        ELSE 'Kim cuong'
    END AS kiem_tra_tay
FROM khach_hangs kh
JOIN nguoi_dungs nd ON kh.id = nd.id
ORDER BY kh.tong_diem_tich_luy DESC;

SELECT 'TEST: user_id khong ton tai → EXPECT: KHONG_TON_TAI' AS test;
SELECT fn_xep_hang_khach_hang(9999) AS ket_qua;

SELECT 'TEST: Kiem tra nguong hang' AS test;
-- id=3: 800 điểm → Đồng
-- id=7: 1200 điểm → Bạc
-- id=6: 4500 điểm → Bạc
-- id=9: 6000 điểm → Vàng
SELECT
    id, tong_diem_tich_luy,
    fn_xep_hang_khach_hang(id) AS hang,
    'Dong(<1000) Bac(<5000) Vang(<10000) KimCuong(>=10000)' AS chu_thich
FROM khach_hangs
WHERE id IN (3, 7, 6, 9)
ORDER BY tong_diem_tich_luy;


SELECT '--- trg_KiemTraTrangThaiDonHang ---' AS '';

-- Chuẩn bị: tạo đơn hàng mới để test trigger
INSERT INTO don_hangs (address_id, user_id, phuong_thuc_thanh_toan, trang_thai_don_hang)
VALUES (1, 1, 'COD', 'cho_xac_nhan');
SET @trigger_order_id = LAST_INSERT_ID();
SELECT CONCAT('Don hang test trigger: order_id = ', @trigger_order_id) AS info;

SELECT 'TEST: cho_xac_nhan → da_xac_nhan → EXPECT: thanh cong' AS test;
UPDATE don_hangs SET trang_thai_don_hang = 'da_xac_nhan' WHERE order_id = @trigger_order_id;
SELECT order_id, trang_thai_don_hang FROM don_hangs WHERE order_id = @trigger_order_id;

SELECT 'TEST: da_xac_nhan → cho_giao_hang → EXPECT: thanh cong' AS test;
UPDATE don_hangs SET trang_thai_don_hang = 'cho_giao_hang' WHERE order_id = @trigger_order_id;
SELECT order_id, trang_thai_don_hang FROM don_hangs WHERE order_id = @trigger_order_id;

SELECT 'TEST: cho_giao_hang → dang_giao_hang → EXPECT: thanh cong' AS test;
UPDATE don_hangs SET trang_thai_don_hang = 'dang_giao_hang' WHERE order_id = @trigger_order_id;
SELECT order_id, trang_thai_don_hang FROM don_hangs WHERE order_id = @trigger_order_id;

SELECT 'TEST: dang_giao_hang → giao_thanh_cong → EXPECT: thanh cong' AS test;
UPDATE don_hangs SET trang_thai_don_hang = 'giao_thanh_cong' WHERE order_id = @trigger_order_id;
SELECT order_id, trang_thai_don_hang FROM don_hangs WHERE order_id = @trigger_order_id;

SELECT 'TEST: Thay doi don da ket thuc → EXPECT: ERROR' AS test;
BEGIN;
    UPDATE don_hangs SET trang_thai_don_hang = 'cho_xac_nhan' WHERE order_id = @trigger_order_id;
ROLLBACK;

SELECT 'TEST: Nhay trang thai khong hop le → EXPECT: ERROR' AS test;
INSERT INTO don_hangs (address_id, user_id, phuong_thuc_thanh_toan, trang_thai_don_hang)
VALUES (1, 1, 'COD', 'cho_xac_nhan');
SET @skip_order_id = LAST_INSERT_ID();
BEGIN;
    UPDATE don_hangs SET trang_thai_don_hang = 'dang_giao_hang' WHERE order_id = @skip_order_id;
ROLLBACK;
DELETE FROM don_hangs WHERE order_id = @skip_order_id;

-- TEST: dang_giao_hang → giao_that_bai (expect: thành công - đây là nhánh thất bại hợp lệ)
SELECT 'TEST: dang_giao_hang → giao_that_bai → EXPECT: thanh cong' AS test;
INSERT INTO don_hangs (address_id, user_id, phuong_thuc_thanh_toan, trang_thai_don_hang)
VALUES (1, 1, 'COD', 'cho_xac_nhan');
SET @fail_order_id = LAST_INSERT_ID();
UPDATE don_hangs SET trang_thai_don_hang = 'da_xac_nhan'    WHERE order_id = @fail_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'cho_giao_hang'  WHERE order_id = @fail_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'dang_giao_hang' WHERE order_id = @fail_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'giao_that_bai'  WHERE order_id = @fail_order_id;
SELECT order_id, trang_thai_don_hang FROM don_hangs WHERE order_id = @fail_order_id;


SELECT '--- trg_CongDiemSauGiaoHang ---' AS '';

SELECT ': Diem khach hang truoc khi giao hang' AS test;
SELECT kh.id, nd.ho, nd.ten, kh.tong_diem_tich_luy
FROM khach_hangs kh JOIN nguoi_dungs nd ON kh.id = nd.id
WHERE kh.id = 1;


SELECT 'TEST: Giao thanh cong → EXPECT: diem tang' AS test;
INSERT INTO don_hangs (address_id, user_id, phuong_thuc_thanh_toan, trang_thai_don_hang, trang_thai_thanh_toan)
VALUES (1, 1, 'COD', 'cho_xac_nhan', 'da_thanh_toan');
SET @point_order_id = LAST_INSERT_ID();
INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua)
VALUES (@point_order_id, 1, 100000, 2); -- 200,000 → nên cộng 20 điểm

SELECT tong_diem_tich_luy AS diem_truoc FROM khach_hangs WHERE id = 1;

UPDATE don_hangs SET trang_thai_don_hang = 'da_xac_nhan'    WHERE order_id = @point_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'cho_giao_hang'  WHERE order_id = @point_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'dang_giao_hang' WHERE order_id = @point_order_id;
UPDATE don_hangs SET trang_thai_don_hang = 'giao_thanh_cong' WHERE order_id = @point_order_id;

SELECT tong_diem_tich_luy AS diem_sau FROM khach_hangs WHERE id = 1;

DELETE FROM don_hangs WHERE order_id IN (@trigger_order_id, @fail_order_id, @point_order_id);