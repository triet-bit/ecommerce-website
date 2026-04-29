DROP PROCEDURE IF EXISTS sp_them_san_pham;
DELIMITER $$
create procedure sp_them_san_pham(
	in ten_san_pham varchar(255) , 
    in mo_ta_chi_tiet varchar(512),
    in loai_bao_hanh varchar(50),
    in to_chuc_san_xuat varchar(100), 
    in gia_ban decimal(13,2), -- ràng buộc 1.3.5
    in so_luong_ton_kho int , -- ràng buộc 1.3.5
    in seller_id int, 
    in trang_thai varchar(50), -- thêm vào ở ràng buộc 1.3.10 
    in p_url_hinh_anh varchar(255) -- Thêm tham số hình ảnh (P9)
) 
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	begin 
		rollback; 
		resignal; 
	end; 
	start transaction; 
	if ten_san_pham is null or trim(ten_san_pham) = '' then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: ten_san_pham must not be null"; 
	end if; 
	
	if mo_ta_chi_tiet is null then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: mo_ta_chi_tiet must not be null"; 
	end if;
	
	if loai_bao_hanh is null then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: loai_bao_hanh must not be null"; 
	end if; 
	
	if to_chuc_san_xuat is null then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: to_chuc_san_xuat must not be null";
	end if; 
	
	if gia_ban is null then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: gia_ban must not be null";
	elseif gia_ban <= 0 then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: gia_ban must not below zero";
	end if; 
	
	if so_luong_ton_kho is null then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so_luong_ton_kho must not be null";
	elseif so_luong_ton_kho < 0 then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so_luong_ton_kho must not below zero";
	end if;
	
	if seller_id is null then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: seller_id must not be null";
	elseif not exists (select 1 from nguoi_bans where id = seller_id) then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: seller_id not exist";
	end if; 
	
	IF trang_thai IS NULL or trang_thai not in ('dang_ban','ngung_ban','het_hang') THEN  
	    SIGNAL SQLSTATE '45000' 
	    SET MESSAGE_TEXT = 'Error: trang_thai iss invalid';
	end IF ;
	
	insert into san_phams (ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat,gia_ban,so_luong_ton_kho, seller_id, trang_thai ) values 
		(ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat,gia_ban,so_luong_ton_kho, seller_id, trang_thai ); 
	
    SET @new_product_id = LAST_INSERT_ID();

    -- Thêm hình minh họa nếu có truyền vào (P9)
    IF p_url_hinh_anh IS NOT NULL AND TRIM(p_url_hinh_anh) <> '' THEN
        INSERT INTO hinh_minh_hoas (product_id, url_hinh_anh) VALUES (@new_product_id, p_url_hinh_anh);
    END IF;

	select 'them san pham thanh cong' as message, @new_product_id as product_id; 
	commit; 		
END $$        

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_cap_nhat_san_pham;
DELIMITER $$
create procedure sp_cap_nhat_san_pham(
	in p_id int, 
	in p_ten varchar(255) , 
    in p_mo_ta varchar(512),
    in p_bao_hanh varchar(50),
    in p_to_chuc_san_xuat varchar(100), 
    in p_gia_ban decimal(13,2), -- ràng buộc 1.3.5
    in p_so_luong_ton_kho int , -- ràng buộc 1.3.5
    in p_trang_thai varchar(50) -- thêm vào ở ràng buộc 1.3.10 
)
begin 
	DECLARE tong_luong_dang_ban int; 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	begin 
		rollback; 
		resignal; 
	end; 
	start transaction;
	if p_id is null or p_id < 0 then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product id is invalid"; 	
	end if; 

	if not exists (select 1 from san_phams where product_id = p_id) then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product not exists"; 	
	end if; 	
	
	if p_so_luong_ton_kho is not null and p_so_luong_ton_kho < 0 then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so luong ton kho is invalid";
	end if; 

    set tong_luong_dang_ban = coalesce((select sum(ct.so_luong_mua) 
	from chi_tiet_don_hangs ct
	join don_hangs dh on ct.order_id = dh.order_id
	where ct.order_detail_id = p_id 
	and dh.trang_thai_don_hang not in ('giao_thanh_cong', 'giao_that_bai')),0);
    if p_so_luong_ton_kho is not null and p_so_luong_ton_kho < tong_luong_dang_ban then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so luong ton kho is invalid";
	end if; 

	if p_gia_ban is not null and p_gia_ban < 0 then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product price is invalid";
	end if; 
	
	if p_trang_thai is not null and p_trang_thai not in ('dang_ban','ngung_ban','het_hang') then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: trang_thai is invalid";
	end if; 
	
	update san_phams 
	set 
		ten_san_pham     = COALESCE(p_ten,     ten_san_pham),
	    mo_ta_chi_tiet   = COALESCE(p_mo_ta,   mo_ta_chi_tiet),
	    loai_bao_hanh    = COALESCE(p_bao_hanh,    loai_bao_hanh),
	    to_chuc_san_xuat = COALESCE(p_to_chuc_san_xuat, to_chuc_san_xuat),
	    gia_ban          = COALESCE(p_gia_ban,           gia_ban),
	    so_luong_ton_kho = COALESCE(p_so_luong_ton_kho, so_luong_ton_kho),
	    trang_thai       = COALESCE(p_trang_thai,        trang_thai)
	where product_id = p_id; 
	COMMIT; 
END $$        

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_xoa_san_pham;
DELIMITER $$
create procedure sp_xoa_san_pham(
	in p_id int 
)
begin 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	begin 
		rollback; 
		resignal; 
	end; 
	start transaction;

	IF NOT EXISTS (
	        SELECT 1 FROM san_phams WHERE product_id = p_id
	    ) THEN
	        SIGNAL SQLSTATE '45000'
	        SET MESSAGE_TEXT = 'Error: san_pham not exist';
	    END IF;	
	if exists (
		select 1 from chi_tiet_don_hangs ct 
		join don_hangs dh on ct.order_id = dh.order_id 
		where ct.order_detail_id = p_id and dh.trang_thai_don_hang not in ('giao_thanh_cong', 'giao_that_bai')
	) then 
		UPDATE san_phams
        SET trang_thai = 'ngung_ban'
        WHERE product_id = p_id;	
        SELECT 'UPDATE: product state has been converted into ngung_ban' AS message;

	ELSE
        DELETE FROM san_phams WHERE product_id = p_id;
        SELECT 'DELETE: product has been deleted' AS message;
    END IF;

	commit; 
END $$        

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_thong_ke_doanh_thu_nguoi_ban;
CREATE PROCEDURE sp_thong_ke_doanh_thu_nguoi_ban(
    IN p_seller_id INT,
    IN p_tu_ngay DATETIME,
    IN p_den_ngay DATETIME
)
BEGIN
    -- 1. Kiểm tra khoảng thời gian hợp lệ
    IF p_tu_ngay > p_den_ngay THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: tu_ngay phai nho hon hoac bang den_ngay';
    END IF;

    -- 2. Kiểm tra seller tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM nguoi_bans WHERE id = p_seller_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: seller_id khong ton tai';
    END IF;

    -- 3. Thống kê doanh thu (chỉ tính đơn đã thanh toán + giao thành công)
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
        
        AND dh.trang_thai_thanh_toan = 'da_thanh_toan'
        AND dh.trang_thai_don_hang = 'giao_thanh_cong'

    GROUP BY 
        sp.product_id, sp.ten_san_pham

    HAVING 
        doanh_thu > 0

    ORDER BY 
        doanh_thu DESC;

END$$

DELIMITER ;

DELIMITER // 
DROP PROCEDURE IF EXISTS sp_lay_don_hang_theo_khach;
CREATE PROCEDURE sp_lay_don_hang_theo_khach(
    IN p_user_id INT, 
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
        vd.don_vi_van_chuyen,
        vd.trang_thai_giao_hang,
        vd.ngay_giao_du_kien,
        vd.chi_phi_giao_hang
    FROM don_hangs dh
    JOIN chi_tiet_don_hangs ctdh ON dh.order_id = ctdh.order_id
    JOIN san_phams sp ON ctdh.order_detail_id = sp.product_id
    LEFT JOIN van_dons vd ON dh.order_id = vd.order_id
    WHERE dh.user_id = p_user_id
      -- Nếu p_trang_thai bị null (hoặc rỗng) thì lấy tất cả, nếu có truyền thì lọc đúng trạng thái
      AND (p_trang_thai IS NULL OR p_trang_thai = '' OR dh.trang_thai_don_hang = p_trang_thai)
    ORDER BY dh.thoi_gian_giao_dich DESC;
END // 
DELIMITER ;

-- Thống kê xếp hạng khách hàng (Sử dụng hàm fn_xep_hang_khach_hang)
DROP PROCEDURE IF EXISTS sp_thong_ke_khach_hang_ranking;
DELIMITER //
CREATE PROCEDURE sp_thong_ke_khach_hang_ranking(IN p_top INT)
BEGIN
    SELECT 
        kh.id AS id,
        CONCAT(nd.ho, ' ', IFNULL(nd.dem, ''), ' ', nd.ten) AS ho_ten,
        nd.email,
        kh.tong_diem_tich_luy,
        fn_xep_hang_khach_hang(kh.id) AS hang_khach_hang,
        IFNULL(SUM(ct.so_luong_mua * ct.gia_ban), 0) AS tong_chi_tieu,
        COUNT(DISTINCT dh.order_id) AS so_don_hang
    FROM khach_hangs kh
    JOIN nguoi_dungs nd ON kh.id = nd.id
    LEFT JOIN don_hangs dh ON kh.id = dh.user_id AND dh.trang_thai_don_hang = 'giao_thanh_cong'
    LEFT JOIN chi_tiet_don_hangs ct ON dh.order_id = ct.order_id
    GROUP BY kh.id, ho_ten, nd.email, kh.tong_diem_tich_luy
    ORDER BY tong_chi_tieu DESC
    LIMIT p_top;
END //
DELIMITER ;