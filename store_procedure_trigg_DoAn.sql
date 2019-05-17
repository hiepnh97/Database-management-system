
-- store procedure

-- Tao ma san pham
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_maSanPham`$$
CREATE PROCEDURE sp_maSanPham (out maSP int(10))
BEGIN
    DECLARE masanpham int(10) ; 
    DECLARE tam int(10) ;   
      Declare v_Found Integer default 1;    
   
	DECLARE DanhSachMaSanPham CURSOR FOR SELECT id FROM db_admin_final.products order by id asc ;
	DECLARE  CONTINUE HANDLER FOR NOT FOUND Set v_Found = 0;
	
	Set tam = 1 ;
	OPEN DanhSachMaSanPham ;
		 
         -- lay tung dong du lieu trong cursor  
		My_Loop : Loop
        FETCH DanhSachMaSanPham INTO masanpham ;
		if v_Found = 0 then
          Leave My_Loop;
		End if;	
			 IF( masanpham > tam ) then	
					 LEAVE My_Loop ; 						
                    -- khong lien tuc
			 ELSE 								
					-- lien tuc                   
                   set tam = tam + 1 ;					
					          
             END IF;
             
		End Loop My_Loop;
        set maSP = tam ;
	CLOSE  DanhSachMaSanPham;
    
END; $$
DELIMITER ;

CALL sp_maSanPham(@result2);
SELECT @result2;

--------------------------------------------
-- Sp_ThemSanPham : Thêm san pham
DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_ThemSanPham`$$
CREATE PROCEDURE Sp_ThemSanPham (  code_product varchar(191) , name varchar(191) , slug varchar(191) ,details varchar(191),
				price double , price_in	double , price_promotion double,description	text ,brand_id	int(10),
                category_id	int(10),featured	tinyint(1)	, new tinyint(1),hot_price	int(10),
                image	varchar(191) ,quanity	int(10)   ,status tinyint(1)             
        )
BEGIN
	
	CALL sp_maSanPham(@result);
	SELECT @result;
    
	INSERT INTO `products`(`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`,
    `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) 
    VALUES ( (SELECT @result) , code_product , name,slug,details,price,price_in,price_promotion,
    description,   brand_id, category_id ,featured,
    new,hot_price,image,quanity , status , null , null);    
    
	
END; $$
DELIMITER ;

CALL Sp_ThemSanPham ( 'nh0007', 'Khay son lì Mira Hydro Shine nh0007 ', 'nh0007-khay-sson-li-mira-22064', 'null khong co', 
					96750, 129000, 0, 
					'Không có !!!', 
					225, 
					1, 
					1, 
					0, 
					1, 
					'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 
					15 , 1  );
				
-----------------------------
-- Update Slide

DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_SuaSlide`$$
CREATE PROCEDURE Sp_SuaSlide  ( id	int(10)  ,image	varchar(191) , link	varchar(191) ,title	varchar(191) , status tinyint(1) ,
		category int(10)              
        )
BEGIN
	
	DECLARE count int default 0 ;
    DECLARE thongbao nvarchar(191) ;
    set count = (select count(*) from db_admin_final.slides where slides.id = id) ;
    IF ( count > 0 ) then
					
		-- cap nhat slide 
        UPDATE slides SET image = image, link =link, title=title,status=status,category_id= category WHERE slides.id = id limit 1;
		select thongbao = 'Update thanh cong';    
    ELSE  
		select thongbao = 'Mã slide không ton tai hoac hinh da trung , vui long kiem tra lai';    
        ROLLBACK ;
    END IF ;
	
END; $$
DELIMITER ;

CALL Sp_SuaSlide ( 9 , 'slides/June2018/PUuHVvgrt0u6sBpn2XCx.jpg' , 'Chuwa cso', null  , 1 , 1 );


----------------------------------------------------
-- Update so luong ma giam gia

DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_CapNhatSoLuongMaGiamGia`$$
CREATE PROCEDURE Sp_CapNhatSoLuongMaGiamGia  ( code_nhap varchar(191) , out thongbao nvarchar(191)
        )
BEGIN
	
	DECLARE qty int ;
    DECLARE count int ;
        
    set count = ( SELECT count(*)  FROM db_admin_final.coupons  where coupons.code = code_nhap AND  status = 1  );
    
    IF (count > 0 ) then
		set qty = ( SELECT quanity  FROM db_admin_final.coupons  where coupons.code = code_nhap  limit 1);
		set qty = qty - 1 ;
		UPDATE coupons SET quanity = qty WHERE code = code_nhap limit 1 ;
        set thongbao = 'true' ;
    ELSE 
			set thongbao=  'Ap dung ma khong thanh cong';
			ROLLBACK ;
    END IF ;	
    
END; $$
DELIMITER ;

CALL Sp_CapNhatSoLuongMaGiamGia('nhh002',@thongbao) ;
select @thongbao;

--------------------------------
-- cap nhat so luong san pham

DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_CapNhatSoLuongSanPham`$$
CREATE PROCEDURE Sp_CapNhatSoLuongSanPham  ( product_id int(10), qty int , out thongbao nvarchar(191) 
        )
BEGIN
	
	DECLARE quanitys int ;
    DECLARE count int ;
    -- DECLARE thongbao nvarchar(191) ;
    
    set count = ( SELECT count(*)  FROM db_admin_final.products  where products.id = product_id AND  status = 1  );
    
    IF (count > 0 ) then
		set quanitys = ( SELECT quanity  FROM db_admin_final.products  where products.id = product_id  );
		set quanitys = quanitys - qty ;
		UPDATE products SET quanity = quanitys WHERE products.id = product_id limit 1 ;
        set  thongbao=  'Cap nhat thanh cong!';
    ELSE 
			set thongbao = 'cap nhat that bai';
			ROLLBACK ;
    END IF ;	
    
END; $$
DELIMITER ;

CALL Sp_CapNhatSoLuongSanPham(2, 2 , @thongbao) ;
select @thongbao ;
---------------------------------
-- Tao ma order
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_MaHoaDon`$$
CREATE PROCEDURE sp_MaHoaDon (out maHD int(10))
BEGIN
    DECLARE maHDtam int(10) ; 
    DECLARE tam int(10) ;   
	Declare v_Found Integer default 1;    
   
	DECLARE DanhSachMaHoaDon CURSOR FOR SELECT id FROM db_admin_final.orders order by id asc ;
	DECLARE  CONTINUE HANDLER FOR NOT FOUND Set v_Found = 0;
	
	Set tam = 1 ;
	OPEN DanhSachMaHoaDon ;		 
         -- lay tung dong du lieu trong cursor  
		My_Loop : Loop
        FETCH DanhSachMaHoaDon INTO maHDtam ;
        -- select maHDtam;
		if v_Found = 0 then
          Leave My_Loop;
		End if;	
			 IF( maHDtam > tam ) then				
					
					 LEAVE My_Loop ; 						
                    -- khong lien tuc
			 ELSE 								
					-- lien tuc                   
                   set tam = tam + 1 ;					
					          
             END IF;            
		End Loop My_Loop;
        set maHD = tam ; 
	CLOSE  DanhSachMaHoaDon;
    
END; $$
DELIMITER ;

CALL sp_MaHoaDon(@resulst2);
SELECT @resulst2;
-------------------------------
-- them hoa don
DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_ThemHoaDon`$$
CREATE PROCEDURE Sp_ThemHoaDon  ( user_id int(10) ,billing_name_on_card	varchar(191) ,billing_discount int(11),billing_discount_code varchar(191)
		,billing_total int(11), payment_gateway varchar(191) , shipped varchar(20),error_order varchar(191)
        )
BEGIN
	DECLARE diemcong float ;
    DECLARE chuoi1 nvarchar(191) ;
    DECLARE id_order int(10) ;
    DECLARE loaikhachhang int(10) ;
    DECLARE diemtichluy float ;
	-- goi tao ma hoa don
	CALL sp_MaHoaDon(@id_order);
	set id_order = (SELECT @id_order );
    
    CALL Sp_CapNhatSoLuongMaGiamGia(billing_discount_code,@chuoi1);
    set chuoi1 = (select @chuoi1 );	
    select chuoi1 ;
    IF (  @chuoi1='true' ) 
		then
			-- khach hang thuoc loai nao		            
            set loaikhachhang = ( SELECT member FROM db_admin_final.users , db_admin_final.customer 
            where users.id = customer.user_id AND users.id= user_id) ;
            
            Case loaikhachhang			 
			  When 1 then   
				set billing_total = billing_total * 1 ;
			  When 2 then
				 set billing_total = billing_total * 0.95 ;
			  Else
				set billing_total = billing_total * 0.9 ;
			  End case;
            -- cong diem tich luy cho khach hang 
            set diemtichluy = (SELECT customer.point FROM db_admin_final.users , db_admin_final.customer 
            where users.id = customer.user_id AND users.id= user_id);
            set diemtichluy = diemtichluy + billing_total*0.1 ;
            update customer set customer.point = diemtichluy where customer.user_id = user_id limit 1 ;
            
			INSERT INTO orders(id, user_id, billing_name_on_card, billing_discount, billing_discount_code, billing_tax, 
            billing_total, payment_gateway, shipped, error) 
            VALUES (id_order,user_id,billing_name_on_card,billing_discount,
            billing_discount_code,10,billing_total,payment_gateway,shipped,error_order) ;
    ELSE 
		select 'Tao hoa don that bai' ;
		ROLLBACK ;
    END IF ; 
    
END; $$
DELIMITER ;

CALL Sp_ThemHoaDon  ( 22 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );


-----------------------------------
-- --------Trigger---------

DROP TRIGGER IF EXISTS `Tg_CapNhat_TinhTrang_SanPham`
-- Update bang san pham
DELIMITER $$
CREATE TRIGGER Tg_CapNhat_TinhTrang_SanPham AFTER UPDATE 
ON products
FOR EACH ROW 
BEGIN
	   
		DECLARE idd int(10) ;       
        
		 SET idd = new.id; -- products
		 
        
		IF( (select products.quanity from products where products.id = idd )=0 and (select products.status from products where products.id = idd) = 1 ) then
			 update products set products.status = 0 where products.id = idd limit 1;
         END IF ;	
         
END ;$$
DELIMITER ;

------------------------------------------
DELIMITER $$
CREATE TRIGGER Tg_CapNhat_LoaiKhachHang AFTER INSERT 
ON orders
FOR EACH ROW 
BEGIN
	  declare id int(10) ;
      set id = new.user_id ;
      
	if( (select customer.member from customer where user_id =  id) = 1 and (select customer.point from customer where user_id =  id) >= 10000 
    and (select customer.point from customer where user_id =  id) < 30000)
	then
		update customer		set member = 2		where user_id =  id ;		
	end if; 
    if( (select customer.member from customer where user_id =  id) = 1 and (select customer.point from customer where user_id =  id) >= 30000)
	then
		update customer		set member = 3		where user_id =  id ;		
	end if; 
    if( (select customer.member from customer where user_id =  id) = 2 and (select customer.point from customer where user_id =  id) >= 30000)
	then
		update customer		set member = 3		where user_id =  id ;		
	end if; 
    
    
        
END ;$$
DELIMITER ;


CALL Sp_ThemHoaDon  (23 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );

-------------------------------------------
DELIMITER $$
CREATE TRIGGER Tg_CapNhat_TrangThai_Coupons AFTER INSERT 
ON orders
FOR EACH ROW 
BEGIN
	  declare code int(10) ;
      set code = new.code ;
      
	if( (select coupons.quanity from coupons where coupons.code = code) = 0)
	then
		update coupons	set status = 0	where coupons.code = code	;	
	end if; 
        
END ;$$
DELIMITER ;

-- ------------------------------------------

SET GLOBAL TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
START TRANSACTION;
CALL Sp_ThemSanPham ( 'nh0007', 'Khay son lì Mira Hydro Shine nh0007 ', 'nh0007-khay-sson-li-mira-22064', 'null khong co', 
					96750, 129000, 0, 
					'Không có !!!', 
					225, 
					1, 
					1, 
					0, 
					1, 
					'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 
					15 , 1  );
                    
DO sleep(10);
ROLLBACK;

START TRANSACTION;
select *  from products WHERE 1 ;
COMMIT ;


--------------------------------
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ  ;
START TRANSACTION ;
SELECT SUM(customer.point) as sum from customer WHERE  customer.member = 1  group by customer.member ; -- customer.user_id = 22
DO sleep(8);
SELECT sum(customer.point) as sum from customer WHERE  customer.member = 1 group by customer.member ; -- customer.user_id = 22 and
COMMIT ;
-------------------------------------
SELECT orders.id , orders.billing_name_on_card , orders.billing_total  from orders WHERE orders.created_at = CURDATE() ;

select @toangdanhthu := ( SELECT SUM(orders.billing_total) from orders WHERE orders.created_at = CURDATE()   ) ;

-------------------------------
SET GLOBAL TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
START TRANSACTION ;
SELECT orders.id , orders.billing_name_on_card , orders.billing_total  from orders WHERE orders.created_at = CURDATE() ;
DO sleep(8) ;
select @toangdanhthu := (SELECT SUM(orders.billing_total) from orders WHERE orders.created_at = CURDATE() ) ;
COMMIT ;

----------------------------------------------------

DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_XoaSanPham`$$ 
CREATE PROCEDURE Sp_XoaSanPham  ( product_code nvarchar(191) ) 	
BEGIN
	
    
	DECLARE sl int ;
    -- start transaction ;
    -- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
    SET SESSION TRANSACTION ISOLATION LEVEL Repeatable Read ;
    START TRANSACTION;		
		SET sl = ( SELECT products.quanity  FROM db_admin_final.products  where products.code_product = product_code);
        
        do sleep(5);
		IF (sl = 0 ) then
			DELETE FROM products WHERE products.code_product = product_code  ;			
		ELSE 				
				ROLLBACK ;
		END IF ; 
  commit;
END; $$
DELIMITER ;

CALL Sp_XoaSanPham ('C380') ;




