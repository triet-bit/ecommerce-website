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
    in trang_thai varchar(50) -- thêm vào ở ràng buộc 1.3.10 
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
