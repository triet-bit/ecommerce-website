-- =====================================================================
-- MOCK DATA - HỆ THỐNG THƯƠNG MẠI ĐIỆN TỬ
-- Thứ tự insert đảm bảo đúng ràng buộc FK
-- =====================================================================

USE ecommerce;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1. NGUOI_DUNGS
-- id 1–10: khách hàng | id 11–15: người bán | id 16–18: quản trị viên
-- Tổng: 18 hàng
-- =====================================================================
INSERT INTO nguoi_dungs (id, ho, dem, ten, so_dien_thoai, email, mat_khau) VALUES
(1,  'Nguyễn', 'Thị',    'Lan',    '0901234501', 'lan.nguyen@gmail.com',    '$2b$12$hashed_pw_1'),
(2,  'Trần',   'Văn',    'Hùng',   '0901234502', 'hung.tran@gmail.com',     '$2b$12$hashed_pw_2'),
(3,  'Lê',     'Thị',    'Mai',    '0901234503', 'mai.le@gmail.com',        '$2b$12$hashed_pw_3'),
(4,  'Phạm',   'Quốc',   'Bảo',    '0901234504', 'bao.pham@gmail.com',      '$2b$12$hashed_pw_4'),
(5,  'Hoàng',  'Minh',   'Tuấn',   '0901234505', 'tuan.hoang@gmail.com',    '$2b$12$hashed_pw_5'),
(6,  'Võ',     'Thị',    'Hoa',    '0901234506', 'hoa.vo@gmail.com',        '$2b$12$hashed_pw_6'),
(7,  'Đặng',   'Văn',    'Long',   '0901234507', 'long.dang@gmail.com',     '$2b$12$hashed_pw_7'),
(8,  'Bùi',    'Thị',    'Tuyết',  '0901234508', 'tuyet.bui@gmail.com',     '$2b$12$hashed_pw_8'),
(9,  'Đinh',   'Hoàng',  'Khoa',   '0901234509', 'khoa.dinh@gmail.com',     '$2b$12$hashed_pw_9'),
(10, 'Dương',  'Thanh',  'Trúc',   '0901234510', 'truc.duong@gmail.com',    '$2b$12$hashed_pw_10'),
-- người bán
(11, 'Công ty', NULL,    'KLONG',   '0281234511', 'seller.klong@gmail.com',  '$2b$12$hashed_pw_11'),
(12, 'Cửa hàng', NULL,  'Thiên Long','0281234512','seller.thienlong@gmail.com','$2b$12$hashed_pw_12'),
(13, 'Shop',   NULL,    'Văn phòng phẩm ABC','0281234513','seller.abc@gmail.com','$2b$12$hashed_pw_13'),
(14, 'Công ty', NULL,   'TechWorld', '0281234514','seller.techworld@gmail.com','$2b$12$hashed_pw_14'),
(15, 'Shop',   NULL,    'FashionHub','0281234515','seller.fashionhub@gmail.com','$2b$12$hashed_pw_15'),
-- quản trị viên
(16, 'Admin',  NULL,    'Super',    '0901234516', 'superadmin@ecom.vn',      '$2b$12$hashed_pw_16'),
(17, 'Admin',  NULL,    'Hệ thống', '0901234517', 'admin.system@ecom.vn',    '$2b$12$hashed_pw_17'),
(18, 'Admin',  NULL,    'Nội dung', '0901234518', 'admin.content@ecom.vn',   '$2b$12$hashed_pw_18');

-- =====================================================================
-- 2. KHACH_HANGS (id 1–10)
-- =====================================================================
INSERT INTO khach_hangs (id, tong_diem_tich_luy, so_diem_da_dung, so_du_vi_dien_tu) VALUES
(1,  1500, 500,  250000),
(2,  3200, 1000, 150000),
(3,  800,  200,  500000),
(4,  2100, 100,  0),
(5,  500,  0,    75000),
(6,  4500, 2000, 1200000),
(7,  1200, 300,  350000),
(8,  900,  400,  80000),
(9,  6000, 2500, 2000000),
(10, 300,  0,    45000);

-- =====================================================================
-- 3. NGUOI_BANS (id 11–15)
-- =====================================================================
INSERT INTO nguoi_bans (id, ten_gian_hang, dia_chi_lay_hang, trang_thai_hoat_dong, giay_phep_kinh_doanh) VALUES
(11, 'KLONG Official Store',     '123 Nguyễn Trãi, Q.1, TP.HCM',       'hoat_dong', 'GP-HCM-2020-001'),
(12, 'Thiên Long Stationery',    '45 Lê Lợi, Q.3, TP.HCM',             'hoat_dong', 'GP-HCM-2019-088'),
(13, 'ABC Văn Phòng Phẩm',       '78 Trần Hưng Đạo, Q.5, TP.HCM',      'hoat_dong', 'GP-HCM-2021-234'),
(14, 'TechWorld Electronics',    '200 Võ Văn Tần, Q.3, TP.HCM',        'hoat_dong', 'GP-HCM-2018-056'),
(15, 'FashionHub Clothing',      '99 Đinh Tiên Hoàng, Bình Thạnh, HCM','tam_ngung', 'GP-HCM-2022-312');  -- FIX: 'ngung_ban' → 'tam_ngung' (đúng ENUM)

-- =====================================================================
-- 4. QUAN_TRI_VIENS (id 16–18)
-- =====================================================================
INSERT INTO quan_tri_viens (id, quyen_han) VALUES
(16, 'super_admin'),
(17, 'quan_ly_don_hang'),
(18, 'quan_ly_san_pham');

-- =====================================================================
-- 5. TAI_KHOAN_NGAN_HANGS
-- =====================================================================
INSERT INTO tai_khoan_ngan_hangs (so_tai_khoan, ten_ngan_hang, ten_chu_tai_khoan, user_id) VALUES
('0001122334455', 'Vietcombank',  'NGUYEN THI LAN',     1),
('9988776655441', 'Techcombank',  'TRAN VAN HUNG',      2),
('1234567890123', 'BIDV',         'LE THI MAI',          3),
('5566778899001', 'Vietinbank',   'PHAM QUOC BAO',      4),
('1122334455667', 'ACB',          'HOANG MINH TUAN',    5),
('6677889900112', 'Sacombank',    'VO THI HOA',         6),
('2233445566778', 'MB Bank',      'DANG VAN LONG',      7),
('7788990011223', 'TPBank',       'BUI THI TUYET',      8),
('3344556677889', 'VPBank',       'DINH HOANG KHOA',    9),
('8899001122334', 'Agribank',     'DUONG THANH TRUC',   10),
('0011223344556', 'Vietcombank',  'CONG TY KLONG',      11),
('1100998877665', 'BIDV',         'THIEN LONG CO LTD',  12);

-- =====================================================================
-- 6. DIA_CHI_GIAO_HANGS
-- Mỗi khách hàng có ít nhất 1 địa chỉ; một số có 2
-- =====================================================================
INSERT INTO dia_chi_giao_hangs (address_id, user_id, so_nha, phuong_xa, tinh_thanh) VALUES
(1,  1,  '12 Lý Tự Trọng',         'Bến Nghé',       'TP. Hồ Chí Minh'),
(2,  1,  '5 Nguyễn Huệ',           'Bến Nghé',       'TP. Hồ Chí Minh'),
(3,  2,  '88 Cách Mạng Tháng 8',   'Phường 5',       'TP. Hồ Chí Minh'),
(4,  3,  '31 Phan Xích Long',       'Phường 2',       'TP. Hồ Chí Minh'),
(5,  4,  '101 Nguyễn Văn Cừ',      'An Hòa',         'Cần Thơ'),
(6,  5,  '22 Trần Phú',            'Hải Châu',       'Đà Nẵng'),
(7,  6,  '7 Hùng Vương',           'Phú Hội',        'Huế'),
(8,  7,  '55 Đinh Bộ Lĩnh',        'Phường 24',      'TP. Hồ Chí Minh'),
(9,  8,  '90 Lê Văn Lương',        'Tân Hưng',       'TP. Hồ Chí Minh'),
(10, 9,  '14 Hoàng Diệu',          'Phước Ninh',     'Đà Nẵng'),
(11, 9,  '3 Ngô Quyền',            'An Hải Bắc',     'Đà Nẵng'),
(12, 10, '66 Trường Chinh',        'Phường 13',      'TP. Hồ Chí Minh');

-- =====================================================================
-- 7. DANH_MUC_SAN_PHAMS (phân cấp: cha trước, con sau)
-- =====================================================================
INSERT INTO danh_muc_san_phams (category_id, ten_danh_muc, mo_ta_danh_muc, url_hinh_anh_dai_dien, parent_category_id) VALUES
-- Danh mục gốc
(1,  'Văn phòng phẩm',   'Đồ dùng học tập và văn phòng',           'img/cat/vanphongpham.jpg',  NULL),
(2,  'Điện tử',          'Thiết bị điện tử, công nghệ',             'img/cat/dientu.jpg',        NULL),
(3,  'Thời trang',       'Quần áo, phụ kiện thời trang',            'img/cat/thoitrang.jpg',     NULL),
(4,  'Sách',             'Sách giáo khoa, sách tham khảo',          'img/cat/sach.jpg',          NULL),
-- Danh mục con của Văn phòng phẩm (1)
(5,  'Sổ tay',           'Các loại sổ tay ghi chép',                'img/cat/sotay.jpg',         1),
(6,  'Bút viết',         'Bút bi, bút mực, bút dạ',                 'img/cat/but.jpg',           1),
(7,  'Giấy',             'Giấy in, giấy note, giấy màu',            'img/cat/giay.jpg',          1),
-- Danh mục con của Điện tử (2)
(8,  'Điện thoại',       'Điện thoại di động các hãng',             'img/cat/dienthoai.jpg',     2),
(9,  'Laptop',           'Máy tính xách tay',                       'img/cat/laptop.jpg',        2),
(10, 'Phụ kiện',         'Ốp lưng, sạc, tai nghe',                  'img/cat/phukien.jpg',       2),
-- Danh mục con của Thời trang (3)
(11, 'Áo',               'Áo thun, áo sơ mi, áo khoác',            'img/cat/ao.jpg',            3),
(12, 'Quần',             'Quần jean, quần kaki, quần short',        'img/cat/quan.jpg',          3);

-- =====================================================================
-- 8. SAN_PHAMS
-- =====================================================================
INSERT INTO san_phams (product_id, ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, seller_id, trang_thai) VALUES
(1,  'Sổ KLONG B5 Caro 200 trang',         'Sổ bìa cứng kẻ caro, giấy 100gsm, phù hợp ghi chép hàng ngày',      '1 tháng đổi lỗi', 'Công ty KLONG',          21500,   500, 11, 'dang_ban'),
(2,  'Sổ KLONG A5 Lined 120 trang',        'Sổ bìa mềm kẻ ngang, nhỏ gọn tiện mang theo',                        '1 tháng đổi lỗi', 'Công ty KLONG',          15000,   800, 11, 'dang_ban'),
(3,  'Bút bi Thiên Long TL-027',           'Bút bi ngòi 0.5mm, mực xanh, viết trơn mượt',                        'Không bảo hành',  'Thiên Long',             3500,    2000, 12, 'dang_ban'),
(4,  'Bút gel Thiên Long GEL-B011',        'Bút gel ngòi 0.5mm, nhiều màu, phù hợp học sinh',                     'Không bảo hành',  'Thiên Long',             5000,    1500, 12, 'dang_ban'),
(5,  'Giấy A4 Double A 500 tờ',            'Giấy in A4 70gsm, độ trắng 98%, chống ẩm',                           '3 tháng',         'Double A Thailand',      85000,   300, 13, 'dang_ban'),
(6,  'Tập 200 trang ABC 4 ô ly',           'Tập học sinh 200 trang, giấy trắng, bìa đẹp',                        '1 tháng đổi lỗi', 'ABC Văn phòng phẩm',     12000,   1000, 13, 'dang_ban'),
(7,  'Điện thoại Samsung Galaxy A55 5G',   'RAM 8GB, bộ nhớ 256GB, camera 50MP, pin 5000mAh',                     '12 tháng',        'Samsung Electronics',    9490000, 50,  14, 'dang_ban'),
(8,  'Tai nghe Bluetooth Sony WH-1000XM5', 'Chống ồn chủ động, pin 30h, âm thanh Hi-Res',                        '12 tháng',        'Sony Corporation',       8490000, 30,  14, 'dang_ban'),
(9,  'Ốp lưng iPhone 15 Pro trong suốt',   'Chất liệu TPU cao cấp, chống sốc 4 góc, không ố vàng',               '3 tháng',         'TechWorld',              89000,   200, 14, 'dang_ban'),
(10, 'Áo thun nam basic FashionHub',       'Chất liệu cotton 100%, form regular, 10 màu',                        '7 ngày đổi trả', 'FashionHub',             199000,  150, 15, 'dang_ban'),
(11, 'Quần jean nam slim fit',             'Chất liệu denim co giãn, đường may chắc chắn, 5 màu',                '7 ngày đổi trả', 'FashionHub',             450000,  80,  15, 'ngung_ban'),
(12, 'Laptop Asus VivoBook 15 X1504',      'Intel Core i5-1235U, RAM 8GB, SSD 512GB, màn 15.6 FHD',              '24 tháng',        'ASUSTeK Computer Inc.',  13990000, 20, 14, 'dang_ban');

-- =====================================================================
-- 9. HINH_MINH_HOA
-- =====================================================================
INSERT INTO hinh_minh_hoas (image_id, product_id, url_hinh_anh) VALUES
(1,  1,  'img/products/klong_b5_caro_1.jpg'),
(2,  1,  'img/products/klong_b5_caro_2.jpg'),
(3,  2,  'img/products/klong_a5_lined_1.jpg'),
(4,  3,  'img/products/tl027_1.jpg'),
(5,  3,  'img/products/tl027_2.jpg'),
(6,  4,  'img/products/gel_b011_1.jpg'),
(7,  5,  'img/products/doublea_a4_1.jpg'),
(8,  6,  'img/products/tap_abc_1.jpg'),
(9,  7,  'img/products/samsung_a55_1.jpg'),
(10, 7,  'img/products/samsung_a55_2.jpg'),
(11, 8,  'img/products/sony_wh1000xm5_1.jpg'),
(12, 9,  'img/products/op_ip15pro_1.jpg'),
(13, 10, 'img/products/ao_thun_basic_1.jpg'),
(14, 10, 'img/products/ao_thun_basic_2.jpg'),
(15, 12, 'img/products/asus_x1504_1.jpg');

-- =====================================================================
-- 10. DANH_MUC (N:N san_phams — danh_muc_san_phams)
-- =====================================================================
INSERT INTO danh_muc (product_id, category_id) VALUES
(1,  5),   -- Sổ KLONG → Sổ tay
(1,  1),   -- Sổ KLONG → Văn phòng phẩm
(2,  5),   -- Sổ A5 → Sổ tay
(3,  6),   -- Bút TL → Bút viết
(3,  1),   -- Bút TL → Văn phòng phẩm
(4,  6),   -- Bút gel → Bút viết
(5,  7),   -- Giấy A4 → Giấy
(5,  1),   -- Giấy A4 → Văn phòng phẩm
(6,  1),   -- Tập ABC → Văn phòng phẩm
(7,  8),   -- Samsung → Điện thoại
(7,  2),   -- Samsung → Điện tử
(8,  10),  -- Tai nghe → Phụ kiện
(8,  2),   -- Tai nghe → Điện tử
(9,  10),  -- Ốp lưng → Phụ kiện
(10, 11),  -- Áo thun → Áo
(10, 3),   -- Áo thun → Thời trang
(11, 12),  -- Quần jean → Quần
(12, 9),   -- Laptop → Laptop
(12, 2);   -- Laptop → Điện tử

-- =====================================================================
-- 11. VOUCHERS
-- =====================================================================
INSERT INTO vouchers (voucher_id, so_lan_su_dung_toi_da, so_lan_da_su_dung, muc_giam_gia, dieu_kien_su_dung, ten_chien_dich_km, thoi_gian_bat_dau, thoi_gian_ket_thuc) VALUES
(1,  100, 45, 50000,  'Đơn hàng tối thiểu 200.000đ',  'Chào mừng 2026',          '2026-01-01 00:00:00', '2026-03-31 23:59:59'),
(2,  50,  12, 100000, 'Đơn hàng tối thiểu 500.000đ',  'Tết Nguyên Đán 2026',     '2026-01-15 00:00:00', '2026-02-10 23:59:59'),
(3,  200, 88, 20000,  'Không giới hạn đơn tối thiểu', 'Flash Sale Thứ 6',        '2026-02-01 00:00:00', '2026-04-30 23:59:59'),
(4,  30,  5,  200000, 'Đơn hàng tối thiểu 1.000.000đ','Sinh nhật sàn 2026',      '2026-03-01 00:00:00', '2026-03-15 23:59:59'),
(5,  500, 0,  30000,  'Đơn hàng tối thiểu 150.000đ',  'Ngày Phụ nữ Việt Nam',   '2026-10-15 00:00:00', '2026-10-20 23:59:59'),
(6,  80,  30, 75000,  'Đơn hàng tối thiểu 300.000đ',  'Giảm giá cuối tháng',    '2026-01-20 00:00:00', '2026-01-31 23:59:59'),
(7,  150, 60, 15000,  'Không giới hạn',               'Miễn phí ship mùa hè',   '2026-04-01 00:00:00', '2026-06-30 23:59:59'),
(8,  40,  8,  150000, 'Đơn hàng tối thiểu 800.000đ',  'Tech Festival',           '2026-03-10 00:00:00', '2026-03-20 23:59:59'),
(9,  60,  22, 50000,  'Đơn hàng tối thiểu 250.000đ',  'Khai xuân mua sắm',      '2026-02-05 00:00:00', '2026-02-28 23:59:59'),
(10, 100, 10, 25000,  'Đơn hàng tối thiểu 100.000đ',  'Voucher Học sinh SV',     '2026-01-10 00:00:00', '2026-12-31 23:59:59');

-- =====================================================================
-- 12. DON_HANGS
-- address_id phải tham chiếu đúng (address_id, user_id) của dia_chi_giao_hangs
-- user_id tham chiếu nguoi_dungs (dùng id khách hàng 1–10)
-- =====================================================================
INSERT INTO don_hangs (order_id, address_id, user_id, voucher_id, thoi_gian_giao_dich, phuong_thuc_thanh_toan, trang_thai_don_hang, trang_thai_thanh_toan) VALUES
(1,  1,  1, 1,    '2026-01-05 10:30:00', 'vi_dien_tu',  'giao_thanh_cong',  'da_thanh_toan'),
(2,  3,  2, 3,    '2026-01-10 14:15:00', 'COD',          'giao_thanh_cong',  'da_thanh_toan'),
(3,  4,  3, NULL, '2026-01-12 09:00:00', 'ngan_hang',    'giao_thanh_cong',  'da_thanh_toan'),
(4,  5,  4, 6,    '2026-01-20 16:45:00', 'COD',          'giao_thanh_cong',  'da_thanh_toan'),
(5,  6,  5, NULL, '2026-02-01 11:20:00', 'vi_dien_tu',  'giao_thanh_cong',  'da_thanh_toan'),
(6,  7,  6, 9,    '2026-02-10 08:30:00', 'ngan_hang',    'da_xac_nhan',      'da_thanh_toan'),
(7,  8,  7, NULL, '2026-02-15 13:00:00', 'COD',          'dang_giao_hang',   'chua_thanh_toan'),
(8,  9,  8, 3,    '2026-02-20 10:00:00', 'vi_dien_tu',  'cho_giao_hang',    'da_thanh_toan'),
(9,  10, 9, 8,    '2026-03-01 09:45:00', 'ngan_hang',    'giao_thanh_cong',  'da_thanh_toan'),
(10, 12, 10,NULL, '2026-03-05 15:30:00', 'COD',          'cho_xac_nhan',     'chua_thanh_toan'),
(11, 2,  1, 10,   '2026-03-10 10:00:00', 'vi_dien_tu',  'giao_that_bai',    'da_thanh_toan'),
(12, 11, 9, NULL, '2026-03-15 11:30:00', 'COD',          'giao_thanh_cong',  'da_thanh_toan');

-- =====================================================================
-- 13. CHI_TIET_DON_HANGS
-- order_detail_id = product_id của sản phẩm đặt mua
-- =====================================================================
INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua) VALUES
-- Đơn 1: Sổ B5 + Bút bi
(1,  1,  21500,   2),
(1,  3,  3500,    5),
-- Đơn 2: Giấy A4 + Bút gel
(2,  5,  85000,   1),
(2,  4,  5000,    3),
-- Đơn 3: Tập ABC + Sổ A5
(3,  6,  12000,   4),
(3,  2,  15000,   2),
-- Đơn 4: Samsung A55
(4,  7,  9490000, 1),
-- Đơn 5: Tai nghe Sony
(5,  8,  8490000, 1),
-- Đơn 6: Ốp lưng + Bút gel
(6,  9,  89000,   1),
(6,  4,  5000,    2),
-- Đơn 7: Áo thun x3
(7,  10, 199000,  3),
-- Đơn 8: Sổ B5 + Giấy A4
(8,  1,  21500,   1),
(8,  5,  85000,   2),
-- Đơn 9: Laptop Asus
(9,  12, 13990000, 1),
-- Đơn 10: Bút bi x10
(10, 3,  3500,    10),
-- Đơn 11: Sổ A5 + Bút bi (đơn giao thất bại)
(11, 2,  15000,   2),
(11, 3,  3500,    4),
-- Đơn 12: Tai nghe Sony + Ốp lưng
(12, 8,  8490000, 1),
(12, 9,  89000,   2);

-- =====================================================================
-- 14. VAN_DONS (chỉ tạo khi đơn đã ở trạng thái 'da_xac_nhan' trở lên)
-- Các đơn có vận đơn: 1,2,3,4,5,6,7,8,9,11,12
-- =====================================================================
INSERT INTO van_dons (van_don_id, order_id, don_vi_van_chuyen, trang_thai_giao_hang, ngay_giao_du_kien, ngay_giao_thuc_te, chi_phi_giao_hang) VALUES
(1,  1,  'giao_hang_tiet_kiem', 'giao_thanh_cong',    '2026-01-08 17:00:00', '2026-01-07 14:30:00', 22000),
(2,  2,  'j&t',                 'giao_thanh_cong',    '2026-01-13 17:00:00', '2026-01-13 10:00:00', 18000),
(3,  3,  'viettel_post',        'giao_thanh_cong',    '2026-01-15 17:00:00', '2026-01-14 16:45:00', 25000),
(4,  4,  'ninjavan',            'giao_thanh_cong',    '2026-01-23 17:00:00', '2026-01-22 11:30:00', 20000),
(5,  5,  'giao_hang_tiet_kiem', 'giao_thanh_cong',    '2026-02-04 17:00:00', '2026-02-04 09:15:00', 22000),
(6,  6,  'j&t',                 'cho_giao_hang',  '2026-02-13 17:00:00', NULL,                  18000),
(7,  7,  'viettel_post',        'dang_giao_hang',  '2026-02-18 17:00:00', NULL,                  25000),
(8,  8,  'ninjavan',            'cho_giao_hang',  '2026-02-23 17:00:00', NULL,                  20000),
(9,  9,  'giao_hang_tiet_kiem', 'giao_thanh_cong',    '2026-03-04 17:00:00', '2026-03-03 15:00:00', 0),
(10, 11, 'j&t',                 'giao_that_bai',     '2026-03-13 17:00:00', NULL,                  18000),
(11, 12, 'viettel_post',        'giao_thanh_cong',    '2026-03-18 17:00:00', '2026-03-17 13:00:00', 22000);

-- =====================================================================
-- 15. DANH_GIA_SAN_PHAMS
-- Chỉ đánh giá đơn 'giao_thanh_cong': order_id 1,2,3,4,5,9,12
-- =====================================================================
-- FIX: thêm danh_gia_id (PK), đổi cột order_detail_id → product_id cho đúng schema
INSERT INTO danh_gia_san_phams (danh_gia_id, order_id, product_id, thoi_gian_danh_gia, url_hinh_anh, noi_dung_binh_luan, so_sao, thoi_gian_sua_cuoi) VALUES
(1,  1,  1,  '2026-01-09 08:00:00', 'img/review/r1.jpg',  'Sổ đẹp, giấy tốt, giao nhanh, rất hài lòng!',         '5', NULL),
(2,  1,  3,  '2026-01-09 08:10:00', NULL,                 'Bút viết trơn, không bị nhòe, dùng tốt.',              '4', NULL),
(3,  2,  5,  '2026-01-14 10:00:00', 'img/review/r3.jpg',  'Giấy trắng đẹp, in ra sắc nét, đóng gói cẩn thận.',   '5', NULL),
(4,  2,  4,  '2026-01-14 10:15:00', NULL,                 'Bút gel viết đẹp nhưng hơi tốn mực.',                  '3', '2026-01-15 09:00:00'),
(5,  3,  6,  '2026-01-15 14:00:00', NULL,                 'Tập bình thường, giấy hơi mỏng nhưng giá ổn.',         '3', NULL),
(6,  3,  2,  '2026-01-15 14:05:00', 'img/review/r6.jpg',  'Sổ nhỏ gọn, tiện mang đi học, thích lắm!',            '5', NULL),
(7,  4,  7,  '2026-01-23 18:00:00', 'img/review/r7.jpg',  'Điện thoại chụp ảnh rất đẹp, pin trâu, giao đúng hẹn.','5', NULL),
(8,  5,  8,  '2026-02-05 09:00:00', NULL,                 'Tai nghe chống ồn cực tốt, âm thanh trong vắt.',       '5', NULL),
(9,  9,  12, '2026-03-04 17:30:00', 'img/review/r9.jpg',  'Laptop chạy nhanh, màn hình đẹp, pin khá tốt.',        '4', '2026-03-05 08:00:00'),
(10, 12, 8,  '2026-03-18 16:00:00', NULL,                 'Tai nghe tốt, đóng gói an toàn.',                      '4', NULL);

-- =====================================================================
-- 16. THEM_VAO_GIO (giỏ hàng hiện tại của khách)
-- =====================================================================
INSERT INTO them_vao_gio (product_id, user_id, so_luong_dinh_mua) VALUES
(1,  2,  1),   -- Khách 2 muốn mua Sổ B5
(3,  2,  3),   -- Khách 2 muốn mua Bút bi x3
(7,  3,  1),   -- Khách 3 muốn mua Samsung A55
(5,  4,  2),   -- Khách 4 muốn mua Giấy A4 x2
(10, 5,  2),   -- Khách 5 muốn mua Áo thun x2
(8,  6,  1),   -- Khách 6 muốn mua Tai nghe Sony
(9,  6,  1),   -- Khách 6 muốn mua Ốp lưng
(12, 7,  1),   -- Khách 7 muốn mua Laptop
(4,  8,  5),   -- Khách 8 muốn mua Bút gel x5
(2,  10, 2),   -- Khách 10 muốn mua Sổ A5 x2
(6,  10, 3),   -- Khách 10 muốn mua Tập ABC x3
(1,  9,  1);   -- Khách 9 muốn mua Sổ B5

-- =====================================================================
-- 17. AP_DUNG_VOUCHERS (đồng bộ với don_hangs.voucher_id != NULL)
-- =====================================================================
INSERT INTO ap_dung_vouchers (voucher_id, order_id) VALUES
(1,  1),
(3,  2),
(6,  4),
(9,  6),
(3,  8),
(8,  9),
(10, 11);

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- BỔ SUNG để đủ >= 10 hàng cho các bảng còn thiếu
-- =====================================================================

-- Thêm 5 người dùng mới (id 19–23) cho nguoi_bans
INSERT INTO nguoi_dungs (id, ho, dem, ten, so_dien_thoai, email, mat_khau) VALUES
(19, 'Shop',   NULL, 'Đồ Gia Dụng MinhHoa',  '0281234519', 'seller.minhhoa@gmail.com',   '$2b$12$hashed_pw_19'),
(20, 'Công ty', NULL, 'Mỹ Phẩm LaVie',        '0281234520', 'seller.lavie@gmail.com',     '$2b$12$hashed_pw_20'),
(21, 'Shop',   NULL, 'Thể Thao SportZone',    '0281234521', 'seller.sportzone@gmail.com', '$2b$12$hashed_pw_21'),
(22, 'Cửa hàng', NULL, 'Sách Hay BookNest',   '0281234522', 'seller.booknest@gmail.com',  '$2b$12$hashed_pw_22'),
(23, 'Công ty', NULL, 'Nội Thất HomeDecor',   '0281234523', 'seller.homedecor@gmail.com', '$2b$12$hashed_pw_23');

-- Thêm 7 người dùng mới (id 24–30) cho quan_tri_viens
INSERT INTO nguoi_dungs (id, ho, dem, ten, so_dien_thoai, email, mat_khau) VALUES
(24, 'Admin', NULL, 'Gian Hàng 1',  '0901234524', 'admin.gianhang1@ecom.vn',  '$2b$12$hashed_pw_24'),
(25, 'Admin', NULL, 'Người Dùng 1', '0901234525', 'admin.nguoidung1@ecom.vn', '$2b$12$hashed_pw_25'),
(26, 'Admin', NULL, 'Đơn Hàng 1',  '0901234526', 'admin.donhang1@ecom.vn',   '$2b$12$hashed_pw_26'),
(27, 'Admin', NULL, 'Sản Phẩm 1',  '0901234527', 'admin.sanpham1@ecom.vn',   '$2b$12$hashed_pw_27'),
(28, 'Admin', NULL, 'Gian Hàng 2', '0901234528', 'admin.gianhang2@ecom.vn',  '$2b$12$hashed_pw_28'),
(29, 'Admin', NULL, 'Người Dùng 2','0901234529', 'admin.nguoidung2@ecom.vn', '$2b$12$hashed_pw_29'),
(30, 'Admin', NULL, 'Đơn Hàng 2', '0901234530', 'admin.donhang2@ecom.vn',   '$2b$12$hashed_pw_30');

-- Bổ sung nguoi_bans (id 19–23)
INSERT INTO nguoi_bans (id, ten_gian_hang, dia_chi_lay_hang, trang_thai_hoat_dong, giay_phep_kinh_doanh) VALUES
(19, 'MinhHoa Đồ Gia Dụng',   '12 Tân Kỳ Tân Quý, Bình Tân, HCM',   'hoat_dong', 'GP-HCM-2021-501'),
(20, 'LaVie Mỹ Phẩm',         '56 Âu Cơ, Tân Phú, HCM',              'hoat_dong', 'GP-HCM-2020-602'),
(21, 'SportZone Thể Thao',    '34 Lạc Long Quân, Q.11, HCM',          'hoat_dong', 'GP-HCM-2019-703'),
(22, 'BookNest Sách Hay',      '78 Nguyễn Đình Chiểu, Q.3, HCM',      'hoat_dong', 'GP-HCM-2023-804'),
(23, 'HomeDecor Nội Thất',    '100 Kinh Dương Vương, Bình Tân, HCM', 'tam_ngung', 'GP-HCM-2022-905');

-- Bổ sung quan_tri_viens (id 24–30)
INSERT INTO quan_tri_viens (id, quyen_han) VALUES
(24, 'quan_ly_gian_hang'),
(25, 'quan_ly_nguoi_dung'),
(26, 'quan_ly_don_hang'),
(27, 'quan_ly_san_pham'),
(28, 'quan_ly_gian_hang'),
(29, 'quan_ly_nguoi_dung'),
(30, 'quan_ly_don_hang');

-- Bổ sung ap_dung_vouchers (thêm 3 hàng từ đơn hàng có voucher chưa được log)
-- Thêm 3 đơn hàng mới có voucher vào don_hangs để đủ 10 hàng ap_dung_vouchers
INSERT INTO don_hangs (order_id, address_id, user_id, voucher_id, thoi_gian_giao_dich, phuong_thuc_thanh_toan, trang_thai_don_hang, trang_thai_thanh_toan) VALUES
(13, 3,  2, 2,  '2026-02-08 09:00:00', 'ngan_hang',   'giao_thanh_cong', 'da_thanh_toan'),
(14, 4,  3, 7,  '2026-03-20 10:00:00', 'COD',          'cho_xac_nhan',    'chua_thanh_toan'),
(15, 6,  5, 10, '2026-03-25 14:00:00', 'vi_dien_tu',  'cho_xac_nhan',    'da_thanh_toan');

INSERT INTO chi_tiet_don_hangs (order_id, order_detail_id, gia_ban, so_luong_mua) VALUES
(13, 1,  21500, 3),
(14, 5,  85000, 1),
(15, 10, 199000, 1);

INSERT INTO ap_dung_vouchers (voucher_id, order_id) VALUES
(2,  13),
(7,  14),
(10, 15);
