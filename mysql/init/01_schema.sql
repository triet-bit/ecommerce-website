SET NAMES 'utf8mb4';
CREATE DATABASE IF NOT EXISTS ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; 

USE ecommerce; 

SET FOREIGN_KEY_CHECKS = 0; 

CREATE TABLE nguoi_dungs(
    id INT AUTO_INCREMENT, 
    ho varchar(50) NOT NULL,
    dem varchar(50),  
    ten varchar(50) NOT NULL, 
    so_dien_thoai varchar(20) UNIQUE,           -- ràng buộc 1.3.6: số điện thoại duy nhất
    email varchar(100) NOT NULL UNIQUE,   -- ràng buộc 1.3.6: email duy nhất
    mat_khau varchar(255) NOT NULL, 
    ngay_tao datetime DEFAULT CURRENT_TIMESTAMP, 
    ngay_cap_nhat datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    PRIMARY KEY (id) 
); 

CREATE TABLE khach_hangs(
    id INT, 
    tong_diem_tich_luy int DEFAULT 0, 
    so_diem_da_dung int DEFAULT 0, 
    so_du_vi_dien_tu float DEFAULT 0 CHECK (so_du_vi_dien_tu >= 0), 
    FOREIGN KEY (id) REFERENCES nguoi_dungs(id) ON DELETE CASCADE, 
    PRIMARY KEY (id), 
    CONSTRAINT check_diem CHECK (so_diem_da_dung <= tong_diem_tich_luy)    -- ràng buộc 1.3.8: điểm đã dùng ≤ tổng tích lũy

); 

CREATE TABLE nguoi_bans(
    id INT , 
    ten_gian_hang varchar(100) NOT NULL, 
    dia_chi_lay_hang varchar(255) NOT NULL, 
    trang_thai_hoat_dong enum('hoat_dong', 'tam_ngung', 'bi_khoa') DEFAULT 'hoat_dong', 
    giay_phep_kinh_doanh varchar(100) NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY (id) REFERENCES nguoi_dungs(id) ON DELETE CASCADE 
    
); 

CREATE TABLE quan_tri_viens(
    id INT , 
    quyen_han enum('super_admin', 'quan_ly_gian_hang', 'quan_ly_nguoi_dung', 'quan_ly_don_hang', 'quan_ly_san_pham') NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY (id) REFERENCES nguoi_dungs(id) ON DELETE CASCADE
); 

CREATE TABLE tai_khoan_ngan_hangs(
    so_tai_khoan varchar(24) NOT NULL, 
    ten_ngan_hang varchar(50) NOT NULL, 
    ten_chu_tai_khoan varchar(100) NOT NULL, 
    user_id INT NOT NULL, 
    PRIMARY KEY (so_tai_khoan, user_id), 
    FOREIGN KEY (user_id) REFERENCES nguoi_dungs(id) ON DELETE CASCADE
); 

CREATE TABLE dia_chi_giao_hangs(
    address_id INT AUTO_INCREMENT,          -- FIX: AUTO_INCREMENT + PK độc lập để don_hangs có thể FK đúng
    user_id INT NOT NULL, 
    phuong_xa varchar(50) NOT NULL, 
    tinh_thanh varchar(50) NOT NULL, 
    so_nha varchar(64) NOT NULL, 
    PRIMARY KEY (address_id),               -- FIX: PK đơn để don_hangs.address_id FK được
    UNIQUE KEY uq_addr_user (address_id, user_id),
    FOREIGN KEY (user_id) REFERENCES khach_hangs(id) ON DELETE CASCADE 
); 

CREATE TABLE danh_muc_san_phams(
    category_id INT AUTO_INCREMENT, 
    ten_danh_muc varchar(50) NOT NULL, 
    mo_ta_danh_muc varchar(255) NOT NULL, 
    url_hinh_anh_dai_dien varchar(255) NOT NULL, 
    parent_category_id INT, -- null is main category
    PRIMARY KEY (category_id), 
    FOREIGN KEY (parent_category_id) REFERENCES danh_muc_san_phams(category_id) ON DELETE SET NULL 
); 

CREATE TABLE san_phams(
    product_id INT AUTO_INCREMENT, 
    ten_san_pham varchar(255) NOT NULL, 
    mo_ta_chi_tiet varchar(512) NOT NULL,
    loai_bao_hanh varchar(50) NOT NULL,
    to_chuc_san_xuat varchar(100) NOT NULL, 
    gia_ban decimal(13,2) NOT NULL CHECK (gia_ban >= 0), -- ràng buộc 1.3.5
    so_luong_ton_kho int NOT NULL CHECK (so_luong_ton_kho >= 0), -- ràng buộc 1.3.5
    seller_id int NOT NULL, 
    trang_thai enum('dang_ban','ngung_ban','het_hang') DEFAULT 'dang_ban', -- thêm vào ở ràng buộc 1.3.10 
    PRIMARY KEY (product_id), 
    FOREIGN KEY (seller_id) REFERENCES nguoi_bans(id) ON DELETE CASCADE 
); 

CREATE TABLE hinh_minh_hoas(
    image_id INT AUTO_INCREMENT, 
    product_id INT NOT NULL, 
    url_hinh_anh varchar(255) NOT NULL, -- thêm vào 
    PRIMARY KEY (image_id, product_id), 
    FOREIGN KEY (product_id) REFERENCES san_phams(product_id) ON DELETE CASCADE 
); 

CREATE TABLE danh_muc(
    product_id INT NOT NULL, 
    category_id INT NOT NULL, 
    PRIMARY KEY (product_id, category_id), 
    FOREIGN KEY (product_id) REFERENCES san_phams(product_id) ON DELETE CASCADE, 
    FOREIGN KEY (category_id) REFERENCES danh_muc_san_phams(category_id) ON DELETE CASCADE 
); 
    
CREATE TABLE them_vao_gio(
    product_id          INT NOT NULL,
    user_id             INT NOT NULL,
    so_luong_dinh_mua   INT NOT NULL DEFAULT 1 CHECK (so_luong_dinh_mua > 0), -- thêm vào: số lượng phải > 0
    PRIMARY KEY (product_id, user_id),
    FOREIGN KEY (product_id) REFERENCES san_phams(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)    REFERENCES khach_hangs(id)        ON DELETE CASCADE
    -- ràng buộc 1.3.5 & 1.3.10: so_luong_dinh_mua <= ton_kho và san_pham.trang_thai = 'dang_ban'
    -- kiểm soát ở tầng ứng dụng hoặc TRIGGER
);
CREATE TABLE vouchers(
    voucher_id INT AUTO_INCREMENT, 
    so_lan_su_dung_toi_da INT NOT NULL CHECK (so_lan_su_dung_toi_da > 0), 
    so_lan_da_su_dung       INT          DEFAULT 0,  -- thêm vào: bổ sung để ktra tính hợp lệ (ràng buộc 1.3.2)
    muc_giam_gia float NOT NULL CHECK (muc_giam_gia > 0), 
    dieu_kien_su_dung varchar(255) NOT NULL, 
    ten_chien_dich_km varchar(255) NOT NULL, 
    thoi_gian_bat_dau datetime NOT NULL, 
    thoi_gian_ket_thuc datetime NOT NULL, 
    CONSTRAINT chk_voucher_time CHECK (thoi_gian_ket_thuc > thoi_gian_bat_dau),  -- ràng buộc 1.3.2
    CONSTRAINT chk_so_lan CHECK (so_lan_da_su_dung <= so_lan_su_dung_toi_da),    -- ràng buộc 1.3.2
    PRIMARY KEY (voucher_id) 
); 

CREATE TABLE don_hangs(
    order_id INT AUTO_INCREMENT, 
    address_id INT NOT NULL,
    voucher_id INT, 
    user_id int NOT NULL, 
    thoi_gian_giao_dich datetime DEFAULT CURRENT_TIMESTAMP, 
    phuong_thuc_thanh_toan enum("COD","vi_dien_tu","ngan_hang") NOT NULL, 
    trang_thai_don_hang enum("cho_xac_nhan","da_xac_nhan","cho_giao_hang","dang_giao_hang","giao_thanh_cong","giao_that_bai") DEFAULT "cho_xac_nhan", 
    trang_thai_thanh_toan enum("chua_thanh_toan","da_thanh_toan") DEFAULT "chua_thanh_toan", 
    
    PRIMARY KEY (order_id), 
    FOREIGN KEY (address_id) REFERENCES dia_chi_giao_hangs(address_id) ON DELETE RESTRICT, 
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id) ON DELETE SET NULL, 
    FOREIGN KEY (user_id) REFERENCES nguoi_dungs(id) ON DELETE RESTRICT
    -- không cho xóa khách hàng khi còn đơn hàng và không cho xóa địa chỉ khi còn đơn hàng 
    -- voucher set null thì là do thích hay không thích áp dụng
); 

CREATE TABLE chi_tiet_don_hangs(
    order_id INT NOT NULL, 
    order_detail_id INT NOT NULL, 
    gia_ban float NOT NULL CHECK (gia_ban >= 0), -- giá chốt tại thời điểm mua (ràng buộc 1.3.7), 
    so_luong_mua int NOT NULL CHECK (so_luong_mua > 0), 
    PRIMARY KEY (order_id, order_detail_id), 
    FOREIGN KEY (order_id) REFERENCES don_hangs(order_id) ON DELETE CASCADE, 
    FOREIGN KEY (order_detail_id) REFERENCES san_phams(product_id) ON DELETE RESTRICT 
); 

CREATE TABLE van_dons(
    van_don_id INT AUTO_INCREMENT, 
    don_vi_van_chuyen enum("viettel_post", "giao_hang_tiet_kiem", "j&t", "ninjavan") NOT NULL,
    trang_thai_giao_hang enum("cho_giao_hang", "dang_giao_hang", "giao_thanh_cong", "giao_that_bai") DEFAULT "cho_giao_hang", -- check lại cái này
    order_id INT NOT NULL UNIQUE, 
    ngay_giao_du_kien datetime NOT NULL, 
    ngay_giao_thuc_te datetime, -- có thể null thì chưa xác định được
    chi_phi_giao_hang float NOT NULL CHECK (chi_phi_giao_hang >= 0), 
    PRIMARY KEY (van_don_id), 
    FOREIGN KEY (order_id) REFERENCES don_hangs(order_id) ON DELETE CASCADE 
); 


CREATE TABLE danh_gia_san_phams(
    danh_gia_id INT AUTO_INCREMENT,         -- FIX: thêm AUTO_INCREMENT tránh phải insert thủ công
    order_id INT, 
    product_id INT, 
    thoi_gian_danh_gia datetime DEFAULT CURRENT_TIMESTAMP, 
    url_hinh_anh varchar(255), 
    noi_dung_binh_luan varchar(512), 
    so_sao enum('1', '2', '3', '4', '5') NOT NULL, 
    thoi_gian_sua_cuoi datetime, -- thêm vào: kiểm soát "chỉnh sửa trong thời gian nhất định" (ràng buộc 1.3.3)
    PRIMARY KEY (danh_gia_id, order_id, product_id), 
    FOREIGN KEY (order_id, product_id)
        REFERENCES chi_tiet_don_hangs(order_id, order_detail_id) ON DELETE CASCADE
); 


CREATE TABLE ap_dung_vouchers(
    voucher_id INT NOT NULL, 
    order_id INT NOT NULL, 
    PRIMARY KEY (order_id),  -- mỗi đơn tối đa 1 voucher (ràng buộc 1.3.2)
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id) ON DELETE CASCADE, 
    FOREIGN KEY (order_id) REFERENCES don_hangs(order_id) ON DELETE CASCADE 
); 



SET FOREIGN_KEY_CHECKS = 1;

