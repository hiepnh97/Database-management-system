
--lost update
	-- T1
START TRANSACTION ;
select @qty := products.quanity from products WHERE products.id = 2 limit 1;
DO sleep(5);
UPDATE products SET products.quanity = @qty - 2 where products.id = 2;
COMMIT; 
	-- T2
START TRANSACTION ;
select @qty := products.quanity from products WHERE products.id = 2 limit 1;
DO sleep(5);
UPDATE products SET products.quanity = @qty - 2 where products.id = 2;
COMMIT; 

	--Giải quyêt
	--T1
START TRANSACTION ;
select @qty := products.quanity from products WHERE products.id = 2 limit 1 for Update ;
DO sleep(5);
UPDATE products SET products.quanity = @qty - 2 where products.id = 2;
COMMIT;
	--T2
	START TRANSACTION ;
UPDATE products SET products.quanity = products.quanity - 5 where products.id = 2 ;
COMMIT ;


---DIRTY READ----
	--T1
START TRANSACTION;
select * from products WHERE 1 ;
	--T2
SET GLOBAL TRANSACTION ISOLATION LEVEL UNCOMMITTED ;
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
                    
DO sleep(8);

ROLLBACK;
	--Giai Quyet
	--T1
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED ;
START TRANSACTION;
select * from products WHERE 1 ;
	--T2
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

----------Unrepeatable data--------------
	--T1 
START TRANSACTION ;

SELECT SUM(customer.point) as sum from customer WHERE  customer.member = 1  group by customer.member ; -- customer.user_id = 22
DO sleep(8);
SELECT sum(customer.point) as sum from customer WHERE  customer.member = 1 group by customer.member ; 
COMMIT ;

	--T2
START TRANSACTION ;
CALL Sp_ThemHoaDon  ( 22 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );
COMMIT ;

	--Giai Quyet
	--T1
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ  ;
START TRANSACTION ;
SELECT SUM(customer.point) as sum from customer WHERE  customer.member = 1  group by customer.member ; 
DO sleep(8);
SELECT sum(customer.point) as sum from customer WHERE  customer.member = 1 group by customer.member ; 
COMMIT ;


	--T2
START TRANSACTION ;
CALL Sp_ThemHoaDon  ( 22 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );
COMMIT ;

--------------PhanTom---------------------
	--T1
START TRANSACTION ;
SELECT orders.id , orders.billing_name_on_card , orders.billing_total  from orders WHERE orders.created_at = CURDATE() ;
DO sleep(8) ;
select @toangdanhthu := (SELECT SUM(orders.billing_total) from orders WHERE orders.created_at = CURDATE() ) ;
COMMIT ;
	--T2
START TRANSACTION ;
CALL Sp_ThemHoaDon  ( 22 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );
COMMIT;

	--Giai Quyet
	--T1
SET GLOBAL TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
START TRANSACTION ;
SELECT orders.id , orders.billing_name_on_card , orders.billing_total  from orders WHERE orders.created_at = CURDATE() ;
DO sleep(8) ;
select @toangdanhthu := (SELECT SUM(orders.billing_total) from orders WHERE orders.created_at = CURDATE() ) ;
COMMIT ;
	--T2
START TRANSACTION ;
CALL Sp_ThemHoaDon  ( 22 , 'Nguyen hoang hiep' ,50000,'nh003' ,165000, 'ATM' , 'Đang chờ' , 'null' );
COMMIT;

----------------DEADLOCK-------------------
	--T1
DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_XoaSanPham`$$ 

CREATE PROCEDURE Sp_XoaSanPham  ( product_code nvarchar(191) ) 	
BEGIN
	
    
	DECLARE sl int ;
    -- start transaction ;
    SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
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
CALL Sp_XoaSanPham ('GK0540') ;

	--T2
DELIMITER $$
DROP PROCEDURE IF EXISTS `Sp_XoaSanPham`$$ 
CREATE PROCEDURE Sp_XoaSanPham  ( product_code nvarchar(191) ) 	
BEGIN 
	DECLARE sl int ;
    -- start transaction ;
    SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
    START TRANSACTION;
		do sleep(5);
		SET sl = ( SELECT products.quanity  FROM db_admin_final.products  where products.code_product = product_code);
        
		IF (sl = 0 ) then
			DELETE FROM products WHERE products.code_product = product_code  ;			
		ELSE 				
				ROLLBACK ;
		END IF ; 
  commit;
END; $$
DELIMITER ;
CALL Sp_XoaSanPham ('GK0540') ;
