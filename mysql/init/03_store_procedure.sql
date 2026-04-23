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

	if not exists (select 1 from san_phams where id = p_id) then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product not exists"; 	
	end if; 	
	
	if exists (
		select 1 
		from chi_tiet_don_hangs ct 
		join don_hangs dh on ct.order_id = dh.order_id
		where ct.order_detail_id = p_id and dh.trang_thai_don_hang not in ('giao_thanh_cong', 'giao_that_bai')
		
	) then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product has active orders, cannot update";
	end if; 
	
	if p_gia_ban is not null and p_gia_ban < 0 then
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: product price is invalid";
	end if; 
	
	if p_so_luong_ton_kho is not null and p_so_luong_ton_kho < 0 then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so luong ton kho is invalid";
	end if; 
	
	if p_trang_thai is not null and p_trang_thai not in ('dang_ban','ngung_ban','het_hang') then 
		signal sqlstate '45000' 
		set MESSAGE_TEXT = "Error: so luong ton kho is invalid";
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
	        SELECT 1 FROM san_phams WHERE id = p_id
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
        WHERE id = p_id;	
        SELECT 'UPDATE: product state has been converted into ngung_ban' AS message;

	ELSE
        DELETE FROM san_phams WHERE id = p_id;
        SELECT 'DELETE: product has been deleted' AS message;
    END IF;

	commit; 
END $$        

DELIMITER ;