-- phpMyAdmin SQL Dump
-- version 4.8.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 18, 2018 at 05:36 AM
-- Server version: 10.1.32-MariaDB
-- PHP Version: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_admin_final`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_CapNhatSoLuongMaGiamGia` (`code_nhap` VARCHAR(191), OUT `thongbao` NVARCHAR(191))  BEGIN
	
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_CapNhatSoLuongSanPham` (`product_id` INT(10), `qty` INT, OUT `thongbao` NVARCHAR(191))  BEGIN
	
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MaHoaDon` (OUT `maHD` INT(10))  BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_maSanPham` (OUT `maSP` INT(10))  BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_SuaSlide` (`id` INT(10), `image` VARCHAR(191), `link` VARCHAR(191), `title` VARCHAR(191), `status` TINYINT(1), `category` INT(10))  BEGIN
	
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
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_ThemHoaDon` (`user_id` INT(10), `billing_name_on_card` VARCHAR(191), `billing_discount` INT(11), `billing_discount_code` VARCHAR(191), `billing_total` INT(11), `payment_gateway` VARCHAR(191), `shipped` VARCHAR(20), `error_order` VARCHAR(191))  BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_ThemSanPham` (`code_product` VARCHAR(191), `name` VARCHAR(191), `slug` VARCHAR(191), `details` VARCHAR(191), `price` DOUBLE, `price_in` DOUBLE, `price_promotion` DOUBLE, `description` TEXT, `brand_id` INT(10), `category_id` INT(10), `featured` TINYINT(1), `new` TINYINT(1), `hot_price` INT(10), `image` VARCHAR(191), `quanity` INT(10), `status` TINYINT(1))  BEGIN
	
	CALL sp_maSanPham(@result);
	SELECT @result;
    
	INSERT INTO `products`(`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`,
    `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) 
    VALUES ( (SELECT @result) , code_product , name,slug,details,price,price_in,price_promotion,
    description,   brand_id, category_id ,featured,
    new,hot_price,image,quanity , status , null , null);    
    
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Sp_XoaSanPham` (`product_code` NVARCHAR(191))  BEGIN
	
    
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `brand`
--

CREATE TABLE `brand` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã thương hiệu',
  `name` varchar(191) NOT NULL COMMENT 'Tên thương hiệu',
  `slug` varchar(191) NOT NULL COMMENT 'Đường dẫn thân thiện',
  `image` varchar(191) NOT NULL COMMENT 'Đường dẫn tới hình',
  `title` varchar(191) DEFAULT NULL COMMENT 'Mô tả thương hiệu',
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Trạng thái thương hiệu',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `brand`
--

INSERT INTO `brand` (`id`, `name`, `slug`, `image`, `title`, `status`, `created_at`, `updated_at`) VALUES
(2, '3CE', '3CE', 'data/thuonghieu/3ce-2222.png', NULL, 0, '2018-06-02 02:13:09', '2018-06-02 02:13:09'),
(60, 'Revlon', 'Revlon', 'data/thuonghieu/revlonlogo-2545.png', NULL, 0, '2018-06-02 02:13:09', '2018-06-02 02:13:09'),
(169, '3W CLINIC', '3W CLINIC', 'brand/June2018/0zoipKa4Ceo6I9clpwb1.png', NULL, 1, '2018-06-03 10:26:18', '2018-06-03 10:26:18'),
(170, 'MENARD', 'MENARD', 'brand/June2018/v2onYe2ZzLv25y6kcdnt.jpg', NULL, 1, '2018-06-03 10:29:10', '2018-06-03 10:29:10'),
(171, 'IOPE', 'IOPE', 'brand/June2018/mAGecAGJHwrzoCVBUwGs.png', NULL, 1, '2018-06-03 10:30:27', '2018-06-03 10:31:47'),
(172, 'Aroma', 'Aroma', 'brand/June2018/gHgV1pBV7aTCveSJr8E0.jpg', NULL, 1, '2018-06-03 10:31:00', '2018-06-03 10:33:46'),
(173, 'Avene', 'Avene', 'brand/June2018/5vZHNZNlBnDgsGO1j15V.png', NULL, 1, '2018-06-03 10:31:24', '2018-06-03 10:33:30'),
(174, 'MUJI', 'MUJI', 'brand/June2018/NU5h0ZJquUGy6U0t7r0H.jpg', NULL, 1, '2018-06-03 10:32:09', '2018-06-03 10:32:09'),
(175, 'Kanebo', 'Kanebo', 'brand/June2018/KeALjkBWM9sb8fdypYXu.png', NULL, 1, '2018-06-03 10:32:51', '2018-06-03 10:33:14'),
(176, 'BANOBAGI', 'BANOBAGI', 'brand/June2018/UyiHBt8kYbNbSLnYvMWj.png', NULL, 1, '2018-06-03 10:34:32', '2018-06-03 10:34:32'),
(177, 'BARABONI', 'BARABONI', 'brand/June2018/BkMtU5cupJOkbly2UXs9.png', NULL, 1, '2018-06-03 10:35:08', '2018-06-03 10:35:08'),
(178, 'BIODERMA', 'BIODERMA', 'brand/June2018/54NRCMLZ9oIm8Sn6GIN9.png', NULL, 1, '2018-06-03 10:35:28', '2018-06-03 10:35:28'),
(179, 'BOBBI BROWN', 'BOBBI BROWN', 'brand/June2018/ErUmi5AZyRhfxNMSAfb0.jpg', NULL, 1, '2018-06-03 10:36:09', '2018-06-03 10:36:09'),
(180, 'BOURJOIS', 'BOURJOIS', 'brand/June2018/8aRtlfNKPQZDGCxCA6Ne.png', NULL, 1, '2018-06-03 10:36:39', '2018-06-03 10:36:39'),
(181, 'BYPHASSE', 'BYPHASSE', 'brand/June2018/6n5XfoVpULWq7QZSkgN9.png', NULL, 1, '2018-06-03 10:37:05', '2018-06-03 10:37:05'),
(182, 'CHANEL', 'CHANEL', 'brand/June2018/euKU0heUF7xMoHXB3BuO.png', NULL, 1, '2018-06-03 10:37:25', '2018-06-03 10:37:25'),
(183, 'CLINIQUE', 'CLINIQUE', 'brand/June2018/txwQCtUr9xuLmHWrqyYT.jpg', NULL, 1, '2018-06-03 10:37:47', '2018-06-03 10:37:47'),
(184, 'CosRoyale', 'CosRoyale', 'brand/June2018/IUxxGiQtxdpedZQ5j4Zz.jpg', NULL, 1, '2018-06-03 10:38:23', '2018-06-03 10:38:23'),
(185, 'Dior', 'Dior', 'brand/June2018/PQuuRdJR5bjjGjYfyv56.png', NULL, 1, '2018-06-03 10:38:48', '2018-06-03 10:38:48'),
(186, 'EOS', 'EOS', 'brand/June2018/eWvmYPWr6OBsBfFvkMpI.png', NULL, 1, '2018-06-03 10:39:09', '2018-06-03 10:39:09'),
(187, 'ETUDE HOUSE', 'ETUDE HOUSE', 'brand/June2018/ZnZ08cycqOliZv9PVuaw.png', NULL, 1, '2018-06-03 10:39:44', '2018-06-03 10:39:44'),
(188, 'EVIAN', 'EVIAN', 'brand/June2018/6hEv7svRkxsMoLs5KDWj.png', NULL, 1, '2018-06-03 10:39:59', '2018-06-03 10:39:59'),
(189, 'Evoduderm', 'Evoduderm', 'brand/June2018/evZTuOamo3XjoL8ShrDa.png', NULL, 1, '2018-06-03 10:40:39', '2018-06-03 10:40:39'),
(190, 'Farm Stay', 'Farm Stay', 'brand/June2018/pmaEy0QTdXIhyLOptsSW.png', NULL, 1, '2018-06-03 10:41:00', '2018-06-03 10:41:00'),
(191, 'FASIO', 'FASIO', 'brand/June2018/8xzYMc5pQ6CK4Kwug40H.png', NULL, 1, '2018-06-03 10:41:25', '2018-06-03 10:41:25'),
(192, 'Framesi', 'Framesi', 'brand/June2018/JbU7aKLMMBONakZskTxA.jpg', NULL, 1, '2018-06-03 10:41:55', '2018-06-03 10:41:55'),
(193, 'GARNIER', 'GARNIER', 'brand/June2018/2Xzb5EZQFjYyBgEGId2y.png', NULL, 1, '2018-06-03 10:42:16', '2018-06-03 10:42:16'),
(194, 'GIVENCHY', 'GIVENCHY', 'brand/June2018/b7rOVTGCdZxjnXp4cy9W.png', NULL, 1, '2018-06-03 10:42:36', '2018-06-03 10:42:36'),
(195, 'GUERLAIN', 'GUERLAIN', 'brand/June2018/b2267nSxRXqEXkbvu715.png', NULL, 1, '2018-06-03 10:43:04', '2018-06-03 10:43:04'),
(196, 'Hada labo', 'Hada labo', 'brand/June2018/3fZQd1pfQHeLhC5Q7Omu.jpg', NULL, 1, '2018-06-03 10:43:45', '2018-06-03 10:43:45'),
(197, 'HERA', 'HERA', 'brand/June2018/F3P88t5AdbOVlPPSMvI3.png', NULL, 1, '2018-06-03 10:43:58', '2018-06-03 10:43:58'),
(198, 'innisfree', 'innisfree', 'brand/June2018/pSJ6oVR7fWRiOa2ASJPX.png', NULL, 1, '2018-06-03 10:44:23', '2018-06-03 10:44:23'),
(199, 'IPKN', 'IPKN', 'brand/June2018/beoftKaVMrjxl6SxCYpo.png', NULL, 1, '2018-06-03 10:44:40', '2018-06-03 10:44:40'),
(200, 'Kiehls', 'Kiehls', 'brand/June2018/nHflsuYFKyXfsJFzj0fk.png', NULL, 1, '2018-06-03 10:45:16', '2018-06-03 10:45:16'),
(201, 'Kose', 'Kose', 'brand/June2018/qQVz2WpGUlbMVV4NGt46.png', NULL, 1, '2018-06-03 10:46:03', '2018-06-03 10:46:03'),
(202, 'Lancome', 'Lancome', 'brand/June2018/yk4xs4kJCC2YJVGjmTr1.jpg', NULL, 1, '2018-06-03 10:46:24', '2018-06-03 10:46:24'),
(203, 'Loccitane', 'Loccitane', 'brand/June2018/iQa0sBfmMwMoRzYkF297.png', NULL, 1, '2018-06-03 10:46:42', '2018-06-03 10:48:28'),
(204, 'Laneige', 'Laneige', 'brand/June2018/puDaY4Rh1rkxcPikkXb3.jpg', NULL, 1, '2018-06-03 10:47:02', '2018-06-03 10:48:47'),
(205, 'OHUI', 'OHUI', 'brand/June2018/YuVa8lg2ZaH90GKUi2i4.png', NULL, 1, '2018-06-03 10:49:19', '2018-06-03 10:49:19'),
(206, 'SK II', 'SK II', 'brand/June2018/AojHCn77DpO7vmKDqdPr.png', NULL, 1, '2018-06-03 10:49:38', '2018-06-03 10:49:38'),
(207, 'LOreal Paris', 'LOreal Paris', 'brand/June2018/JwJ8LD9xLcs60h5sx48h.png', NULL, 1, '2018-06-03 10:49:57', '2018-06-03 10:49:57'),
(208, 'MAC', 'MAC', 'brand/June2018/2N9B4cd6cNgKkvtv48Er.png', NULL, 1, '2018-06-03 10:50:32', '2018-06-03 10:50:32'),
(209, 'Maybelline', 'Maybelline', 'brand/June2018/TMj4iodrrM2RvBNdad4c.jpg', NULL, 1, '2018-06-03 10:50:51', '2018-06-03 10:50:51'),
(210, 'mik@vonk', 'mik@vonk', 'brand/June2018/IQy9FD2JFIiiREFihxaM.jpg', NULL, 1, '2018-06-03 10:51:16', '2018-06-03 10:51:16'),
(211, 'Mira Aroma', 'Mira Aroma', 'brand/June2018/Gu1t5Kx0dalzGWvPwvYh.jpg', NULL, 1, '2018-06-03 10:51:47', '2018-06-03 10:51:47'),
(212, 'MiraCulous', 'MiraCulous', 'brand/June2018/y5cBub5WbMLZNx0oOcrd.jpg', NULL, 1, '2018-06-03 10:52:08', '2018-06-03 10:52:08'),
(213, 'NATURE REPUBLIC', 'NATURE REPUBLIC', 'brand/June2018/vEbS7SsiYLstJFwO5EMt.jpeg', NULL, 1, '2018-06-03 10:52:28', '2018-06-03 10:52:28'),
(214, 'Neutrogena', 'Neutrogena', 'brand/June2018/vc9R033nUUITsnZfrEmd.png', NULL, 1, '2018-06-03 10:52:49', '2018-06-03 10:52:49'),
(215, 'Nuxe', 'Nuxe', 'brand/June2018/8anNqcugf5necEPYZw9y.png', NULL, 1, '2018-06-03 10:53:09', '2018-06-03 10:53:09'),
(216, 'OLAY', 'OLAY', 'brand/June2018/Iun0j5yoIynvRZSem4hs.png', NULL, 1, '2018-06-03 10:55:48', '2018-06-03 10:55:48'),
(217, 'Paulas Choice', 'Paulas Choice', 'brand/June2018/HPMrlAYBLYJkGfOkUHdu.png', NULL, 1, '2018-06-03 10:56:02', '2018-06-03 10:56:02'),
(218, 'PetaFresh', 'PetaFresh', 'brand/June2018/XZxAP0XjnFsxchn9g4OW.jpg', NULL, 1, '2018-06-03 10:56:17', '2018-06-03 10:56:17'),
(219, 'QUIMI-ROMAR', 'QUIMI-ROMAR', 'brand/June2018/9ulRDSmw8i6atJvcbT0Z.png', NULL, 1, '2018-06-03 10:56:44', '2018-06-03 10:56:44'),
(220, 'Revlon', 'Revlon', 'brand/June2018/2Z7Y4lQNV7A5s8iFRdmf.png', NULL, 1, '2018-06-03 10:57:08', '2018-06-03 10:57:08'),
(221, 'Shiseido', 'Shiseido', 'brand/June2018/YWA9imWqXHfMFvt61KQF.png', NULL, 1, '2018-06-03 10:57:21', '2018-06-03 10:57:21'),
(222, 'Shu Uemura', 'Shu Uemura', 'brand/June2018/4IGFKykzZoOwaMSGkn2i.png', NULL, 1, '2018-06-03 10:57:37', '2018-06-03 10:57:37'),
(223, 'SKINFOOD', 'SKINFOOD', 'brand/June2018/QmuZSBUbixCLrP6QJ9b5.png', NULL, 1, '2018-06-03 10:57:51', '2018-06-03 10:57:51'),
(224, 'Suri', 'Suri', 'brand/June2018/7eeIgrKq1KEB6gPIXhYc.jpg', NULL, 1, '2018-06-03 10:58:08', '2018-06-03 10:58:08'),
(225, 'Mira', 'Mira', 'brand/June2018/MZRwRWZjreQOzPC39hVW.png', NULL, 1, '2018-06-03 10:58:28', '2018-06-03 10:58:28'),
(226, 'The Body Shop', 'The Body Shop', 'brand/June2018/CWXVQJp3QWsmoi9TUgWo.png', NULL, 1, '2018-06-03 10:58:50', '2018-06-03 10:58:50'),
(227, 'The Face Shop', 'The Face Shop', 'brand/June2018/mI16bYzeGpoDZFVtDAe6.png', NULL, 1, '2018-06-03 10:59:04', '2018-06-03 10:59:04'),
(228, 'The Saem', 'The Saem', 'brand/June2018/7aNjAn8WCudThkcJo7PM.png', NULL, 1, '2018-06-03 10:59:17', '2018-06-03 10:59:17'),
(229, 'TONY MOLY', 'TONY MOLY', 'brand/June2018/umB33gtpeM4M6Bz9BcYD.png', NULL, 1, '2018-06-03 10:59:37', '2018-06-03 10:59:37'),
(230, 'Vichy', 'Vichy', 'brand/June2018/zzUwAgccrwF9dbRSZeI2.png', NULL, 1, '2018-06-03 10:59:54', '2018-06-03 10:59:54'),
(231, 'Whoo', 'Whoo', 'brand/June2018/NGkAGQkdBvwLtTW3hml2.jpg', NULL, 1, '2018-06-03 11:00:08', '2018-06-03 11:00:08'),
(232, 'Yves Rocher', 'Yves Rocher', 'brand/June2018/C45VA47po86MNU5mnEZs.png', NULL, 1, '2018-06-03 11:00:21', '2018-06-03 11:00:21'),
(233, 'Yves Saint Laurent', 'Yves Saint Laurent', 'brand/June2018/ianep4Kbjtbw3DfGjL9X.png', NULL, 1, '2018-06-03 11:00:33', '2018-06-03 11:00:33');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã danh mục',
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên danh mục',
  `slug` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Đường dẫn thân thiện',
  `parent_id` int(10) UNSIGNED DEFAULT '0' COMMENT 'Mã danh mục cha',
  `sub_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã danh mục con',
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Đường dẫn hình ảnh',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Trạng thái danh mục',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo danh mục',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật danh mục'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`id`, `name`, `slug`, `parent_id`, `sub_id`, `image`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Mỹ phẩm', 'my-pham', NULL, NULL, 'category/June2018/utIKkFvWjwQTj7AWwg7e.png', 1, NULL, '2018-06-03 14:15:20'),
(2, 'Chăm sóc da', 'cham-soc-da', NULL, NULL, 'category/June2018/f39X4SqfK042bw3EQ8IP.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:15:49'),
(3, 'Chăm sóc tóc', 'cham-soc-toc', NULL, NULL, 'category/June2018/NqUKdelIVxQgNZy8p3C2.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:15:58'),
(4, 'Chăm sóc móng', 'cham-soc-mong', NULL, NULL, 'category/June2018/VMkxGbeWuhTEogBYW0od.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:16:39'),
(5, 'Dụng cụ làm đẹp', 'dung-cu-lam-dep', NULL, NULL, 'category/June2018/UejN9wv5bQlBlpTwbR5z.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:16:44'),
(6, 'Chăm sóc cá nhân', 'cham-soc-ca-nhan', NULL, NULL, 'category/June2018/ytneu3bTtNSLlyVrTqt4.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:16:52'),
(7, 'Hàng gia dụng', 'hang-gia-dung', NULL, NULL, 'category/June2018/So1XZb2bxphqp0f6XxCJ.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:17:46'),
(8, 'Trang trí nhà cửa', 'trang-tri-nha-cua', NULL, NULL, 'category/June2018/hd0WlZ9ucyXQCKOFf1Uy.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:17:37'),
(9, 'Giặt giũ & Vệ sinh nhà cửa', 'giat-giu-ve-sinh-nha-cua', NULL, NULL, 'category/June2018/Xz1JSPm4pf1Lo472x865.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:17:31'),
(10, 'Phụ kiện thời trang', 'phu-kien-thoi-trang', NULL, NULL, 'category/June2018/HXmxAXmTxzElItKCMjrz.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:17:16'),
(11, 'Thực phẩm', 'thuc-pham', NULL, NULL, 'category/June2018/CAeYoHwWNaDZbhfe9CVW.png', 1, '2018-05-29 01:17:54', '2018-06-03 14:17:09'),
(33, 'Trang điểm mắt', 'trang-diem-eye', 1, NULL, NULL, 1, NULL, NULL),
(34, 'Trang điểm môi', 'trang-diem-moi', 1, NULL, NULL, 1, NULL, NULL),
(35, 'Tẩy trang', 'tay-trang', 1, NULL, NULL, 1, NULL, NULL),
(39, 'Trang điểm mặt 2', 'trang-diem', 1, NULL, NULL, 1, NULL, NULL),
(40, 'Serum', 'serum', 2, NULL, NULL, 1, NULL, NULL),
(41, 'Mặt nạ', 'mat-na', 2, NULL, NULL, 1, NULL, NULL),
(42, 'Dưỡng da mặt', 'duong-da-mat', 2, NULL, NULL, 1, NULL, NULL),
(43, 'Nước hoa hồng', 'nuoc-hoa-hong', 2, NULL, NULL, 1, NULL, NULL),
(44, 'Tẩy tế bào chết', 'tay-te-bao-chet', 2, NULL, NULL, 1, NULL, NULL),
(92, 'Xà bông tắm', 'xa-bong-tam', 2, NULL, NULL, 1, NULL, NULL),
(93, 'Sữa rửa mặt', 'sua-rua-mat', 2, NULL, NULL, 1, NULL, NULL),
(94, 'Dưỡng thể', 'duong-the', 2, NULL, NULL, 1, NULL, NULL),
(95, 'Chống nắng', 'chong-nang', 2, NULL, NULL, 1, NULL, NULL),
(96, 'Sữa tắm', 'sua-tam', 2, NULL, NULL, 1, NULL, NULL),
(97, 'Trị mụn', 'tri-mun', 2, NULL, NULL, 1, NULL, NULL),
(98, 'Xịt khoáng', 'xit-khoang', 2, NULL, NULL, 1, NULL, NULL),
(99, 'Dưỡng da tay', 'duong-da-tay', 2, NULL, NULL, 1, NULL, NULL),
(100, 'Dưỡng daa mắt', 'duong-da-mat-', 2, NULL, NULL, 1, NULL, NULL),
(101, 'Dầu gội & Dầu xả', 'dau-goi-dau-xa', 3, NULL, NULL, 1, NULL, NULL),
(102, 'Uốn tóc & Duỗi tóc', 'uon-toc-duoi-toc', 3, NULL, NULL, 1, NULL, NULL),
(103, 'Keo xịt tóc', 'keo-xit-toc', 3, NULL, NULL, 1, NULL, NULL),
(104, 'Dụng cụ chăm sóc tóc', 'dung-cu-cham-soc-toc', 3, NULL, NULL, 1, NULL, NULL),
(105, 'Dưỡng tóc & Ủ tóc', 'duong-toc-u-toc', 3, NULL, NULL, 1, NULL, NULL),
(106, 'Thuốc nhuộm tóc', 'thuoc-nhuom-toc', 3, NULL, NULL, 1, NULL, NULL),
(107, 'Dưỡng móng', 'duong-mong-rua-mong', 4, NULL, NULL, 1, NULL, NULL),
(108, 'Sơn móng & Vẽ móng', 'son-mong-ve-mong', 4, NULL, NULL, 1, NULL, NULL),
(109, 'Cọ trang điểm', 'co-trang-diem', 5, NULL, NULL, 1, NULL, NULL),
(110, 'Bông phấn & Bọt biển', 'bong-phan-bot-bien', 5, NULL, NULL, 1, NULL, NULL),
(111, 'Bấm mi & Kéo tỉa', 'bam-mi-keo-tia', 5, NULL, NULL, 1, NULL, NULL),
(112, 'Cắt móng & Dũa móng', 'cat-mong-dua-mong', 5, NULL, NULL, 1, NULL, NULL),
(113, 'Khăn giấy ướt', 'khan-giay-uot', 5, NULL, NULL, 1, NULL, NULL),
(114, 'Bông tẩy trang', 'bong-tay-trang', 5, NULL, NULL, 1, NULL, NULL),
(115, 'Lông mi giả', 'long-mi-gia', 5, NULL, NULL, 1, NULL, NULL),
(116, 'Nhíp mày', 'nhip-may', 5, NULL, NULL, 1, NULL, NULL),
(117, 'Chăm sóc răng', 'cham-soc-rang', 6, NULL, NULL, 1, NULL, NULL),
(118, 'Khử mùi', 'khu-mui', 6, NULL, NULL, 1, NULL, NULL),
(119, 'Vệ sinh phụ nữ', 've-sinh-phu-nu', 6, NULL, NULL, 1, NULL, NULL),
(120, 'Dao cạo & Lưỡi dao', 'dao-cao-luoi-dao', 6, NULL, NULL, 1, NULL, NULL),
(121, 'Khẩu trang', 'khau-trang', 6, NULL, NULL, 1, NULL, NULL),
(122, 'Nhà bếp', 'nha-bep', 7, NULL, NULL, 1, NULL, NULL),
(123, 'Nhà tắm', 'nha-tam', 7, NULL, NULL, 1, NULL, NULL),
(124, 'Phòng ngủ', 'phong-ngu', 7, NULL, NULL, 1, NULL, NULL),
(125, 'Phòng khách', 'phong-khach', 7, NULL, NULL, 1, NULL, NULL),
(126, 'Đồ tiện ích', 'do-tien-ich', 7, NULL, NULL, 1, NULL, NULL),
(127, 'Khử mùi xe hơi', 'khu-mui-xe-hoi', 8, NULL, NULL, 1, NULL, NULL),
(128, 'Tinh dầu', 'tinh-dau', 8, NULL, NULL, 1, NULL, NULL),
(129, 'Túi thơm', 'tui-thom', 8, NULL, NULL, 1, NULL, NULL),
(130, 'Xịt thơm phòng', 'xit-thom-phong', 8, NULL, NULL, 1, NULL, NULL),
(131, 'Hạt thơm', 'hat-thom', 8, NULL, NULL, 1, NULL, NULL),
(132, 'Sáp thơm & Gel thơm', 'sap-thom-gel-thom', 8, NULL, NULL, 1, NULL, NULL),
(133, 'Nước giặt', 'nuoc-giat', 9, NULL, NULL, 1, NULL, NULL),
(134, 'Nước lau sàn', 'nuoc-lau-san', 9, NULL, NULL, 1, NULL, NULL),
(135, 'Diệt côn trùng', 'diet-con-trung', 9, NULL, NULL, 1, NULL, NULL),
(136, 'Vệ sinh máy giặt', 've-sinh-may-giat', 9, NULL, NULL, 1, NULL, NULL),
(137, 'Bột giặt', 'bot-giat', 9, NULL, NULL, 1, NULL, NULL),
(138, 'Nước tẩy', 'nuoc-tay', 9, NULL, NULL, 1, NULL, NULL),
(139, 'Túi đựng rác', 'tui-dung-rac', 9, NULL, NULL, 1, NULL, NULL),
(140, 'Giấy vệ sinh', 'giay-ve-sinh', 9, NULL, NULL, 1, NULL, NULL),
(141, 'Nước xả', 'nuoc-xa', 9, NULL, NULL, 1, NULL, NULL),
(142, 'Khăn đa năng', 'khan-da-nang', 10, NULL, NULL, 1, NULL, NULL),
(143, 'Găng tay & Vớ tất', 'gang-tay-vo-tat', 10, NULL, NULL, 1, NULL, NULL),
(144, 'Giày dép', 'giay-dep', 10, NULL, NULL, 1, NULL, NULL),
(145, 'Phụ kiện quần áo', 'phu-kien-quan-ao', 10, NULL, NULL, 1, NULL, NULL),
(146, 'Khăn choàng', 'khan-choang', 10, NULL, NULL, 1, NULL, NULL),
(147, 'Ba lô/Túi/Ví', 'ba-lotuivi', 10, NULL, NULL, 1, NULL, NULL),
(148, 'Mũ nón', 'mu-non', 10, NULL, NULL, 1, NULL, NULL),
(149, 'Phụ kiện tóc', 'phu-kien-toc', 10, NULL, NULL, 1, NULL, NULL),
(150, 'Trang sức', 'trang-suc', 10, NULL, NULL, 1, NULL, NULL),
(151, 'Ô dù', 'o-du', 10, NULL, NULL, 1, NULL, NULL),
(152, 'Kính', 'kinh', 10, NULL, NULL, 1, NULL, NULL),
(153, 'Gấu bông', 'gau-bong', 10, NULL, NULL, 1, NULL, NULL),
(154, 'Đồ ăn', 'do-an', 11, NULL, NULL, 1, NULL, NULL),
(155, 'Đồ uống', 'do-uong', 11, NULL, NULL, 1, NULL, NULL),
(156, 'Che khuyết điểm', 'che-khuyet-diem', 33, NULL, NULL, 1, '2018-06-03 14:05:32', '2018-06-03 14:05:32'),
(179, 'Phấn má hồng', 'phan-ma-hong', 39, NULL, NULL, 1, NULL, NULL),
(180, 'Kem nền BB', 'kem-nen-bb', 39, NULL, NULL, 1, NULL, NULL),
(181, 'Phấn nước', 'phan-nuoc', 39, NULL, NULL, 1, NULL, NULL),
(182, 'Phấn phủ', 'phan-phu', 39, NULL, NULL, 1, NULL, NULL),
(183, 'Phấn nền', 'phan-nen', 39, NULL, NULL, 1, NULL, NULL),
(184, 'Phấn tạo khối', 'phan-tao-khoi', 39, NULL, NULL, 1, NULL, NULL),
(185, 'Kẻ chân mày', 'ke-chan-may', 33, NULL, NULL, 1, NULL, NULL),
(186, 'Phấn mắt', 'phan-mat', 33, NULL, NULL, 1, NULL, NULL),
(187, 'Mascara', 'mascara', 33, NULL, NULL, 1, NULL, NULL),
(188, 'Kẻ mắt', 'ke-mat', 33, NULL, NULL, 1, NULL, NULL),
(189, 'Kẻ mí', 'ke-mi', 33, NULL, NULL, 1, NULL, NULL),
(190, 'Khay son', 'khay-son', 34, NULL, NULL, 1, NULL, NULL),
(191, 'Son kem', 'son-kem', 34, NULL, NULL, 1, NULL, NULL),
(192, 'Son thỏi', 'son-thoi', 34, NULL, NULL, 1, NULL, NULL),
(193, 'Son dưỡng', 'son-duong', 34, NULL, NULL, 1, NULL, NULL),
(194, 'Son bóng', 'son-bong', 34, NULL, NULL, 1, NULL, NULL),
(195, 'Son xăm', 'son-xam', 34, NULL, NULL, 1, NULL, NULL),
(196, 'Son lì', 'son-li', 34, NULL, NULL, 1, NULL, NULL),
(197, 'Kẻ môi', 'ke-moi', 34, NULL, NULL, 1, NULL, NULL),
(198, 'Tẩy trang mắt, môi', 'tay-trang-mat-moi', 35, NULL, NULL, 1, NULL, NULL),
(199, 'Tẩy trang mặt', 'tay-trang-mat', 35, NULL, NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `category_product`
--

CREATE TABLE `category_product` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã sản phầm thương hiệu',
  `product_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã sản phẩm',
  `category_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã danh mục',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã mã giảm giá',
  `code` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'CODE giảm giá',
  `type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại giảm giá',
  `value` int(11) DEFAULT NULL COMMENT 'Số tiền trừ',
  `quanity` int(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Số lượng có thể dùng',
  `percent_off` int(11) DEFAULT NULL COMMENT 'Phần trăm được giảm',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Trạng thái mã giảm giá',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coupons`
--

INSERT INTO `coupons` (`id`, `code`, `type`, `value`, `quanity`, `percent_off`, `status`, `created_at`, `updated_at`) VALUES
(1, 'nhh002', 'percent', NULL, 27, 50, 1, '2018-05-28 21:46:29', '2018-06-06 03:32:37'),
(2, 'nh003', 'fixed', 50000, 29, NULL, 1, '2018-05-28 22:07:43', '2018-06-06 03:24:09');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã khách hàng',
  `name` varchar(191) NOT NULL COMMENT 'Tên khách hàng',
  `email` varchar(191) NOT NULL COMMENT 'Thư điện tử',
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã tài khoản',
  `gender` varchar(10) NOT NULL DEFAULT '1' COMMENT 'Giới tính',
  `birthday` date DEFAULT NULL COMMENT 'Ngày sinh',
  `phone_number` varchar(20) DEFAULT NULL COMMENT 'Số điện thoại',
  `address` varchar(191) DEFAULT NULL COMMENT 'Địa chỉ',
  `point` float NOT NULL DEFAULT '0' COMMENT 'Điểm tích lũy',
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Trạng thái của khách hàng',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật',
  `member` varchar(191) NOT NULL DEFAULT '1' COMMENT 'Loại thành viên'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`id`, `name`, `email`, `user_id`, `gender`, `birthday`, `phone_number`, `address`, `point`, `status`, `created_at`, `updated_at`, `member`) VALUES
(6, 'hhhh', 'hhhh@gmail.com', 22, '1', '1997-06-23', '9999999', 'KTX khu B Đại Học Quốc Gia TP Hồ CHí Minh', 160875, 1, '2018-06-03 19:17:48', '2018-06-03 19:17:48', '3'),
(9, 'nhhhhhhh', 'test@test.com', 23, '1', '1997-06-22', '999999999', 'KTX khu B Đại Học Quốc Gia TP Hồ CHí Minh', 17600, 1, '2018-06-03 19:26:26', '2018-06-03 19:26:26', '2'),
(10, 'test2', 'test2@test.com', 24, '1', '1997-06-09', '112121221', 'KTX khu B Đại Học Quốc Gia TP Hồ CHí Minh', 9900, 1, '2018-06-03 19:29:54', '2018-06-03 19:29:54', '1'),
(11, 'test3', 'test3@test.com', 25, '2', NULL, NULL, NULL, 0, 1, '2018-06-03 19:31:13', '2018-06-03 19:31:13', '1'),
(12, 'test12', 'test12@gmail.com', 26, '1', NULL, NULL, NULL, 0, 1, '2018-06-03 19:32:26', '2018-06-03 19:32:26', '1'),
(13, 'test', 'test13@gmail.com', 27, '1', NULL, NULL, NULL, 0, 1, '2018-06-03 19:36:15', '2018-06-03 19:36:15', '1'),
(14, 'test14', 'test14@gmail.com', 28, '1', NULL, NULL, NULL, 0, 1, '2018-06-03 20:40:47', '2018-06-03 20:40:47', '1'),
(15, 'test15', 'test15@gmail.com', 29, '1', NULL, NULL, NULL, 0, 1, '2018-06-03 21:05:34', '2018-06-03 21:05:34', '1'),
(16, 'Lý Đạt', 'dat.ly.dev@gmail.com', 31, '1', NULL, NULL, NULL, 0, 1, '2018-06-05 19:27:57', '2018-06-05 19:27:57', '1');

-- --------------------------------------------------------

--
-- Table structure for table `data_rows`
--

CREATE TABLE `data_rows` (
  `id` int(10) UNSIGNED NOT NULL,
  `data_type_id` int(10) UNSIGNED NOT NULL,
  `field` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `required` tinyint(1) NOT NULL DEFAULT '0',
  `browse` tinyint(1) NOT NULL DEFAULT '1',
  `read` tinyint(1) NOT NULL DEFAULT '1',
  `edit` tinyint(1) NOT NULL DEFAULT '1',
  `add` tinyint(1) NOT NULL DEFAULT '1',
  `delete` tinyint(1) NOT NULL DEFAULT '1',
  `details` text COLLATE utf8mb4_unicode_ci,
  `order` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `data_rows`
--

INSERT INTO `data_rows` (`id`, `data_type_id`, `field`, `type`, `display_name`, `required`, `browse`, `read`, `edit`, `add`, `delete`, `details`, `order`) VALUES
(1, 1, 'id', 'number', 'ID', 1, 1, 1, 1, 1, 1, NULL, 1),
(2, 1, 'name', 'text', 'Name', 1, 1, 1, 1, 1, 1, NULL, 2),
(3, 1, 'email', 'text', 'Email', 1, 1, 1, 1, 1, 1, NULL, 3),
(4, 1, 'password', 'password', 'Password', 1, 0, 0, 1, 1, 0, NULL, 4),
(5, 1, 'remember_token', 'text', 'Remember Token', 0, 0, 0, 0, 0, 0, NULL, 5),
(6, 1, 'created_at', 'timestamp', 'Created At', 0, 1, 1, 0, 0, 0, NULL, 6),
(7, 1, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 7),
(8, 1, 'avatar', 'image', 'Avatar', 0, 1, 1, 1, 1, 1, '{\"default\":\"users/June2018/w56bI0JYedPQbZaESHmp.png\"}', 8),
(9, 1, 'user_belongsto_role_relationship', 'relationship', 'Role', 0, 1, 1, 1, 1, 0, '{\"model\":\"TCG\\\\Voyager\\\\Models\\\\Role\",\"table\":\"roles\",\"type\":\"belongsTo\",\"column\":\"role_id\",\"key\":\"id\",\"label\":\"display_name\",\"pivot_table\":\"roles\",\"pivot\":\"0\",\"taggable\":\"0\"}', 10),
(10, 1, 'user_belongstomany_role_relationship', 'relationship', 'Roles', 0, 1, 1, 1, 1, 0, '{\"model\":\"TCG\\\\Voyager\\\\Models\\\\Role\",\"table\":\"roles\",\"type\":\"belongsToMany\",\"column\":\"id\",\"key\":\"id\",\"label\":\"display_name\",\"pivot_table\":\"user_roles\",\"pivot\":\"1\",\"taggable\":\"0\"}', 11),
(12, 1, 'settings', 'hidden', 'Settings', 0, 0, 0, 0, 0, 0, NULL, 12),
(13, 2, 'id', 'number', 'ID', 1, 0, 0, 0, 0, 0, '', 1),
(14, 2, 'name', 'text', 'Name', 1, 1, 1, 1, 1, 1, '', 2),
(15, 2, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, '', 3),
(16, 2, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, '', 4),
(17, 3, 'id', 'hidden', 'Mã', 1, 1, 1, 0, 1, 1, NULL, 1),
(18, 3, 'name', 'text', 'Tên', 1, 1, 1, 1, 1, 1, NULL, 2),
(19, 3, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 4),
(20, 3, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 5),
(21, 3, 'display_name', 'text', 'Tên hiển thị', 1, 1, 1, 1, 1, 1, NULL, 3),
(22, 1, 'role_id', 'text', 'Role', 0, 1, 1, 1, 1, 1, NULL, 9),
(23, 4, 'id', 'number', 'ID', 1, 0, 0, 0, 0, 0, '', 1),
(24, 4, 'parent_id', 'select_dropdown', 'Parent', 0, 0, 1, 1, 1, 1, '{\"default\":\"\",\"null\":\"\",\"options\":{\"\":\"-- None --\"},\"relationship\":{\"key\":\"id\",\"label\":\"name\"}}', 2),
(25, 4, 'order', 'text', 'Order', 1, 1, 1, 1, 1, 1, '{\"default\":1}', 3),
(26, 4, 'name', 'text', 'Name', 1, 1, 1, 1, 1, 1, '', 4),
(27, 4, 'slug', 'text', 'Slug', 1, 1, 1, 1, 1, 1, '{\"slugify\":{\"origin\":\"name\"}}', 5),
(28, 4, 'created_at', 'timestamp', 'Created At', 0, 0, 1, 0, 0, 0, '', 6),
(29, 4, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, '', 7),
(30, 5, 'id', 'number', 'ID', 1, 0, 0, 0, 0, 0, '', 1),
(31, 5, 'author_id', 'text', 'Author', 1, 0, 1, 1, 0, 1, '', 2),
(32, 5, 'category_id', 'text', 'Category', 1, 0, 1, 1, 1, 0, '', 3),
(33, 5, 'title', 'text', 'Title', 1, 1, 1, 1, 1, 1, '', 4),
(34, 5, 'excerpt', 'text_area', 'Excerpt', 1, 0, 1, 1, 1, 1, '', 5),
(35, 5, 'body', 'rich_text_box', 'Body', 1, 0, 1, 1, 1, 1, '', 6),
(36, 5, 'image', 'image', 'Post Image', 0, 1, 1, 1, 1, 1, '{\"resize\":{\"width\":\"1000\",\"height\":\"null\"},\"quality\":\"70%\",\"upsize\":true,\"thumbnails\":[{\"name\":\"medium\",\"scale\":\"50%\"},{\"name\":\"small\",\"scale\":\"25%\"},{\"name\":\"cropped\",\"crop\":{\"width\":\"300\",\"height\":\"250\"}}]}', 7),
(37, 5, 'slug', 'text', 'Slug', 1, 0, 1, 1, 1, 1, '{\"slugify\":{\"origin\":\"title\",\"forceUpdate\":true},\"validation\":{\"rule\":\"unique:posts,slug\"}}', 8),
(38, 5, 'meta_description', 'text_area', 'Meta Description', 1, 0, 1, 1, 1, 1, '', 9),
(39, 5, 'meta_keywords', 'text_area', 'Meta Keywords', 1, 0, 1, 1, 1, 1, '', 10),
(40, 5, 'status', 'select_dropdown', 'Status', 1, 1, 1, 1, 1, 1, '{\"default\":\"DRAFT\",\"options\":{\"PUBLISHED\":\"published\",\"DRAFT\":\"draft\",\"PENDING\":\"pending\"}}', 11),
(41, 5, 'created_at', 'timestamp', 'Created At', 0, 1, 1, 0, 0, 0, '', 12),
(42, 5, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, '', 13),
(43, 5, 'seo_title', 'text', 'SEO Title', 0, 1, 1, 1, 1, 1, '', 14),
(44, 5, 'featured', 'checkbox', 'Featured', 1, 1, 1, 1, 1, 1, '', 15),
(45, 6, 'id', 'number', 'ID', 1, 0, 0, 0, 0, 0, '', 1),
(46, 6, 'author_id', 'text', 'Author', 1, 0, 0, 0, 0, 0, '', 2),
(47, 6, 'title', 'text', 'Title', 1, 1, 1, 1, 1, 1, '', 3),
(48, 6, 'excerpt', 'text_area', 'Excerpt', 1, 0, 1, 1, 1, 1, '', 4),
(49, 6, 'body', 'rich_text_box', 'Body', 1, 0, 1, 1, 1, 1, '', 5),
(50, 6, 'slug', 'text', 'Slug', 1, 0, 1, 1, 1, 1, '{\"slugify\":{\"origin\":\"title\"},\"validation\":{\"rule\":\"unique:pages,slug\"}}', 6),
(51, 6, 'meta_description', 'text', 'Meta Description', 1, 0, 1, 1, 1, 1, '', 7),
(52, 6, 'meta_keywords', 'text', 'Meta Keywords', 1, 0, 1, 1, 1, 1, '', 8),
(53, 6, 'status', 'select_dropdown', 'Status', 1, 1, 1, 1, 1, 1, '{\"default\":\"INACTIVE\",\"options\":{\"INACTIVE\":\"INACTIVE\",\"ACTIVE\":\"ACTIVE\"}}', 9),
(54, 6, 'created_at', 'timestamp', 'Created At', 1, 1, 1, 0, 0, 0, '', 10),
(55, 6, 'updated_at', 'timestamp', 'Updated At', 1, 0, 0, 0, 0, 0, '', 11),
(56, 6, 'image', 'image', 'Page Image', 0, 1, 1, 1, 1, 1, '', 12),
(57, 7, 'id', 'hidden', 'Id', 1, 0, 1, 1, 1, 1, NULL, 1),
(58, 7, 'code_product', 'text', 'Mã sản phẩm', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 3),
(59, 7, 'name', 'text', 'Tên sản phẩm', 1, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 2),
(60, 7, 'slug', 'text', 'Slug', 1, 0, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 20),
(61, 7, 'details', 'text', 'Details', 0, 0, 1, 1, 1, 1, NULL, 19),
(62, 7, 'price', 'number', 'Giá bán', 1, 1, 1, 1, 1, 1, NULL, 12),
(63, 7, 'price_in', 'number', 'Giá nhập', 1, 1, 1, 1, 1, 1, NULL, 13),
(64, 7, 'price_promotion', 'number', 'Giá khuyến mãi', 0, 1, 1, 1, 1, 1, NULL, 14),
(65, 7, 'description', 'rich_text_box', 'Mô tả', 1, 0, 1, 1, 1, 1, NULL, 10),
(66, 7, 'brand_id', 'number', 'Id thương hiệu', 0, 0, 1, 1, 1, 1, NULL, 7),
(67, 7, 'category_id', 'number', 'Id danh mục', 0, 0, 1, 1, 1, 1, NULL, 9),
(68, 7, 'featured', 'checkbox', 'Bán chạy', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 11),
(69, 7, 'new', 'checkbox', 'Mới', 0, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 15),
(70, 7, 'image', 'image', 'Hình đại diện', 0, 1, 1, 1, 1, 1, NULL, 4),
(72, 7, 'quanity', 'number', 'Số lượng', 1, 1, 1, 1, 1, 1, NULL, 17),
(73, 7, 'status', 'checkbox', 'Status', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 18),
(74, 7, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 21),
(75, 7, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 22),
(76, 8, 'id', 'hidden', 'Mã', 1, 1, 1, 0, 1, 1, NULL, 1),
(77, 8, 'name', 'text', 'Tên', 1, 1, 1, 1, 1, 1, NULL, 2),
(78, 8, 'slug', 'text', 'Slug', 1, 1, 1, 1, 1, 1, NULL, 4),
(79, 8, 'parent_id', 'number', 'Mã danh mục cha', 0, 1, 1, 1, 1, 1, NULL, 5),
(80, 8, 'sub_id', 'number', 'Mã danh mục con', 0, 1, 1, 1, 1, 1, NULL, 6),
(81, 8, 'status', 'checkbox', 'Trạng thái', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 7),
(82, 8, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 8),
(83, 8, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 9),
(84, 9, 'id', 'hidden', 'Mã', 1, 1, 1, 1, 1, 1, NULL, 1),
(85, 9, 'code', 'text', 'Mã Giảm giá', 1, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:20\"}}', 2),
(86, 9, 'type', 'select_dropdown', 'Phương thức giảm', 1, 1, 1, 1, 1, 1, '{\"default\":\"Fixed Value\",\"options\":{\"fixed\":\"Fixed Value\",\"percent\":\"Percent Off\"}}', 3),
(87, 9, 'value', 'number', 'Tiền giảm', 0, 1, 1, 1, 1, 1, '{\"null\":\"\"}', 4),
(88, 9, 'quanity', 'number', 'Số lượng', 1, 1, 1, 1, 1, 1, NULL, 6),
(89, 9, 'percent_off', 'number', 'Phần trăm giảm', 0, 1, 1, 1, 1, 1, '{\"null\":\"\"}', 5),
(90, 9, 'status', 'checkbox', 'Trạng thái', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 7),
(91, 9, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 8),
(92, 9, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 9),
(93, 10, 'id', 'hidden', 'Mã', 1, 1, 1, 1, 1, 1, NULL, 1),
(94, 10, 'name', 'text', 'Tên', 1, 1, 1, 1, 1, 1, NULL, 2),
(95, 10, 'slug', 'text', 'Slug', 1, 1, 1, 1, 1, 1, NULL, 3),
(96, 10, 'image', 'image', 'Hình ảnh', 1, 1, 1, 1, 1, 1, NULL, 4),
(97, 10, 'title', 'text', 'Mô tả', 0, 1, 1, 1, 1, 1, NULL, 5),
(98, 10, 'status', 'checkbox', 'Trạng thái', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 6),
(99, 10, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 7),
(101, 14, 'id', 'hidden', 'Id', 1, 1, 1, 1, 1, 1, NULL, 1),
(102, 14, 'image', 'image', 'Image', 1, 1, 1, 1, 1, 1, NULL, 2),
(103, 14, 'link', 'text', 'Link', 1, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"required|max:191\"}}', 3),
(104, 14, 'title', 'text', 'Title', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 4),
(105, 14, 'status', 'checkbox', 'Status', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 5),
(106, 14, 'category_id', 'number', 'Category Id', 0, 1, 1, 1, 1, 1, '{\"default\":\"\"}', 6),
(107, 14, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 7),
(108, 14, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 8),
(109, 15, 'id', 'hidden', 'Mã', 1, 1, 1, 1, 1, 1, NULL, 1),
(110, 15, 'name', 'text', 'Tên', 1, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 3),
(111, 15, 'email', 'text', 'Email', 1, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 4),
(112, 15, 'user_id', 'number', 'Mã user', 0, 1, 1, 1, 1, 1, NULL, 2),
(113, 15, 'gender', 'select_dropdown', 'Giới tính', 1, 1, 1, 1, 1, 1, '{\"default\":\"Nam\",\"options\":{\"1\":\"Nam\",\"2\":\"Nữ\"}}', 5),
(114, 15, 'birthday', 'date', 'Ngày sinh', 0, 1, 1, 1, 1, 1, '{\"format\":\"%Y-%m-%d\"}', 10),
(115, 15, 'phone_number', 'text', 'Số điện thoại', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:20\"}}', 6),
(116, 15, 'address', 'text', 'Địa chỉ', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 7),
(117, 15, 'point', 'number', 'Điểm tích lũy', 1, 1, 1, 1, 1, 1, '{\"default\":0}', 8),
(118, 15, 'status', 'checkbox', 'Trạng thái', 1, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 11),
(119, 15, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 12),
(120, 15, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 13),
(121, 15, 'member', 'select_dropdown', 'Loại thành viên', 1, 1, 1, 1, 1, 1, '{\"default\":\"Thường\",\"options\":{\"1\":\"Thường\",\"2\":\"VIP\",\"3\":\"Diamond\"}}', 9),
(122, 17, 'id', 'hidden', 'Mã đơn hàng', 1, 1, 1, 0, 1, 1, NULL, 1),
(123, 17, 'user_id', 'number', 'Mã người dùng', 0, 1, 1, 1, 1, 1, NULL, 2),
(130, 17, 'billing_name_on_card', 'text', 'Tên trên thẻ thành toán', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 9),
(131, 17, 'billing_discount', 'number', 'Giảm giá', 0, 1, 1, 1, 1, 1, NULL, 10),
(132, 17, 'billing_discount_code', 'text', 'Mã giảm giá', 0, 1, 1, 1, 1, 1, NULL, 11),
(134, 17, 'billing_tax', 'number', 'Thuế', 1, 1, 1, 1, 1, 1, '{\"default\":10}', 13),
(135, 17, 'billing_total', 'number', 'Tổng tiền', 1, 1, 1, 1, 1, 1, NULL, 14),
(136, 17, 'payment_gateway', 'select_dropdown', 'Phương thức thanh toán', 1, 1, 1, 1, 1, 1, '{\"default\":\"COD\",\"options\":{\"COD\":\"COD\",\"ATM\":\"ATM\"}}', 15),
(137, 17, 'shipped', 'select_dropdown', 'Trạng thái', 1, 1, 1, 1, 1, 1, '{\"default\":\"Đang chờ\",\"options\":{\"Đang chờ\":\"Đang chờ\",\"Đang vận chuyển\":\"Đang vận chuyển\",\"Thành Công\":\"Thành công\"}}', 16),
(138, 17, 'error', 'text', 'Ghi chú', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"max:191\"}}', 17),
(139, 17, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 18),
(140, 17, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 19),
(141, 18, 'id', 'hidden', 'Mã', 1, 1, 1, 0, 1, 1, NULL, 0),
(142, 18, 'order_id', 'number', 'Mã đơn hàng', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"required\"}}', 2),
(143, 18, 'product_id', 'number', 'Mã sản phẩm', 0, 1, 1, 1, 1, 1, '{\"validation\":{\"rule\":\"required\"}}', 3),
(144, 18, 'quantity', 'number', 'Số lượng mua', 1, 1, 1, 1, 1, 1, NULL, 4),
(145, 18, 'created_at', 'timestamp', 'Created At', 0, 0, 0, 0, 0, 0, NULL, 5),
(146, 18, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 6),
(147, 7, 'hot_price', 'checkbox', 'Hot', 0, 1, 1, 1, 1, 1, '{\"on\":\"ON\",\"off\":\"OFF\"}', 16),
(148, 7, 'product_belongsto_brand_relationship', 'relationship', 'Thương hiệu', 0, 1, 1, 1, 1, 1, '{\"model\":\"App\\\\Brand\",\"table\":\"brand\",\"type\":\"belongsTo\",\"column\":\"brand_id\",\"key\":\"id\",\"label\":\"name\",\"pivot_table\":\"brand\",\"pivot\":\"0\",\"taggable\":\"0\"}', 6),
(149, 7, 'product_belongsto_category_relationship', 'relationship', 'Danh Mục', 0, 1, 1, 1, 1, 1, '{\"model\":\"App\\\\Category\",\"table\":\"category\",\"type\":\"belongsTo\",\"column\":\"category_id\",\"key\":\"id\",\"label\":\"name\",\"pivot_table\":\"brand\",\"pivot\":\"0\",\"taggable\":\"0\"}', 8),
(150, 10, 'updated_at', 'timestamp', 'Updated At', 0, 0, 0, 0, 0, 0, NULL, 8),
(151, 8, 'image', 'image', 'Hình ảnh', 0, 1, 1, 1, 1, 1, NULL, 3);

-- --------------------------------------------------------

--
-- Table structure for table `data_types`
--

CREATE TABLE `data_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name_singular` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name_plural` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `policy_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `controller` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `generate_permissions` tinyint(1) NOT NULL DEFAULT '0',
  `server_side` tinyint(4) NOT NULL DEFAULT '0',
  `details` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `data_types`
--

INSERT INTO `data_types` (`id`, `name`, `slug`, `display_name_singular`, `display_name_plural`, `icon`, `model_name`, `policy_name`, `controller`, `description`, `generate_permissions`, `server_side`, `details`, `created_at`, `updated_at`) VALUES
(1, 'users', 'users', 'User', 'Users', 'voyager-person', 'TCG\\Voyager\\Models\\User', 'TCG\\Voyager\\Policies\\UserPolicy', NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-05-31 22:21:40', '2018-06-03 12:54:35'),
(2, 'menus', 'menus', 'Menu', 'Menus', 'voyager-list', 'TCG\\Voyager\\Models\\Menu', NULL, '', '', 1, 0, NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(3, 'roles', 'roles', 'Role', 'Roles', 'voyager-lock', 'TCG\\Voyager\\Models\\Role', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-05-31 22:21:40', '2018-06-03 03:07:21'),
(4, 'categories', 'categories', 'Category', 'Categories', 'voyager-categories', 'TCG\\Voyager\\Models\\Category', NULL, '', '', 1, 0, NULL, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(5, 'posts', 'posts', 'Post', 'Posts', 'voyager-news', 'TCG\\Voyager\\Models\\Post', 'TCG\\Voyager\\Policies\\PostPolicy', '', '', 1, 0, NULL, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(6, 'pages', 'pages', 'Page', 'Pages', 'voyager-file-text', 'TCG\\Voyager\\Models\\Page', NULL, '', '', 1, 0, NULL, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(7, 'products', 'products', 'Product', 'Products', 'voyager-bag', 'App\\Product', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 06:50:24', '2018-06-02 16:43:03'),
(8, 'category', 'category', 'Category', 'Categories', 'voyager-window-list', 'App\\Category', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 07:04:53', '2018-06-03 01:53:18'),
(9, 'coupons', 'coupons', 'Coupon', 'Coupons', 'voyager-diamond', 'App\\Coupon', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 07:17:52', '2018-06-03 03:13:08'),
(10, 'brand', 'brand', 'Brand', 'Brands', 'voyager-tag', 'App\\Brand', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 07:30:23', '2018-06-02 16:47:54'),
(14, 'slides', 'slides', 'Slide', 'Slides', 'voyager-lab', 'App\\Slide', NULL, NULL, NULL, 1, 0, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(15, 'customer', 'customer', 'Customer', 'Customers', 'voyager-people', 'App\\Customer', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 07:47:32', '2018-06-03 03:15:05'),
(17, 'orders', 'orders', 'Order', 'Orders', 'voyager-receipt', 'App\\Order', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 08:14:58', '2018-06-03 03:09:28'),
(18, 'order_product', 'order-product', 'Order Product', 'Order Products', 'voyager-basket', 'App\\Order_product', NULL, NULL, NULL, 1, 1, '{\"order_column\":null,\"order_display_column\":null}', '2018-06-01 09:55:30', '2018-06-03 03:10:14');

-- --------------------------------------------------------

--
-- Table structure for table `menus`
--

CREATE TABLE `menus` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menus`
--

INSERT INTO `menus` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'admin', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(2, 'menu_product', '2018-06-01 16:49:38', '2018-06-01 16:49:38');

-- --------------------------------------------------------

--
-- Table structure for table `menu_items`
--

CREATE TABLE `menu_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `menu_id` int(10) UNSIGNED DEFAULT NULL,
  `title` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '_self',
  `icon_class` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `order` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `route` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parameters` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu_items`
--

INSERT INTO `menu_items` (`id`, `menu_id`, `title`, `url`, `target`, `icon_class`, `color`, `parent_id`, `order`, `created_at`, `updated_at`, `route`, `parameters`) VALUES
(1, 1, 'Bảng điều khiển', '', '_self', 'voyager-boat', '#000000', NULL, 1, '2018-05-31 22:21:40', '2018-06-02 13:54:11', 'voyager.dashboard', 'null'),
(2, 1, 'Media', '', '_self', 'voyager-images', NULL, NULL, 12, '2018-05-31 22:21:40', '2018-06-01 10:03:19', 'voyager.media.index', NULL),
(3, 1, 'Users', '', '_self', 'voyager-person', NULL, NULL, 10, '2018-05-31 22:21:40', '2018-06-01 10:03:19', 'voyager.users.index', NULL),
(4, 1, 'Vai trò', '', '_self', 'voyager-lock', '#000000', NULL, 4, '2018-05-31 22:21:40', '2018-06-03 02:51:34', 'voyager.roles.index', 'null'),
(5, 1, 'Công cụ', '', '_self', 'voyager-tools', '#000000', NULL, 15, '2018-05-31 22:21:40', '2018-06-03 02:56:23', NULL, ''),
(6, 1, 'Tùy chỉnh menu', '', '_self', 'voyager-list', '#000000', 5, 1, '2018-05-31 22:21:40', '2018-06-03 02:53:51', 'voyager.menus.index', 'null'),
(7, 1, 'Database', '', '_self', 'voyager-data', NULL, 5, 2, '2018-05-31 22:21:40', '2018-06-01 09:38:53', 'voyager.database.index', NULL),
(8, 1, 'Mẫu Icon', '', '_self', 'voyager-compass', '#000000', 5, 3, '2018-05-31 22:21:40', '2018-06-03 02:55:59', 'voyager.compass.index', 'null'),
(10, 1, 'Cài đặt', '', '_self', 'voyager-settings', '#000000', NULL, 16, '2018-05-31 22:21:40', '2018-06-03 02:56:23', 'voyager.settings.index', 'null'),
(12, 1, 'Bài viết', '', '_self', 'voyager-news', '#000000', NULL, 13, '2018-05-31 22:21:41', '2018-06-03 02:57:09', 'voyager.posts.index', 'null'),
(13, 1, 'Tin tức', '', '_self', 'voyager-file-text', '#000000', NULL, 14, '2018-05-31 22:21:41', '2018-06-03 02:56:55', 'voyager.pages.index', 'null'),
(15, 1, 'Sản phẩm', '', '_self', 'voyager-bag', '#000000', NULL, 2, '2018-06-01 06:50:24', '2018-06-03 02:51:17', 'voyager.products.index', 'null'),
(16, 1, 'Danh mục', '', '_self', 'voyager-window-list', '#000000', NULL, 5, '2018-06-01 07:04:53', '2018-06-03 02:51:46', 'voyager.category.index', 'null'),
(17, 1, 'Mã giảm giá', '', '_self', 'voyager-diamond', '#000000', NULL, 8, '2018-06-01 07:17:53', '2018-06-03 02:52:23', 'voyager.coupons.index', 'null'),
(18, 1, 'Thương hiệu', '', '_self', 'voyager-tag', '#000000', NULL, 3, '2018-06-01 07:30:23', '2018-06-03 02:51:25', 'voyager.brand.index', 'null'),
(19, 1, 'Slides', '', '_self', 'voyager-lab', NULL, NULL, 11, '2018-06-01 07:39:15', '2018-06-01 10:03:19', 'voyager.slides.index', NULL),
(20, 1, 'Khách hàng', '', '_self', 'voyager-people', '#000000', NULL, 9, '2018-06-01 07:47:32', '2018-06-03 02:52:34', 'voyager.customer.index', 'null'),
(21, 1, 'Đơn đặt hàng', '', '_self', 'voyager-receipt', '#000000', NULL, 6, '2018-06-01 08:14:58', '2018-06-03 02:52:01', 'voyager.orders.index', 'null'),
(22, 1, 'Chi tiết đơn đặt hàng', '', '_self', 'voyager-basket', '#000000', NULL, 7, '2018-06-01 09:55:30', '2018-06-03 02:52:14', 'voyager.order-product.index', 'null');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2016_01_01_000000_add_voyager_user_fields', 1),
(4, '2016_01_01_000000_create_data_types_table', 1),
(5, '2016_05_19_173453_create_menu_table', 1),
(6, '2016_10_21_190000_create_roles_table', 1),
(7, '2016_10_21_190000_create_settings_table', 1),
(8, '2016_11_30_135954_create_permission_table', 1),
(9, '2016_11_30_141208_create_permission_role_table', 1),
(10, '2016_12_26_201236_data_types__add__server_side', 1),
(11, '2017_01_13_000000_add_route_to_menu_items_table', 1),
(12, '2017_01_14_005015_create_translations_table', 1),
(13, '2017_01_15_000000_make_table_name_nullable_in_permissions_table', 1),
(14, '2017_03_06_000000_add_controller_to_data_types_table', 1),
(15, '2017_04_21_000000_add_order_to_data_rows_table', 1),
(16, '2017_07_05_210000_add_policyname_to_data_types_table', 1),
(17, '2017_08_05_000000_add_group_to_settings_table', 1),
(18, '2017_11_26_013050_add_user_role_relationship', 1),
(19, '2017_11_26_015000_create_user_roles_table', 1),
(20, '2018_03_11_000000_add_user_settings', 1),
(21, '2018_03_14_000000_add_details_to_data_types_table', 1),
(22, '2018_03_16_000000_make_settings_value_nullable', 1),
(23, '2016_01_01_000000_create_pages_table', 2),
(24, '2016_01_01_000000_create_posts_table', 2),
(25, '2016_02_15_204651_create_categories_table', 2),
(26, '2017_04_11_000000_alter_post_nullable_fields_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã hóa đơn',
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã tài khoản',
  `billing_name_on_card` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Tên người đặt',
  `billing_discount` int(11) DEFAULT '0' COMMENT 'Số tiền được giảm',
  `billing_discount_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'CODE giảm giá',
  `billing_tax` int(11) NOT NULL DEFAULT '10' COMMENT 'Thuế',
  `billing_total` int(11) NOT NULL COMMENT 'Tổng tiền',
  `payment_gateway` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'COD' COMMENT 'Phương thức thanh toán',
  `shipped` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Đang chờ' COMMENT 'Trạng thái đơn hàng',
  `error` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Ghi chú',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `billing_name_on_card`, `billing_discount`, `billing_discount_code`, `billing_tax`, `billing_total`, `payment_gateway`, `shipped`, `error`, `created_at`, `updated_at`) VALUES
(1, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(2, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(3, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(4, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(5, 23, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(6, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(7, 22, 'Nguyen hoang hiep', 50000, 'nhh002', 10, 156750, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(8, 22, 'Nguyen hoang hiep', 50000, 'nhh002', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(9, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(10, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(11, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', NULL, NULL),
(12, 1, 'Admin', 50000, 'nh003', 10, 1254000, 'COD', 'Thành Công', NULL, '2018-06-04 08:55:32', '2018-06-05 10:40:07'),
(13, 1, 'Admin', 50000, 'nh003', 10, 1254000, 'COD', 'Đang chờ', '', '2018-06-04 09:00:49', '2018-06-04 09:00:49'),
(14, 1, 'Admin', 50000, 'nh003', 10, 65211, 'ATM', 'Đang vận chuyển', NULL, '2018-06-04 09:08:49', '2018-06-05 08:40:25'),
(15, 1, 'Admin', 50000, 'nh003', 10, 0, 'COD', 'Đang chờ', '', '2018-06-05 18:22:07', '2018-06-05 18:22:07'),
(16, 1, 'Admin', 0, 'nh003', 10, 30000, 'COD', 'Đang chờ', '', '2018-06-05 18:26:36', '2018-06-05 18:26:36'),
(17, 1, 'Admin', 50000, 'nh003', 10, 0, 'COD', 'Đang chờ', '', '2018-06-05 18:29:45', '2018-06-05 18:29:45'),
(18, 1, 'Admin', 50000, 'nh003', 10, 0, 'COD', 'Đang chờ', '', '2018-06-05 18:32:15', '2018-06-05 18:32:15'),
(19, 1, 'Admin', 75000, 'nhh002', 10, 75000, 'COD', 'Đang chờ', '', '2018-06-05 18:35:03', '2018-06-05 18:35:03'),
(20, 1, 'Admin', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 18:42:33', '2018-06-05 18:42:33'),
(21, 1, 'Admin', 165000, 'nhh002', 10, 165000, 'COD', 'Đang chờ', '', '2018-06-05 18:47:29', '2018-06-05 18:47:29'),
(22, 1, 'Admin', 165000, 'nhh002', 10, 165000, 'COD', 'Đang chờ', '', '2018-06-05 18:48:21', '2018-06-05 18:48:21'),
(23, 30, 'hr', 50000, 'nh003', 10, 1371000, 'ATM', 'Đang chờ', '', '2018-06-05 19:22:45', '2018-06-05 19:22:45'),
(24, 31, 'Lý Đạt', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 19:28:19', '2018-06-05 19:28:19'),
(25, 31, 'Lý Đạt', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 19:29:02', '2018-06-05 19:29:02'),
(26, 31, 'Lý Đạt', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 19:30:13', '2018-06-05 19:30:13'),
(27, 31, 'Lý Đạt', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 19:31:58', '2018-06-05 19:31:58'),
(28, 31, 'Lý Đạt', 50000, 'nh003', 10, 280000, 'COD', 'Đang chờ', '', '2018-06-05 19:32:15', '2018-06-05 19:32:15'),
(29, 30, 'hr', 50000, 'nh003', 10, 238000, 'ATM', 'Đang chờ', '', '2018-06-06 02:53:43', '2018-06-06 02:53:43'),
(30, 1, 'Admin', 0, NULL, 10, 896750, 'ATM', 'Đang chờ', '', '2018-06-06 03:19:27', '2018-06-06 03:19:27'),
(31, 1, 'Admin', 0, NULL, 10, 830000, 'COD', 'Đang chờ', '', '2018-06-06 03:20:24', '2018-06-06 03:20:24'),
(32, 1, 'Admin', 50000, 'nh003', 10, 40000, 'ATM', 'Đang chờ', '', '2018-06-06 03:24:50', '2018-06-06 03:24:50'),
(33, 1, 'Admin', 50000, 'nh003', 10, 40000, 'COD', 'Đang chờ', '', '2018-06-06 03:31:00', '2018-06-06 03:31:00'),
(34, 1, 'Admin', 50000, 'nh003', 10, 40000, 'ATM', 'Đang chờ', '', '2018-06-06 03:32:45', '2018-06-06 03:32:45'),
(35, 31, 'Lý Đạt', 50000, 'nh003', 10, 150010, 'COD', 'Đang chờ', '', '2018-06-06 03:51:53', '2018-06-06 03:51:53'),
(36, 31, 'Lý Đạt', 0, NULL, 10, 295010, 'COD', 'Đang chờ', '', '2018-06-06 03:57:35', '2018-06-06 03:57:35'),
(37, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(38, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 156750, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(39, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(40, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 156750, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(41, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 148500, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(42, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 156750, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(43, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(44, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 165000, 'ATM', 'Đang chờ', 'null', '2018-06-09 17:00:00', NULL),
(45, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 148500, 'ATM', 'Đang chờ', 'null', '2018-06-10 10:40:52', '2018-06-10 10:40:52'),
(46, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 148500, 'ATM', 'Đang chờ', 'null', '2018-06-10 10:42:14', '2018-06-10 10:42:14'),
(47, 22, 'Nguyen hoang hiep', 50000, 'nh003', 10, 148500, 'ATM', 'Đang chờ', 'null', '2018-06-10 10:48:33', '2018-06-10 10:48:33');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `Tg_CapNhat_LoaiKhachHang` AFTER INSERT ON `orders` FOR EACH ROW BEGIN
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
        
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_product`
--

CREATE TABLE `order_product` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã chi tiết hóa đơn',
  `order_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã hóa đơn',
  `product_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã sản phẩm',
  `quantity` int(10) UNSIGNED NOT NULL COMMENT 'Sô lượng mua',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_product`
--

INSERT INTO `order_product` (`id`, `order_id`, `product_id`, `quantity`, `created_at`, `updated_at`) VALUES
(1, 12, 142, 7, '2018-06-04 08:55:32', '2018-06-04 08:55:32'),
(2, 12, 7, 1, '2018-06-04 08:55:32', '2018-06-04 08:55:32'),
(3, 13, 142, 7, '2018-06-04 09:00:49', '2018-06-04 09:00:49'),
(4, 13, 7, 1, '2018-06-04 09:00:49', '2018-06-04 09:00:49'),
(5, 14, 10, 1, '2018-06-04 09:08:49', '2018-06-04 09:08:49'),
(6, 14, 52, 1, '2018-06-04 09:08:49', '2018-06-04 09:08:49'),
(10, 18, 11, 1, '2018-06-05 18:32:15', '2018-06-05 18:32:15'),
(11, 23, 146, 1, '2018-06-05 19:22:45', '2018-06-05 19:22:45'),
(12, 23, 150, 1, '2018-06-05 19:22:45', '2018-06-05 19:22:45'),
(13, 23, 12, 1, '2018-06-05 19:22:45', '2018-06-05 19:22:45'),
(17, 29, 10, 3, '2018-06-06 02:53:43', '2018-06-06 02:53:43'),
(18, 29, 9, 1, '2018-06-06 02:53:43', '2018-06-06 02:53:43'),
(19, 30, 148, 1, '2018-06-06 03:19:27', '2018-06-06 03:19:27'),
(20, 30, 5, 1, '2018-06-06 03:19:27', '2018-06-06 03:19:27'),
(21, 31, 11, 1, '2018-06-06 03:20:24', '2018-06-06 03:20:24'),
(22, 31, 148, 1, '2018-06-06 03:20:24', '2018-06-06 03:20:24'),
(25, 34, 11, 3, '2018-06-06 03:32:45', '2018-06-06 03:32:45'),
(26, 35, 50, 2, '2018-06-06 03:51:53', '2018-06-06 03:51:53'),
(27, 36, 50, 2, '2018-06-06 03:57:35', '2018-06-06 03:57:35'),
(28, 36, 137, 2, '2018-06-06 03:57:35', '2018-06-06 04:07:46');

-- --------------------------------------------------------

--
-- Table structure for table `pages`
--

CREATE TABLE `pages` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Ma bài viết',
  `author_id` int(11) NOT NULL COMMENT 'Mã tác giả',
  `title` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tiêu đề',
  `excerpt` text COLLATE utf8mb4_unicode_ci,
  `body` text COLLATE utf8mb4_unicode_ci COMMENT 'Nội dung',
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Đường dẫn hình ảnh',
  `slug` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Đường dẫn thân thiện',
  `meta_description` text COLLATE utf8mb4_unicode_ci COMMENT 'Mô tả',
  `meta_keywords` text COLLATE utf8mb4_unicode_ci COMMENT 'Từ khóa',
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INACTIVE' COMMENT 'Trang thái bài viết',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pages`
--

INSERT INTO `pages` (`id`, `author_id`, `title`, `excerpt`, `body`, `image`, `slug`, `meta_description`, `meta_keywords`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Hello World', 'Hang the jib grog grog blossom grapple dance the hempen jig gangway pressgang bilge rat to go on account lugger. Nelsons folly gabion line draught scallywag fire ship gaff fluke fathom case shot. Sea Legs bilge rat sloop matey gabion long clothes run a shot across the bow Gold Road cog league.', '<p>Hello World. Scallywag grog swab Cat o\'nine tails scuttle rigging hardtack cable nipper Yellow Jack. Handsomely spirits knave lad killick landlubber or just lubber deadlights chantey pinnace crack Jennys tea cup. Provost long clothes black spot Yellow Jack bilged on her anchor league lateen sail case shot lee tackle.</p>\r\n<p>Ballast spirits fluke topmast me quarterdeck schooner landlubber or just lubber gabion belaying pin. Pinnace stern galleon starboard warp carouser to go on account dance the hempen jig jolly boat measured fer yer chains. Man-of-war fire in the hole nipperkin handsomely doubloon barkadeer Brethren of the Coast gibbet driver squiffy.</p>', 'pages/June2018/7lcfmSg8NVWXaq68nx1K.jpg', 'hello-world', 'Yar Meta Description', 'Keyword1, Keyword2', 'ACTIVE', '2018-05-31 22:21:41', '2018-06-03 19:38:25');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã quyền',
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên quyền',
  `table_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Tên bảng',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `key`, `table_name`, `created_at`, `updated_at`) VALUES
(1, 'browse_admin', NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(2, 'browse_bread', NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(3, 'browse_database', NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(4, 'browse_media', NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(5, 'browse_compass', NULL, '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(6, 'browse_menus', 'menus', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(7, 'read_menus', 'menus', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(8, 'edit_menus', 'menus', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(9, 'add_menus', 'menus', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(10, 'delete_menus', 'menus', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(11, 'browse_roles', 'roles', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(12, 'read_roles', 'roles', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(13, 'edit_roles', 'roles', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(14, 'add_roles', 'roles', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(15, 'delete_roles', 'roles', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(16, 'browse_users', 'users', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(17, 'read_users', 'users', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(18, 'edit_users', 'users', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(19, 'add_users', 'users', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(20, 'delete_users', 'users', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(21, 'browse_settings', 'settings', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(22, 'read_settings', 'settings', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(23, 'edit_settings', 'settings', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(24, 'add_settings', 'settings', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(25, 'delete_settings', 'settings', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(26, 'browse_categories', 'categories', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(27, 'read_categories', 'categories', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(28, 'edit_categories', 'categories', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(29, 'add_categories', 'categories', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(30, 'delete_categories', 'categories', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(31, 'browse_posts', 'posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(32, 'read_posts', 'posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(33, 'edit_posts', 'posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(34, 'add_posts', 'posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(35, 'delete_posts', 'posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(36, 'browse_pages', 'pages', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(37, 'read_pages', 'pages', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(38, 'edit_pages', 'pages', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(39, 'add_pages', 'pages', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(40, 'delete_pages', 'pages', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(41, 'browse_hooks', NULL, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(42, 'browse_products', 'products', '2018-06-01 06:50:24', '2018-06-01 06:50:24'),
(43, 'read_products', 'products', '2018-06-01 06:50:24', '2018-06-01 06:50:24'),
(44, 'edit_products', 'products', '2018-06-01 06:50:24', '2018-06-01 06:50:24'),
(45, 'add_products', 'products', '2018-06-01 06:50:24', '2018-06-01 06:50:24'),
(46, 'delete_products', 'products', '2018-06-01 06:50:24', '2018-06-01 06:50:24'),
(47, 'browse_category', 'category', '2018-06-01 07:04:53', '2018-06-01 07:04:53'),
(48, 'read_category', 'category', '2018-06-01 07:04:53', '2018-06-01 07:04:53'),
(49, 'edit_category', 'category', '2018-06-01 07:04:53', '2018-06-01 07:04:53'),
(50, 'add_category', 'category', '2018-06-01 07:04:53', '2018-06-01 07:04:53'),
(51, 'delete_category', 'category', '2018-06-01 07:04:53', '2018-06-01 07:04:53'),
(52, 'browse_coupons', 'coupons', '2018-06-01 07:17:53', '2018-06-01 07:17:53'),
(53, 'read_coupons', 'coupons', '2018-06-01 07:17:53', '2018-06-01 07:17:53'),
(54, 'edit_coupons', 'coupons', '2018-06-01 07:17:53', '2018-06-01 07:17:53'),
(55, 'add_coupons', 'coupons', '2018-06-01 07:17:53', '2018-06-01 07:17:53'),
(56, 'delete_coupons', 'coupons', '2018-06-01 07:17:53', '2018-06-01 07:17:53'),
(57, 'browse_brand', 'brand', '2018-06-01 07:30:23', '2018-06-01 07:30:23'),
(58, 'read_brand', 'brand', '2018-06-01 07:30:23', '2018-06-01 07:30:23'),
(59, 'edit_brand', 'brand', '2018-06-01 07:30:23', '2018-06-01 07:30:23'),
(60, 'add_brand', 'brand', '2018-06-01 07:30:23', '2018-06-01 07:30:23'),
(61, 'delete_brand', 'brand', '2018-06-01 07:30:23', '2018-06-01 07:30:23'),
(62, 'browse_slides', 'slides', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(63, 'read_slides', 'slides', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(64, 'edit_slides', 'slides', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(65, 'add_slides', 'slides', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(66, 'delete_slides', 'slides', '2018-06-01 07:39:15', '2018-06-01 07:39:15'),
(67, 'browse_customer', 'customer', '2018-06-01 07:47:32', '2018-06-01 07:47:32'),
(68, 'read_customer', 'customer', '2018-06-01 07:47:32', '2018-06-01 07:47:32'),
(69, 'edit_customer', 'customer', '2018-06-01 07:47:32', '2018-06-01 07:47:32'),
(70, 'add_customer', 'customer', '2018-06-01 07:47:32', '2018-06-01 07:47:32'),
(71, 'delete_customer', 'customer', '2018-06-01 07:47:32', '2018-06-01 07:47:32'),
(72, 'browse_orders', 'orders', '2018-06-01 08:14:58', '2018-06-01 08:14:58'),
(73, 'read_orders', 'orders', '2018-06-01 08:14:58', '2018-06-01 08:14:58'),
(74, 'edit_orders', 'orders', '2018-06-01 08:14:58', '2018-06-01 08:14:58'),
(75, 'add_orders', 'orders', '2018-06-01 08:14:58', '2018-06-01 08:14:58'),
(76, 'delete_orders', 'orders', '2018-06-01 08:14:58', '2018-06-01 08:14:58'),
(77, 'browse_order_product', 'order_product', '2018-06-01 09:55:30', '2018-06-01 09:55:30'),
(78, 'read_order_product', 'order_product', '2018-06-01 09:55:30', '2018-06-01 09:55:30'),
(79, 'edit_order_product', 'order_product', '2018-06-01 09:55:30', '2018-06-01 09:55:30'),
(80, 'add_order_product', 'order_product', '2018-06-01 09:55:30', '2018-06-01 09:55:30'),
(81, 'delete_order_product', 'order_product', '2018-06-01 09:55:30', '2018-06-01 09:55:30');

-- --------------------------------------------------------

--
-- Table structure for table `permission_role`
--

CREATE TABLE `permission_role` (
  `permission_id` int(10) UNSIGNED NOT NULL COMMENT 'Mã quyền',
  `role_id` int(10) UNSIGNED NOT NULL COMMENT 'Mã vai trò'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permission_role`
--

INSERT INTO `permission_role` (`permission_id`, `role_id`) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(3, 1),
(3, 2),
(4, 1),
(4, 2),
(5, 1),
(5, 2),
(6, 1),
(6, 2),
(7, 1),
(7, 2),
(8, 1),
(8, 2),
(9, 1),
(9, 2),
(10, 1),
(10, 2),
(11, 1),
(11, 2),
(12, 1),
(12, 2),
(13, 1),
(13, 2),
(14, 1),
(14, 2),
(15, 1),
(15, 2),
(16, 1),
(16, 2),
(16, 4),
(17, 1),
(17, 2),
(17, 4),
(18, 1),
(18, 2),
(18, 4),
(19, 1),
(19, 2),
(19, 4),
(20, 1),
(20, 2),
(20, 4),
(21, 1),
(21, 2),
(22, 1),
(22, 2),
(23, 1),
(23, 2),
(24, 1),
(24, 2),
(25, 1),
(25, 2),
(26, 1),
(26, 2),
(27, 1),
(27, 2),
(28, 1),
(28, 2),
(29, 1),
(29, 2),
(30, 1),
(30, 2),
(31, 1),
(31, 2),
(32, 1),
(32, 2),
(33, 1),
(33, 2),
(34, 1),
(34, 2),
(35, 1),
(35, 2),
(36, 1),
(36, 2),
(37, 1),
(37, 2),
(38, 1),
(38, 2),
(39, 1),
(39, 2),
(40, 1),
(40, 2),
(41, 1),
(41, 2),
(42, 1),
(42, 2),
(43, 1),
(43, 2),
(44, 1),
(44, 2),
(45, 1),
(45, 2),
(46, 1),
(46, 2),
(47, 1),
(47, 2),
(48, 1),
(48, 2),
(49, 1),
(49, 2),
(50, 1),
(50, 2),
(51, 1),
(51, 2),
(52, 1),
(52, 2),
(53, 1),
(53, 2),
(54, 1),
(54, 2),
(55, 1),
(55, 2),
(56, 1),
(56, 2),
(57, 1),
(57, 2),
(58, 1),
(58, 2),
(59, 1),
(59, 2),
(60, 1),
(60, 2),
(61, 1),
(61, 2),
(62, 1),
(62, 2),
(63, 1),
(63, 2),
(64, 1),
(64, 2),
(65, 1),
(65, 2),
(66, 1),
(66, 2),
(67, 1),
(67, 2),
(68, 1),
(68, 2),
(69, 1),
(69, 2),
(70, 1),
(70, 2),
(71, 1),
(71, 2),
(72, 1),
(72, 2),
(73, 1),
(73, 2),
(74, 1),
(74, 2),
(75, 1),
(75, 2),
(76, 1),
(76, 2),
(77, 1),
(77, 2),
(78, 1),
(78, 2),
(79, 1),
(79, 2),
(80, 1),
(80, 2),
(81, 1),
(81, 2);

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `id` int(10) UNSIGNED NOT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `title` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `seo_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `excerpt` text COLLATE utf8mb4_unicode_ci,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `meta_description` text COLLATE utf8mb4_unicode_ci,
  `meta_keywords` text COLLATE utf8mb4_unicode_ci,
  `status` enum('PUBLISHED','DRAFT','PENDING') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`id`, `author_id`, `category_id`, `title`, `seo_title`, `excerpt`, `body`, `image`, `slug`, `meta_description`, `meta_keywords`, `status`, `featured`, `created_at`, `updated_at`) VALUES
(1, 0, NULL, 'Lorem Ipsum Post', NULL, 'This is the excerpt for the Lorem Ipsum Post', '<p>This is the body of the lorem ipsum post</p>', 'posts/post1.jpg', 'lorem-ipsum-post', 'This is the meta description', 'keyword1, keyword2, keyword3', 'PUBLISHED', 0, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(2, 0, NULL, 'My Sample Post', NULL, 'This is the excerpt for the sample Post', '<p>This is the body for the sample post, which includes the body.</p>\n                <h2>We can use all kinds of format!</h2>\n                <p>And include a bunch of other stuff.</p>', 'posts/post2.jpg', 'my-sample-post', 'Meta Description for sample post', 'keyword1, keyword2, keyword3', 'PUBLISHED', 0, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(3, 0, NULL, 'Latest Post', NULL, 'This is the excerpt for the latest post', '<p>This is the body for the latest post</p>', 'posts/post3.jpg', 'latest-post', 'This is the meta description', 'keyword1, keyword2, keyword3', 'PUBLISHED', 0, '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(4, 0, NULL, 'Yarr Post', NULL, 'Reef sails nipperkin bring a spring upon her cable coffer jury mast spike marooned Pieces of Eight poop deck pillage. Clipper driver coxswain galleon hempen halter come about pressgang gangplank boatswain swing the lead. Nipperkin yard skysail swab lanyard Blimey bilge water ho quarter Buccaneer.', '<p>Swab deadlights Buccaneer fire ship square-rigged dance the hempen jig weigh anchor cackle fruit grog furl. Crack Jennys tea cup chase guns pressgang hearties spirits hogshead Gold Road six pounders fathom measured fer yer chains. Main sheet provost come about trysail barkadeer crimp scuttle mizzenmast brig plunder.</p>\n<p>Mizzen league keelhaul galleon tender cog chase Barbary Coast doubloon crack Jennys tea cup. Blow the man down lugsail fire ship pinnace cackle fruit line warp Admiral of the Black strike colors doubloon. Tackle Jack Ketch come about crimp rum draft scuppers run a shot across the bow haul wind maroon.</p>\n<p>Interloper heave down list driver pressgang holystone scuppers tackle scallywag bilged on her anchor. Jack Tar interloper draught grapple mizzenmast hulk knave cable transom hogshead. Gaff pillage to go on account grog aft chase guns piracy yardarm knave clap of thunder.</p>', 'posts/post4.jpg', 'yarr-post', 'this be a meta descript', 'keyword1, keyword2, keyword3', 'PUBLISHED', 0, '2018-05-31 22:21:41', '2018-05-31 22:21:41');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã sản phẩm',
  `code_product` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'CODE sản phẩm',
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên sản phẩm',
  `slug` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Đường dẫn thân thiện',
  `details` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Giới thiệu sản phẩm',
  `price` double NOT NULL COMMENT 'Giá bán',
  `price_in` double NOT NULL COMMENT 'Giá mua',
  `price_promotion` double DEFAULT '0' COMMENT 'Giá đã giảm giá',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mô tả chi tiết sản phẩm',
  `brand_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã thương hiệu',
  `category_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã danh mục',
  `featured` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Sản phẩm nổi bật',
  `new` tinyint(1) UNSIGNED DEFAULT '1' COMMENT 'Sản phẩm mới',
  `hot_price` int(10) DEFAULT NULL COMMENT 'Sản phẩm giá tốt',
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Đường dẫn hình ảnh',
  `quanity` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Số lượng tồn',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Trạng thái sản phẩm',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`, `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) VALUES
(2, 'B636s565', 'Khay son lì Mira Hydro Shine B63656ssss5 ', 'B636sss565-khay-son-li-mira-2206', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 4, 0, NULL, NULL),
(3, 'B636s56545', 'Khay son lì Mira Hydro Shine B63656ssss5455 ', 'B636sss56555-khay-son-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 19, 1, NULL, NULL),
(4, 'B636s56545s', 'Khay son lì Mira Hydro Shine B63656ssss5455s ', 'B636sss56555-khay-sson-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 9, 1, NULL, NULL),
(5, 'B633', 'Khay son lì Mira Hydro Shine (5 màu)', 'b633khay-son-li-mira-2206.png', 'null', 96750, 129000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">M&agrave;u son cực chuẩn khi thoa l&ecirc;n m&ocirc;i, khả năng b&aacute;m m&agrave;u suốt nhiều giờ, thoải m&aacute;i ăn uống nhưng son kh&ocirc;ng bị tr&ocirc;i Chất son chứa dưỡng chất mềm m&ocirc;i, chuẩn xu hướng son l&igrave; nhưng m&ocirc;i kh&ocirc;ng bị kh&ocirc;</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">HDSD : D&ugrave;ng cọ vẽ m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">Bảo quản: để nơi tho&aacute;ng m&aacute;t v&agrave; kh&ocirc; r&aacute;o, Tr&aacute;nh nơi c&oacute; &aacute;nh nắng mặt trời trực tiếp chiếu v&agrave;o</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">Khuyến c&aacute;o: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">NSX&amp;Lot: xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">HSD: 03 năm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">Khối lượng tịnh: 4g</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">Xuất xứ: H&agrave;n Quốc &nbsp; &nbsp; &nbsp;&nbsp;</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">NK&amp;PP: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 9, 1, NULL, '2018-06-03 12:43:39'),
(6, 'B592', 'Khay son môi Mira Hydro Shine Lips (7 màu)', 'b592khay-mira-hydro-shine-9915.png', 'null', 96750, 129000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Son m&ocirc;i Mira Hydro Shine Lips trang điểm m&ocirc;i, tạo cho bạn một l&agrave;n m&ocirc;i gợi cảm<br /> - M&agrave;u sắc hiện đại, quyến rũ v&agrave; cực kỳ sang trọng<br /> - Đa dạng m&agrave;u sắc, ph&ugrave; hợp với phong c&aacute;ch trang điểm của bạn</p>\r\n</div>', 225, 1, 1, 0, 0, 'products/June2018/BCB6KLkl89F71FPtKFWw.png', 9, 1, NULL, '2018-06-03 12:44:45'),
(7, 'GK0544', 'Phấn Nước Su:M37 Siêu Mịn, Che Khuyết Điểm, Chống Nắng Su:M Air Rising Glow Cover Metal Cushion', 'gk0544-4360.jpg', 'null', 800000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"line-height: normal;\"><strong>Phấn Nước Su:M37 Si&ecirc;u Mịn, Che Khuyết Điểm, Chống Nắng </strong>(<em>K&egrave;m L&otilde;i Refill</em>)</p>\r\n<p style=\"line-height: normal;\">Phấn nước Su:m37 gi&uacute;p da kh&ocirc; tho&aacute;ng, chỉ số chống nắng SPF50 bảo vệ da dưới &aacute;nh nắng mặt trời v&agrave; t&aacute;c hại từ m&ocirc;i trường Cấu tr&uacute;c hạt phấn Elastic Cover Powder gi&uacute;p che phủ kỹ tr&ecirc;n bề mặt da, cho lớp nền s&aacute;ng b&oacute;ng kh&ocirc;ng khuyết điểm c&ugrave;ng cảm gi&aacute;c ẩm mịn c&ugrave;ng độ chống nắng cao&nbsp;Lớp nền mỏng nhẹ, mượt m&agrave; tự nhi&ecirc;n C&ocirc;ng thức kh&ocirc;ng phấn hoạt thạch hạn chế tối đa k&iacute;ch ứng da B&ocirc;ng phấn mềm dễ d&agrave;n trải Ph&ugrave; hợp mọi loại da, đặc biệt da nhờn v&agrave; nhiều khuyết điểm</p>\r\n<p style=\"line-height: normal; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;<strong>Sử Dụng:</strong> D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều phấn theo chiều cấu tạo da v&agrave; vỗ nhẹ để phấn mịn đều hơnCần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn</p>\r\n<p style=\"margin-bottom: 0001pt; line-height: normal;\"><strong>Thành ph&acirc;̀n: </strong>In tr&ecirc;n bao b&igrave;</p>\r\n<p style=\"margin-bottom: 0001pt;\"><strong>Bảo quản: </strong>Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; line-height: normal;\"><strong>Khuyến c&aacute;o: </strong>Ngưng sử dụng nếu c&oacute; dấu hiệu di ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>NSX&amp;Lot: </strong>Xem tr&ecirc;n bao bì sản ph&acirc;̉m<strong>HSD:</strong>&nbsp; 03 năm (12 th&aacute;ng sau lần đầu mở nắp hộp sử dụng)</p>\r\n<p style=\"text-align: justify;\"><strong>Xuất xứ:</strong> H&agrave;n Quốc</p>\r\n</div>', 224, 1, 1, 0, 0, 'products/June2018/zmhGUTMT40yNK76UfhqB.jpg', 5, 1, NULL, '2018-06-03 12:47:23'),
(8, 'GK0466', 'Phấn Nước Đa Năng Kiềm Dầu Sáng Da Laneige (SPF 50/PA+++)', 'gk0466-7295.jpg', 'null', 558000, 620000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"color: black;\">Kem phấn nước đa năng được sản xuất theo c&ocirc;ng nghệ mới nhất, </span>kết hợp c&aacute;c t&iacute;nh năng vượt trội d&agrave;nh ri&ecirc;ng cho l&agrave;n da mỏng manh&nbsp; của phụ nữ Ch&acirc;u &Aacute;: (1)Dưỡng ẩm kiềm dầu gấp 2 lần, (2)Kem l&oacute;t trang điểm, (3)Chống nắng SPF 50+, (4)Lớp nền mỏng tho&aacute;ng mồ h&ocirc;i v&agrave; (5)Lớp phấn phủ s&aacute;ng bật t&ocirc;ng, si&ecirc;u mịn</p>\r\n<p><strong>Sử Dụng:</strong> D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều phấn theo chiều cấu tạo da v&agrave; vỗ nhẹ để phấn mịn đều hơnCần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn</p>\r\n<p><strong>Thành ph&acirc;̀n: </strong>In tr&ecirc;n bao b&igrave;</p>\r\n<p><strong>Bảo quản: </strong>Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p><strong>Khuyến c&aacute;o: </strong>Ngưng sử dụng nếu c&oacute; dấu hiệu di ứng</p>\r\n<p><strong>NSX&amp;Lot: </strong>Xem tr&ecirc;n bao bì sản ph&acirc;̉m<strong>HSD:</strong>&nbsp; 03 năm (12 th&aacute;ng sau lần đầu mở nắp hộp sử dụng)</p>\r\n</div>', 204, 1, 0, 1, 0, 'products/June2018/nAb1iN6w2jNfZo6Q6vRK.jpg', 0, 0, NULL, '2018-06-03 12:48:52'),
(9, 'GK0541', 'Tony Moly Mini Bery Lip Balm - Son Dưỡng Ẩm Môi Chống Nắng Chiết Xuất Táo Xanh', 'gk0541-2628.jpg', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"text-align: justify;\"><strong><span style=\"font-weight: normal;\"><span style=\"font-size: 110pt;\">Son dưỡng m&ocirc;i Tonymoly Mini Berry Lip Balm</span></span></strong><span style=\"font-size: 110pt;\"> chiết xuất từ tr&aacute;i c&acirc;y gi&agrave;u th&iacute;ch hợp cho m&ocirc;i nhạy cảm, kh&ocirc;, nứt nẻ Son dưỡng cung cấp ẩm cho m&ocirc;i, bổ sung dưỡng chất cho l&agrave;n m&ocirc;i căng mịn, hồng h&agrave;o Đặc biệt chỉ số chống nắng SPF 18 gi&uacute;p bảo vệ m&ocirc;i dưới &aacute;nh nắng mặt trời</span></p>\r\n<p style=\"text-align: justify;\"><em><span style=\"font-size: 110pt;\">Son c&oacute; 3 m&ugrave;i hương: #01 Cherry (tr&aacute;i anh đ&agrave;o) ,&nbsp;#02 Blueberry (tr&aacute;i ph&uacute;c bồn tử) ,&nbsp;#03 Apple (t&aacute;o xanh)</span></em></p>\r\n<p style=\"line-height: normal;\"><strong>Sử dụng: </strong>Thoa son trực tiếp l&ecirc;n m&ocirc;i trước khi thoa son m&agrave;u</p>\r\n<p><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Bảo quản:</strong> Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; hiện tượng dị ứng</p>\r\n<p><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm <strong>HSD:</strong> 03 năm (12 th&aacute;ng sau khi mở nắp)</p>\r\n<p><strong>Thể t&iacute;ch thực</strong>: 35g <strong>Xu&acirc;́t xứ:</strong> Hàn Qu&ocirc;́c</p>\r\n<p><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">Thương hiệu:&nbsp;&nbsp; Tony Moly</span></span></p>\r\n</div>', 2, 1, 1, 1, 0, 'products/June2018/hMlaLYhZ6KKfSBMmlWTZ.jpg', 0, 0, NULL, '2018-06-03 12:51:02'),
(10, 'GK0540', 'Tony Moly Mini Bery Lip Balm - Son Dưỡng Ẩm Môi Chống Nắng Chiết Xuất Blueberry Phúc Bồn Tử', 'gk0540-2838.jpg', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"text-align: justify;\"><strong><span style=\"font-weight: normal;\"><span style=\"font-size: 110pt;\">Son dưỡng m&ocirc;i Tonymoly Mini Berry Lip Balm</span></span></strong><span style=\"font-size: 110pt;\"> chiết xuất từ tr&aacute;i c&acirc;y gi&agrave;u th&iacute;ch hợp cho m&ocirc;i nhạy cảm, kh&ocirc;, nứt nẻ Son dưỡng cung cấp ẩm cho m&ocirc;i, bổ sung dưỡng chất cho l&agrave;n m&ocirc;i căng mịn, hồng h&agrave;o Đặc biệt chỉ số chống nắng SPF 18 gi&uacute;p bảo vệ m&ocirc;i dưới &aacute;nh nắng mặt trời</span></p>\r\n<p style=\"text-align: justify;\"><em><span style=\"font-size: 110pt;\">Son c&oacute; 3 m&ugrave;i hương: #01 Cherry (tr&aacute;i anh đ&agrave;o) ,&nbsp;#02 Blueberry (tr&aacute;i ph&uacute;c bồn tử) ,&nbsp;#03 Apple (t&aacute;o xanh)</span></em></p>\r\n<p style=\"line-height: normal;\"><strong>Sử dụng: </strong>Thoa son trực tiếp l&ecirc;n m&ocirc;i trước khi thoa son m&agrave;u</p>\r\n<p><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Bảo quản:</strong> Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; hiện tượng dị ứng</p>\r\n<p><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm <strong>HSD:</strong> 03 năm (12 th&aacute;ng sau khi mở nắp)</p>\r\n<p><strong>Thể t&iacute;ch thực</strong>: 35g <strong>Xu&acirc;́t xứ:</strong> Hàn Qu&ocirc;́c</p>\r\n<p>Thương hiệu:&nbsp;&nbsp; Tony Moly</p>\r\n</div>', 229, 1, 1, 1, 0, 'products/June2018/chSSdDJQplFpUOhgMdCi.jpg', 0, 0, NULL, '2018-06-03 12:52:36'),
(11, 'GK0539', 'Tony Moly Mini Bery Lip Balm - Son Dưỡng Ẩm Môi Chống Nắng Chiết Xuất Cherry Cà Chua', 'gk0539-1433.jpg', 'null', 72000, 80000, 30000, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"text-align: justify;\"><strong><span style=\"font-weight: normal;\"><span style=\"font-size: 18pxt;\">Son dưỡng m&ocirc;i Tonymoly Mini Berry Lip Balm</span></span></strong><span style=\"font-size: 18px;\"> chiết xuất từ tr&aacute;i c&acirc;y gi&agrave;u th&iacute;ch hợp cho m&ocirc;i nhạy cảm, kh&ocirc;, nứt nẻ Son dưỡng cung cấp ẩm cho m&ocirc;i, bổ sung dưỡng chất cho l&agrave;n m&ocirc;i căng mịn, hồng h&agrave;o Đặc biệt chỉ số chống nắng SPF 18 gi&uacute;p bảo vệ m&ocirc;i dưới &aacute;nh nắng mặt trời</span></p>\r\n<p style=\"text-align: justify;\"><em><span style=\"font-size: 18px;\">Son c&oacute; 3 m&ugrave;i hương: #01 Cherry (tr&aacute;i anh đ&agrave;o) ,&nbsp;#02 Blueberry (tr&aacute;i ph&uacute;c bồn tử) ,&nbsp;#03 Apple (t&aacute;o xanh)</span></em></p>\r\n<p style=\"line-height: normal;\"><strong>Sử dụng: </strong>Thoa son trực tiếp l&ecirc;n m&ocirc;i trước khi thoa son m&agrave;u</p>\r\n<p><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Bảo quản:</strong> Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; hiện tượng dị ứng</p>\r\n<p><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm <strong>HSD:</strong> 03 năm (12 th&aacute;ng sau khi mở nắp)</p>\r\n<p><strong>Thể t&iacute;ch thực</strong>: 35g <strong>Xu&acirc;́t xứ:</strong> Hàn Qu&ocirc;́c</p>\r\n<p><strong>Thương hiệu</strong>:&nbsp;&nbsp; Tony Moly</p>\r\n</div>', 229, 1, 1, 1, 1, 'products/June2018/IGQcr6ch8XTrOrdaRMCX.jpg', 16, 1, NULL, '2018-06-04 06:15:12'),
(12, 'GK0534', 'Phấn nước hoàng cung cao cấp màu thời trang - The Whoo Luxury Golden Cushion', 'gk0534the-whoo-luxury-golden-cushion-3946.jpg', 'null', 1200000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Phấn nước Luxury Golden Cushion SPF50+/PA+++ dưỡng trắng, cải thiện nếp nhăn, chống nắng với c&aacute;c th&agrave;nh phần Đ&ocirc;ng y gi&uacute;p mang đến một l&agrave;n da s&aacute;ng v&agrave; lộng lẫy nhờ c&aacute;c th&agrave;nh phần được thẩm thấu v&agrave;o da ngay khi chạm v&agrave;o L&agrave;n da ẩm mịn, căng b&oacute;ng c&ugrave;ng với hiệu quả b&aacute;m d&iacute;nh vượt trội Bước đột ph&aacute; của cushion l&agrave; t&iacute;nh mỏng, mượt tự nhi&ecirc;n nhưng vẫn che được những khuyết điểm tr&ecirc;n khu&ocirc;n mặt tạo cho n&ecirc;n một lớp nền ho&agrave;n hảo</p>\r\n<p style=\"line-height: normal; background: white;\"><strong>Sử Dụng:</strong> D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều phấn theo chiều cấu tạo da v&agrave; vỗ nhẹ để phấn mịn đều hơnCần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn</p>\r\n<p style=\"margin-bottom: 0001pt; line-height: normal;\"><strong>Thành ph&acirc;̀n: </strong>In tr&ecirc;n bao b&igrave;</p>\r\n<p style=\"margin-bottom: 0001pt;\"><strong>Bảo quản: </strong>Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; line-height: normal;\"><strong>Khuyến c&aacute;o: </strong>Ngưng sử dụng nếu c&oacute; dấu hiệu di ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>NSX&amp;Lot: </strong>Xem tr&ecirc;n bao bì sản ph&acirc;̉m</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>HSD:</strong> 03 năm (12 th&aacute;ng sau lần đầu mở nắp hộp sử dụng)</p>\r\n<p style=\"text-align: justify;\"><strong>Xuất xứ:</strong> H&agrave;n Quốc</p>\r\n<p style=\"text-align: justify;\"><strong>Thương hiệu: </strong>OHUI</p>\r\n</div>', 231, 1, 0, 1, 0, 'products/June2018/V4NKzMDJiHiQ2Pg4Xrm5.jpg', 10, 1, NULL, '2018-06-03 12:55:23'),
(13, 'GK0520', 'Son Tint Dưỡng Môi Màu Thời Trang Viên Kẹo Siêu Ngọt Ngào The Saem Saemmul Mousse Candy Tint - Đỏ Cherry', '-mousse-candy-tint-red-mango-9968.jpg', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"color: black;\">Son tint được chiết xuất từ mật ong, chứa collagen v&agrave; axit hyaluronic gi&uacute;p son giữ m&agrave;u suốt nhiều giờ m&agrave; kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i Son được thiết kế h&igrave;nh vi&ecirc;n kẹo bắt mắt, ngọt ng&agrave;o Những gam m&agrave;u thời trang hương tr&aacute;i c&acirc;y m&ugrave;a h&egrave; đem đến l&agrave;n m&ocirc;i tươi trẻ, căng mọng</span></p>\r\n<p><strong><span style=\"color: black;\">C&oacute; 4 m&agrave;u:</span></strong></p>\r\n<p><span style=\"color: black;\"># Red mango:&nbsp; Đỏ thời trang</span></p>\r\n<p><span style=\"color: black;\"># Strawberry:&nbsp; Hồng d&acirc;u</span></p>\r\n<p><span style=\"color: black;\"># Carrot Mouse: Cam c&agrave; rốt</span></p>\r\n<p><span style=\"color: black;\"># Dark Cherry: Đỏ mận anh đ&agrave;o</span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> Thoa son trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng,</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\">nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>NSX&amp;Lot:</strong> Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Xuất xứ: </strong>H&agrave;n Quốc &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>\r\n<p><strong>Thương hiệu: </strong>The Saem</p>\r\n</div>', 228, 1, 0, 0, 0, 'products/June2018/TYnjO1tM4W47rCmq6kCt.jpg', 20, 1, NULL, '2018-06-03 12:56:09'),
(14, 'GK0519', 'Son Tint Dưỡng Môi Màu Thời Trang Viên Kẹo Siêu Ngọt Ngào The Saem Saemmul Mousse Candy Tint - Cam Carot', 'the-saem-saemmul-mousse-candy-tintcarrot-mouse-2434.png', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"color: black;\">Son tint được chiết xuất từ mật ong, chứa collagen v&agrave; axit hyaluronic gi&uacute;p son giữ m&agrave;u suốt nhiều giờ m&agrave; kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i Son được thiết kế h&igrave;nh vi&ecirc;n kẹo bắt mắt, ngọt ng&agrave;o Những gam m&agrave;u thời trang hương tr&aacute;i c&acirc;y m&ugrave;a h&egrave; đem đến l&agrave;n m&ocirc;i tươi trẻ, căng mọng</span></p>\r\n<p><strong><span style=\"color: black;\">C&oacute; 4 m&agrave;u:</span></strong></p>\r\n<p><span style=\"color: black;\"># Red mango:&nbsp; Đỏ thời trang</span></p>\r\n<p><span style=\"color: black;\"># Strawberry:&nbsp; Hồng d&acirc;u</span></p>\r\n<p><span style=\"color: black;\"># Carrot Mouse: Cam c&agrave; rốt</span></p>\r\n<p><span style=\"color: black;\"># Dark Cherry: Đỏ mận anh đ&agrave;o</span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> Thoa son trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng,</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\">nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>NSX&amp;Lot:</strong> Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Xuất xứ: </strong>H&agrave;n Quốc &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>\r\n<p><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">Thương hiệu: </span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">The Saem</span></span></p>\r\n</div>', 228, 1, 1, 0, 0, 'products/June2018/0W6kpxRK2YeXVxXibKK3.png', 20, 1, NULL, '2018-06-03 12:57:01'),
(15, 'GK0518', 'Son Tint Dưỡng Môi Màu Thời Trang Viên Kẹo Siêu Ngọt Ngào The Saem Saemmul Mousse Candy Tint - Hồng Dâu', 'the-saem-saemmul-mousse-candy-tintstrawberry-3625.jpg', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"color: black;\">Son tint được chiết xuất từ mật ong, chứa collagen v&agrave; axit hyaluronic gi&uacute;p son giữ m&agrave;u suốt nhiều giờ m&agrave; kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i Son được thiết kế h&igrave;nh vi&ecirc;n kẹo bắt mắt, ngọt ng&agrave;o Những gam m&agrave;u thời trang hương tr&aacute;i c&acirc;y m&ugrave;a h&egrave; đem đến l&agrave;n m&ocirc;i tươi trẻ, căng mọng</span></p>\r\n<p><strong><span style=\"color: black;\">C&oacute; 4 m&agrave;u:</span></strong></p>\r\n<p><span style=\"color: black;\"># Red mango:&nbsp; Đỏ thời trang</span></p>\r\n<p><span style=\"color: black;\"># Strawberry:&nbsp; Hồng d&acirc;u</span></p>\r\n<p><span style=\"color: black;\"># Carrot Mouse: Cam c&agrave; rốt</span></p>\r\n<p><span style=\"color: black;\"># Dark Cherry: Đỏ mận anh đ&agrave;o</span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> Thoa son trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng,</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\">nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>NSX&amp;Lot:</strong> Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Xuất xứ: </strong>H&agrave;n Quốc &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>\r\n<p><strong>Thương hiệu: </strong>The Saem</p>\r\n</div>', 228, 1, 0, 0, 0, 'products/June2018/TuZkHwFBkBUGPtkS4Y1P.jpg', 20, 1, NULL, '2018-06-03 12:58:05'),
(16, 'GK0517', 'Son Tint Dưỡng Môi Màu Thời Trang Viên Kẹo Siêu Ngọt Ngào The Saem Saemmul Mousse Candy Tint - Đỏ', 'gk0517the-saem-saemmul-mousse-candy-tint-do-1245.png', 'null', 72000, 80000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"color: black;\">Son tint được chiết xuất từ mật ong, chứa collagen v&agrave; axit hyaluronic gi&uacute;p son giữ m&agrave;u suốt nhiều giờ m&agrave; kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i Son được thiết kế h&igrave;nh vi&ecirc;n kẹo bắt mắt, ngọt ng&agrave;o Những gam m&agrave;u thời trang hương tr&aacute;i c&acirc;y m&ugrave;a h&egrave; đem đến l&agrave;n m&ocirc;i tươi trẻ, căng mọng</span></p>\r\n<p><strong><span style=\"color: black;\">C&oacute; 4 m&agrave;u:</span></strong></p>\r\n<p><span style=\"color: black;\"># Red mango:&nbsp; Đỏ thời trang</span></p>\r\n<p><span style=\"color: black;\"># Strawberry:&nbsp; Hồng d&acirc;u</span></p>\r\n<p><span style=\"color: black;\"># Carrot Mouse: Cam c&agrave; rốt</span></p>\r\n<p><span style=\"color: black;\"># Dark Cherry: Đỏ mận anh đ&agrave;o</span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> Thoa son trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng,</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\">nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>NSX&amp;Lot:</strong> Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Xuất xứ: </strong>H&agrave;n Quốc &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>\r\n<p><strong>Thương hiệu: </strong>The Saem</p>\r\n</div>', 228, 1, 0, 0, 0, 'products/June2018/M4r1BtZRi88d7PdPsxKp.png', 20, 1, NULL, '2018-06-03 12:58:49'),
(17, 'E370', 'Chì mí kết hợp chì mày Suri Secret Pen Maker', 'e370-7816.jpg', 'null', 42750, 57000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Đầu ch&igrave; được thiết kế đặc biệt d&aacute;ng oval mảnh để tạo 2 c&ocirc;ng dụng: kẻ mi mắt với n&eacute;t mảnh sắc mịn v&agrave; tạo d&aacute;ng ch&acirc;n m&agrave;y dễ d&agrave;ng Ruột ch&igrave; si&ecirc;u mềm, n&eacute;t ch&igrave; cực thanh Ch&igrave; c&oacute; chổi chải m&agrave;y đ&iacute;nh k&egrave;m<br /> Gồm 4 m&agrave;u: #1 đen tuyền, &nbsp;#02 n&acirc;u cafe, #03 n&acirc;u s&aacute;ng, #05 n&acirc;u sẫm&nbsp;<br /> <strong>Sử dụng:</strong><br /> Kẻ m&iacute;: Kẻ s&aacute;t ch&acirc;n m&iacute; mắt, th&iacute;ch hợp phong c&aacute;ch trang điểm tự nhi&ecirc;n<br /> Kẻ m&agrave;y: D&ugrave;ng ch&igrave; kẻ từng n&eacute;t nhỏ dọc theo chiều mọc của l&ocirc;ng m&agrave;y, theo h&igrave;nh dạng mong muốn, ch&uacute; &yacute; phần đu&ocirc;i l&ocirc;ng m&agrave;y lu&ocirc;n đậm v&agrave; mảnh hơn phần đầu l&ocirc;ng m&agrave;y<br /> <strong>Bảo quản</strong>: Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Định lượng</strong> : 12 c&acirc;y / bịch&nbsp;<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao bì sản phẩm<br /> <strong>HSD</strong>: &nbsp;03 năm &nbsp;<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc&nbsp;<br /> <strong>NK&amp;PP</strong>: &nbsp;C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 224, 1, 0, 1, 0, 'products/June2018/oJCtlYUIFH75JNiPJXtC.jpg', 12, 1, NULL, '2018-06-03 12:59:31'),
(18, 'E293', 'Kem nền trang điểm BB xoá nhăn Mik@vonk Anti Aging & Wrinkle Care', 'e293bb-xoa-nhan-mikvonk-30ml-7754.png', 'null', 150000, 200000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Hoạt chất Adenosine trong kem trang điểm BB dưỡng da xo&aacute; nhăn gi&uacute;p cải thiện, t&aacute;i tạo l&agrave;n da v&agrave; chống l&atilde;o ho&aacute; hiệu quả Lớp kem nền chống đổ dầu gi&uacute;p che c&aacute;c đốm th&acirc;m, vết đỏ v&agrave; giảm thiểu tối đa c&aacute;c khiếm khuyết tr&ecirc;n bề mặt da<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng m&uacute;t hoặc cọ lấy một lượng kem vừa đủ chấm đều l&ecirc;n mặt, sau đ&oacute; t&aacute;n đều tay cho đến khi lớp kem che phủ to&agrave;n bộ gương mặt Phủ th&ecirc;m một phấn mỏng nếu cần<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng sản phẩm khi c&oacute; dấu hiệu dị ứng<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Thể t&iacute;ch thực</strong>: 30ml<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm HSD: 03 năm (12 th&aacute;ng sau khi mở nắp)<br /> <strong>SX,ĐG&amp;PP</strong>: CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 210, 1, 1, 0, 0, 'products/June2018/xq17JavZ901BUOefWxRV.png', 8, 1, NULL, '2018-06-03 13:00:07'),
(19, 'E253', 'Phấn mắt thời trang Mik@vonk Eyeshadow', 'e253phan-mat-mikvonk-3808.png', 'null', 54000, 72000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Phấn mắt thời trang Mik@vonk Eyeshadow với hạt phấn si&ecirc;u nhẹ, mịn, độ b&aacute;m cao, an to&agrave;n cho da</p>\r\n</div>', 210, 1, 0, 1, 0, 'products/June2018/ePhy6Hfv48998hbvAuGW.png', 5, 1, NULL, '2018-06-03 13:00:45'),
(20, 'E111', 'Chì kẻ mí Mik@vonk Professional Eyeliner Pencil', 'e111chi-mi-goi-mikvonk-316.png', 'null', 34500, 46000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Ch&igrave; kẻ m&iacute; mắt Mik@vonk Professional Eyeliner pencil cho bạn đ&ocirc;i mắt thật nổi bật v&agrave; quyến rũ<br /> - Ch&igrave; kẻ m&iacute; mịn, n&eacute;t m&atilde;nh, dễ sử dụng<br /> <strong>Sử dụng</strong>: D&ugrave;ng ch&igrave; vẽ đều l&ecirc;n v&ugrave;ng m&iacute; mắt cần trang điểm<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n</div>', 210, 1, 1, 0, 0, 'products/June2018/vmNx3zMD0YKOXAeW6USx.png', 12, 1, NULL, '2018-06-03 13:01:29'),
(21, 'GK0529', 'Son Môi Hoàng Cung Cao Cấp Màu Thời Trang #42 (Đỏ cổ điển) - The Whoo Luxury Lipstick #42', 'luxury-lipstick42-812.png', 'null', 720000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Son m&ocirc;i cao cấp được chiết xuất từ thi&ecirc;n nhi&ecirc;n dưỡng m&ocirc;i mềm mượt, giữ m&agrave;u suốt nhiều giờ Son cải thiện nếp nhăn tr&ecirc;n m&ocirc;i, sắc son cổ điển, thời trang, phong c&aacute;ch</p>\r\n<p><em>C&oacute; 3 m&agrave;u son:</em></p>\r\n<p>#15: Hồng đất</p>\r\n<p>#25: Hồng c&oacute; nhũ</p>\r\n<p>#42: Đỏ cổ điển</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Xuất xứ:</strong> H&agrave;n Quốc<strong> &nbsp; </strong></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Thương hiệu:</strong> The Whoo</p>\r\n</div>', 231, 1, 0, 1, 0, 'products/June2018/ZSgUCeIkFvIRVWcDJadJ.png', 10, 1, NULL, '2018-06-03 13:02:51'),
(22, 'GK0528', 'Son Môi Hoàng Cung Cao Cấp Màu Thời Trang #25 (Hồng có nhũ) - The Whoo Luxury Lipstick #25', 'luxury-lipstick-special-set25thannap-6861.png', 'null', 720000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Son m&ocirc;i cao cấp được chiết xuất từ thi&ecirc;n nhi&ecirc;n dưỡng m&ocirc;i mềm mượt, giữ m&agrave;u suốt nhiều giờ Son cải thiện nếp nhăn tr&ecirc;n m&ocirc;i, sắc son cổ điển, thời trang, phong c&aacute;ch</p>\r\n<p><em>C&oacute; 3 m&agrave;u son:</em></p>\r\n<p>#15: Hồng đất</p>\r\n<p>#25: Hồng c&oacute; nhũ</p>\r\n<p>#42: Đỏ cổ điển</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Xuất xứ:</strong> H&agrave;n Quốc<strong> &nbsp; </strong></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Thương hiệu:</strong> The Whoo</p>\r\n</div>', 231, 1, 1, 1, 0, 'products/June2018/9NXxMzY9V3Diek5fXCuH.png', 10, 1, NULL, '2018-06-03 13:04:34'),
(23, 'GK0527', 'Son Môi Hoàng Cung Cao Cấp Màu Thời Trang #15 (Hồng đất) - The Whoo Luxury Lipstick #15', 'luxury-lipstick-special-set15thannap-3543.png', 'null', 720000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Son m&ocirc;i cao cấp được chiết xuất từ thi&ecirc;n nhi&ecirc;n dưỡng m&ocirc;i mềm mượt, giữ m&agrave;u suốt nhiều giờ Son cải thiện nếp nhăn tr&ecirc;n m&ocirc;i, sắc son cổ điển, thời trang, phong c&aacute;ch</p>\r\n<p><em>C&oacute; 3 m&agrave;u son:</em></p>\r\n<p><strong>#15:</strong> Hồng đất</p>\r\n<p><strong>#25: </strong>Hồng c&oacute; nhũ</p>\r\n<p><strong>#42: </strong>Đỏ cổ điển</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Sử dụng:</strong> D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify; line-height: normal;\"><strong>Bảo quản:</strong> Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Xuất xứ:</strong> H&agrave;n Quốc<strong> &nbsp; </strong></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Thương hiệu:</strong> The Whoo</p>\r\n</div>', 231, 1, 1, 0, 0, 'products/June2018/6Hohf1cn6Hga4YGMYEIJ.png', 10, 1, NULL, '2018-06-03 13:05:14'),
(24, 'E108', 'Chì kẻ môi Mik@vonk Professional Lipliner Pencil', 'e108chi-moi-goi-mikvonk-3088.png', 'null', 34500, 46000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Ch&igrave; kẻ m&ocirc;i Mik@vonk với m&agrave;u sắc thời trang kết hợp với chất liệu cao cấp tạo n&ecirc;n sản phẩm ch&igrave; viền m&ocirc;i Mik@von với độ mềm vừa phải, độ mịn tuyệt đối để khi sử dụng bạn sẽ dễ d&agrave;ng c&oacute; được đường viền m&ocirc;i như &yacute; v&agrave; chuẩn x&aacute;c nhất<br /> <strong>Sử dụng</strong>: kẻ đường viền quanh m&ocirc;i trước khi thoa son tạo m&agrave;u trong long m&ocirc;i<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>HSD</strong>: 3 năm</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/fDgXwwYuqGtgbd87uMSl.png', 12, 1, NULL, '2018-06-03 13:06:16'),
(25, 'D059', 'Phấn má hồng MiraCulous Flowery Blusher', 'd0593d2-1979.jpg', 'null', 204000, 272000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn m&aacute; hồng MiraCulous Flowery Blusher với c&ocirc;ng dụng s&aacute;ng da đa sắc l&acirc;u tr&ocirc;i được chiết xuất từ thi&ecirc;n nhi&ecirc;n tạo độ s&aacute;ng tự nhi&ecirc;n, tinh tế<br /> - Hạt phấn mịn, nhẹ nh&agrave;ng phủ tr&ecirc;n v&ugrave;ng xương g&ograve; m&aacute; cho gương mặt ửng hồng, rạng rỡ<br /> - Sản phẩm m&aacute; hồng cao cấp từ H&agrave;n Quốc MiraCulous</p>\r\n</div>', 212, 1, 0, 1, 0, 'products/June2018/wxTSX1StqmNsmrzd8sfb.jpg', 5, 1, NULL, '2018-06-03 13:06:53'),
(31, 'B506', 'Bút sáp kẻ mắt nhiều màu nhũ bạc Mira Eyeshadow', 'b506butkesapmatnhieumaunhubacex-4100.jpg', 'null', 69750, 93000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>-B&uacute;t vẽ mắt s&aacute;p Mira Eyeshadow được cấu tạo từ những hạt m&agrave;u si&ecirc;u nhỏ cho m&agrave;u mắt si&ecirc;u mịn, lấp l&aacute;nh<br /> - Nhiều m&agrave;u sắc thời trang v&agrave; s&agrave;nh điệu<br /> <strong>Sử dụng</strong>: Vặn nhẹ cho phần s&aacute;p nh&ocirc; l&ecirc;n, thoa trực tiếp l&ecirc;n m&iacute; mắt hoặc bầu mắt<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng ngay khi thấy hiện tượng da bị k&iacute;ch ứng<br /> <strong>HSD</strong>: 3 năm</p>\r\n</div>', 225, 1, 0, 0, 0, 'products/June2018/vlkdKcc9FYWpnb1DGA33.jpg', 9, 1, NULL, '2018-06-03 13:11:30'),
(32, 'B493', 'Chì kẻ viền môi Mira Auto Lipliner', 'b493205-7064.jpg', 'null', 48000, 64000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Ch&igrave; kẻ viền m&ocirc;i Mira Auto Lipliner với m&agrave;u sắc thời trang kết hợp với chất liệu cao cấp tạo n&ecirc;n sản phẩm ch&igrave; viền m&ocirc;i MIRA với độ mềm vừa phải, độ mịn tuyệt đối để khi sử dụng bạn sẽ dễ d&agrave;ng c&oacute; được đường viền m&ocirc;i như &yacute; v&agrave; chuẩn x&aacute;c nhất</p>\r\n</div>', 225, 1, 0, 0, 0, 'products/June2018/Xv9GYNSrChSa9Qe5SobK.jpg', 10, 1, NULL, '2018-06-03 13:12:11'),
(33, 'B486', 'Chì mí kim tuyến Mira Glitter Auto Eyeliner Pen', 'b486chimikimtuyenmira-2323.jpg', 'null', 40500, 54000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Ch&igrave; m&iacute; kim tuyến Mira Glitter Auto Eyeliner Pen tạo đường kẻ mịn, sắc n&eacute;t với nhiều m&agrave;u sắc tươi tắn hợp thời trang<br /> - Đặc biệt độ &aacute;nh kim tuyến c&oacute; trong ch&igrave;, l&agrave;m cho &aacute;nh nh&igrave;n của bạn trở n&ecirc;n thu h&uacute;t v&agrave; ấn tượng<br /> <strong>Sử dụng</strong>: Vặn cho đầu ch&igrave; nh&ocirc; l&ecirc;n, vẽ đều l&ecirc;n v&ugrave;ng ch&acirc;n m&agrave;y cần trang điểm<br /> <strong>Khuyến c&aacute;o</strong>: ngưng sử dụng ngay khi da bị k&iacute;ch ứng<br /> <strong>HSD</strong>: 3 năm</p>\r\n</div>', 225, 1, 0, 0, 0, 'products/June2018/Xk9hV0iNlyMqgKsypRTb.jpg', 10, 1, NULL, '2018-06-03 13:12:48'),
(34, 'E255', 'Phấn nén chống nắng đa chức năng Mira Blue Saturday Duo Baking Pact', 'e255phan-nen-chong-nang-da-chuc-nang-mira-4342.png', 'null', 236250, 315000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Phấn n&eacute;n chống nắng đa chức năng MIRA Blue saturday duo baking pact cấu tạo từ c&aacute;c hạt phấn si&ecirc;u mịn chứa vitamin A v&agrave; C tạo lớp nền mỏng mịn, kiềm dầu, đặc biệt bảo vệ da dưới &aacute;nh nắng mặt trời &nbsp;Sản phẩm được thiết kế 2 ngăn th&ocirc;ng minh kết hợp bởi:<br /> Phấn trang điểm che phủ mịn m&agrave;ng tạo l&agrave;n da tự nhi&ecirc;n cho to&agrave;n gương mặt<br /> Phấn tạo khối, tạo điểm nhấn v&ugrave;ng chữ T C&oacute; thể sử dụng để trang điểm phần mắt<br /> Thiết kế nhỏ gọn k&egrave;m b&ocirc;ng phấn tiện dụng<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng phấn thoa nhẹ nh&agrave;ng tr&ecirc;n to&agrave;n khu&ocirc;n mặt, sau đ&oacute; thoa phấn tạo khối v&agrave;o v&ugrave;ng chữ T, tr&aacute;nh miết b&ocirc;ng phấn để tạo độ mịn v&agrave; b&aacute;m phấn hơn<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; hiện tượng dị ứng<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp)<br /> <strong>Khối lượng tịnh</strong>: 12g<br /> <strong>Xu&acirc;́t xứ</strong>: Hàn Qu&ocirc;́c<br /> <strong>NK&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 225, 1, 0, 0, 0, 'products/June2018/65AUpk2nine8ZzhXWe6I.png', 0, 1, NULL, '2018-06-03 13:13:25'),
(35, 'E315', 'Phấn trang điểm tạo khối Mik@vonk Mineral Shading Compact', 'e315phan-trang-diem-tao-khoi-mikvonk2-4886.png', 'null', 80250, 107000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Bộ phấn 2 ngăn gồm m&agrave;u s&aacute;ng v&agrave; tối d&ugrave;ng để tạo điểm nhấn, đồng thời khắc phục những khiếm khuyết tr&ecirc;n gương mặt Hạt phấn mịn, độ b&aacute;m tốt v&agrave; chống đổ dầu&nbsp;<br /> <strong>Hướng dẫn sử dụng</strong>: Những người c&oacute; sống mũi thấp v&agrave; mắt th&acirc;m quầng, d&ugrave;ng phấn m&agrave;u s&aacute;ng che phủ v&ugrave;ng dưới mắt v&agrave; dọc sống mũi, tạo điểm nhấn cho gương mặt trở n&ecirc;n thanh tho&aacute;t, h&agrave;i h&ograve;a D&ugrave;ng phấn m&agrave;u tối đ&aacute;nh dọc 2 b&ecirc;n xương h&agrave;m để tạo gương mặt thon gọn<br /> <strong>Th&agrave;nh ph&acirc;̀n</strong>: Talc, Mica, Methymethacrylate crosspolymer, bismuth Oxychloride, Dimethicone, Etylhexylmethoxycicinnamate, Diisostearyl Malate, Fragance, Titanium Dioxide, Iron Oxide Red, Iron Oxide Black, Iron Oxide Yellow<br /> <strong>Bảo quản</strong>: Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng sản phẩm khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Hạn sử dụng</strong> : 03 năm ( 24 th&aacute;ng sau khi mở nắp )<br /> <strong>Khối lượng tịnh</strong>: 12g&nbsp;<br /> <strong>SX,ĐG&amp;PP</strong>: CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/EOxPuGy0UjXSoObAR7nn.png', 10, 1, NULL, '2018-06-03 13:15:08'),
(36, 'E297', 'Phấn má hồng siêu mịn sắc hoa tươi Suri', 'e297ma-hong-sac-hoa-tuoi-suri1-2745.png', 'null', 171750, 229000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Những hạt phấn mịn, si&ecirc;u nhẹ với sắc m&agrave;u tươi trẻ, trung thực được lấy cảm hứng từ hoa hồng v&agrave; anh đ&agrave;o<br /> <strong>C&oacute; 3 sự lựa chọn ph&ugrave; hợp từng độ tuổi:</strong><br /> <strong>#01</strong>: Sắc hồng trẻ trung d&agrave;nh cho tuổi teen<br /> <strong>#02</strong>: Sắc cam đất &amp; hồng đ&agrave;o đem đến vẻ quyến rũ d&agrave;nh cho tuổi trung ni&ecirc;n<br /> <strong>#03</strong>: Sắc cam d&acirc;u &amp; hồng thời thượng d&agrave;nh cho qu&yacute; c&ocirc; c&ocirc;ng sở<br /> Sự h&agrave;i h&ograve;a giữa m&agrave;u cam &amp; m&agrave;u hồng dễ d&agrave;ng tạo điểm nhấn cho đ&ocirc;i g&ograve; m&aacute;Phấn ngăn h&uacute;t mồ h&ocirc;i, ph&ugrave; hợp mọi loại da<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ đ&iacute;nh t&aacute;n một lượng phấn vừa đủ thoa nhẹ l&ecirc;n m&aacute;<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy c&oacute; hiện tượng dị ứng da<br /> <strong>NSX&amp;Lot</strong>: Xem bao b&igrave; sản phẩm HSD: 03 năm (24 th&aacute;ng sau khi mở nắp) Thể t&iacute;ch thực: 8g<br /> <strong>ĐG&amp;PP</strong>: CN C&ocirc;ng ty TNHH Mỹ Phẩm Mira</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/KJv4ZHqPgeLaumoNlycl.png', 5, 1, NULL, '2018-06-03 13:15:58'),
(37, 'E281', 'Son môi bền màu siêu dưỡng ẩm lâu phai Mik@vonk Silky Shot Lipstick', 'e281son-moi-ben-mau-sieu-duong-lau-phai-mikvonk-4221.png', 'null', 182250, 243000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Chất son cao cấp, m&agrave;u chuẩn bền l&acirc;u, kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i, cung cấp dưỡng ẩm cho bờ m&ocirc;i căng mọng Đặc biệt c&oacute; thể che khuyết điểm của m&ocirc;i như nếp nhăn, m&ocirc;i th&acirc;m<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 42g &nbsp;&nbsp;<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/ilWMfFmxHaUlc5hSO5Sy.png', 10, 1, NULL, '2018-06-03 13:16:37'),
(38, 'E336', 'Son lì chuẩn màu lâu phai Suri', 'e336son-li-chuan-mau-lau-phai-suri-velvet-4404.png', 'null', 257250, 343000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Chất son mềm mượt, giữ m&agrave;u cực chuẩn khi thoa l&ecirc;n m&ocirc;i, kh&ocirc;ng phai suốt nhiều giờ Điểm cộng của d&ograve;ng son Velvet Suri l&agrave; vinamin E dưỡng ẩm chứa trong son, cho l&agrave;n m&ocirc;i căng mọng nhưng son vẫn giữ độ l&igrave; tuyệt đối<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm &nbsp;(sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 37g<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;<br /> <strong>NK&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/L0fwosD0xo02iM2s8Jqd.png', 10, 1, NULL, '2018-06-03 13:17:31'),
(39, 'E294', 'Phấn phủ Mik@vonk Blooming Face Powder (30g)', 'e294phan-phu-mikvonk-4511.png', 'null', 182250, 243000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn phủ Mik@vonk Blooming Face Powder được sản xuất với từ th&agrave;nh phần tự nhi&ecirc;n theo c&ocirc;ng nghệ ti&ecirc;n tiến nhất của H&agrave;n Quốc bảo vệ da một c&aacute;ch tự nhi&ecirc;n, được chiết xuất từ thực vật gi&uacute;p cho da l&aacute;ng mịn, nhẹ nh&agrave;ng, mềm mại v&agrave; kh&ocirc;ng bị dầu<br /> - Phấn phủ Mik@vonk &nbsp;blooming face powder cho bạn một khu&ocirc;n mặt trang điểm ho&agrave;n hảo<br /> <strong>Sử dụng</strong>: Lấy một lượng vừa đủ d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều l&ecirc;n v&ugrave;ng mặt cần trang điểm<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng ngay khi thấy dấu hiệu k&iacute;ch ứng da<br /> <strong>Xuất xứ</strong>: H&agrave;n quốc<br /> <strong>HSD</strong>: 3 năm<br /> <strong>Trọng lượng</strong>: 30g</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/ropAqPrTXNLJTkuJfGK0.png', 10, 1, NULL, '2018-06-03 13:18:07'),
(40, 'E363', 'Phấn nước sáng da bật tông thần thánh Muse Vera Pink Me Tone Up Cushion', 'e363phan-nuoc-sang-da-bat-tong-than-thanh-2in1-8579.png', 'null', 407250, 543000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Khả năng che phủ tuyệt đỉnh, x&oacute;a mờ đốm th&acirc;m, vết mụn, da mịn như nhung, s&aacute;ng bật t&ocirc;ng chỉ sau v&agrave;i ph&uacute;t thoa phấn nước Da mướt, căng mọng, trong veo nhưng kh&ocirc;ng đổ dầu Lớp phấn bền m&agrave;u suốt cả ng&agrave;y Chỉ số chống nắng SPF 50+ bảo vệ da an to&agrave;n dưới &aacute;nh nắng mặt trời<br /> Miếng b&ocirc;ng phấn chuy&ecirc;n dụng đ&iacute;nh k&egrave;m gi&uacute;p ph&aacute;t huy tối đa t&aacute;c dụng của phấn nước 2 trong 1<br /> Th&agrave;nh phần: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> Bảo quản: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp Nếu kem d&iacute;nh v&agrave;o mắt, rửa lại bằng nước sạch<br /> Khuyến c&aacute;o: Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/oEW7t9xCE4rKOlpzUky5.png', 5, 1, NULL, '2018-06-03 13:18:49'),
(41, 'E150', 'Phấn má hồng 4 ô Mik@vonk Multi Powder', 'e150ma-hong-4o-mikvonk-5406.png', 'null', 117750, 157000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn m&aacute; hồng Mik@vonk Multi Powder được thiết kế với cấu tr&uacute;c pha trộn nhiều m&agrave;u sắc kh&aacute;c nhau, hạt phấn mịn, độ b&aacute;m cao, giữ cho m&aacute; lu&ocirc;n hồng h&agrave;o<br /> - Gi&uacute;p bạn c&oacute; khu&ocirc;n mặt lu&ocirc;n rạng rỡ, mịn m&agrave;ng v&agrave; trắng s&aacute;ng</p>\r\n</div>', 210, 1, 0, 0, 0, 'products/June2018/WmReNGKxXM5A3Zp0Bu6H.png', 10, 1, NULL, '2018-06-03 13:19:21');
INSERT INTO `products` (`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`, `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) VALUES
(42, 'E271', 'Chì mày xé Suri Eyebrow Pencil', 'e271chi-xe101black-3799.png', 'null', 19500, 26000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><strong>C&ocirc;ng dụng</strong>: Ch&igrave; mềm mại, m&agrave;u tự nhi&ecirc;n gi&uacute;p dễ d&agrave;ng định h&igrave;nh d&aacute;ng ch&acirc;n m&agrave;y Thiết kế đặc biệt, kh&ocirc;ng cần chuốt ch&igrave;<br /> Sử dụng: D&ugrave;ng ch&igrave; kẻ d&aacute;ng ch&acirc;n m&agrave;y theo &yacute; muốn Sau khi d&ugrave;ng hết phần ch&igrave;, k&eacute;o nhẹ sợi chỉ dọc th&acirc;n ch&igrave;, d&ugrave;ng tay t&aacute;ch lớp giấy bảo vệ quanh ch&igrave; Đậy nắp sau khi sử dụng<br /> --------------------------------------------------------------------<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp)</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/dFDAtT9JxugaV1OfATvo.png', 12, 1, NULL, '2018-06-03 13:19:57'),
(43, 'D263', 'Son kem không trôi BRILLANTE', 'd263son-kem-khong-troi-brillante1-4651.png', 'null', 129000, 172000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Chất son kem lỏng l&agrave; sự kết hợp mới lạ giữa son l&igrave; si&ecirc;u mịn c&ugrave;ng ch&uacute;t mượt m&agrave; của son dưỡng Son kh&ocirc;ng tr&ocirc;i suốt nhiều giờ Được chiết xuất từ tinh dầu tr&aacute;i bơ v&agrave; tr&aacute;i đ&agrave;o an to&agrave;n cho l&agrave;n m&ocirc;i mỏng manh<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i, để lớp son thấm dần v&agrave;o m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm &nbsp;(sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 35g &nbsp; &nbsp;Xuất xứ: H&agrave;n Quốc &nbsp; &nbsp; &nbsp;<br /> <strong>NK&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 210, 1, 0, 1, 0, 'products/June2018/Wv06xDltdkaM4JWdFHht.png', 0, 1, NULL, '2018-06-03 13:21:03'),
(44, 'D253', 'Phấn má hồng ướt lâu trôi MiraCulous', 'd253ma-hong-uot-miraculous1-peach-8681.png', 'null', 129000, 172000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Si&ecirc;u phẩm phấn m&aacute; hồng ướt của H&agrave;n Quốc đem đến l&agrave;n da ửng hồng, mềm mịn, ửng m&agrave;u rất tự nhi&ecirc;n<br /> Phấn dạng nước phủ đều tr&ecirc;n da, l&acirc;u tr&ocirc;i, si&ecirc;u kiềm dầu<br /> C&oacute; 2 m&agrave;u hồng v&agrave; cam<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n theo h&igrave;nh xoắn ốc ch&eacute;o l&ecirc;n th&aacute;i dương Cần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng sản phẩm khi c&oacute; dấu hiệu dị ứng<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Thể t&iacute;ch thực</strong>: 12g<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (12 th&aacute;ng sau khi mở nắp)</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/WaHHljvPMxcYy7ar2fjn.png', 5, 1, NULL, '2018-06-03 13:21:52'),
(45, 'D233', 'Phấn má hồng khoáng chất Suri Mineral Blusher (10g)', 'phanmahongsurid2-6584.png', 'null', 155250, 207000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Những hạt phấn mịn h&ograve;a trộn tinh tế giữa sắc cam &amp; hồng gi&uacute;p bạn g&aacute;i dễ d&agrave;ng tạo điểm nhấn cho đ&ocirc;i g&ograve; m&aacute;<br /> T&ocirc;ng m&agrave;u tươi s&aacute;ng, h&agrave;i h&ograve;a, l&acirc;u tr&ocirc;i, ph&ugrave; hợp mọi loại da<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ hoặc b&ocirc;ng phấn t&aacute;n một lượng phấn vừa đủ thoa nhẹ l&ecirc;n m&aacute;<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy c&oacute; hiện tượng dị ứng da&nbsp;<br /> <strong>NSX&amp;Lot</strong>: Xem bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp) &nbsp;<br /> <strong>Thể t&iacute;ch thực</strong>: 10g<br /> <strong>Xu&acirc;́t xứ</strong>: Hàn Qu&ocirc;́c</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/Vc3Y1WIZYibnuFaZH2iX.PNG', 5, 1, NULL, '2018-06-03 13:25:52'),
(46, 'D249', 'Son lót dưỡng ẩm bảo vệ môi chiết xuất trái bơ mỡ Suri Blossom Lip', 'd249-5623.jpg', 'null', 32250, 43000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Tinh dầu tr&aacute;i bơ mỡ cung cấp dưỡng ẩm cực cao, tạo sắc m&ocirc;i tươi tắn, tự nhi&ecirc;n<br /> Son l&oacute;t dưỡng ẩm tạo m&agrave;u Suri kh&ocirc;ng chỉ gi&uacute;p ngăn ngừa những h&oacute;a chất c&oacute; thể g&acirc;y hại cho m&ocirc;i từ son m&agrave;u m&agrave; c&ograve;n duy tr&igrave; m&ocirc;i ẩm mượt v&agrave; chống nắng an to&agrave;n với SPF 18 C&oacute; thể phối hợp &nbsp;c&ugrave;ng son l&igrave; để l&agrave;n m&ocirc;i th&ecirc;m quyến rũ<br /> <strong>C&oacute; 3 m&agrave;u</strong>: đỏ dưa hấu, hồng tươi v&agrave; &aacute;nh cam<br /> <strong>Sử dụng</strong>: Thoa son trực tiếp l&ecirc;n m&ocirc;i trước khi thoa son m&agrave;u<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; hiện tượng dị ứng<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm HSD: 03 năm (12 th&aacute;ng sau khi mở nắp)<br /> <strong>Thể t&iacute;ch thực</strong>: 18g &nbsp;ĐG&amp;PP: CN c&ocirc;ng ty TNHH Mỹ Phẩm Mira</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/VQWurjSvfdtah7kDkBPc.jpg', 20, 1, NULL, '2018-06-03 13:26:37'),
(47, 'D227', 'Phấn má hồng hút dầu siêu mịn MiraCulous Bright Flash Multi Blusher', 'phanmahonghutdaumiraculousd227-8000.jpg', 'null', 204000, 272000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Phấn m&aacute; hồng h&uacute;t dầu si&ecirc;u mịn, bền m&agrave;u nhiều t&ocirc;ng m&agrave;u thời trang từ sắc hồng đến m&agrave;u cam trong c&ugrave;ng 1 hộp phấn đem đến vẻ tươi trẻ rạng rỡ cho to&agrave;n gương mặt<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ đ&iacute;nh k&egrave;m t&aacute;n đều l&ecirc;n b&acirc;̀u m&aacute; theo phong c&aacute;ch trang điểm<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Nơi tho&aacute;ng, kh&ocirc;Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (sử dụng tốt nhất 24 th&aacute;ng kể từ khi mở nắp) <br /> Nh&atilde;n hiệu: MiraCulous</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/y9bMB3MsesSm1teZrqlc.jpg', 5, 1, NULL, '2018-06-03 13:28:48'),
(48, 'D256', 'Chì mí kết hợp chì mày siêu tiết kiệm MiraCulous Secret Pen Maker', 'd256chi-mi-ket-hop-chi-may-sieu-tiet-kiem-miracuclous-7864.png', 'null', 49000, 57000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Đầu ch&igrave; được thiết kế đặc biệt d&aacute;ng oval mảnh để tạo 2 c&ocirc;ng dụng: kẻ mi mắt với n&eacute;t mảnh sắc mịn v&agrave; tạo d&aacute;ng ch&acirc;n m&agrave;y dễ d&agrave;ng Ruột ch&igrave; si&ecirc;u mềm, n&eacute;t ch&igrave; cực thanh Ch&igrave; c&oacute; chổi chải m&agrave;y đ&iacute;nh k&egrave;m<br /> Gồm 4 m&agrave;u: #01 đen tuyền, #02 n&acirc;u cafe, #03 n&acirc;u s&aacute;ng, #05 n&acirc;u sẫm&nbsp;<br /> <strong>Sử dụng:</strong><br /> Kẻ m&iacute;: Kẻ s&aacute;t ch&acirc;n m&iacute; mắt, th&iacute;ch hợp phong c&aacute;ch trang điểm tự nhi&ecirc;n<br /> Kẻ m&agrave;y: D&ugrave;ng ch&igrave; kẻ từng n&eacute;t nhỏ dọc theo chiều mọc của l&ocirc;ng m&agrave;y, theo h&igrave;nh dạng mong muốn, ch&uacute; &yacute; phần đu&ocirc;i l&ocirc;ng m&agrave;y lu&ocirc;n đậm v&agrave; mảnh hơn phần đầu l&ocirc;ng m&agrave;y<br /> <strong>Bảo quản:</strong> Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Định lượng</strong> : 12 c&acirc;y / bịch&nbsp;<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao bì sản phẩm<br /> <strong>HSD</strong>: &nbsp;03 năm &nbsp;<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc&nbsp;<br /> <strong>NK&amp;PP</strong>: &nbsp;C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/U0s4cIqfQWoTz2C3MKIA.png', 12, 1, NULL, '2018-06-03 13:27:07'),
(49, 'D268', 'Phấn trang điểm khoáng chất vitamin E , kiểm soát dầu bảo vệ da , chống nắng MiraCulous', 'd268phan-vitamin-e-kiem-soat-dau-5634.png', 'null', 257250, 343000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Hạt phấn si&ecirc;u mịn chứa kho&aacute;ng chất, vitamin E c&ugrave;ng độ b&aacute;m cao cho lớp nền mỏng mịn, kiềm dầu, kh&ocirc;ng tr&ocirc;i suốt nhiều giờ C&ocirc;ng thức ti&ecirc;n tiến ph&ugrave; hợp cho da thường đến da hỗn hợp, chỉ số SPF 35 PA+++ bảo vệ da an to&agrave;n dưới &aacute;nh nắng mặt trời v&agrave; tia UVA-UVB Hiệu chỉnh sắc da &nbsp;chỉ sau 1 lần phủ phấn<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng phấn đ&iacute;nh k&egrave;m lấy một lượng vừa đủ thoa đều l&ecirc;n mặt v&agrave; cổ<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm Nguy&ecirc;n liệu nhập từ H&agrave;n Quốc<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp )<br /> Sản phẩm của c&ocirc;ng ty TNHH Mỹ Phẩm MIRA<br /> <strong>SX&amp;PP</strong>: CN c&ocirc;ng ty TNHH Mỹ Phẩm MIRA<br /> Sản xuất theo c&ocirc;ng nghệ H&agrave;n Quốc</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/XdH1Loe1gXDlClYuJbAX.png', 5, 1, NULL, '2018-06-03 13:27:59'),
(50, 'D226', 'Phấn mắt 3 ô siêu mịn MiraCulous Bright Flash Eyeshadow', 'd226mau-mat-3-mau-sieu-min-hoa-cuc-miraculous-9543.png', 'null', 171750, 229000, 100005, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Phấn mắt dạng n&eacute;n, hạt phấn si&ecirc;u mịn, bền m&agrave;u, kết hợp 3 t&ocirc;ng m&agrave;u thời trang kh&aacute;c nhau trong c&ugrave;ng 1 hộp phấn gi&uacute;p bạn dễ d&agrave;ng phối m&agrave;u khi trang điểm mắt<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ đ&iacute;nh k&egrave;m t&aacute;n đều phấn l&ecirc;n tr&ecirc;n mi mắt v&agrave; bầu mắt<br /> ----------------------------------------------------------------------------------<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Nơi tho&aacute;ng, kh&ocirc;Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (sử dụng tốt nhất 24 th&aacute;ng kể từ khi mở nắp)</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/gl52TQEeV6r3DzdEikik.png', 3, 1, NULL, '2018-06-03 13:37:27'),
(51, 'D515', 'Son kem lâu trôi MiraCulous Cashmere Matte Lip Cream', 'd270sonkemlautroimiraculous-440.jpg', 'null', 129000, 172000, 20000, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>SON KEM L&Igrave; SI&Ecirc;U MỊN KH&Ocirc;NG TR&Ocirc;I MIRACULOUS&nbsp;</strong><br /> &nbsp;- Chất son kem lỏng l&agrave; sự kết hợp mới lạ giữa son l&igrave; si&ecirc;u mịn c&ugrave;ng ch&uacute;t mượt m&agrave; của son dưỡng<br /> &nbsp;- Son kh&ocirc;ng tr&ocirc;i suốt nhiều giờ<br /> &nbsp;- Được chiết xuất từ tinh dầu tr&aacute;i bơ v&agrave; tr&aacute;i đ&agrave;o an to&agrave;n cho l&agrave;n m&ocirc;i mỏng manh<br /> &nbsp;- Kh&ocirc;ng chứa parapen<br /> &nbsp;- 5 tone m&agrave;u thời trang<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i, để lớp son thấm dần v&agrave;o m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Hạn sử dụng</strong> : 03 năm &nbsp;(sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) &nbsp;<br /> Khối lượng tịnh: 4g<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc &nbsp; &nbsp; &nbsp; &nbsp;<br /> Nhập khẩu v&agrave; ph&acirc;n phối : C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/sTdyXrMT8XZULEfWucVq.jpg', 8, 1, NULL, '2018-06-03 13:40:15'),
(52, 'S212', 'Son nhung lì dưỡng môi Mira Primary Impression Matte Lipstick', 'd305son-nhung-li-duong-moi-chiet-xuat-trai-bo5-1146.png', 'null', 192750, 257000, 43211, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Chất son l&igrave;, mướt mịn trượt tr&ecirc;n m&ocirc;i như lớp nhung c&ugrave;ng dưỡng chất nu&ocirc;i dưỡng gi&uacute;p m&ocirc;i kh&ocirc;ng bị kh&ocirc;, lu&ocirc;n mềm mịn v&agrave; rực rỡ<br /> M&agrave;u l&ecirc;n cưc chuẩn, c&oacute; 4 m&agrave;u đ&aacute;p ứng mọi phong c&aacute;ch<br /> Trang điểm: #01: Nude thời thượng, #02: Hồng berry, #03: Đỏ cam#, 05: Đỏ nhung<br /> HDSD: Thoa son trực tiếp l&ecirc;n m&ocirc;i hoặc dung cọ<br /> Th&agrave;nh phần, NSX&amp;Lot: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> Bảo quản: Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> Khuyến c&aacute;o: Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng<br /> HSD: 03 năm ( 12 th&aacute;ng sau khi mở nắp )<br /> Khối lượng tịnh: 4g Xuất xứ: H&agrave;n Quốc Số CB: 34316/17/CBMP-QLD<br /> NK&amp;PP: c&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 179, 1, 0, 1, 0, 'products/June2018/BAtILgBlH323HuJzbaL4.jpg', 5, 1, NULL, '2018-06-03 13:42:29'),
(53, 'D134', 'Son kem MiraCulous Nude Moist Matte Liptint', 'd280son-kem-miraculou-6776.jpg', 'null', 171750, 229000, 123432, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Son kem Miraculous Moist Matte l&agrave; sự kết hợp giữa son l&igrave; v&agrave; dưỡng nhưng kh&ocirc;ng ho&agrave;n to&agrave;n kh&ocirc; l&igrave; m&agrave; vẫn đảm bảo độ mềm mại cần thiết, lưu giữ m&agrave;u như son xăm đảm bảo cho bạn một bờ m&ocirc;i quyến rũ suốt nhiều giờ C&oacute; 3 tone m&agrave;u thời trang: đỏ, cam đỏ, hồng<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i, để lớp son thấm dần v&agrave;o m&ocirc;i Th&agrave;nh phần: Xem d&ograve;ng \"Ingredients\" tr&ecirc;n vỏ hộp Bảo quản: Để nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng NSX&amp;Lot: Được in tr&ecirc;n bao b&igrave; sản phẩm HSD: 03 năm &nbsp;(sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) &nbsp;<br /> <strong>Khối lượng tịnh</strong>: 7g Xuất xứ: H&agrave;n Quốc &nbsp; &nbsp;&nbsp;<br /> <strong>NK&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA<br /> &nbsp;</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/HzE6Wxc6g3U8xHK2qYhe.jpg', 5, 1, NULL, '2018-06-03 13:41:58'),
(54, 'D432', 'Son lì lâu trôi Suri Pure Matte Lipstick Hàn Quốc', 'd236son-li-lau-troi-suri-2210.png', 'null', 171750, 229000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">C&ocirc;ng dụng</span>: chất son mịn l&igrave;, m&agrave;u son l&acirc;u phai, chứa vitamin E dưỡng m&ocirc;i mềm mượt Sắc son thời trang, đa dạng ph&ugrave; hợp nhiều phong c&aacute;ch trang điểm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Sử dụng:</span>&nbsp;D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Th&agrave;nh phần:</span>&nbsp;Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Bảo quản:</span>&nbsp;Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Khuyến c&aacute;o:</span>&nbsp;Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">NSX&amp;Lot:</span>&nbsp;Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">HSD:</span>&nbsp;03 năm (sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp)</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Khối lượng tịnh:</span>&nbsp;35g&nbsp;&nbsp;&nbsp;&nbsp;<span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Xuất xứ:</span>&nbsp;H&agrave;n Quốc</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Nh&atilde;n hiệu:</span><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">&nbsp;SURI</span></p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">NK&amp;PP:</span>&nbsp;C&ocirc;ng ty TNHH Mỹ Phẩm&nbsp;<span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">MIRA</span></p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/1TfTA5htRUE9fdytwmuL.png', 10, 1, NULL, '2018-06-03 13:42:54'),
(55, 'D123', 'Son dưỡng tạo màu lâu trôi MiraCulous Glow Tint Lip (SPF18)', 'd221sonduongtaomaulautroimiraculous-5117.jpg', 'null', 236250, 315000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Cung cấp độ ẩm cần thiết cho l&agrave;n m&ocirc;i, đồng thời tạo m&agrave;u son l&acirc;u tr&ocirc;i cho sắc m&ocirc;i tươi tắn, căng mọng tự nhi&ecirc;n trong suốt nhiều giờ Chỉ số chống nắng SPF 18 bảo vệ m&ocirc;i an to&agrave;n dưới &aacute;nh nắng mặt trời<br /> <strong>Sử dụng</strong>: Thoa son trực tiếp l&ecirc;n m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 41g &nbsp; &nbsp;Xuất xứ: H&agrave;n Quốc &nbsp; &nbsp;<br /> <strong>Nh&atilde;n hiệu</strong>: MiraCulous</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/oVztHp276lNSECwF9QBb.png', 10, 1, NULL, '2018-06-03 13:43:25'),
(56, 'D328', 'Son môi siêu dưỡng ẩm và tạo màu tự nhiên CosRoyale Convert Lipstick', 'd13003-7632.jpg', 'null', 204000, 272000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Son m&ocirc;i si&ecirc;u dưỡng ẩm v&agrave; tạo m&agrave;u tự nhi&ecirc;n CosRoyale Convert Lipstick với tinh dầu hạt bơ kết hợp c&ugrave;ng vitamin từ dầu Castor nu&ocirc;i dưỡng, t&aacute;i tạo sức sống cho l&agrave;n m&ocirc;i, cho m&ocirc;i mềm mại tự nhi&ecirc;n suốt nhiều giờ<br /> - Khi thoa son l&ecirc;n m&ocirc;i, son phối hợp c&ugrave;ng sắc th&aacute;i ri&ecirc;ng của l&agrave;n m&ocirc;i mỗi người sẽ ửng m&agrave;u hồng ngọt ng&agrave;o hoặc m&agrave;u cam quyến rũ<br /> - Son c&oacute; m&ugrave;i hương tr&aacute;i c&acirc;y dịu ngọt, thanh m&aacute;t</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/cFYnOjpPjR4CnEtWQB0E.jpg', 10, 1, NULL, '2018-06-03 13:44:11'),
(57, 'D219', 'Son môi siêu dưỡng ẩm và lâu trôi MiraCulous', 'd289a-9921.jpg', 'null', 225000, 300000, 99997, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Son m&ocirc;i thời trang si&ecirc;u dưỡng ẩm v&agrave; l&acirc;u tr&ocirc;i MiraCulous với sắc son từ cổ điển sang trọng đến hiện đại trẻ trung c&ugrave;ng với dưỡng chất mềm m&ocirc;i hương dịu ngọt giữ ẩm suốt 7 giờ cho l&agrave;n m&ocirc;i lu&ocirc;n căng mọng<br /> - M&agrave;u cực chuẩn, bền l&acirc;u<br /> - Thiết kế tinh tế, thời trang</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/XWDCp1MRuDF34YCtZVxN.jpg', 10, 1, NULL, '2018-06-03 13:45:21'),
(58, 'D301', 'Phấn cặp Suri Two Way Cake (15g)', 'd288phan-cap-suri-two-way-cake-50.png', 'null', 236250, 315000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Hạt phấn mịn chứa collagen, vitamin E c&ugrave;ng độ b&aacute;m cao cho lớp nền mỏng, kiềm dầu, s&aacute;ng m&agrave;u bền l&acirc;u suốt hơn 12h Chỉ số SPF 35 PA++ bảo vệ da an to&agrave;n dưới &aacute;nh nắng mặt trời v&agrave; tia UVA-UVB, kết hợp c&ugrave;ng collagen nu&ocirc;i dưỡng từng tế b&agrave;o da từ b&ecirc;n trong<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng phấn đ&iacute;nh k&egrave;m lấy một lượng vừa đủ thoa đều l&ecirc;n mặt v&agrave; cổ<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm Nguy&ecirc;n liệu nhập từ H&agrave;n Quốc<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm (24 th&aacute;ng sau khi mở nắp )<br /> <strong>SX &amp; PP</strong>: CN c&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 195, 1, 0, 0, 0, 'products/June2018/iWEdkR0r4YXyWm1diRai.png', 5, 1, NULL, '2018-06-03 13:53:31'),
(59, 'D499', 'Son môi Mira Aroma Slim Lip Stick', 'c283sonmoimiraaromaslimlipstickd2-8635.jpg', 'null', 102000, 136000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Son m&ocirc;i Mira AROMA Slim Lip Stick - sản phẩm nổi trội với khả năng tạo m&agrave;u v&agrave; chăm s&oacute;c m&ocirc;i<br /> - Cảm gi&aacute;c nhẹ nh&agrave;ng khi sử dụng cho đ&ocirc;i m&ocirc;i mềm mại v&agrave; quyến rũ<br /> - Dưỡng chất c&oacute; trong son cho bạn sự &ecirc;m &aacute;i v&agrave; kh&ocirc;ng c&ograve;n cảm gi&aacute;c đ&ocirc;i m&ocirc;i bị kh&ocirc; hoặc son bị bết d&iacute;nh<br /> <strong>Sử dụng</strong>: D&ugrave;ng thỏi son thoa trực tiếp l&ecirc;n m&ocirc;i<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>HSD</strong>: 3 năm, 12 th&aacute;ng sau khi mở nắp<br /> Th&ocirc;ng tin chi tiết được in tr&ecirc;n vỏ hộp sản phẩm</p>\r\n</div>', 174, 1, 0, 0, 0, 'products/June2018/twCNQZ0x658j33w9TW69.png', 5, 1, NULL, '2018-06-03 13:53:49'),
(60, 'C254', 'Son xăm lì siêu mịn không trôi Mira Aroma Tattoo Liptint (6g)', 'c368son-xam-li-sieu-min-khong-troi-mira-aroma-1860.png', 'null', 96750, 129000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Chất son mượt m&agrave; kết hợp giữa son gel sữa v&agrave; son kem đem đến l&agrave;n m&ocirc;i mịn l&igrave;, kh&ocirc;ng tr&ocirc;i suốt nhiều giờ Kh&ocirc;ng chứa parapen, an to&agrave;n cho m&ocirc;i mỏng manh<br /> C&oacute; 2 m&agrave;u: #1: đỏ thời thượng, quyến rũ, #2: hồng cam c&agrave; chua tươi trẻ<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i, để lớp son thấm dần v&agrave;o m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03 năm &nbsp;(sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 6g <strong>Số CB</strong>: 001895/16/CBMP-HCM<br /> <strong>SX,ĐG&amp;PP</strong>: CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 175, 1, 0, 0, 0, 'products/June2018/YUVxEfDYSSbUd703rIi6.png', 4, 1, NULL, '2018-06-03 13:54:07'),
(61, 'D569', 'Chì mày định hình Mira Aroma Square Eyebrow Pencil', 'c361chi-may-dinh-hinh-mira-aroma-856.png', 'null', 49000, 57000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Đầu ch&igrave; được thiết kế đặc biệt, c&oacute; thể kẻ n&eacute;t mảnh, n&eacute;t d&agrave;y gi&uacute;p dễ d&agrave;ng định h&igrave;nh d&aacute;ng ch&acirc;n m&agrave;y Ruột ch&igrave; si&ecirc;u mềm, n&eacute;t ch&igrave; cực thanh Ch&igrave; c&oacute; chổi chải m&agrave;y đ&iacute;nh k&egrave;m Đặc biệt: kh&ocirc;ng lem, dễ d&agrave;ng tẩy trang<br /> <strong>Sử dụng</strong>: D&ugrave;ng ch&igrave; kẻ từng n&eacute;t nhỏ dọc theo chiều mọc của l&ocirc;ng m&agrave;y, theo h&igrave;nh dạng mong muốn, ch&uacute; &yacute; phần đu&ocirc;i l&ocirc;ng m&agrave;y lu&ocirc;n đậm v&agrave; mảnh hơn phần đầu l&ocirc;ng m&agrave;y D&ugrave;ng chổi đ&iacute;nh k&egrave;m chải lại để n&eacute;t ch&igrave; h&ograve;a lẫn c&ugrave;ng đường ch&acirc;n m&agrave;y sẵn c&oacute;<br /> <strong>Bảo quản</strong>: Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao bì sản ph&acirc;̉m<br /> <strong>HSD</strong>: &nbsp;03 năm&nbsp;<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>NK&amp;PP</strong>: &nbsp;C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/aCYaeVfMvQBepYYLIpJI.jpg', 9, 1, NULL, '2018-06-03 13:55:33'),
(62, 'D699', 'Kem che khuyết điểm Aroma Cover Foundation (14g)', 'c211kem-che-khuyet-diem-aroma-1661.png', 'null', 59250, 79000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>&nbsp;Kem che khuyết điểm Aroma Cover Foundation với c&ocirc;ng thức đặc biệt &nbsp;gi&uacute;p bạn dễ d&agrave;ng che c&aacute;c lớp t&agrave;n nhang, c&aacute;c lớp da th&ocirc; r&aacute;p v&agrave;<br /> c&aacute;c khuyết điểm tr&ecirc;n khu&ocirc;n mặt Trả lại cho bạn một khu&ocirc;n mặt tươi s&aacute;ng rạng rỡ kh&ocirc;ng t&igrave; vết<br /> - C&ocirc;ng thức đặc biệt gi&uacute;p bạn trang điểm xinh xắn m&agrave; kh&ocirc;ng tổn hại đến da<br /> - Sử dụng: Sau khi rửa v&agrave; lau kh&ocirc; mặt thật sạch, d&ugrave;ng một lượng vừa đủ thoa đều l&ecirc;n tr&ecirc;n c&aacute;c v&ugrave;ng da c&oacute; khuyết điểm cho đến khi vừa &yacute;<br /> - Lưu &yacute;: N&ecirc;n t&aacute;n đều kem để tạo hiệu ứng cho khu&ocirc;n mặt tự nhi&ecirc;n hơn<br /> - Xuất xứ: H&agrave;n Quốc<br /> - HSD: 3 năm, 12 th&aacute;ng sau khi mở nắp<br /> - Th&ocirc;ng tin chi tiết được in tr&ecirc;n vỏ hộp sản phẩm</p>\r\n</div>', 2, 1, 0, 0, 0, 'products/June2018/JkGAdd8tGpMUByhFOMG1.png', 5, 1, NULL, '2018-06-03 13:55:52'),
(63, 'D258', 'Phấn trang điểm Aroma Two Way Cake (14g)', 'c265phan-trang-diem-aroma-2860.png', 'null', 129000, 172000, 99995, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Phấn trang điểm Aroma Two Way Cake với chiết xuất từ thực vật v&agrave; c&aacute;c hoạt chất c&oacute; trong tự nhi&ecirc;n, tạo n&ecirc;n c&aacute;c hạt phấn cực mịn, với độ b&aacute;m d&iacute;nh cao, hạn chế tối đa sự tiết b&atilde; nhờn, l&agrave;m cho da trắng tự nhi&ecirc;n Chất UV protection bảo vệ da khỏi c&aacute;c tia cực t&iacute;m c&oacute; hại (một trong những nguy&ecirc;n nh&acirc;n g&acirc;y ra sạm da)</p>\r\n<p>Ngo&agrave;i ra, phấn trang điểm Aroma c&ograve;n c&oacute; t&aacute;c dụng che khuyết điểm một c&aacute;c c&oacute; hiệu quả, sử dụng được cho tất cả c&aacute;c t&igrave;nh trạng da</p>\r\n</div>', 172, 1, 0, 0, 0, 'products/June2018/qxDfHRtUzPRRhgPAcRFX.jpg', 10, 1, NULL, '2018-06-03 13:57:13'),
(64, 'A213', 'Phấn phủ Aroma Candy Shine Powder 10g', 'c266d2-8151.jpg', 'null', 75000, 100000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn phủ Aroma Candy Shine Powder d&ugrave;ng để trang điểm l&agrave;m cho da mặt mịn m&agrave;ng hơn<br /> - C&oacute; t&aacute;c dụng thấm mồ h&ocirc;i v&agrave; chất nhờn tiết ra tr&ecirc;n da giữ m&atilde;i vẻ tươi s&aacute;ng cho khu&ocirc;n mặt</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/lQfCdNsiwYNQZjDawsji.jpg', 5, 1, NULL, '2018-06-03 13:56:55'),
(65, 'B556', 'Phấn mắt 8 ô siêu mịn Mira Aroma Shadow Palette 8 Colors (2g x8)', 'c365phan-mat-sieu-min-mira-aroma-132.png', 'null', 129000, 172000, 119995, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Phấn mắt dạng n&eacute;n, hạt phấn si&ecirc;u mịn, bền m&agrave;u, kết hợp 8 t&ocirc;ng m&agrave;u thời trang kh&aacute;c nhau trong c&ugrave;ng 1 hộp phấn gi&uacute;p bạn dễ d&agrave;ng phối m&agrave;u khi trang điểm mắt Thiết kế tinh tế, thon gọn, k&egrave;m cọ trang điểm mắt<br /> <strong>Sử dụng</strong>: D&ugrave;ng cọ đ&iacute;nh k&egrave;m t&aacute;n đều phấn l&ecirc;n tr&ecirc;n mi mắt v&agrave; bầu mắt<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Nơi tho&aacute;ng, kh&ocirc;Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Hạn sử dụng</strong> : 03 năm (sử dụng tốt nhất 24 th&aacute;ng kể từ khi mở nắp) <br /> <strong>Khối lượng tịnh</strong>: 2gx8<br /> <strong>SX,ĐG&amp;PP</strong>: CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 182, 1, 0, 0, 0, 'products/June2018/GYFvq6mUqvQebGbVmGtk.jpg', 10, 1, NULL, '2018-06-03 13:59:05'),
(66, 'D656', 'Son Mira Aroma Rouge Shine Lips', 'c381son-mira-aroma-shine-rouge-5953.png', 'null', 144750, 193000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Sự kết hợp ho&agrave;n hảo giữa son m&ocirc;i v&agrave; dưỡng chất bảo vệ &nbsp;m&ocirc;i từ tinh dầu hạt nho tạo n&ecirc;n Son Mira Aroma Rouge Shine Lips gi&uacute;p l&agrave;n m&ocirc;i của bạn lu&ocirc;n tươi tắn, đầy sức sống<br /> - Son c&oacute; nhiều sắc m&agrave;u đa dạng, trẻ trung</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/LSizgHjUiCtvAuATziDs.png', 10, 1, NULL, '2018-06-03 13:59:27'),
(67, 'Q896', 'Son dưỡng môi Mira Aroma Hi-Tech Lip Polish Hàn Quốc (6g)', 'c377-5353.jpg', 'null', 85500, 114000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Son dưỡng m&ocirc;i Mira Aroma Hi-Tech Lip Polish đặc biệt mang phong c&aacute;ch thời trang ho&agrave;n to&agrave;n mới<br /> - Đầu cọ dạng silicon dễ d&agrave;ng tạo m&agrave;u cho đ&ocirc;i m&ocirc;i, kết hợp với son b&oacute;ng ngọc trai tạo n&ecirc;n một bộ đ&ocirc;i ho&agrave;n hảo cho đ&ocirc;i m&ocirc;i thật căng mọng, đầy đặn, gợi cảm, thu h&uacute;t mọi &aacute;nh nh&igrave;n<br /> - Dưỡng chất tự nhi&ecirc;n trong son tạo th&agrave;nh lớp phim nhẹ v&agrave; mỏng tr&ecirc;n m&ocirc;i, cung cấp độ ẩm, l&agrave;m mềm dịu, bền m&agrave;u trong nhiều giờ, bảo vệ đ&ocirc;i m&ocirc;i khỏi &ocirc; nhiễm m&ocirc;i trường v&agrave; c&aacute;c t&aacute;c hại từ tia cực t&iacute;m trong &aacute;nh mắt trời L&agrave;n m&ocirc;i bạn vẫn quyến rũ, nổi bật v&agrave; tự tin trong giao tiếp</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/W4mNzBHRNW0rBGqcnFEs.png', 10, 1, NULL, '2018-06-03 13:59:45'),
(68, 'D595', 'Chì vẽ mày Aroma Eyebrow Pencil', 'c379chi-ke-may-aroma-7597.png', 'null', 37500, 50000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Thiết kế tiện dụng gồm một đầu ch&igrave; n&eacute;t tự nhi&ecirc;n cho l&ocirc;ng m&agrave;y v&agrave; một đầu chổi mềm gi&uacute;p dễ d&agrave;ng chải , định h&igrave;nh d&aacute;ng đường ch&acirc;n m&agrave;y <br /> - Ch&igrave; kẻ m&agrave;y mịn, n&eacute;t m&atilde;nh, dễ sử dụng<br /> Sử dụng: D&ugrave;ng ch&igrave; vẽ đều l&ecirc;n v&ugrave;ng ch&acirc;n m&agrave;y cần trang điểm<br /> Khuyến c&aacute;o: Ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> HSD: 3 năm</p>\r\n</div>', 60, 1, 0, 0, 0, 'products/June2018/e6cUYYooDdLmyHco108O.jpg', 10, 1, NULL, '2018-06-03 14:00:01'),
(69, 'D566', 'Son dưỡng ẩm tạo màu lâu trôi Mira Aroma Moist Matte Lip Tint', 'c350son-moi-duong-am-tao-mau-lau-troi29-7131.png', 'null', 161250, 215000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>C&ocirc;ng dụng: Son tạo m&agrave;u m&ocirc;i đỏ &aacute;nh cam hoặc hồng đ&agrave;o, chứa tinh dầu dừa bổ sung độ ẩm cần thiết cho l&agrave;n m&ocirc;i lu&ocirc;n mềm mượt trong suốt nhiều giờ Chỉ số chống nắng SPF 12 bảo vệ m&ocirc;i an to&agrave;n dưới &aacute;nh nắng mặt trời<br /> Sử dụng: Thoa son trực tiếp l&ecirc;n m&ocirc;i<br /> ---------<br /> Th&agrave;nh phần: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> Bảo quản: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> Khuyến c&aacute;o: Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng<br /> NSX&amp;Lot: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> HSD: 03 năm (sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) <br /> Khối lượng tịnh: 35g &nbsp; &nbsp;Xuất xứ: H&agrave;n Quốc &nbsp;&nbsp;</p>\r\n</div>', 169, 1, 0, 0, 0, 'products/June2018/mRsz5X1Z5PV5dfghRJJi.jpg', 20, 1, NULL, '2018-06-03 14:00:49'),
(70, 'D669', 'Màu mắt 3 ô Mira Crystal Shine Shadow', 'c339mau-mat-3-mau-mira-crystal-7563.png', 'null', 85500, 114000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- M&agrave;u mắt 3 &ocirc; MIRA Crystal Shine Shadow với nhiều m&agrave;u thời trang được ph&aacute;t triển bởi c&aacute;c chuy&ecirc;n gia từ H&agrave;n quốc với m&agrave;u sắc đang thịnh h&agrave;ng nhất tại MILAN - PARIS - NEW YORK<br /> - Sự lựa chọn của c&aacute;c chuy&ecirc;n gia trang điểm<br /> Sử dụng: D&ugrave;ng cọ trang điểm mắt vẽ đều m&agrave;u mắt l&ecirc;n tr&ecirc;n v&ugrave;ng mi mắt cần trang điểm<br /> Khuyến c&aacute;o: Ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> HSD: 3 năm, 12 th&aacute;ng sau khi mở nắp (sử dụng)</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/Vwh0GaOXQPY8RES3EsIq.jpg', 10, 1, NULL, '2018-06-03 14:01:04'),
(71, 'F656', 'Phấn nén kết hợp kem nền siêu mịn Mira Aroma BB Compact Foundation', 'c299kem-bb-compact-foundation-8683.png', 'null', 171750, 229000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn n&eacute;n kết hợp kem nền si&ecirc;u mịn Mira AROMA BB compact foundation được sản xuất từ sự kết hợp ho&agrave;n hảo giữa phấn trang điểm v&agrave; kem nền BB chiết xuất từ kho&aacute;ng chất biển v&agrave; ngọc trai &nbsp;tạo n&ecirc;n sản phẩm cao cấp v&agrave; tiện dụng trong trang điểm<br /> - Độ chống nắng SPF 30 PA++ gi&uacute;p bảo vệ l&agrave;n da chống lại c&aacute;c tia tử ngoại UVA v&agrave; UVB g&acirc;y tổn thương da<br /> - C&aacute;c hạt phấn si&ecirc;u nhỏ đem đến vẻ mịn m&agrave;ng tự nhi&ecirc;n cho l&agrave;n da</p>\r\n</div>', 176, 1, 0, 0, 0, 'products/June2018/6UfLjxGFxT46jNxUZxOk.png', 10, 1, NULL, '2018-06-03 14:01:39'),
(72, 'T596', 'Phấn má hồng Mira Aroma Multi Blusher', 'c376ma-hong-trang-diem-mira-aroma-9058.png', 'null', 144750, 193000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- M&aacute; hồng trang điểm Mira AROMA Multi blusher với hạt phấn mịn m&agrave;ng được sản xuất từ c&aacute;c th&agrave;nh phần thi&ecirc;n nhi&ecirc;n gi&uacute;p cho bạn c&oacute; được một khu&ocirc;n mặt trang điểm ho&agrave;n hảo Đa dạng m&agrave;u sắc, thời trang, cho bạn nhiều phong c&aacute;ch trang điểm<br /> - Gi&uacute;p bạn lu&ocirc;n tự tin v&agrave; rạng ngời mỗi ng&agrave;y</p>\r\n</div>', 178, 1, 0, 0, 0, 'products/June2018/IAablEPOgaKY676ikWdx.jpg', 10, 1, NULL, '2018-06-03 14:02:48'),
(73, 'R223', 'Son dưỡng môi tạo màu tự nhiên Mira Limpid Liptint Bar', 'b637son-duong-moi-tao-mau-tu-nhien-mira-9375.png', 'null', 192750, 257000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Với th&agrave;nh phần dưỡng m&ocirc;i, tạo m&agrave;u v&agrave; l&agrave;m mềm m&ocirc;i tự nhi&ecirc;n cho l&agrave;n m&ocirc;i đ&agrave;n hồi v&agrave; mềm mại, m&agrave;u sắc bền l&acirc;u gi&uacute;p tự tin suốt nhiều giờ Son thấm s&acirc;u, nu&ocirc;i dưỡng m&ocirc;i căng mọng, mướt mềm, kh&ocirc;ng nếp nhăn Th&iacute;ch hợp sử dụng mọi thời tiết đặc biệt l&agrave; thời tiết lạnh&nbsp;<br /> <strong>Hướng dẫn sử dụng</strong> : D&ugrave;ng cọ vẽ m&ocirc;i hoặc thoa trực tiếp l&ecirc;n m&ocirc;i<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>NSX&amp;Lot</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Hạn sử dụng</strong>&nbsp;: 03 năm<br /> <strong>Khối lượng tịnh</strong>: 35g<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc&nbsp;<br /> <strong>Số CB</strong>: 56165/12/CBMP &ndash; QLD &nbsp;&nbsp;</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/ORznL3JFmSypZOFWRGCO.jpg', 10, 1, NULL, '2018-06-03 14:03:03'),
(74, 'R565', 'Son MIRA 2 đầu tiện dụng (son dưỡng và son kem lì siêu mịn không trôi)', 'b634son-dou-lip-makeup1-185.png', 'null', 236250, 315000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>C&ocirc;ng dụng</strong>: Thỏi son được thiết kế 2 đầu tiện dụng bao gồm:<br /> Son dưỡng kh&ocirc;ng m&agrave;u: Dưỡng m&ocirc;i ẩm mềm mượt, đồng thời tạo lớp m&agrave;ng chắn bảo vệ l&agrave;n m&ocirc;i mỏng manh dưới &aacute;nh nắng mặt trời<br /> Son kem l&igrave; si&ecirc;u mịn kh&ocirc;ng tr&ocirc;i: Chất son si&ecirc;u mượt m&agrave;, m&agrave;u son HD sắc n&eacute;t, nhẹ như kh&ocirc;ng<br /> Son kh&ocirc;ng chứa paraben, an to&agrave;n cho l&agrave;n m&ocirc;i, kh&ocirc;ng g&acirc;y kh&ocirc; m&ocirc;i&nbsp;<br /> <strong>Sử dụng</strong>: Thoa son dưỡng m&ocirc;i, sau đ&oacute; d&ugrave;ng cọ t&ocirc; son l&ecirc;n m&ocirc;i, để lớp son thấm dần v&agrave;o m&ocirc;i</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/8bzfufcXxWkL0RLHkX3T.jpeg', 10, 1, NULL, '2018-06-03 14:03:21'),
(75, 'D106', 'Chì mày đa chức năng MIRA', 'b617chi-may-dinh-hinh-mira-6456.png', 'null', 49000, 64000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Gi&uacute;p định h&igrave;nh v&agrave; tạo n&eacute;t l&ocirc;ng m&agrave;y như &yacute; Đầu ch&igrave; được thiết kế tam gi&aacute;c, dễ d&agrave;ng tạo n&eacute;t ch&igrave; lớn hay nhỏ, kết hợp ruột ch&igrave; mềm mịn, độ b&aacute;m cao, duy tr&igrave; n&eacute;t vẽ suốt cả ng&agrave;y C&oacute; 4 t&ocirc;ng n&acirc;u ph&ugrave; hợp mọi phong c&aacute;ch trang điểm ( kể cả cho người xăm m&agrave;y)<br /> Đặc biệt: kh&ocirc;ng lem, kh&ocirc;ng thấm nước&nbsp;<br /> Sử dụng: Vặn nhẹ cho phần ch&igrave; nh&ocirc; l&ecirc;n, kẻ từ giữa đến đu&ocirc;i ch&acirc;n m&agrave;y, d&ugrave;ng cọ chải lại<br /> Th&agrave;nh phần: Ethylhexyl Palmitate, Hydrogenated Palm Kernel Oil, Synthetic Japan Wax, Polyethylene, Glucol Montanate&hellip;<br /> Bảo quản: Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> Khuyến c&aacute;o: Ngưng sử dụng nếu c&oacute; dấu hiệu di ứng<br /> NSX&amp;Lot: Xem tr&ecirc;n bao b&igrave; sản phẩm HSD: &nbsp;03 năm &nbsp;<br /> Xuất xứ: H&agrave;n Quốc NK&amp;PP: &nbsp;C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 184, 1, 0, 0, 0, 'products/June2018/RDCVvtvSoxSqSlPFbdEo.jpg', 12, 1, NULL, '2018-06-03 14:03:47'),
(76, 'D199', 'Che khuyết điểm chống nắng 2 đầu MIRA', 'b614che-khuyet-diem-chong-nang-2-dau21-4123.png', 'null', 144750, 193000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Thanh che khuyết điểm tiện dụng 2 đầu tạo n&ecirc;n lớp che phủ cực mịn, kh&ocirc;ng b&iacute;t lỗ ch&acirc;n l&ocirc;ng, kết hợp giữa 2 loại:<br /> - Thanh che: gi&uacute;p che đốm th&acirc;m, vết đỏ, mụn, t&agrave;n nhang<br /> -Che khuyết điểm dạng lỏng k&egrave;m cọ gi&uacute;p dễ d&agrave;ng t&aacute;n mỏng lớp kem để che quầng th&acirc;m, v&ugrave;ng cần che phủ rộng<br /> Đặc biệt, kem che khuyết điểm c&oacute; chỉ số chống nắng SPF 27-28/PA ++ bảo vệ da an to&agrave;n dưới &aacute;nh nắng mặt trời<br /> Sử dụng : D&ugrave;ng thanh che , hoặc cọ chấm l&ecirc;n những v&ugrave;ng muốn che phủ, sau đ&oacute; t&aacute;n nhẹ, đều tay<br /> Th&agrave;nh phần: Xem tr&ecirc;n bao b&igrave;<br /> Bảo quản: Để nơi kh&ocirc;, thoáng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> Khuyến c&aacute;o: Ngưng sử dụng &nbsp;khi c&oacute; dấu hiệu dị ứng<br /> NSX&amp;Lot: Xem tr&ecirc;n bao b&igrave; sản phẩm HSD: 03 năm<br /> Khối lượng tịnh: xxx g Sản xuất theo c&ocirc;ng nghệ H&agrave;n Quốc<br /> ĐG&amp;PP: CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 182, 1, 0, 0, 0, 'products/June2018/LnRQZcZ0uvB06jalozPu.jpg', 6, 1, NULL, '2018-06-03 14:04:10'),
(77, 'D122', 'Viết kẻ mí mắt tinh chất trà xanh Mira', 'c347-108.jpg', 'null', 129000, 172000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><strong>Viết kẻ m&iacute; mắt tinh chất tr&agrave; xanh MIRA Perfect Green Tea Pen Eyeliner</strong> được sản xuất từ những th&agrave;nh phần chiết xuất từ tinh chất l&aacute; tr&agrave; xanh v&agrave; bổ sung từ c&aacute;c tinh dầu thảo dược thi&ecirc;n nhi&ecirc;n<br /> - Viết kẻ m&iacute; mắt tr&agrave; xanh MIRA tạo điểm nhấn cho đ&ocirc;i mắt th&ecirc;m gợi cảm, quyến rũ<br /> - Viết kẻ m&iacute; mắt tr&agrave; xanh ho&agrave;n to&agrave;n kh&ocirc;ng lem, kh&ocirc;ng bị bết d&iacute;nh khi sử dụng<br /> <strong>Sử dụng</strong>: D&ugrave;ng đầu cọ vẻ đều l&ecirc;n hai m&iacute; mắt cho đến khi tạo được đường viền như &yacute;<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng nếu thấy da c&oacute; bất k&igrave; sự k&iacute;ch ứng n&agrave;o<br /> <strong>HSD</strong>: 2 năm (06 th&aacute;ng khi mở nắp)<br /> <strong>Xuất xứ</strong>: H&agrave;n quốc</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/wmLueirF4A4Iuv9YqWTz.jpg', 20, 1, NULL, '2018-06-03 14:04:30'),
(78, 'D953', 'Viết lông kẻ mí MIRA', 'b635vietlongkemimiratruelasting-6217.jpg', 'null', 155250, 207000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Viết kẻ l&ocirc;ng kẻ m&iacute; MIRA được thiết kế với ng&ograve;i viết thanh gọn, tạo n&eacute;t vẽ mảnh, mịn</p>\r\n<p>- D&ugrave;ng viết để vẽ d&agrave;i đu&ocirc;i mắt hoặc viền mi mắt tr&ecirc;n, mi mắt dưới cho mắt th&ecirc;m to tr&ograve;n, sắc sảo</p>\r\n<p>- M&agrave;u mực đen tuyền suốt 24h, kh&ocirc;ng lem, dễ tẩy trang</p>\r\n<p><strong>Th&agrave;nh phần: </strong>Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>Bảo quản: </strong>Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p><strong>Khuyến c&aacute;o: </strong>Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p><strong>NSX&amp;Lot: </strong>Được in tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p><strong>HSD:</strong> 02 năm (06 th&aacute;ng sau khi mở nắp)</p>\r\n<p><strong>Thể t&iacute;ch thực:</strong> 08ml</p>\r\n<p><strong>Xuất xứ: </strong>H&agrave;n Quốc&nbsp; &nbsp;</p>\r\n<p><strong>NK&amp;PP:</strong> C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 191, 1, 0, 0, 0, 'products/June2018/zw1Ry5posr61MfkAAPjp.jpg', 20, 1, NULL, '2018-06-03 14:04:43'),
(79, 'G659', 'Phấn phủ MIRA Cherry Shine Powder', 'b601phanphumiracherryshinepowder-3535.jpg', 'null', 90750, 122000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Phấn phủ MIRA Cherry shine powder c&oacute; nhiều t&ocirc;ng m&agrave;u th&iacute;ch hợp cho mọi loại da, hạt phấn mịn với khả năng thấm h&uacute;t tốt, hạn chế hiện tượng da b&oacute;ng nhờn do dầu Tạo lớp phủ nhẹ nh&agrave;ng l&aacute;ng mịn</p>\r\n<p>- Cho bạn vẻ đẹp tự nhi&ecirc;n v&agrave; thật quyến rũ<br /> &nbsp;</p>\r\n</div>', 2, 1, 0, 0, 0, 'products/June2018/XpyZI2Ibc0h5fnzCtcCI.jpg', 20, 1, NULL, '2018-06-03 14:04:57');
INSERT INTO `products` (`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`, `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) VALUES
(80, 'E956', 'Kem che khuyết điểm Aroma 4 in 1', 'c3781d2-1977.jpg', 'null', 117750, 157000, 110000, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kem che khuyết điểm AROMA BB 4 in 1</strong> cho l&agrave;n da ho&agrave;n hảo<br /> - Dưỡng da tự nhi&ecirc;n từ kho&aacute;ng chất<br /> - L&agrave;m kem nền s&aacute;ng da<br /> - Bảo vệ da khỏi tia cực t&iacute;m v&agrave; t&aacute;c hại của m&ocirc;i trường<br /> - Giải ph&aacute;p ho&agrave;n hảo cho l&agrave;n da mịn m&agrave;ng v&agrave; bảo vệ da suốt nhiều giờ<br /> <strong>- Sử dụng</strong>: D&ugrave;ng đầu cọ chấm kem l&ecirc;n những vết th&acirc;m hoặc v&ugrave;ng da xỉn m&agrave;u tr&ecirc;n mặt, sau đ&oacute; d&ugrave;ng đầu ng&oacute;n tay thoa đều cho kem thấm hết v&agrave;o da<br /> <strong>- Khuyến c&aacute;o</strong>: Ngưng sử dụng ngay khi thấy da bị dị ứng<br /> <strong>- Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>- HSD</strong>: 3 năm, 12 th&aacute;ng sau khi mở nắp<br /> <strong>- Trọng lượng</strong>: 20g</p>\r\n</div>', 224, 1, 0, 0, 0, 'products/June2018/aGwEXnMz8gHPlcxcZZFv.png', 19, 1, NULL, '2018-06-03 14:06:48'),
(81, 'D257', 'Kem nền đa năng trà xanh Mira Aroma', 'c295p-1222.jpg', 'null', 112500, 150000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kem nền đa năng tr&agrave; xanh Mira Aroma</strong> ngo&agrave;i t&aacute;c dụng của lớp kem nền ho&agrave;n hảo v&agrave; che khuyết điểm vượt trội, sản phẩm c&ograve;n c&oacute; khả năng gi&uacute;p duy tr&igrave; độ ẩm v&agrave; l&agrave;m trắng da<br /> Sử dụng sản phẩm hằng ng&agrave;y để c&oacute; một l&agrave;n da mịn m&agrave;ng, tự nhi&ecirc;n v&agrave; trắng s&aacute;ng hơn</p>\r\n</div>', 191, 1, 0, 0, 0, 'products/June2018/AZFZeg6CMlaVlhWfKKZi.jpg', 13, 1, NULL, '2018-06-03 14:07:20'),
(82, 'A564', 'Bột kẻ mày Aroma', 'c336-3314.jpg', 'null', 129000, 172000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Bột kẻ m&agrave;y AROMA Shine Brown Liner Cake Type</strong> được sản xuất từ th&agrave;nh phần thi&ecirc;n nhi&ecirc;n, hạt phấn với cấu tạo cực mịn, gi&uacute;p bạn dễ d&agrave;ng trang điểm<br /> - Đem đến cho bạn khu&ocirc;n mặt trang điểm rạng ngời</p>\r\n<p><strong>Sử dụng</strong>: D&ugrave;ng cọ định vị v&ugrave;ng trang điểm, vẽ nhẹ nh&agrave;ng cho đến khi đạt hiệu quả mong muốn<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng ngay khi thấy hiện tượng da bị k&iacute;ch ứng<br /> <strong>HSD</strong>: 3 năm, 12 th&aacute;ng sau khi mở nắp (sử dụng)</p>\r\n</div>', 192, 1, 0, 0, 0, 'products/June2018/nSeQ8Y9hcMMNWBK1Wa6L.jpg', 20, 1, NULL, '2018-06-03 14:07:41'),
(83, 'A232', 'Mascara Mira Monaliza', 'c320-16.jpg', 'null', 54000, 72000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><strong>Mascara MIRA Monaliza</strong> dễ d&agrave;ng sử dụng, gi&uacute;p cho bạn c&oacute; được một đ&ocirc;i mi cong v&uacute;t, d&agrave;y v&agrave; gợi cảm<br /> - Đầu cọ/chổi được thiết kế đặc biệt gi&uacute;p định h&igrave;nh từng sợi mi ho&agrave;n hảo, kể cả những sợi mi ngắn nhất trong suốt nhiều giờ<br /> - Tiện lợi, nhanh ch&oacute;ng v&agrave; sang trọng</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/lsRxmV0F5KUhQFebNJj0.png', 19, 1, NULL, '2018-06-03 14:08:25'),
(84, 'T466', 'Mascara dưỡng mi Aroma', 'mascaraduongmitunhienaromaeyeheelcaocaphanquoc10mlhangchinhhang1505716573268281419b451292f43e162311c21bfd25c8eb0ezoom-9453.jpg', 'null', 54000, 72000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Mascara dưỡng mi Aroma Eyehell</strong> kh&ocirc;ng chỉ gi&uacute;p mi d&agrave;y, cong tự nhi&ecirc;n m&agrave; c&ograve;n dưỡng mi v&agrave; gi&uacute;p mi d&agrave;i hơn<br /> - Cho bạn l&ocirc;ng mi khoẻ mạnh v&agrave; cong v&uacute;t<br /> - Một sản phẩm cao cấp AROMA H&agrave;n Quốc<br /> <strong>Sử dụng</strong>: D&ugrave;ng đầu cọ mascara chải đều từ trong mi đến đầu ngọn của mi mắt<br /> <strong>Khuyến c&aacute;o</strong>: tr&aacute;nh để mascara rơi v&agrave;o mắt, để xa tầm với trẻ em<br /> <strong>HSD</strong>: 2 năm, 12 th&aacute;ng sau khi mở nắp (sử dụng)</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/lUhc8uEJnTWPhjtm9DKe.png', 19, 1, NULL, '2018-06-03 14:09:18'),
(85, 'F896', 'Kẻ mắt nước Mira Aroma', 'c298kematnuocmiraaroma-4993.jpg', 'null', 91500, 122000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kẻ mắt nước Mira AROMA Liquid Eyeliner</strong> tạo sự kh&aacute;c biệt v&agrave; quyến rũ cho đ&ocirc;i mắt bạn<br /> - Với kẻ mắt nước Mira Aroma Đầu chổi thanh mảnh, dễ kẻ, sắc n&eacute;t, nhanh kh&ocirc; v&agrave; giữ m&agrave;u bền l&acirc;u Phần c&aacute;n cọ d&agrave;i, dễ cầm, dễ kẻ<br /> Sử dụng: D&ugrave;ng cọ kẻ theo s&aacute;t đường m&iacute; mắt tr&ecirc;n v&agrave; m&iacute; mắt dưới để tạo điểm nhấn, cho đ&ocirc;i mắt th&ecirc;m long lanh, sắc n&eacute;t<br /> Khuyến c&aacute;o: Ngưng sử dụng ngay khi thấy c&oacute; hiện tượng k&iacute;ch ứng xảy ra, tr&aacute;nh tiếp x&uacute;c với mắt, để xa tầm với trẻ em<br /> HSD: 2 năm, 12 th&aacute;ng sau khi mở nắp</p>\r\n</div>', 180, 1, 0, 0, 0, 'data/anhsanpham/c298kematnuocmiraaroma-4993.jpg', 20, 1, NULL, '2018-06-03 14:09:34'),
(86, 'Y333', 'Tinh chất sữa Mascara Mira Aroma', 'c292tinhchatmascarad2-6646.jpg', 'null', 37500, 50000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Với bất kỳ sản phẩm Mascara n&agrave;o khi sử dụng một thời gian sẽ xuất hiện t&igrave;nh trạng kh&ocirc; v&agrave; v&oacute;n cục Để giải quyết t&igrave;nh trạng n&agrave;y, chỉ cần cho 2 hoặc 3 giọt tinh chất sữa MASCARA EMULSION Mira AROMA v&agrave;o th&acirc;n sản phẩm<br /> - D&ugrave;ng cọ chải mi trộn đều bạn sẽ c&oacute; một sản phẩm Mascara ho&agrave;n hảo như mới Đồng thời với c&ocirc;ng dụng nu&ocirc;i dưỡng, dưỡng ẩm v&agrave; l&agrave;m d&agrave;y mi gi&uacute;p bảo vệ mi khỏi rụng, cho bạn một l&agrave;n mi khoẻ như &yacute;<br /> - Sử dụng: Nhỏ 2-3 giọt tinh chất sữa Mascara Emulsion v&agrave;o th&acirc;n sản phẩm, d&ugrave;ng cọ chải mi trộn đều<br /> - HSD: 3 năm<br /> - Xuất xứ: H&agrave;n Quốc<br /> - Dung t&iacute;ch: 20ml</p>\r\n</div>', 189, 1, 0, 0, 0, 'products/June2018/deJgwASprjR8snLO9vE8.png', 20, 1, NULL, '2018-06-03 14:09:53'),
(87, 'I255', 'Dung dịch tẩy trang mắt & môi 2 tầng Mira', 'b541-8603.jpg', 'null', 69750, 93000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Với c&ocirc;ng thức điều chế 2 tầng chứa collagen, tinh dầu oải hương gi&uacute;p loại bỏ lớp trang điểm v&agrave; bảo vệ v&ugrave;ng da nhạy cảm quanh mắt, m&ocirc;i</p>\r\n<p><strong>- Sử dụng</strong>: Lắc đều cho 2 tầng dung dịch được ho&agrave; tan sau đ&oacute; thấm l&ecirc;n b&ocirc;ng tẩy trang v&agrave; lau sạch v&ugrave;ng cần tẩy trangC&oacute; thể tẩy trang khắp mặt<br /> <strong>- Th&agrave;nh phần</strong>: Xem tr&ecirc;n sản phẩmNguy&ecirc;n liệu nhập từ H&agrave;n Quốc<br /> <strong>- Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Đ&oacute;ng chặt nắp chai sau khi sử dụng<br /> <strong>- Khuyến c&aacute;o</strong>: Ngưng d&ugrave;ng khi c&oacute; hiện tượng k&iacute;ch ứng da<br /> <strong>- HSD</strong>: 03 năm ( 12 th&aacute;ng kể từ khi mở nắp)<br /> <strong>- Thể t&iacute;ch thực</strong>: 50ml</p>\r\n</div>', 182, 1, 0, 0, 0, 'products/June2018/fPNGnS9aT8ewOHgeuv5u.png', 19, 1, NULL, '2018-06-03 14:10:11'),
(88, 'U335', 'Mascara trà xanh Mira Aroma', 'b553mcrtraxanh-5213.jpg', 'null', 117750, 157000, 100000, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Mascara tr&agrave; xanh Mira Aroma</strong> t&aacute;c dụng gi&uacute;p mi d&agrave;y gấp 2 lần, mi cong đến 76 độ, kh&ocirc;ng lem, l&acirc;u tr&ocirc;i, kh&ocirc;ng thấm nước, tinh chất tr&agrave; xanh trong mascara k&iacute;ch th&iacute;ch mi mọc d&agrave;i hơn<br /> - Đầu cọ/chổi được thiết kế đặc biệt gi&uacute;p định h&igrave;nh từng sợi mi ho&agrave;n hảo, kể cả những sợi mi ngắn nhất trong suốt nhiều giờ<br /> <strong>Sử dụng</strong>: Sau khi bấm cong mi, d&ugrave;ng cọ/chổi chuốt mascara từ ch&acirc;n mi ra ngo&agrave;i C&oacute; thể chuốt 2 lần cho mi th&ecirc;m d&agrave;y v&agrave; cong<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>Khuyến c&aacute;o</strong>: ngưng sử dụng khi thấy dấu hiệu k&iacute;ch ứng da<br /> <strong>HSD</strong>: 02 năm, 6 th&aacute;ng khi mở nắp<br /> <strong>Dung t&iacute;ch</strong>: 85 ml</p>\r\n</div>', 178, 1, 0, 0, 0, 'products/June2018/QPP4gDzkh66GOOdFbGht.jpg', 20, 1, NULL, '2018-06-03 14:10:39'),
(89, 'O456', 'Mascara thông minh Mira', 'mascaramirahong3d2-7619.jpg', 'null', 102000, 136000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>&nbsp;Được cấu tạo từ h&agrave;ng ngh&igrave;n sợi cellulose kết hợp c&ugrave;ng tinh dầu từ thi&ecirc;n nhi&ecirc;n trong mascara tạo n&ecirc;n lớp phim mỏng bao phủ quanh mi từ gốc đến ngọn cho sợi mi cong v&agrave; d&agrave;i hơn ngay tức khắc<br /> - Đầu cọ/chổi được thiết kế th&ocirc;ng minh bao phủ từng sợi mi cho h&agrave;ng mi cong, d&agrave;y v&agrave; mau kh&ocirc; trong t&iacute;ch tắc<br /> - C&ocirc;ng thức dưỡng mi ti&ecirc;n tiến bảo vệ mi, đồng thời gi&uacute;p dễ d&agrave;ng tẩy trang m&agrave; kh&ocirc;ng cần đến dung dịch tẩy trang chuy&ecirc;n dụng</p>\r\n<p><strong>Sử dụng</strong>: D&ugrave;ng bấm mi để tạo độ cong nhẹ cho mi Sau đ&oacute;, d&ugrave;ng mascara chuốt đều tay từ trong gốc mi Chuốt th&ecirc;m một hoặc nhiều lần để tạo độ d&agrave;y v&agrave; d&agrave;i như &yacute;<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm Nguy&ecirc;n liệu nhập từ H&agrave;n Quốc<br /> <strong>Bảo quản</strong>: Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng<br /> <strong>Thể t&iacute;ch thực</strong>: 8ml</p>\r\n</div>', 208, 1, 0, 0, 0, 'products/June2018/A1bC2NQ5bOOSpeMeO23j.jpg', 20, 1, NULL, '2018-06-03 14:11:01'),
(90, 'F331', 'Viên khăn nén diệt khuẩn tiện dụng Mira (12 viên)', 'b647vienkhanuotnentuid2-4643.jpg', 'null', 27000, 36000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\">Vi&ecirc;n khăn n&eacute;n được l&agrave;m từ chất liệu bột gỗ Cellulose thi&ecirc;n nhi&ecirc;n khi thả v&agrave;o nước sẽ trở th&agrave;nh chiếc khăn mềm mại, mịn m&agrave;ng Khăn d&ugrave;ng lau mặt hoặc tẩy trang kh&ocirc;ng g&acirc;y r&aacute;t, đỏ da Khăn th&acirc;n thiện với m&ocirc;i trường c&oacute; khả năng ti&ecirc;u huỷ nhanh Chỉ sử dụng một lần, kh&ocirc;ng t&aacute;i sử dụng</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">HDSD:&nbsp;</span>Thả vi&ecirc;n khăn v&agrave;o nước sạch, sau đ&oacute; d&ugrave;ng khăn lau mặt, tẩy trang với dung dịch chuy&ecirc;n dụng</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Th&agrave;nh phần:&nbsp;</span>Bột gỗ cellulose</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Bảo quản:&nbsp;</span>Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Khuyến c&aacute;o:&nbsp;</span>Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">NSX:&nbsp;</span>&nbsp;Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">HSD:&nbsp;</span>3 năm (sau khi nh&uacute;ng v&agrave;o nước chỉ d&ugrave;ng 1 lần)</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">Xuất xứ:</span>&nbsp;Sản phẩm nhập khẩu H&agrave;n Quốc&nbsp;</p>\r\n<p style=\"margin: 0px; padding: 0px; border: 0px; font-variant-numeric: inherit; font-stretch: inherit; font-size: 16px; line-height: inherit; font-family: Arial, Helvetica, sans-serif; vertical-align: baseline; color: #000000; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; vertical-align: baseline;\">ĐG&amp;PP:</span>&nbsp;C&ocirc;ng ty TNHH Mỹ Ph&acirc;̉m Mira</p>\r\n</div>', 212, 1, 0, 0, 0, 'products/June2018/EGdla9fnAdVjK6350JXP.jpg', 20, 1, NULL, '2018-06-03 14:11:43'),
(91, 'G466', 'Son tạo màu tự nhiên lâu phai, lâu trôi mướt mịn hương trái cây dịu ngọt - Etude House Dear Darling Tint RD307', 'etude-house-dear-darling-106.jpg', 'null', 80100, 89000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<div>Chất son mịn, mướt như lớp jelly trải tr&ecirc;n m&ocirc;i, vitamin chiết xuất từ tr&aacute;i c&acirc;y nu&ocirc;i dưỡng m&ocirc;i ẩm mượt Hương thơm tr&aacute;i c&acirc;y dịu ngọt, l&acirc;u tr&ocirc;i, l&acirc;u phai Thiết kế bao b&igrave; tươi trẻ, đặc biệt th&acirc;n c&acirc;y son trong suốt, gi&uacute;p dễ d&agrave;ng nh&igrave;n thấy m&agrave;u son b&ecirc;n trong</div>\r\n<div><strong>Sử dụng: </strong>Thoa son trực tiếp l&ecirc;n m&ocirc;i</div>\r\n<div><strong>Th&agrave;nh phần: </strong>Xem tr&ecirc;n bao b&igrave; sản phẩm</div>\r\n<div><strong>Bảo quản:</strong> Để son thẳng đứng, nơi kh&ocirc; tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</div>\r\n<div><strong>Khuyến c&aacute;o:</strong> Ngưng sử dụng khi c&oacute; dấu hiệu dị ứng</div>\r\n<div><strong>NSX&amp;Lot: </strong>Được in tr&ecirc;n bao b&igrave; sản phẩm</div>\r\n<div><strong>HSD: </strong>03 năm (sử dụng tốt nhất 12 th&aacute;ng kể từ khi mở nắp) &nbsp;</div>\r\n<div><strong>Khối lượng tịnh: </strong>41g&nbsp; &nbsp;<br /> <strong>Xuất xứ: </strong>H&agrave;n Quốc&nbsp;</div>\r\n<div><strong>NK&amp;PP:</strong> C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</div>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/huIMoMAj95U9wC3VuJje.png', 19, 1, NULL, '2018-06-03 14:12:32'),
(92, 'D963', 'Viết kẻ mí mắt Mira True Lasting', 'b538truelasting2-5531.jpg', 'null', 155250, 207000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>KH&Ocirc;NG LEM, ĐEN TUYỀN SUỐT 24 GIỜ</strong></p>\r\n<p>- Viết kẻ m&iacute; mắt MIRA True lasting eyeliner được thiết kế với ng&ograve;i viết thanh gọn, tạo n&eacute;t vẽ mảnh, mịn<br /> - D&ugrave;ng viết để vẽ d&agrave;i đu&ocirc;i mắt hoặc viền mi mắt tr&ecirc;n, mi mắt dưới cho mắt th&ecirc;m to tr&ograve;n, sắc sảo<br /> - M&agrave;u mực đen tuyền suốt 24h, kh&ocirc;ng lem, dễ tẩy trang<br /> <strong>Th&agrave;nh phần</strong>: Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản</strong>: Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng<br /> <strong>NSX&amp;Lot</strong>: Được in tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 02 năm ( 06 th&aacute;ng sau khi mở nắp ) <strong>Thể t&iacute;ch thực</strong>: 08ml<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc &nbsp; <strong>NK&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/zOZEjfloHgAl0M0AieB5.png', 20, 1, NULL, '2018-06-03 14:12:51'),
(93, 'Q563', 'Gel kẻ mí mắt Mira', 'gelkemimatmira-9739.jpg', 'null', 64500, 86000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Gel kẻ m&iacute; mắt MIRA Dramatic Gel Pen Eyeliner</strong> l&agrave; giải ph&aacute;p kết hợp giữa kẻ mắt dạng ch&igrave; v&agrave; dạng kem, tạo đường viền m&iacute; sắc n&eacute;t, mềm mại tự nhi&ecirc;n<br /> Đặc biệt kh&ocirc;ng lem, kh&ocirc;ng tr&ocirc;i trong suốt nhiều giờ</p>\r\n<p><strong>- Sử dụng</strong>: Xoay nhẹ th&acirc;n ch&igrave;, d&ugrave;ng ch&igrave; chấm những đốm nhỏ dọc theo mi mắt tr&ecirc;n, sau đ&oacute; d&ugrave;ng ch&igrave; nối liền c&aacute;c chấm th&agrave;nh đường viền mi Để c&oacute; đ&ocirc;i mắt tự nhi&ecirc;n n&ecirc;n kẻ 2/3 mi mắt về ph&iacute;a đu&ocirc;i mắt cho mắt th&ecirc;m to tr&ograve;n<br /> - Gel kẻ mắt l&agrave; sự lựa chọn tối ưu cho phong c&aacute;ch trang điểm mắt kh&oacute;i (Smoky eyes)<br /> <strong>- Khuyến c&aacute;o</strong>: Tr&aacute;nh xa tầm tay trẻ em Dừng sử dụng nếu c&oacute; hiện tượng dị ứng<br /> <strong>- HSD</strong>: 2 năm kể từ ng&agrave;y sản xuất (6 th&aacute;ng kể từ ng&agrave;y mở nắp)<br /> <strong>- Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n</div>', 172, 1, 0, 0, 0, 'products/June2018/lptLdLyT8ZrgFpW7H0Fu.jpg', 20, 1, NULL, '2018-06-03 14:13:11'),
(94, 'D235', 'Kem nền trang điểm Mira (30ml)', 'b600nkemnentrangdiemmira-relax-8341.jpg', 'null', 236250, 315000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kem nền trang điểm MIRA Relax Liquid Foundation</strong> c&oacute; t&aacute;c dụng tạo nền cho da, che lấp ho&agrave;n hảo c&aacute;c khuyết điểm Ngo&agrave;i ra c&ograve;n c&oacute; t&aacute;c dụng chống nắng, bảo vệ da Đem lại l&agrave;n da tươi m&aacute;t, kh&ocirc;ng b&oacute;ng nhờn<br /> - Cho vẻ đẹp tự nhi&ecirc;n như c&aacute;nh hoa tươi</p>\r\n<p><strong>Sử dụng</strong>: Lấy một lượng vừa đủ cho ra tay hay b&ocirc;ng phấn, t&aacute;n đều cho đến khi tạo lớp l&oacute;t ho&agrave;n hảo<br /> <strong>Khuyến c&aacute;o</strong>: Ngưng sử dụng ngay khi thấy c&oacute; hiện tượng k&iacute;ch ứng da xảy ra<br /> <strong>HSD</strong>: 3 năm kể từ ng&agrave;y sản xuất<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>Dung t&iacute;ch</strong>: 30ml</p>\r\n</div>', 185, 1, 0, 0, 0, 'products/June2018/qHK6MR0glj28ASloPmux.jpg', 20, 1, NULL, '2018-06-03 14:13:41'),
(95, 'H546', 'Mascara 3D Suri cong dày không thấm nước', 'e321mascara-3d-suri2-3119.jpg', 'null', 80250, 107000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Mascara 3D đang được ưa chuộng nhất H&agrave;n Quốc bởi c&ocirc;ng thức dưỡng mi vượt bậc kết hợp c&ugrave;ng hiệu ứng cong d&agrave;y 3D thời trang Từng sợi mi được bao phủ từ gốc đến ngọn nhờ chổi chuốt mi được thiết kế &ocirc;m s&aacute;t h&agrave;ng mi Kh&ocirc;ng thấm nước nhưng dễ d&agrave;ng tẩy trang m&agrave; kh&ocirc;ng cần đến dung dịch tẩy trang chuy&ecirc;n dụng<br /> <strong>Sử dụng: </strong>D&ugrave;ng bấm mi để tạo độ cong nhẹ cho mi Sau đ&oacute;, d&ugrave;ng mascara chuốt đều tay từ trong gốc mi Chuốt th&ecirc;m một hoặc nhiều lần để tạo độ d&agrave;y v&agrave; d&agrave;i như &yacute;<br /> <strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm&nbsp;<br /> <strong>Bảo quản:</strong> Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp<br /> <strong>Khuyến c&aacute;o:</strong> Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng&nbsp;<br /> <strong>NSX&amp;Lot: </strong>In tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD:</strong> 02 năm (06 th&aacute;ng sau khi mở nắp)<br /> <strong>Khối lượng tịnh:</strong> 8ml<br /> <strong>Xuất xứ: </strong>H&agrave;n Quốc<br /> <strong>NK&amp;PP:</strong> C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n</div>', 231, 1, 0, 0, 0, 'products/June2018/ccSO1j30qDkBMvT4C8qh.jpg', 20, 1, NULL, '2018-06-03 14:15:25'),
(96, 'D213', 'Màu mắt sáp Mira', 'maumatsapmirab521-1590.jpg', 'null', 42750, 57000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Mắt s&aacute;p MIRA Eyeshadow</strong> d&ugrave;ng trang điểm mắt, tạo hiệu ứng cho mắt, với m&agrave;u mắt s&aacute;p kim tuyến MIRA cho bạn đ&ocirc;i mắt đẹp long lanh<br /> Sự lựa chọn của chuy&ecirc;n gia trang điểm</p>\r\n<p><strong>- Sử dụng</strong>: D&ugrave;ng cọ t&aacute;n đều m&agrave;u mắt l&ecirc;n v&ugrave;ng mi mắt cần trang điểm<br /> <strong>- Khuyến c&aacute;o</strong>: Ngưng sử dụng khi thấy hiện tượng k&iacute;ch ứng da<br /> <strong>- Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>- Trọng lượng</strong>: 4g<br /> <strong>- HSD</strong>: 3 năm, 12 th&aacute;ng sau khi mở nắp<br /> - Th&ocirc;ng tin chi tiết được in tr&ecirc;n vỏ hộp sản phẩm</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/ADSRGtaJOSEDT7Q05Jqo.jpg', 20, 1, NULL, '2018-06-03 14:16:11'),
(97, 'G322', 'Kem nền CC Cream 5in1 Mira (25ml)', 'kemccmiracolorcorrectioncream25ml14712576226475362d858d23a16f45379c4314629e82de240zoom-8612.jpg', 'null', 144750, 193000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kem CC MIRA Color Correction Cream</strong> hiệu chỉnh sắc da, che phủ mịn m&agrave;ng<br /> Với c&ocirc;ng thức điều chế cải tiến độc đ&aacute;o, kem CC được xem l&agrave; thế hệ vượt trội hơn so với kem BB về chất lượng cũng như c&ocirc;ng dụng<br /> <strong>5 C&ocirc;ng dụng của kem CC:</strong><br /> * L&agrave;m s&aacute;ng da<br /> * Cung cấp độ ẩm<br /> * Che phủ mịn m&agrave;ng<br /> * Giảm vết nhăn, khuyết điểm<br /> * Cải thiện cấu tr&uacute;c da (dưỡng da)<br /> &gt;&gt; Chỉ số SPF 30 PA +++ bảo vệ da an to&agrave;n dưới &aacute;nh nắng Kem CC l&agrave; lựa chọn th&ocirc;ng minh của bạn g&aacute;i hiện đại, gi&uacute;p bạn g&aacute;i tiết kiệm thời gian trang điểm nhưng vẫn lu&ocirc;n rạng rỡ</p>\r\n<p><strong>Sử dụng</strong>: d&ugrave;ng một lượng vừa đủ t&aacute;n đều l&ecirc;n da mặt, c&oacute; thể d&ugrave;ng th&ecirc;m phấn phủ<br /> <strong>Lưu &yacute;</strong>: để nơi tho&aacute;ng m&aacute;t, tr&aacute;nh &aacute;nh nắng Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>HSD</strong>: 3 năm (12 th&aacute;ng sau khi mở nắp)<br /> <strong>Thể t&iacute;ch thực</strong>: 25ml</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/NoybpeLqaeicuZg1V91r.jpg', 20, 1, NULL, '2018-06-03 14:17:14'),
(98, 'T235', 'Kem lót BB đa chức năng Mira (40ml)', 'b499kemlotbbmiradachucnang2-4321.jpg', 'null', 182250, 243000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Kem BB đa chức năng MIRA Jewel wrinkle care &amp; whitening</strong> được sử dụng như một giải ph&aacute;p tổng hợp trong trang điểm<br /> - Kem l&oacute;t BB Mira đa chức năng chứa nhiều th&agrave;nh phần l&agrave;m dịu, dưỡng ẩm v&agrave; l&agrave;m s&aacute;ng da hiệu quả Gi&uacute;p bạn đạt kết quả tối đa để c&oacute; một l&agrave;n da tỏa s&aacute;ng Ngo&agrave;i c&ocirc;ng dụng l&agrave; kem l&oacute;t với độ chống nắng SPF 50 chống tia cực t&iacute;mkem c&ograve;n c&oacute; th&ecirc;m chức năng che khuyết điểm, l&agrave;m trắng da v&agrave; ngăn ngừa nếp nhăn hiệu quả<br /> - C&ocirc;ng thức chế tạo đặt biệt th&iacute;ch hợp cho mọi loại da, nhẹ nh&agrave;ng thấm h&uacute;t s&acirc;u v&agrave;o da kh&ocirc;ng để lại cảm gi&aacute;c b&oacute;ng nhờn hoặc th&ocirc; r&aacute;p<br /> - Da sẽ trắng mịn tự nhi&ecirc;n như da thật<br /> - <strong>Sử dụng</strong>: D&ugrave;ng một lượng vừa đủ, t&aacute;n đều khắp mặt cho kem thấm hết v&agrave;o da Sau đ&oacute; tiếp tục c&aacute;c bước trang điểm kh&aacute;c<br /> - Đặc biệt, nếu th&iacute;ch &ldquo;gu&rdquo; trang điểm đơn giản, nhẹ nh&agrave;ng th&igrave; c&oacute; thể sử dụng m&aacute; hồng ngay sau khi sử dụng Kem l&oacute;t BB đa chức năng MIRA Jewel wrinkle care&amp;whitening kh&ocirc;ng cần th&ecirc;m lớp phấn<br /> - <strong>Dung t&iacute;ch</strong>: 40ml<br /> - <strong>Xuất xứ</strong>: H&agrave;n quốc</p>\r\n</div>', 171, 1, 0, 0, 0, 'products/June2018/O7MtVZimEY9HPyHs7GkY.png', 20, 1, NULL, '2018-06-03 14:17:56'),
(99, 'E561', 'Gel kẻ mắt nước Mira', 'gelkematnuocmiranew-3717.jpg', 'null', 64500, 86000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Gel kẻ mắt nước MIRA Gel eyeliner kẻ m&iacute; mắt dạng gel mềm cho bạn đường viền m&iacute; mắt tự nhi&ecirc;n m&agrave; vẫn sắc n&eacute;t với độ b&aacute;m m&agrave;u cao, kh&ocirc;ng lem, kh&ocirc;ng bết d&iacute;nh, dễ d&agrave;ng tẩy rữa<br /> - Sản phẩm c&oacute; cọ k&egrave;m theo tiện lợi khi sử dụng<br /> - D&ugrave;ng cọ tạo n&eacute;t vẽ dọc theo đường cong s&aacute;t m&iacute; mắt (C&oacute; thể d&ugrave;ng cọ thấm một &iacute;t nước)<br /> - HSD: 02 năm (Sử dụng tốt nhất trong 6 th&aacute;ng sau khi mở nắp)<br /> - Xuất xứ: H&agrave;n Quốc<br /> - Khuyến c&aacute;o: Ngưng sử dụng ngay khi thấy c&oacute; dấu hiệu k&iacute;ch ứng<br /> - Th&ocirc;ng tin chi tiết được in bao b&igrave; sản phẩm</p>\r\n</div>', 181, 1, 0, 0, 0, 'products/June2018/io6YI0Sdoygw3m1gY0jT.jpg', 20, 1, NULL, '2018-06-03 14:18:51'),
(100, 'E232', 'Phấn nước CC Mira', 'b630cccreamcushion-9196.jpg', 'null', 204000, 272000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong>Mira Cushion Air CC Cream</strong> thuộc dạng phấn lỏng, khi phủ l&ecirc;n da sẽ tạo n&ecirc;n lớp m&agrave;ng mịn phủ sương trong suốt Phấn nước c&oacute; chứa th&agrave;nh phần ngăn loang mồ h&ocirc;i, kiềm dầu tốt gi&uacute;p l&agrave;n da căng mịn tươi trẻ, đồng thời cung cấp nước, dưỡng ẩm cho da mang lại vẻ đẹp tự nhi&ecirc;n v&agrave; nhẹ nh&agrave;ng chăm s&oacute;c da hằng ng&agrave;y Chỉ số chống nắng SPF30+ gi&uacute;p bảo vệ da khỏi t&aacute;c động từ c&aacute;c yếu tố m&ocirc;i trường, &aacute;nh nắng Được sử dụng l&agrave;m lớp nền trang điểm Trang điểm đơn giản chỉ cần một lớp phấn v&agrave; phủ nhẹ lớp phấn hồng, bạn đ&atilde; c&oacute; vẻ b&ecirc;n ngo&agrave;i tươi s&aacute;ng<br /> <strong>Sử dụng</strong>: D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều Cần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn<br /> <strong>Bảo quản</strong>: Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp&nbsp;<br /> <strong>Khuyến c&aacute;o</strong>: Để xa tầm tay trẻ em Ngưng sử dụng nếu c&oacute; hiện tượng k&iacute;ch ứng<br /> <strong>NSX&amp;Lot</strong>: In tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>HSD</strong>: 03năm<br /> <strong>Thể t&iacute;ch</strong>: 15g<br /> <strong>Xuất xứ</strong>: H&agrave;n Quốc<br /> <strong>NK, ĐG&amp;PP</strong>: C&ocirc;ng ty TNHH Mỹ Phẩm MIRA &nbsp;<br /> <strong>Số CB</strong> : 24935/16/CBMP-QLD &nbsp;</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/UAWbCSQi9FzXm6UBMEea.jpg', 20, 1, NULL, '2018-06-03 14:19:10'),
(101, 'D546', 'Kem tẩy trang dưỡng da nha đam MIK@VONK Aloe vera make up remover cream', 'e295kem-tay-trang-duong-da-nha-dam-mikvonk-aloe-vera-make-up-remover-cream-246.png', 'null', 48000, 64000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>- Kem tẩy trang dưỡng da nha đam MIK@VONK Aloe vera make up remover cream loại bỏ lớp trang điểm đồng thời l&agrave;m sạch s&acirc;u lớp bụi bẩn tr&ecirc;n bề mặt da<br /> - Nồng độ pH trong nha đam duy tr&igrave; mức c&acirc;n bằng tự nhi&ecirc;n cho da mềm mại, mịn m&agrave;ng ngay sau khi tẩy trang</p>\r\n</div>', 183, 1, 0, 0, 0, 'products/June2018/QIoStj9dst8U5L98R1tU.jpeg', 20, 1, NULL, '2018-06-03 14:19:28'),
(102, 'A466', 'Phấn nước giữ ẩm che phủ toàn diện SPF 50++', 'k0121moist-perfect-cover21-9200.png', 'null', 403000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Th&agrave;nh phần gi&agrave;u dưỡng chất chiết xuất từ thực vật cung cấp độ ẩm dồi d&agrave;o cho da nhưng kiềm dầu tối đa Khả năng che phủ to&agrave;n diện, x&oacute;a mờ nếp nhăn, vết th&acirc;m, đốm đỏ đem đến l&agrave; da căng mọng, mướt mịn đồng m&agrave;u tự nhi&ecirc;n Phấn chống nắng hữu hiệu với chỉ số SPF 50+<br /> <strong>Sử dụng:</strong> D&ugrave;ng b&ocirc;ng phấn ấn nhẹ v&agrave;o miếng nệm m&uacute;t để lấy phấn, sau đ&oacute; d&ugrave;ng b&ocirc;ng phấn t&aacute;n đều phấn l&ecirc;n da v&agrave; vỗ nhẹ để phấn mịn đều hơnCần đ&oacute;ng hộp lại ngay sau mỗi lần lấy phấn để tr&aacute;nh l&agrave;m kh&ocirc; phấn<br /> <strong>Th&agrave;nh phần: </strong>Xem tr&ecirc;n bao b&igrave; sản phẩm<br /> <strong>Bảo quản:</strong> Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp Nếu kem d&iacute;nh v&agrave;o mắt, rửa lại bằng nước sạch<br /> <strong>Khuyến c&aacute;o: </strong>Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n</div>', 178, 1, 0, 0, 0, 'products/June2018/pTbL4yskx6FlPj3ezHrN.jpg', 20, 1, NULL, '2018-06-03 14:20:02'),
(103, 'D135', 'Bút lông Kbloom', 'k0043but-long-kbloom-24h-2815.png', 'null', 63000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 185, 1, 0, 0, 0, 'products/June2018/D04OMPlLPyRaiNJEaxZ3.png', 20, 1, NULL, '2018-06-03 14:20:20'),
(104, 'D969', 'Viết kẻ mày + mí Kbloom #02', 'k0051viet-ke-may-mi-kbloom-02-3663.png', 'null', 37000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 170, 1, 0, 0, 0, 'products/June2018/x09xF7pm75lwmOYf3Qg4.png', 17, 1, NULL, '2018-06-03 14:20:42'),
(105, 'D235', 'Viết kẻ mày + mí Kbloom #01', 'k0050viet-ke-may-mi-kbloom-01-2797.png', 'null', 37000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 176, 1, 0, 0, 0, 'products/June2018/vtBLRDqvefMDXTTVmL8b.jpg', 12, 1, NULL, '2018-06-03 14:21:10'),
(106, 'D267', 'Khăn giấy lụa ướt tẩy trang, kháng khuẩn cao cấp (100 tờ/gói)', 'k0083khan-giay-uot-100-mieng-3032.png', 'null', 42000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\">Khăn giấy lụa cao cấp được l&agrave;m từ vải tơ kh&ocirc;ng dệt, kh&ocirc;ng xơ chứa vitamin E, nước tinh khiết v&agrave; th&agrave;nh phần kh&aacute;ng khuẩn Khăn gi&uacute;p tẩy sạch lớp trang điểm, lớp bụi bẩn b&aacute;m s&acirc;u dưới lỗ ch&acirc;n l&ocirc;ng, đồng thời vẫn duy tr&igrave; độ ẩm cần thiết v&agrave; ngăn mụn Khăn giấylụa ướt tẩy trang gi&uacute;p phụ nữ tiết kiệm thời gian tẩy trang nhưng vẫn duy tr&igrave; l&agrave;n da sạch, khỏe</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Th&agrave;nh phần:</span>&nbsp;Vải kh&ocirc;ng dệt, &eacute;p kim</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">NSX:</span>&nbsp;In tr&ecirc;n bao b&igrave;</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Khối lượng:</span>&nbsp;200mm x 200mm , 100 tờ/g&oacute;i</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Bảo quản:</span>&nbsp;Nơi kh&ocirc;, m&aacute;t Tr&aacute;nh tầm tay trẻ em</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">HSD:</span>&nbsp;In tr&ecirc;n bao b&igrave; (2 th&aacute;ng sau khi mở nắp sử dụng)</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; color: #000000; font-family: Helvetica;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Xuất xứ: H&agrave;n Quốc</span></p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/SCCbw57VrQBpz08PkukU.png', 20, 1, NULL, '2018-06-03 14:22:11'),
(107, 'D533', 'Khăn giấy lụa ướt tẩy trang, kháng khuẩn cao cấp (30 tờ/gói)', 'k0082khan-giay-uot-30-mieng-8680.png', 'null', 24000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Khăn giấy lụa cao cấp được l&agrave;m từ vải tơ kh&ocirc;ng dệt, kh&ocirc;ng xơ chứa vitamin E, nước tinh khiết v&agrave; th&agrave;nh phần kh&aacute;ng khuẩn&nbsp; Khăn gi&uacute;p tẩy sạch lớp trang điểm, lớp bụi bẩn b&aacute;m s&acirc;u dưới lỗ ch&acirc;n l&ocirc;ng, đồng thời vẫn duy tr&igrave; độ ẩm cần thiết v&agrave; ngăn mụn Khăn giấylụa ướt tẩy trang gi&uacute;p phụ nữ tiết kiệm thời gian tẩy trang nhưng vẫn duy tr&igrave; l&agrave;n da sạch, khỏe</p>\r\n<p><strong>Th&agrave;nh phần:</strong> Vải kh&ocirc;ng dệt,&eacute;p kim</p>\r\n<p><strong>NSX:</strong> In tr&ecirc;n bao b&igrave;</p>\r\n<p><strong>Khối lượng:</strong> 200mm x 200mm , 30 tờ/g&oacute;i</p>\r\n<p><strong>Bảo quản:</strong> Nơi kh&ocirc;, m&aacute;t Tr&aacute;nh tầm tay trẻ em</p>\r\n<p><strong>HSD:</strong>&nbsp; In tr&ecirc;n bao b&igrave; (2 th&aacute;ng sau khi mở nắp sử dụng)</p>\r\n<p><strong>Xuất xứ: H&agrave;n Quốc</strong></p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/JP7XaFbOeuk45uWuNcTU.jpg', 20, 1, NULL, '2018-06-03 14:22:33'),
(108, 'O365', 'Bông tẩy trang không dệt, ép biên 2 mặt Suboon (200 miếng)', 'k0118bong-tay-trang-200pcs-2898.png', 'null', 49000, 54000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>200 miếng b&ocirc;ng được l&agrave;m từ vải kh&ocirc;ng dệt, 2 mặt, &eacute;p kim tinh tế,tuyệt đối kh&ocirc;ng để lại xơ tr&ecirc;n da v&agrave; tiết kiệm tối da dung dịch dưỡng da, dung dịch tẩy trang C&oacute; thể sử dụng để lau sạch lớp sơn m&oacute;ng tay/ch&acirc;n<br /> <strong>Sử Dụng: </strong>Thấm dung dịch tẩy trang / dưỡng da l&ecirc;n miếng b&ocirc;ng v&agrave; lau nhẹ nh&agrave;ng<br /> <strong>Th&agrave;nh phần: </strong>In tr&ecirc;n bao b&igrave;<br /> <strong>Bảo quản:</strong> Nơi kh&ocirc;, m&aacute;t Tr&aacute;nh tầm tay trẻ em<br /> <strong>Nhập khẩu: </strong>H&agrave;n Quốc<br /> <strong>ĐG&amp;PP: </strong>CN C&ocirc;ng ty TNHH Mỹ Phẩm MIRA</p>\r\n<p>&nbsp;</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/pug543brx1CrlZb3yhYT.jpg', 0, 1, NULL, '2018-06-03 14:22:53'),
(109, 'E236', 'Mặt Nạ Tẩy Tế Bào Chết Tối Ưu Chiết Xuất Hoa Hồng -  Innisfree Capsule Recipe Pack 10ml', 'mat-na-tay-te-bao-chet-toi-uu-chiet-xuat-hoa-hong-innisfree-9030.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ chiết xuất hoa hồng gi&uacute;p dễ d&agrave;ng loại bỏ những tế b&agrave;o da chết trong l&uacute;c massage tr&ecirc;n da Tinh chất hoa hồng trong mặt nạ gi&uacute;p da ẩm mịn, trắng s&aacute;ng hơn sau khi sử dụng, Đặc biệt kh&ocirc;ng g&acirc;y kh&ocirc; da, ph&ugrave; hợp mọi loại da</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><span style=\"background-color: #ffffff;\"><span style=\"font-size: 144px;\"><span style=\"font-family: helvetica;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</span></span></span></p>\r\n<p><strong>Sử dụng: </strong>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, sau 10 ph&uacute;t rửa lại mặt bằng nước ấm</p>\r\n<p style=\"text-align: justify;\"><strong>Bảo quản:</strong> Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"text-align: justify;\"><strong>Khuyến c&aacute;o: </strong>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"text-align: justify;\"><strong>NSX&amp;Lot:</strong> In dưới đ&aacute;y chai<strong> HSD</strong>: 03năm</p>\r\n<p style=\"text-align: justify;\"><strong>Thể t&iacute;ch thực:</strong> 10ml</p>\r\n<p style=\"text-align: justify;\"><strong>Thương hiệu</strong>: Innisfree</p>\r\n<p style=\"text-align: justify;\"><strong>Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/McwXRnVIYoNbD4SEA2cV.jpg', 30, 1, NULL, '2018-06-03 14:23:17'),
(110, 'A323', 'Mặt nạ ngủ, dưỡng trắng da chiết xuất gạo (Phù hợp da khô, da thường) - Innisfree Capsule Recipe Pack 10ml', 'mat-na-ngu-duong-trang-da-chiet-xuat-gao-3332.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><strong><span style=\"font-weight: normal;\">Mặt nạ</span></strong> chiết xuất gạo cung cấp chất dinh dưỡng gi&uacute;p da trắng s&aacute;ng căng mịn Kết cấu kh&aacute; đặc n&ecirc;n chỉ thoa một lớp mỏng</p>\r\n<p><span style=\"text-align: justify;\"><span style=\"background-color: #ffffff;\"><span style=\"font-size: 144px;\"><span style=\"font-family: helvetica;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</span></span></span></span></p>\r\n<p><strong>Sử dụng: </strong>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"text-align: justify;\"><strong>Bảo quản:</strong> Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"text-align: justify;\"><strong>Khuyến c&aacute;o: </strong>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"text-align: justify;\"><strong>NSX&amp;Lot:</strong> In dưới đ&aacute;y chai<strong> HSD</strong>: 03năm</p>\r\n<p style=\"text-align: justify;\"><strong>Thể t&iacute;ch thực:</strong> 10ml</p>\r\n<p style=\"text-align: justify;\"><strong>Thương hiệu</strong>: Innisfree</p>\r\n<p style=\"text-align: justify;\"><strong>Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n</div>', 178, 1, 0, 0, 0, 'products/June2018/l1dPRiHcdwr3PNISL3Zn.jpg', 30, 1, NULL, '2018-06-03 14:28:47'),
(111, 'A698', 'Mặt nạ kiềm dầu, se khít lỗ chân lông chiết xuất tro núi lửa Volcanic (Phù hợp da dầu, da hỗn hợp) - Innisfree Capsule Recipe Pack 10ml', 'mat-na-kiem-dau-se-khit-lo-chan-long-chiet-xuat-tro-nui-lua-volcanic-1562.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Mặt nạ chứa th&agrave;nh phần được chắt lọc từ nham thạch nguội sau khi n&uacute;i lửa phun tr&agrave;o, c&oacute; t&aacute;c dụng hấp thu lượng b&atilde; nhờn ẩn tr&ecirc;n da, se kh&iacute;t lỗ ch&acirc;n l&ocirc;ng, cung cấp độ ẩm v&agrave; ngăn mụn</p>\r\n<p>&nbsp;</p>\r\n<p style=\"padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify; margin: initial initial 00001pt initial;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Sử dụng:&nbsp;</span>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Bảo quản:</span>&nbsp;Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Khuyến c&aacute;o:&nbsp;</span>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">NSX&amp;Lot:</span>&nbsp;In dưới đ&aacute;y chai<span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">&nbsp;HSD</span>: 03năm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Thể t&iacute;ch thực:</span>&nbsp;10ml</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Thương hiệu</span>: Innisfree</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; background-color: #ffffff; text-align: justify;\"><span style=\"margin: 0px; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-weight: bold;\">Xuất xứ</span>: H&agrave;n Quốc</p>\r\n</div>', 179, 1, 0, 0, 0, 'products/June2018/yzBwMVnTgybmGPxlxklw.jpg', 30, 1, NULL, '2018-06-03 14:35:53'),
(112, 'D323', 'Mặt nạ ngủ dưỡng ẩm ngăn mụn chiết xuất trà xanh - Innisfree Capsule Recipe Pack 10ml', 'mat-na-ngu-duong-am-ngan-mun-chiet-xuat-tra-xanh-3595.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ được chiết xuất từ l&aacute; tr&aacute; xanh được trồng tr&ecirc;n đảo Jeju Axit amin v&agrave; kho&aacute;ng chất từ l&aacute; tr&agrave; gi&uacute;p giữ ẩm cho da, kh&aacute;ng khuẩn, ngăn mụn</p>\r\n<p style=\"padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify; margin: initial initial 00001pt initial;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Sử dụng:&nbsp;</span></span>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Bảo quản:</span></span>&nbsp;Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Khuyến c&aacute;o:&nbsp;</span></span>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">NSX&amp;Lot:</span></span>&nbsp;In dưới đ&aacute;y chai<span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">&nbsp;HSD</span></span>: 03năm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thể t&iacute;ch thực:</span></span>&nbsp;10ml</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thương hiệu</span></span>: Innisfree</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Xuất xứ</span></span>: H&agrave;n Quốc</p>\r\n</div>', 188, 1, 0, 0, 0, 'products/June2018/MiLb9xIHxfvq1O3OuV9W.jpg', 30, 1, NULL, '2018-06-03 14:38:16');
INSERT INTO `products` (`id`, `code_product`, `name`, `slug`, `details`, `price`, `price_in`, `price_promotion`, `description`, `brand_id`, `category_id`, `featured`, `new`, `hot_price`, `image`, `quanity`, `status`, `created_at`, `updated_at`) VALUES
(113, 'D522', 'Mặt nạ ngủ dưỡng ẩm dành cho da mụn chiết xuất Bija & Aloe - Innisfree Capsule Recipe Pack 10ml', 'mat-na-ngu-duong-am-danh-cho-da-mun-chiet-xuat-bija-aloe-8914.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ được chiết xuất từ quả Bija được nu&ocirc;i trồn tại đảo Jeju chuy&ecirc;n d&agrave;nh cho da mụn Mặt nạ chiết xuất từ Bija v&agrave; nha đam ngo&agrave;i t&aacute;c dụng dưỡng da dịu m&aacute;t c&ograve;n gi&uacute;p phục hồi v&agrave; ngăn mụn trở lại</p>\r\n<p style=\"padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify; margin: initial initial 00001pt initial;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Sử dụng:&nbsp;</span></span>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Bảo quản:</span></span>&nbsp;Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Khuyến c&aacute;o:&nbsp;</span></span>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">NSX&amp;Lot:</span></span>&nbsp;In dưới đ&aacute;y chai<span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">&nbsp;HSD</span></span>: 03năm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thể t&iacute;ch thực:</span></span>&nbsp;10ml</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thương hiệu</span></span>: Innisfree</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">&nbsp;</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Xuất xứ</span></span>: H&agrave;n Quốc</p>\r\n</div>', 2, 1, 0, 0, 0, 'products/June2018/pApn0F8ptDmxgXeooVBg.jpg', 30, 1, NULL, '2018-06-03 14:38:46'),
(114, 'D232', 'Mặt nạ ngủ chiết xuất quả Aronia trẻ hóa da - Innisfree Capsule Recipe Pack 10ml', 'mat-na-ngu-chiet-xuat-qua-aronia-tre-hoa-da-4920.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ được chiết xuất từ quả Aronia, thuộc d&ograve;ng họ Berries, c&oacute; t&aacute;c dụng chống oxy h&oacute;a, dưỡng da săn chắc, mịn m&agrave;ng, tươi s&aacute;ng Kết cấu mềm, nhẹ, thẩm thấu nhanh Sản phẩm ph&ugrave; hợp mọi loại da</p>\r\n<p style=\"padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify; margin: initial initial 00001pt initial;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Sử dụng:&nbsp;</span></span>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Bảo quản:</span></span>&nbsp;Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Khuyến c&aacute;o:&nbsp;</span></span>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">NSX&amp;Lot:</span></span>&nbsp;In dưới đ&aacute;y chai<span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">&nbsp;HSD</span></span>: 03năm</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thể t&iacute;ch thực:</span></span>&nbsp;10ml</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Thương hiệu</span></span>: Innisfree</p>\r\n<p style=\"margin: initial; padding: 0px; box-sizing: border-box; border: 0px; font-size: 144px; font-family: Helvetica; text-align: justify;\"><span style=\"padding: 0px; box-sizing: border-box; border: 0px; font-weight: bold;\"><span style=\"font-size: 144px;\">Xuất xứ</span></span>: H&agrave;n Quốc</p>\r\n</div>', 190, 1, 0, 0, 0, 'products/June2018/GDwZbRAjVjdoUZZsbrAl.jpg', 30, 1, NULL, '2018-06-03 14:44:01'),
(115, 'D356', 'Mặt Nạ Ngủ Chiết Xuất Từ Tre Giảm Nhiệt, Dịu Mát Da - Innisfree Capsule Recipe Pack 10ml', 'mat-na-ngu-chiet-xuat-tu-tre-giam-nhiet-diu-mat-da-9256.png', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ được tinh chế từ nước tre tinh khiết gi&uacute;p l&agrave;m dịu da ngay tức th&igrave; v&agrave; cung cấp độ ẩm tối ưu Kết cấu mềm, nhẹ, thẩm thấu nhanh đem đến cảm gi&aacute;c dịu m&aacute;t, sảng kho&aacute;i Sản phẩm ph&ugrave; hợp mọi loại da</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ được thiết kế dạng &ldquo;hũ sữa chua&rdquo; nhỏ tiện dụng, c&oacute; nắp đậy k&iacute;n Mỗi hộp mặt nạ c&oacute; thể d&ugrave;ng 2-3 lần, rất tiết kiệm</p>\r\n<p><strong>Sử dụng: </strong>Rửa mặt sạch, lấy một lượng th&iacute;ch hợp thoa đều nhẹ nh&agrave;ng l&ecirc;n mặt, để nguy&ecirc;n trạng th&aacute;i đi ngủ v&agrave; rửa mặt v&agrave;o s&aacute;ng h&ocirc;m sau</p>\r\n<p style=\"text-align: justify;\"><strong>Bảo quản:</strong> Đậy nắp lại sau khi sử dụng Bảo quản để nơi xa tầm tay trẻ em Để nơi tho&aacute;ng m&aacute;t Tr&aacute;nh &aacute;nh nắng trực tiếp N&ecirc;n bảo quản trong tủ lạnh sau khi sử dụng lần đầu Một hộp c&oacute; thể d&ugrave;ng 2-3 lần</p>\r\n<p style=\"text-align: justify;\"><strong>Khuyến c&aacute;o: </strong>Kh&ocirc;ng được u&ocirc;́ng Đ&ecirc;̉ xa tầm tay trẻ em Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"text-align: justify;\"><strong>NSX&amp;Lot:</strong> In dưới đ&aacute;y chai<strong> HSD</strong>: 03năm</p>\r\n<p style=\"text-align: justify;\"><strong>Thể t&iacute;ch thực:</strong> 10ml</p>\r\n<p style=\"text-align: justify;\"><strong>Thương hiệu</strong>: Innisfree</p>\r\n<p style=\"text-align: justify;\"><strong>Xuất xứ</strong>: H&agrave;n Quốc</p>\r\n<p>&nbsp;</p>\r\n</div>', 190, 1, 0, 0, 0, 'products/June2018/aQEscxFQkyC1NPmyFwk9.jpg', 30, 1, NULL, '2018-06-03 14:45:03'),
(116, 'A456', 'Mặt Nạ Trắng Da, Loại Bỏ Bã Nhờn, Se Khít Lỗ Chân Lông Chiết Xuất Cám Gạo - Innisfree My Real Squeeze Mask - Rice', 'mat-na-cham-soc-da-innisfree-tu-gao-3202.png', 'null', 19000, 26000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ mềm mại, độ đ&agrave;n hồi cao, gi&uacute;p da dễ d&agrave;ng hấp thu dưỡng chất khi sử dụng Được chiết xuất từ 100% c&aacute;m gạo chứa axit phytic c&oacute; t&aacute;c dụng hỗ trợ loại bỏ da chết, b&atilde; nhờn Tinh chất c&aacute;m gạo c&ograve;n gi&uacute;p se kh&iacute;t lỗ ch&acirc;n l&ocirc;ng, dưỡng da trắng s&aacute;ng mịn m&agrave;ng</p>\r\n<p style=\"text-align: justify; margin: 60pt 0in 0001pt 0in;\"><strong>C&aacute;ch d&ugrave;ng: </strong>Rửa mặt sạch bằng sữa rửa mặt Mở g&oacute;i, đắp miếng mặt nạ l&ecirc;n da từ 20-30 ph&uacute;t Gỡ bỏ mặt ra, d&ugrave;ng ng&oacute;n tay massage nhẹ nh&agrave;ng theo chiều xoắn ốc để tinh chất c&ograve;n đọng lại thẩm thấu v&agrave;o da Rửa lại mặt bằng nước sạch</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Bảo quản:</strong> Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khuyến c&aacute;o:</strong> Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm <strong>HSD: </strong>03 năm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khối lượng tịnh:</strong> 20ml/mi&ecirc;́ng <strong>Xuất Xứ:</strong> H&agrave;n Quốc&nbsp;&nbsp;</p>\r\n</div>', 170, 1, 0, 0, 0, 'products/June2018/LPpu8n2Pg37hQeavVKCn.jpg', 10, 1, NULL, '2018-06-03 14:45:20'),
(117, 'D335', 'Mặt Nạ Loại Bỏ Tế Bào Chết, Trắng Da Chiết Xuất Yến Mạch - Innisfree My Real Squeeze Mask - Oatmeal', 'mat-na-innisfree-ngu-coc-7172.jpg', 'null', 19000, 26000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\">Mặt nạ mềm mại, độ đ&agrave;n hồi cao, gi&uacute;p da dễ d&agrave;ng hấp thu dưỡng chất khi sử dụng Được chiết xuất từ 100% yến mạch gi&agrave;u chất dinh dưỡng Dưỡng chất từ yến mạch gi&uacute;p da trắng s&aacute;ng hơn mỗi ng&agrave;y, loại bỏ tế b&agrave;o chết, mụn c&aacute;m tr&ecirc;n da m&agrave; kh&ocirc;ng g&acirc;y kh&ocirc; da</p>\r\n<p style=\"text-align: justify; margin: 60pt 0in 0001pt 0in;\"><strong>C&aacute;ch d&ugrave;ng: </strong>Rửa mặt sạch bằng sữa rửa mặt Mở g&oacute;i, đắp miếng mặt nạ l&ecirc;n da từ 20-30 ph&uacute;t Gỡ bỏ mặt ra, d&ugrave;ng ng&oacute;n tay massage nhẹ nh&agrave;ng theo chiều xoắn ốc để tinh chất c&ograve;n đọng lại thẩm thấu v&agrave;o da Rửa lại mặt bằng nước sạch</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Bảo quản:</strong> Nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khuyến c&aacute;o:</strong> Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm <strong>HSD: </strong>03 năm</p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong>Khối lượng tịnh:</strong> 20ml/mi&ecirc;́ng <strong>Xuất Xứ:</strong> H&agrave;n Quốc&nbsp;&nbsp;</p>\r\n<p>&nbsp;</p>\r\n</div>', 174, 1, 0, 0, 0, 'products/June2018/eWeXjuKwHXuDogri2kzX.jpg', 10, 1, NULL, '2018-06-03 14:45:37'),
(118, 'D986', 'Sữa Trẻ Hóa Trắng Da Tinh Chất Sữa Non - 3W Clinic Crystal White Milky Lotion 150g', '3w-clinic-crystal-white-milky-lotion-2736.jpg', 'null', 210000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p><span style=\"font-family: times new roman,serif;\">Tinh chất sữa non kết hợp c&ugrave;ng kho&aacute;ng chất v&agrave; vitamin dưỡng da trắng mịn sau mỗi lần sử dụng Kết cấu sữa dưỡng cực nhẹ, thẩm thấu s&acirc;u v&agrave;o từng tế b&agrave;o, kh&ocirc;ng chỉ dưỡng trắng an to&agrave;n, sữa c&ograve;n cung cấp dưỡng ẩm, se kh&iacute;t lỗ ch&acirc;n l&ocirc;ng Sữa kh&ocirc;ng chứa dầu kho&aacute;ng, kh&ocirc;ng chứa benzo phenone, kh&ocirc;ng phenoxyethanol, kh&ocirc;ng chứa paraben, an to&agrave;n cho da, ph&ugrave; hợp mọi loại da</span></p>\r\n<p style=\"background: #F5F1E5;\"><strong><span style=\"font-size: 110pt;\">Sử dụng:</span></strong> <span style=\"font-size: 110pt;\">Sau khi rửa mặt hoặc tắm Lau kh&ocirc; người Lấy một lượng vừa đủ thoa l&ecirc;n mặt hoặc phần cơ thể muốn l&agrave;m trắng, sau đ&oacute; massage nhẹ nh&agrave;ng 2-3 ph&uacute;t để kem thẩm thấu v&agrave;o da Sử dụng cho cả mặt v&agrave; to&agrave;n th&acirc;n</span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">Th&agrave;nh phần:</span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\"> Xem tr&ecirc;n bao b&igrave; sản phẩm </span></span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">Bảo quản:</span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\"> Để nơi kh&ocirc;, tho&aacute;ng Tr&aacute;nh &aacute;nh nắng trực tiếp</span></span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">Khuyến c&aacute;o:</span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\"> Ngưng d&ugrave;ng khi c&oacute; dấu hiệu dị ứng</span></span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">NSX&amp;Lot:</span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\"> Được in tr&ecirc;n bao b&igrave; sản phẩm</span></span></p>\r\n<p style=\"margin-bottom: 0001pt; text-align: justify;\"><strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\">HSD:</span></span></strong><span style=\"font-family: times new roman,serif;\"><span style=\"font-size: 120pt;\"> 03 năm( 12 th&aacute;ng sau khi mở nắp) <strong>Khối lượng tịnh:</strong> 150g</span></span></p>\r\n</div>', 189, 1, 0, 0, 0, 'products/June2018/WtK68TmWGYfKNJJyc94C.jpg', 10, 1, NULL, '2018-06-03 14:45:52'),
(119, 'D632', 'Sữa Rửa Mặt Nam Ngừa Mụn & Kháng Khuẩn 50g - Mens Biore Facial Foam Acne Defense', 'ngan-ngua-mun-100g-4820.jpg', 'null', 35000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 185, 1, 0, 0, 0, 'products/June2018/1mLqtTqOkTlgUEKml3ob.jpg', 6, 1, NULL, '2018-06-03 14:46:08'),
(120, 'A356', 'Sữa Rửa Mặt Nam Tác Động Kép Sạch Sâu Da Trông Sáng Khỏe 100g - Mens Biore Double Scrub Facial Foam White Energy', 'nam-trang-da-nam-tinh-6007.jpg', 'null', 36000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 173, 1, 0, 0, 0, 'products/June2018/MdUbe5iomCKlKSK0RvbE.jpg', 6, 1, NULL, '2018-06-03 14:46:23'),
(121, 'D569', 'Sữa Rửa Mặt Nam Tác Động Kép Sạch Sâu 50g - Mens Biore Double Scrub Facial Foam Deep Action', 'nam-tac-dong-kep-sach-sau-1901.jpg', 'null', 35000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 190, 1, 0, 0, 0, 'products/June2018/N7Khal5brWbKrv6a3ZAU.jpg', 6, 1, NULL, '2018-06-03 14:46:41'),
(122, 'Q231', 'Sữa Rửa Mặt Nam Tác Động Kép Sạch Sâu 100g - Mens Biore Double Scrub Facial Foam Deep Action', 'nam-tac-dong-kep-sach-sau-1632.jpg', 'null', 55000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 184, 1, 0, 0, 0, 'products/June2018/hgu3tpAGdSOYiTqpxZZ4.jpg', 5, 1, NULL, '2018-06-03 14:46:59'),
(123, 'D138', 'Sữa Rửa Mặt Nam Tác Động Kép Sạch Sâu Cực Mát Lạnh 50g - Mens Biore Double Scrub Facial Foam Deep Action Extra Cool', 'nam-tac-dong-kep-sach-sau-mat-lanh-1334.jpg', 'null', 35000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 181, 1, 0, 0, 0, 'products/June2018/KvSfeO3feqEyOvv144pK.jpg', 6, 1, NULL, '2018-06-03 14:47:17'),
(124, 'B356', 'Sữa Rửa Mặt Nam Tác Động Kép Sạch Sâu Cực Mát Lạnh 100g - Mens Biore Double Scrub Facial Foam Deep Action Extra Cool', 'nam-tac-dong-kep-sach-sau-mat-lanh-2352.jpg', 'null', 55000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 181, 1, 0, 0, 0, 'products/June2018/a2DpNCw7u8ufwBcOlfV3.jpg', 5, 1, NULL, '2018-06-03 14:47:45'),
(125, 'E565', 'Sữa Rửa Mặt Nam Ngừa Mụn & Kháng Khuẩn 100g - Mens Biore Facial Foam Acne Defense', 'ngan-ngua-mun-100g-6416.jpg', 'null', 55000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 187, 1, 0, 0, 0, 'products/June2018/Th6BH6qkbbZgrn2jvnLf.jpg', 5, 1, NULL, '2018-06-03 14:49:39'),
(126, 'F659', 'Chống Nắng Cực Mạnh - Super Block SPF 81+ 30g', 'super-block-spf-81-683.jpg', 'null', 71000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 2, 1, 0, 0, 0, 'products/June2018/afwphpIsggfBYNId58t6.jpg', 10, 1, NULL, '2018-06-03 14:50:00'),
(127, 'D556', 'Chống Nắng Dưỡng Ẩm Da - Out-Going SPF 50+ 30g', 'out-going-spf-50-6879.jpg', 'null', 58000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 185, 1, 0, 0, 0, 'products/June2018/qzdvkLT78zrnrFB0mqed.jpg', 2, 1, NULL, '2018-06-03 14:50:33'),
(128, 'D364', 'Chống Nắng Cho Bé - Baby Mild SPF 35+ 30g', 'baby-milk-spf-35-8004.jpg', 'null', 69000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 188, 1, 0, 0, 0, 'products/June2018/kv0QD8NuL1oK3JIghErd.jpg', 2, 1, NULL, '2018-06-03 14:50:56'),
(129, 'D236', 'Chống Nắng Dưỡng Trắng Da - Whiterning UV SPF 50+ 30g', 'whiterning-uv-spf-50-1413.jpg', 'null', 69000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 188, 1, 0, 0, 0, 'products/June2018/pLqi7DKQ4q0XFKfJQUkS.jpg', 2, 1, NULL, '2018-06-03 14:51:30'),
(130, 'T366', 'Sữa Chống Nắng Dưỡng Da Ẩm Mịn - Skin Aqua UV Moisture Milk SPF 50+ 30g', 'skin-aqua-uv-moisture-milk-spf-50-2767.jpg', 'null', 78000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 176, 1, 0, 0, 0, 'products/June2018/m7WZuVlsykiCCrr4RCGw.jpg', 2, 1, NULL, '2018-06-03 14:51:57'),
(131, 'R356', 'Chống Nắng Mạnh, Giải Nhiệt Da - Super Cool SPF 50', 'super-cool-spf-50-5158.jpg', 'null', 69000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 180, 1, 0, 0, 0, 'products/June2018/B0HzTfucaAEyYpAXfASD.jpg', 2, 1, NULL, '2018-06-03 14:52:32'),
(132, 'D698', 'Sữa Chống Nắng Dưỡng Da Trắng Mịn - Skin Aqua Clear White SPF 50', 'skin-aqua-clear-white-spf-50-9392.jpg', 'null', 94000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 175, 1, 0, 0, 0, 'products/June2018/4aj5YBjgZJmzTq4H3uXL.jpg', 2, 1, NULL, '2018-06-03 14:52:54'),
(133, 'A653', 'Tinh Chất Chống Nắng Dưỡng Da Trắng Mịn - Skin Aqua Silky White Essence SPF 50+ PA 25g', 'skin-aqua-silky-white-essence-spf50-4406.jpg', 'null', 93000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 188, 1, 0, 0, 0, 'products/June2018/otZgTEQm4Ry4xVM4ooYm.jpg', 2, 1, NULL, '2018-06-03 14:53:45'),
(134, 'H556', 'Sữa Chống Nắng Dưỡng Da Ngừa Mụn - Skin Aqua Acne Clear Milk SPF 50', 'skin-aqua-acne-clear-milk-spf-50-6198.jpg', 'null', 94000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 187, 1, 0, 0, 0, 'products/June2018/40qkSC0wAM9I1WVX6gV0.png', 2, 1, NULL, '2018-06-03 14:54:03'),
(135, 'P355', 'Gel Chống Nắng Dưỡng Da Trắng Mịn - Skin Aqua Silky White Gel SPF50', 'skin-aqua-silky-white-gel-spf-32-956.jpg', 'null', 79000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 181, 1, 0, 0, 0, 'products/June2018/pJ6cqxKfY0yFi7Cm8fOf.png', 2, 1, NULL, '2018-06-03 14:54:28'),
(136, 'I323', 'Kem Chống Mũi Đốt Remos', 'kem-chong-mui-dot-remos-8488.png', 'null', 25000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 178, 1, 0, 0, 0, 'products/June2018/thluZ59UfXkuQV660igK.jpg', 2, 1, NULL, '2018-06-03 14:55:07'),
(137, 'O233', 'Sữa Chống Nắng Tạo Nền Trắng Mịn (Ngăn Sặm Đen, Dưỡng Trắng Mịn) - Skin Aqua SPF 50 Cc Milk', 'skin-aqua-spf50-cc-milk-8073.jpg', 'null', 95000, 50000, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 183, 1, 0, 0, 1, 'products/June2018/ELmcp5voXJpiOVE3U0Q9.jpg', 1, 1, NULL, '2018-06-03 17:16:06'),
(138, 'L633', 'Kem Đặc Trị Dưỡng Ẩm, Chống Lão Hóa Laneige - Laneige Time Freeze Intensive Cream 10ml', 'kem-dac-tri-duong-am-chong-lao-hoa-laneige-3577.jpg', 'null', 22000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 182, 1, 0, 0, 0, 'products/June2018/I9txnOkYtVjekSB9MSzd.jpg', 25, 1, NULL, '2018-06-03 14:55:52'),
(139, 'K365', 'Kem Nghệ Beaumore - Beaumore Turmeric Cream 10g', 'kem-nghe-beaumore10g-5158.jpg', 'null', 39000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Kem nghệ đặc trị mụn &amp; sẹo th&acirc;m l&agrave;m tan biến c&aacute;c vết sẹo th&acirc;m do mụn để lại, đồng thời ngăn ngừa hiệu quả sự h&igrave;nh th&agrave;nh của mụn đầu đen Chiết xuất từ tinh chất củ nghệ v&agrave; vitamin (A &amp; E) bổ sung th&ecirc;m năng lượng cho c&aacute;c tế b&agrave;o da, thấm s&acirc;u v&agrave; k&iacute;ch th&iacute;ch sự ph&aacute;t triển của c&aacute;c tế b&agrave;o da mới</p>\r\n<p><strong>C&aacute;ch d&ugrave;ng:&nbsp;</strong>Sau khi rửa mặt sạch sẽ, lấy một lượng vừa đủ để thoa l&ecirc;n vết sẹo th&acirc;m hoặc chỗ đau Sử dụng h&agrave;ng ng&agrave;y, tốt nhất v&agrave;o buổi tối trước khi đi ngủ, sẽ đem lại hiệu quả nhanh</p>\r\n<p><em><u>Lưu &yacute;</u>: T&aacute;c dụng c&oacute; thể kh&aacute;c nhau t&ugrave;y cơ địa mỗi người</em></p>\r\n<p><strong>&nbsp;Xuất xứ:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thương hiệu: BEAUMORE</strong></p>\r\n</div>', 182, 1, 0, 0, 0, 'products/June2018/7aFFPwXQtoTdOaDWxkAK.png', 15, 1, NULL, '2018-06-03 14:56:27'),
(140, NULL, 'Kem Nghệ Beaumore - Beaumore Turmeric Cream 40g', 'kem-nghe-beaumore-40g-4974.jpg', 'null', 99000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Kem nghệ đặc trị mụn &amp; sẹo th&acirc;m l&agrave;m tan biến c&aacute;c vết sẹo th&acirc;m do mụn để lại, đồng thời ngăn ngừa hiệu quả sự h&igrave;nh th&agrave;nh của mụn đầu đen Chiết xuất từ tinh chất củ nghệ v&agrave; vitamin (A &amp; E) bổ sung th&ecirc;m năng lượng cho c&aacute;c tế b&agrave;o da, thấm s&acirc;u v&agrave; k&iacute;ch th&iacute;ch sự ph&aacute;t triển của c&aacute;c tế b&agrave;o da mới</p>\r\n<p><strong>C&aacute;ch d&ugrave;ng:&nbsp;&nbsp;</strong>Sau khi rửa mặt sạch sẽ, lấy một lượng vừa đủ để thoa l&ecirc;n vết sẹo th&acirc;m hoặc chỗ đau Sử dụng h&agrave;ng ng&agrave;y, tốt nhất v&agrave;o buổi tối trước khi đi ngủ, sẽ đem lại hiệu quả nhanh</p>\r\n<p><em><u>Lưu &yacute;</u>: T&aacute;c dụng c&oacute; thể kh&aacute;c nhau t&ugrave;y cơ địa mỗi người</em></p>\r\n<p><strong>&nbsp;Xuất xứ:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thương hiệu: BEAUMORE</strong></p>\r\n</div>', 2, 1, 0, 0, 0, 'products/June2018/uTmw96ciMWrlmoHO6kjI.png', 10, 1, NULL, '2018-06-03 14:39:25'),
(141, 'C235', 'Sữa Rửa Mặt Mango Usa - Beaumore Mango Mandarin Scrub 120g', 'sua-rua-mat-mango-usa-6784.jpg', 'null', 79000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 188, 1, 0, 0, 1, 'products/June2018/B3suNztUlkE7X68ZlBLO.jpg', 10, 1, NULL, '2018-06-03 14:57:47'),
(142, 'G236', 'Mặt Nạ Bột Aloe - Aloe Modeling Mask 100g', 'mat-na-bot-aloe-5420.jpg', 'null', 72000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 178, 1, 0, 0, 1, 'products/June2018/nhZYMCBdtYJDuI8evjbU.png', 10, 1, NULL, '2018-06-03 14:58:05'),
(143, 'Y236', 'Mặt Nạ Bột Collagen - Collagen Modeling Mask 100g', 'mat-na-bot-collagen-2716.jpg', 'null', 72000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 179, 1, 0, 0, 0, 'products/June2018/5RaMiMweZzITBsw8MhcS.jpg', 10, 1, NULL, '2018-06-03 14:58:19'),
(144, 'S236', 'Mặt Nạ Bột Vitamin C - Vitamin C Modeling Mask 100g', 'mat-na-bot-vitaminc100g-7956.jpg', 'null', 72000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 184, 1, 0, 0, 0, 'products/June2018/kfLr3bs5K6QT565MAupZ.jpg', 5, 1, NULL, '2018-06-03 14:58:34'),
(145, 'D365', 'Mặt Nạ Beaumore Collagen', 'mat-na-beaumore-collagen-1923.jpg', 'null', 18000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 184, 1, 0, 0, 0, 'products/June2018/m3Uv8FJflufxnn7eA3mm.png', 20, 1, NULL, '2018-06-03 15:01:19'),
(146, 'Q236', 'Tinh Dầu Massage Olive - Sandras Olive Body Essential Oil 88ml', 'tinh-dau-massage-olive-4093.jpg', 'null', 72000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 179, 1, 0, 0, 1, 'products/June2018/4PcIgtk9HWl9PGapa0jt.jpg', 10, 1, NULL, '2018-06-03 14:59:16'),
(147, 'W134', 'Tinh Dầu Massage Nha Đam - Sandras Aloe Body Essential Oil 88ml', 'tinh-dau-massage-nha-dam-2745.jpg', 'null', 72000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">&nbsp;</div>', 184, 1, 0, 0, 0, 'products/June2018/fRJRReJSm0j4S2iVZ4aI.jpg', 10, 1, NULL, '2018-06-03 14:59:46'),
(148, 'R236', 'Kem Làm Đẹp Từ Linh Chi Và Đông Trùng Hạ Thảo - Sandras Beauty Lingzhi Cordyceps Sinensis Beauty Cream 15g', 'kem-lingzhi15g-726.png', 'null', 800000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p style=\"text-align: justify;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"color: black;\">Với sự kết hợp độc đ&aacute;o của c&aacute;c loại thảo mộc tự nhi&ecirc;n v&agrave; c&aacute;c vitamin, đ&ocirc;ng tr&ugrave;ng hạ thảo c&oacute; t&aacute;c dụng hoạt huyết, c&oacute; khả năng l&agrave;m tăng tốc lưu lượng m&aacute;u</span> Gi&uacute;p <span style=\"color: black;\">suy giảm chất catecholamine do l&atilde;o h&oacute;a cũng như c&aacute;c tổn thương do &aacute;nh nắng mặt trời g&acirc;y ra</span></span></span></p>\r\n<p style=\"text-align: justify;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"color: black;\">K&iacute;ch hoạt sự ph&acirc;n b&agrave;o v&agrave; h&igrave;nh th&agrave;nh tế b&agrave;o mới, đồng thời c&oacute; c&aacute;c dụng dưỡng da, l&agrave;m </span></span></span></p>\r\n<p style=\"text-align: justify;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"color: black;\">chậm qu&aacute; tr&igrave;nh l&atilde;o h&oacute;a, x&oacute;a mờ những đốm n&acirc;u hoặc t&agrave;n nhang tr&ecirc;n da một c&aacute;ch tự&nbsp;</span></span></span><span style=\"color: black; font-family: arial, helvetica, sans-serif; font-size: 14px;\">nhi&ecirc;n</span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Sử dụng:</strong> Lấy một lượng kem vừa đủ thoa đều l&ecirc;n da c&aacute;c v&ugrave;ng mặt, cổ sau khi rửa mặt sạch</span></span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Th&agrave;nh phần:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</span></span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Bảo quản</strong>: Nơi kh&ocirc; thoáng Tránh ánh nắng trực ti&ecirc;́p</span></span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Khuy&ecirc;́n cáo:</strong> Ngưng sử dụng khi thấy c&oacute; d&acirc;́u hi&ecirc;̣u dị ứng da Kh&ocirc;ng sử dụng ở c&aacute;c v&ugrave;ng da bị trầy xước hay vết thương hở Tr&aacute;nh xa tầm tay trẻ em, đ&oacute;ng nắp kỹ sau khi sử dụng</span></span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>NSX&amp;Lot:</strong> Xem tr&ecirc;n bao b&igrave; sản phẩm</span></span></p>\r\n<p style=\"margin-bottom: 0001pt;\"><span style=\"font-size: 14px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>HSD:</strong> 02 năm (24 th&aacute;ng sau khi mở nắp) <strong>Xu&acirc;́t xứ:</strong> Mỹ</span></span></p>\r\n<p>&nbsp;</p>\r\n</div>', 182, 1, 0, 0, 1, 'products/June2018/eoVKxND5ShfVRo3ph8zC.png', 3, 1, NULL, '2018-06-03 15:00:12'),
(149, 'D259', 'Kem Nghệ Nhật - Beaumore Pure Turmeric Cream 20ml', 'kem-nghe-nhat-7671.jpg', 'null', 68000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>Kem nghệ đặc trị mụn &amp; sẹo th&acirc;m chiết xuất từ tinh chất củ nghệ v&agrave; vitamin (A &amp; E) bổ sung th&ecirc;m năng lượng cho c&aacute;c tế b&agrave;o da, thấm s&acirc;u v&agrave; k&iacute;ch th&iacute;ch sự ph&aacute;t triển của c&aacute;c tế b&agrave;o da mới</p>\r\n<p><strong>C&aacute;ch d&ugrave;ng:&nbsp;</strong>Sau khi rửa mặt sạch sẽ, lấy một lượng vừa đủ để thoa l&ecirc;n vết sẹo th&acirc;m hoặc chỗ đau Sử dụng h&agrave;ng ng&agrave;y, tốt nhất v&agrave;o buổi tối trước khi đi ngủ, sẽ đem lại hiệu quả nhanh</p>\r\n<p><strong>&nbsp;Xuất xứ:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thương hiệu: BEAUMORE</strong></p>\r\n</div>', 191, 1, 0, 0, 1, 'products/June2018/anuneI6TVeVTrIOtuQlO.jpg', 0, 1, NULL, '2018-06-03 15:00:45'),
(150, NULL, 'Sữa Rửa Mặt Nghệ Nhật - Beaumore Turmeric Facial Cleanser 100g', 'sua-rua-mat-nghe-nhat100g-586.jpg', 'null', 149000, 0, 0, '<div class=\"noidung_ta\" style=\"clear: left;\">\r\n<p>L&agrave;m sạch da, kh&aacute;ng khuẩn, giữ ẩm, mềm mịn da Giải quyết c&aacute;c vấn đề về mụn, l&agrave;m giảm vết th&acirc;m gi&uacute;p da trắng s&aacute;ng, mịn m&agrave;ng</p>\r\n<p><strong>C&aacute;ch d&ugrave;ng:&nbsp;</strong>Lấy 1 lượng vừa đủ cho v&agrave;o l&ograve;ng b&agrave;n tay, sau đ&oacute; thoa v&agrave; massage nhẹ nh&agrave;ng l&ecirc;n mặt từ 1-2 ph&uacute;t rồi rửa lại bằng nước sạch Sử dụng từ 1-2 lần/ng&agrave;y</p>\r\n<p><strong>&nbsp;Xuất xứ:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thương hiệu: BEAUMORE</strong></p>\r\n</div>', 180, 1, 0, 0, 1, 'products/June2018/pcvfwjn9xxOt9YDpAXCq.jpg', 10, 1, NULL, '2018-06-03 15:01:43'),
(151, 'B633333', 'Khay son lì Mira Hydro Shine 33 ', '33-khay-sson-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 9, 1, NULL, NULL),
(152, 'B63333333', 'Khay son lì Mira Hydro Shine 333 ', '33-khay-sson-li-mira-220643', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 0, 1, NULL, NULL),
(500, 'B636s5654', 'Khay son lì Mira Hydro Shine B63656ssss54 ', 'B636sss565-khay-son-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 9, 1, NULL, NULL),
(502, 'nh0005', 'Khay son lì Mira Hydro Shine nh0005 ', 'nh0005-khay-sson-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 9, 1, NULL, NULL),
(503, 'nh0006', 'Khay son lì Mira Hydro Shine nh0006 ', 'nh0006-khay-sson-li-mira-22064', 'null khong co', 96750, 129000, 0, 'Không có !!!', 225, 1, 1, 0, 1, 'products/June2018/Ba0jgp3eeSwQ7wuxWlA2.png', 15, 1, NULL, NULL);

--
-- Triggers `products`
--
DELIMITER $$
CREATE TRIGGER `Tg_CapNhat_TinhTrang_SanPham` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
	   
		DECLARE idd int(10) ;       
        
		 SET idd = new.id; -- products
		 
        
		IF( (select products.quanity from products where products.id = idd )=0 and (select products.status from products where products.id = idd) = 1 ) then
			 update products set products.status = 0 where products.id = idd limit 1;
         END IF ;	
         
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã vai trò',
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên vai trò',
  `display_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên vai trò hiển thị',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `display_name`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'Administrator', '2018-05-31 22:21:40', '2018-05-31 22:21:40'),
(2, 'user_manager', 'User Manager', '2018-05-31 22:21:40', '2018-06-02 23:26:28'),
(3, 'customer', 'Khách hàng', '2018-06-03 03:04:08', '2018-06-03 03:04:08'),
(4, 'hr', 'Quản lý nhân sự', '2018-06-05 19:18:56', '2018-06-05 19:18:56');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã cài đặt',
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Khóa cài đặt',
  `display_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên hiển thị',
  `value` text COLLATE utf8mb4_unicode_ci COMMENT 'Giá trị',
  `details` text COLLATE utf8mb4_unicode_ci COMMENT 'Chi tiết',
  `type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại dữ liệu',
  `order` int(11) NOT NULL DEFAULT '1',
  `group` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nhóm'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `key`, `display_name`, `value`, `details`, `type`, `order`, `group`) VALUES
(1, 'site.title', 'Site Title', 'Site Title', '', 'text', 1, 'Site'),
(2, 'site.description', 'Site Description', 'Site Description', '', 'text', 2, 'Site'),
(3, 'site.logo', 'Site Logo', '', '', 'image', 3, 'Site'),
(4, 'site.google_analytics_tracking_id', 'Google Analytics Tracking ID', NULL, '', 'text', 4, 'Site'),
(5, 'admin.bg_image', 'Admin Background Image', 'settings/June2018/zDjxFIj954ZtJwj0yM60.jpg', '', 'image', 5, 'Admin'),
(6, 'admin.title', 'Admin Title', 'ADMIN', '', 'text', 1, 'Admin'),
(7, 'admin.description', 'Admin Description', 'Đồ án phát triền ứng dụng web', '', 'text', 2, 'Admin'),
(8, 'admin.loader', 'Admin Loader', 'settings/June2018/SVvhnoMWFAPKxJUeTYA4.gif', '', 'image', 3, 'Admin'),
(9, 'admin.icon_image', 'Admin Icon Image', 'settings/June2018/UrDdFru2RyPb2PRjetV2.png', '', 'image', 4, 'Admin'),
(10, 'admin.google_analytics_client_id', 'Google Analytics Client ID (used for admin dashboard)', '705351013753-qhqql7bjebibjnbio3iemn5m388fb6rj.apps.googleusercontent.com', '', 'text', 1, 'Admin');

-- --------------------------------------------------------

--
-- Table structure for table `slides`
--

CREATE TABLE `slides` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã slide',
  `image` varchar(191) NOT NULL COMMENT 'Đường dẫn hình ảnh',
  `link` varchar(191) NOT NULL COMMENT 'Đường dẫn đi',
  `title` varchar(191) DEFAULT NULL COMMENT 'Tiêu đề',
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Trạng thái',
  `category_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã danh mục',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `slides`
--

INSERT INTO `slides` (`id`, `image`, `link`, `title`, `status`, `category_id`, `created_at`, `updated_at`) VALUES
(1, 'slides/June2018/OSdYSSGCwLFfzfjx96rz.jpg', 'http://uit.thietkewebneda.com/danh-muc/1', NULL, 1, NULL, '2018-06-03 00:04:45', '2018-06-03 00:04:45'),
(2, 'slides/June2018/FNky9aNlfMox7lGOQzxG.jpg', '#', NULL, 1, NULL, '2018-06-03 00:05:27', '2018-06-03 00:05:27'),
(3, 'slides/June2018/RsO8OxbFpnWZu46MMIXS.jpg', '#', NULL, 1, NULL, '2018-06-03 00:05:44', '2018-06-03 00:05:44'),
(4, 'slides/June2018/bVNBlRZNwAAehFjvZZE9.jpg', '#', NULL, 1, NULL, '2018-06-03 00:05:57', '2018-06-03 00:05:57'),
(5, 'slides/June2018/hWzopnspzGIKRidtM1fW.jpg', '#', NULL, 0, NULL, '2018-06-03 00:05:58', '2018-06-03 00:09:04'),
(6, 'slides/June2018/GidPajmhOUDqK2d9yPVN.jpg', '#', NULL, 0, NULL, '2018-06-03 00:07:03', '2018-06-03 00:07:03'),
(7, 'slides/June2018/cTrxDzIorhp7nskG0t8h.jpg', '#', NULL, 0, NULL, '2018-06-03 00:08:17', '2018-06-03 00:08:17'),
(8, 'slides/June2018/xRf5jYqmRcrgWKNcKPZj.jpg', '#', NULL, 0, NULL, '2018-06-03 00:08:34', '2018-06-03 00:08:34'),
(9, 'slides/June2018/PUuHVvgrt0u6sBpn2XCx.jpg', 'Chuwa cso', NULL, 1, 1, '2018-06-03 00:08:51', '2018-06-03 00:08:51');

-- --------------------------------------------------------

--
-- Table structure for table `translations`
--

CREATE TABLE `translations` (
  `id` int(10) UNSIGNED NOT NULL,
  `table_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `column_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foreign_key` int(10) UNSIGNED NOT NULL,
  `locale` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `translations`
--

INSERT INTO `translations` (`id`, `table_name`, `column_name`, `foreign_key`, `locale`, `value`, `created_at`, `updated_at`) VALUES
(1, 'data_types', 'display_name_singular', 5, 'pt', 'Post', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(2, 'data_types', 'display_name_singular', 6, 'pt', 'Página', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(3, 'data_types', 'display_name_singular', 1, 'pt', 'Utilizador', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(4, 'data_types', 'display_name_singular', 4, 'pt', 'Categoria', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(5, 'data_types', 'display_name_singular', 2, 'pt', 'Menu', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(6, 'data_types', 'display_name_singular', 3, 'pt', 'Função', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(7, 'data_types', 'display_name_plural', 5, 'pt', 'Posts', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(8, 'data_types', 'display_name_plural', 6, 'pt', 'Páginas', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(9, 'data_types', 'display_name_plural', 1, 'pt', 'Utilizadores', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(10, 'data_types', 'display_name_plural', 4, 'pt', 'Categorias', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(11, 'data_types', 'display_name_plural', 2, 'pt', 'Menus', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(12, 'data_types', 'display_name_plural', 3, 'pt', 'Funções', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(13, 'categories', 'slug', 1, 'pt', 'categoria-1', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(14, 'categories', 'name', 1, 'pt', 'Categoria 1', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(15, 'categories', 'slug', 2, 'pt', 'categoria-2', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(16, 'categories', 'name', 2, 'pt', 'Categoria 2', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(17, 'pages', 'title', 1, 'pt', 'Olá Mundo', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(18, 'pages', 'slug', 1, 'pt', 'ola-mundo', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(19, 'pages', 'body', 1, 'pt', '<p>Olá Mundo. Scallywag grog swab Cat o\'nine tails scuttle rigging hardtack cable nipper Yellow Jack. Handsomely spirits knave lad killick landlubber or just lubber deadlights chantey pinnace crack Jennys tea cup. Provost long clothes black spot Yellow Jack bilged on her anchor league lateen sail case shot lee tackle.</p>\r\n<p>Ballast spirits fluke topmast me quarterdeck schooner landlubber or just lubber gabion belaying pin. Pinnace stern galleon starboard warp carouser to go on account dance the hempen jig jolly boat measured fer yer chains. Man-of-war fire in the hole nipperkin handsomely doubloon barkadeer Brethren of the Coast gibbet driver squiffy.</p>', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(20, 'menu_items', 'title', 1, 'pt', 'Painel de Controle', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(21, 'menu_items', 'title', 2, 'pt', 'Media', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(22, 'menu_items', 'title', 12, 'pt', 'Publicações', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(23, 'menu_items', 'title', 3, 'pt', 'Utilizadores', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(24, 'menu_items', 'title', 11, 'pt', 'Categorias', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(25, 'menu_items', 'title', 13, 'pt', 'Páginas', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(26, 'menu_items', 'title', 4, 'pt', 'Funções', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(27, 'menu_items', 'title', 5, 'pt', 'Ferramentas', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(28, 'menu_items', 'title', 6, 'pt', 'Menus', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(29, 'menu_items', 'title', 7, 'pt', 'Base de dados', '2018-05-31 22:21:41', '2018-05-31 22:21:41'),
(30, 'menu_items', 'title', 10, 'pt', 'Configurações', '2018-05-31 22:21:41', '2018-05-31 22:21:41');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL COMMENT 'Mã tài khoản',
  `role_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Mã vai trò',
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên',
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên đăng nhập',
  `avatar` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT 'users/June2018/w56bI0JYedPQbZaESHmp.png' COMMENT 'Đường dẫn ảnh đại diện',
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mật khẩu',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `settings` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày tạo',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role_id`, `name`, `email`, `avatar`, `password`, `remember_token`, `settings`, `created_at`, `updated_at`) VALUES
(1, 1, 'Admin', 'admin@admin.com', 'users/June2018/FPB9DkNdC1fOrDHVEMUf.png', '$2y$10$pmPKkcijXczF5E6SeLGZB.sBC/8j.vt21FuFKUfYfaTX34mC.uqv6', '4ATichsB5PA5BUVvUos53bZZksfLefF18I2q4wgp50oww5FanQbjW2Cysg8Q', NULL, '2018-05-31 22:21:41', '2018-06-05 19:00:06'),
(2, 2, 'Thành Đạt', 'thanhdat@gmail.com', 'users/June2018/m1K0fT12dmr0FOhfwIIn.png', '$2y$10$0ApSnDkwd/jmc/5sCJIYt.7fNgKQAM.viW/UBoLs7VtkxAkdeu6SO', NULL, '{\"locale\":\"en\"}', '2018-06-02 23:17:00', '2018-06-05 19:01:55'),
(22, 3, 'hiệp nguyễn hoàng', 'vuabip2000@gmail.com', 'users/June2018/l2ILbN5Fo9vDLZXJ2qrb.jpg', '$2y$10$hJliwYGgXN8LmdCDPPZmFO1D63rPO0up.RIoDGcx9wcyA1uPB3pHC', NULL, NULL, NULL, '2018-06-05 19:04:00'),
(23, 3, 'test', 'test@test.com', 'users/June2018/AMPGXgxnJ9RSfnkprrEN.png', '$2y$10$yXcCBVbVwgfRcPzZVotv1uuHTgT2Yrc8C33KkVY4qmhllkuraSH2q', 'Si1u6QIZqYT4JLFw6rel8nYLTlZscnaBPoowQsnTOvxPvuXezWuSDSRzDIs0', NULL, '2018-06-03 19:25:06', '2018-06-05 19:01:44'),
(24, 3, 'test2', 'tets2@test.com', 'users/June2018/4y3MDOY1abgBzDb8cHsJ.png', '$2y$10$kkmGJ.gw2oSatgE7r3Q7be/eZlWqSPMVfkO4typ4LSQZpQRAmcBlq', NULL, NULL, '2018-06-03 19:28:53', '2018-06-03 19:28:53'),
(25, 3, 'test3', 'test3@test.com', 'users/June2018/QUChHqJ5eveGGKZR3jN9.png', '$2y$10$.WpXrpJhBI/LtZ9c7.LXqenC4xKNlxjspAKogqLhPVr8P0bxFmRhu', NULL, NULL, NULL, '2018-06-05 19:04:11'),
(26, 3, 'test12', 'test12@gmail.com', 'users/June2018/VdIdFAK0VW7WbXDoCVUJ.png', '$2y$10$p2Umi0Gmj..lNTS40gbKX.nYxDySRcit5FsTk3MtH5aNiiouAVpj.', NULL, NULL, NULL, '2018-06-05 19:04:31'),
(27, 3, 'test', 'test13@gmail.com', 'users/June2018/w56bI0JYedPQbZaESHmp.png', '$2y$10$jRxhv7HnK2bk0AMUlyYD5.0lMeceli2dTnjaRj./kSAoAE1ZPMBfG', '5NWo6R0fEP1Fktp0PhWhiWD8KcIIo3aZsY803GJM94rHgZRz2peTr0xE4wgr', NULL, NULL, NULL),
(28, 3, 'test14', 'test14@gmail.com', 'users/June2018/w56bI0JYedPQbZaESHmp.png', '$2y$10$5SyrUz3jqaXvWeS2wFQoW.LUTMMVCr08f1.vjt8RZNIMYRnpUaC6e', 'ZMeE7Rjs6TJofuqgmQHVZXMIBPXWdfjOXyeo2o7Nf2aPla2MXLhBXdona29x', NULL, NULL, '2018-06-05 19:04:44'),
(29, 3, 'test15', 'test15@gmail.com', 'users/June2018/WcvfHOr9k4IVuJzFAQSY.png', '$2y$10$4tpuNbMBlNHzLjiN.Y83ROrrafh1E74ph0fRNW0opDValLz9gSSi2', '3sBHzFPS6f0YEsrwR6V2wuKB2VPXkIozDZXVqeavGwdjEpjOge53lLzIAirS', NULL, NULL, '2018-06-05 19:09:52'),
(30, 4, 'hr', 'hr@gmail.com', 'users/June2018/HcLSVvfc91uA4MsjrGUt.jpg', '$2y$10$gNv3qVtV6gBoe8dzqz97xOB/CPC/6g992U.qhyQT11nnlgiceHcC6', 'jO4aywHqmKEkUTKof0di8Airga3MBJjRtkeGKrKa10viYuu9CAKnmQTa4Eo7', NULL, '2018-06-05 19:15:51', '2018-06-05 19:19:52'),
(31, 3, 'Lý Đạt', 'dat.ly.dev@gmail.com', 'users/June2018/w56bI0JYedPQbZaESHmp.png', '$2y$10$D7iRe695ZNLJlwKVkDcpLuN3wDSZF3GGvg.5MBKuRa/UnERB.82GW', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'Mã tài khoản',
  `role_id` int(10) UNSIGNED NOT NULL COMMENT 'Mã vai trò'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
(2, 2),
(23, 3),
(24, 3),
(30, 4);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brand`
--
ALTER TABLE `brand`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_name_unique` (`name`),
  ADD UNIQUE KEY `category_slug_unique` (`slug`),
  ADD KEY `parent_id` (`parent_id`),
  ADD KEY `sub_id` (`sub_id`);

--
-- Indexes for table `category_product`
--
ALTER TABLE `category_product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_product_product_id_foreign` (`product_id`),
  ADD KEY `category_product_category_id_foreign` (`category_id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coupons_code_unique` (`code`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone_number_unique` (`phone_number`) USING BTREE,
  ADD UNIQUE KEY `user_id_UNIQUE` (`user_id`) USING BTREE,
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `data_rows`
--
ALTER TABLE `data_rows`
  ADD PRIMARY KEY (`id`),
  ADD KEY `data_rows_data_type_id_foreign` (`data_type_id`);

--
-- Indexes for table `data_types`
--
ALTER TABLE `data_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `data_types_name_unique` (`name`),
  ADD UNIQUE KEY `data_types_slug_unique` (`slug`);

--
-- Indexes for table `menus`
--
ALTER TABLE `menus`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `menus_name_unique` (`name`);

--
-- Indexes for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `menu_items_menu_id_foreign` (`menu_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_product`
--
ALTER TABLE `order_product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`) USING BTREE,
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `pages`
--
ALTER TABLE `pages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pages_slug_unique` (`slug`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `permissions_key_index` (`key`);

--
-- Indexes for table `permission_role`
--
ALTER TABLE `permission_role`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `permission_role_permission_id_index` (`permission_id`),
  ADD KEY `permission_role_role_id_index` (`role_id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `posts_slug_unique` (`slug`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `products_name_unique` (`name`),
  ADD UNIQUE KEY `products_slug_unique` (`slug`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_name_unique` (`name`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `settings_key_unique` (`key`);

--
-- Indexes for table `slides`
--
ALTER TABLE `slides`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `translations`
--
ALTER TABLE `translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `translations_table_name_column_name_foreign_key_locale_unique` (`table_name`,`column_name`,`foreign_key`,`locale`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_role_id_foreign` (`role_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_id`,`role_id`),
  ADD KEY `user_roles_user_id_index` (`user_id`),
  ADD KEY `user_roles_role_id_index` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brand`
--
ALTER TABLE `brand`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã thương hiệu', AUTO_INCREMENT=234;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã danh mục', AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT for table `category_product`
--
ALTER TABLE `category_product`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã sản phầm thương hiệu';

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã mã giảm giá', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã khách hàng', AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `data_rows`
--
ALTER TABLE `data_rows`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT for table `data_types`
--
ALTER TABLE `data_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `menus`
--
ALTER TABLE `menus`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã hóa đơn', AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `order_product`
--
ALTER TABLE `order_product`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết hóa đơn', AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `pages`
--
ALTER TABLE `pages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Ma bài viết', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã quyền', AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã sản phẩm', AUTO_INCREMENT=504;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã vai trò', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã cài đặt', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `slides`
--
ALTER TABLE `slides`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã slide', AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `translations`
--
ALTER TABLE `translations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Mã tài khoản', AUTO_INCREMENT=32;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `category`
--
ALTER TABLE `category`
  ADD CONSTRAINT `category_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `category` (`id`),
  ADD CONSTRAINT `category_ibfk_2` FOREIGN KEY (`sub_id`) REFERENCES `category` (`id`);

--
-- Constraints for table `category_product`
--
ALTER TABLE `category_product`
  ADD CONSTRAINT `category_product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `data_rows`
--
ALTER TABLE `data_rows`
  ADD CONSTRAINT `data_rows_data_type_id_foreign` FOREIGN KEY (`data_type_id`) REFERENCES `data_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD CONSTRAINT `menu_items_menu_id_foreign` FOREIGN KEY (`menu_id`) REFERENCES `menus` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `order_product`
--
ALTER TABLE `order_product`
  ADD CONSTRAINT `order_product_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_product_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `permission_role`
--
ALTER TABLE `permission_role`
  ADD CONSTRAINT `permission_role_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `permission_role_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brand` (`id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
