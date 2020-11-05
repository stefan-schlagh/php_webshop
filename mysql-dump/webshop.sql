-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Erstellungszeit: 05. Nov 2020 um 08:50
-- Server-Version: 10.4.15-MariaDB
-- PHP-Version: 7.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `webshop`
--

DELIMITER $$
--
-- Prozeduren
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `createCatTable` (IN `catlist` VARCHAR(255))  NO SQL
BEGIN
	DECLARE i INT DEFAULT 0;
    
	#temporäre Tabelle für Ketgorieliste wird angelegt
    DROP TABLE IF EXISTS tempcat;
    CREATE TEMPORARY TABLE tempcat(
        id INT PRIMARY KEY AUTO_INCREMENT,
        CID INT
    );
    #temporäre Tabelle wird befüllt
    IF (JSON_LENGTH(catlist)>0 && 
        JSON_EXTRACT(catlist,'$[0]') != 0) THEN
        WHILE i < JSON_LENGTH(catlist) DO
            INSERT INTO tempcat (CID) VALUES (JSON_EXTRACT(catlist,CONCAT('$[',i,']')));
            SELECT i+1 INTO i;
        END WHILE;
    ELSE
        INSERT INTO tempcat (CID) SELECT CID FROM category;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createSubCatTable` (IN `subcatlist` VARCHAR(255))  NO SQL
BEGIN
	DECLARE i INT DEFAULT 0;
    
	#temporäre Tabelle für Ketgorieliste wird angelegt
    DROP TABLE IF EXISTS tempsubcat;
    CREATE TEMPORARY TABLE tempsubcat(
        id INT PRIMARY KEY AUTO_INCREMENT,
        SCID INT
    );
    #temporäre Tabelle wird befüllt
    IF (JSON_LENGTH(subcatlist)>0 && 
        JSON_EXTRACT(subcatlist,'$[0]') != 0) THEN
        WHILE i < JSON_LENGTH(subcatlist) DO
            INSERT INTO tempsubcat (SCID) VALUES (JSON_EXTRACT(subcatlist,CONCAT('$[',i,']')));
            SELECT i+1 INTO i;
        END WHILE;
    ELSE
        INSERT INTO tempsubcat (SCID) SELECT SCID FROM subcategory;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertReview` (IN `pidp` INT, IN `uidp` INT, IN `ratingp` INT, IN `reviewTextp` VARCHAR(4000))  NO SQL
INSERT INTO review (PID,UID,Rating,ReviewText,ReviewDate,ReviewTime) 
VALUES (pidp,uidp,ratingp,reviewTextp,CURRENT_DATE(),CURRENT_TIME())$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `orderProducts` (IN `uid1` INT)  NO SQL
BEGIN
	DECLARE bid1 INT DEFAULT 0;
    DECLARE cid1 INT DEFAULT 0;
    
    SELECT cartId INTO cid1 FROM user WHERE UID = uid1;
    
    #neue Bestellung wird angelegt
    INSERT INTO bestellung (UID,Datum,Uhrzeit)
    VALUES (uid1,CURRENT_DATE(),CURRENT_TIME);
    
    #bid wird initialisiert
    SELECT max(BID) INTO bid1 FROM bestellung;
    
    INSERT INTO bestellposition(BID,PID,Menge,PName,PPreis)
	SELECT bid1,c.PID,c.Num,p.Bez,p.Preis
    FROM cart c 
    INNER JOIN produkt p
	ON c.PID = p.PID
    WHERE c.CID = cid1;
    
    #cart wird gelöscht
    DELETE FROM cart WHERE CID = cid1;
    
    #cartid in user wird gelöscht
    UPDATE user SET cartId = '0' WHERE UID = uid1;
    
    SELECT bid1 AS 'bid';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectAllProducts` (IN `catlist` VARCHAR(255), IN `subcatlist` VARCHAR(255), IN `search` VARCHAR(255))  NO SQL
BEGIN
	
    SET @a0 = catlist;
    CALL createCatTable(@a0);
    
    SET @a1 = subcatlist;
    CALL createSubCatTable(@a1);
    
    #Abfrage
    SELECT produkt.PID, produkt.Bez, category.Name AS 'Category', subcategory.Name AS 'SubCategory'
    FROM produkt
    
    INNER JOIN tempcat
    ON produkt.CID = tempcat.CID
    
    INNER JOIN tempsubcat
    ON produkt.SCID = tempsubcat.SCID
    
    INNER JOIN category 
    ON produkt.CID = category.CID
    
    INNER JOIN subcategory
    ON produkt.SCID = subcategory.SCID
    
    WHERE produkt.Bez LIKE CONCAT('%', search, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCart` (IN `uid1` INT)  NO SQL
SELECT user.UID,count(cart.CID) AS 'cart' 
FROM user

INNER JOIN cart 
ON user.cartId = cart.CID

GROUP BY cart.CID
HAVING user.UID = uid1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCartContent` (IN `uid1` INT)  NO SQL
SELECT c.CIID,c.CID,c.PID,c.Num,p.Bez,p.Preis
FROM cart c

INNER JOIN user u
ON c.CID = u.cartId

INNER JOIN produkt p
ON c.PID = p.PID

WHERE u.UID = uid1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectCategorys` (IN `search` VARCHAR(255), IN `catlist` VARCHAR(255))  NO SQL
BEGIN

	SET @a0 = catlist;
    CALL createCatTable(@a0);
    
    #Abfrage
    SELECT category.CID, category.Name, count(produkt.PID) AS 'Anzahl'
    FROM category
    
    LEFT JOIN produkt
    ON category.CID = produkt.CID
    
    INNER JOIN tempcat
    ON category.CID = tempcat.CID
    
    WHERE produkt.Bez LIKE CONCAT('%', search, '%')
    AND EXISTS (SELECT productimage.PIID 
                FROM productimage 
                WHERE productimage.PIID = produkt.PIID)
    GROUP BY category.CID
    
    UNION
    SELECT category.CID, category.Name, '0'
    FROM category
    
    WHERE NOT category.CID = ANY(SELECT produkt.CID 
                        FROM produkt     
                        INNER JOIN tempcat
    					ON produkt.CID = tempcat.CID
                        WHERE Bez LIKE CONCAT('%', search, '%'))
    ORDER BY CID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectPassword` (IN `uname` VARCHAR(30))  NO SQL
SELECT Password FROM user WHERE username = uname$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProductInformation` (IN `pid1` INT)  NO SQL
SELECT p.Bez, p.Preis, p.Gewicht, p.Volumen, p.Beschreibung, 
	productimage.path AS 'ImgSource',
	category.Name AS 'Category',
	subcategory.Name AS 'Subcategory',
    avg(review.Rating) AS 'AvgRating',
    COUNT(review.Rating) AS 'NumRating'

FROM produkt p

INNER JOIN productimage
ON p.PIID = productimage.PIID

INNER JOIN category
ON p.CID = category.CID

INNER JOIN subcategory
ON p.SCID = subcategory.SCID

LEFT JOIN review
ON p.PID = review.PID

GROUP BY p.PID
    
HAVING p.PID = pid1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProductLimit` (IN `search` VARCHAR(255), IN `startValue` INT, IN `length` INT, IN `catlist` VARCHAR(255), IN `subcatlist` VARCHAR(255))  NO SQL
BEGIN

	SET @a0 = catlist;
    CALL createCatTable(@a0);
    
    SET @a1 = subcatlist;
    CALL createSubCatTable(@a1);
    
    SELECT 	
    	produkt.PID,produkt.Bez,produkt.Preis,
        productimage.path AS 'ImgSource' ,
        produkt.CID,category.Name AS 'Category',
        produkt.SCID,subcategory.Name AS 'Subcategory',
        avg(review.Rating) AS AvgRating,
        COUNT(review.Rating) AS NumRating
        
    FROM produkt 

    INNER JOIN productimage 
    ON produkt.PIID = productimage.PIID

    INNER JOIN category 
    ON produkt.CID = category.CID 
    
    INNER JOIN tempcat
    ON produkt.CID = tempcat.CID

    INNER JOIN subcategory 
    ON produkt.SCID = subcategory.SCID 
    
    INNER JOIN tempsubcat
    ON produkt.SCID = tempsubcat.SCID

	LEFT JOIN review
    ON produkt.PID = review.PID
    
    GROUP BY produkt.PID
    
    HAVING Bez LIKE CONCAT('%', search, '%')
    ORDER BY Bez 
    LIMIT startValue,length;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProductLimitShort` (IN `search` VARCHAR(255), IN `start` INT, IN `length` INT)  NO SQL
BEGIN

	SET @a0 = catlist;
    CALL createCatTable(@a0);
    
    SET @a1 = subcatlist;
    CALL createSubCatTable(@a1);

	SELECT produkt.PID,produkt.Bez 
	FROM produkt
	
	
    INNER JOIN tempcat
    ON produkt.CID = tempcat.CID
    
	INNER JOIN tempsubcat
    ON produkt.SCID = tempsubcat.SCID
    
    WHERE Bez LIKE CONCAT('%', search, '%')
	ORDER BY Bez
    LIMIT start,length;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProducts1` (IN `search` VARCHAR(255))  NO SQL
SELECT produkt.PID,produkt.Bez,produkt.Preis,productimage.path AS 'ImgSource' ,produkt.CID,produkt.SCID 
FROM produkt 
INNER JOIN productimage ON produkt.PIID = productimage.PIID 
WHERE Bez LIKE CONCAT('%', search, '%')
ORDER BY Bez$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectProductShort` (IN `search` VARCHAR(255), IN `catlist` VARCHAR(255), IN `subcatlist` VARCHAR(255))  NO SQL
BEGIN

	SET @a0 = catlist;
    CALL createCatTable(@a0);
    
    SET @a1 = subcatlist;
    CALL createSubCatTable(@a1);

	SELECT produkt.PID,produkt.Bez 
	FROM produkt
	
	
    INNER JOIN tempcat
    ON produkt.CID = tempcat.CID
    
	INNER JOIN tempsubcat
    ON produkt.SCID = tempsubcat.SCID
    
    WHERE Bez LIKE CONCAT('%', search, '%')
	ORDER BY Bez;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectReview` (IN `productID` INT, IN `startValue` INT, IN `length` INT)  NO SQL
SELECT r.Rating AS 'Rating', r.ReviewText AS 'ReviewText',
DATE_FORMAT(r.ReviewDate,'%d.%m.%Y') AS 'ReviewDate', r.ReviewTime AS 'ReviewTime',
u.Username AS 'Username'
FROM review r
INNER JOIN user u
ON r.UID = u.UID
WHERE PID = productID
ORDER BY r.ReviewDate DESC, r.ReviewTime DESC 
LIMIT startValue,length$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectSubCategorys` (IN `search` VARCHAR(255), IN `cid1` INT, IN `catlist` VARCHAR(255), IN `subcatlist` VARCHAR(255))  NO SQL
BEGIN
	
    SET @a0 = catlist;
    CALL createCatTable(@a0);
    
	SET @a1 = subcatlist;
    CALL createSubCatTable(@a1);
    
    SELECT subcategory.SCID,subcategory.Name,count(produkt.PID) AS 'Anzahl'
    FROM subcategory
    
    INNER JOIN produkt
    ON subcategory.SCID = produkt.SCID
    
    INNER JOIN tempcat
    ON subcategory.CID = tempcat.CID
    
    INNER JOIN tempsubcat
    ON subcategory.SCID = tempsubcat.SCID
    
    WHERE produkt.Bez LIKE CONCAT('%', search, '%')
    AND subcategory.CID = cid1
    AND EXISTS (SELECT productimage.PIID 
                FROM productimage 
                WHERE productimage.PIID = produkt.PIID)
    GROUP BY subcategory.SCID
    UNION
    SELECT subcategory.SCID, subcategory.Name, '0'
    FROM subcategory
    WHERE subcategory.CID = cid1 
    AND NOT subcategory.SCID = ANY(SELECT produkt.SCID 
                       FROM produkt 
                       INNER JOIN tempcat
    				   ON produkt.CID = tempcat.CID
                       INNER JOIN tempsubcat
                       ON produkt.SCID = tempsubcat.SCID
                       WHERE Bez LIKE CONCAT('%', search, '%') 
                       AND produkt.CID = cid1)
    ORDER BY SCID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCart` (IN `uid1` INT, IN `cartValue` VARCHAR(4000))  NO SQL
UPDATE user SET cart = cartValue WHERE UID = uid1$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `admin`
--

CREATE TABLE `admin` (
  `AID` int(11) NOT NULL,
  `Username` varchar(30) COLLATE utf8_german2_ci NOT NULL,
  `Password` varchar(255) COLLATE utf8_german2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `bestellposition`
--

CREATE TABLE `bestellposition` (
  `BPID` int(11) NOT NULL,
  `BID` int(11) NOT NULL,
  `PID` int(11) NOT NULL,
  `Menge` int(11) NOT NULL,
  `PName` varchar(255) CHARACTER SET utf8 NOT NULL,
  `PPreis` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `bestellposition`
--

INSERT INTO `bestellposition` (`BPID`, `BID`, `PID`, `Menge`, `PName`, `PPreis`) VALUES
(1, 1, 5, 23, 'Brett Lärche 23x120x3000', 5),
(2, 1, 16, 24, 'Schraube M16x50', 0.42),
(3, 2, 12, 14, 'Brett Lärche  23x120x2500', 2.5),
(4, 2, 9, 15, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(5, 2, 1, 567, 'Nagel 100mm', 0.03),
(6, 3, 7, 12, 'Brett Fichte 40x200x1000', 2),
(7, 3, 12, 456, 'Brett Lärche  23x120x2500', 2.5),
(8, 3, 19, 345, 'Spanplatte 38x1800x1000', 15),
(9, 3, 20, 456, 'Spanplatte 38x1800x500', 10),
(10, 4, 7, 16, 'Brett Fichte 40x200x1000', 2),
(11, 4, 13, 23, 'Brett Lärche  23x120x2000', 2),
(12, 4, 12, 999, 'Brett Lärche  23x120x2500', 2.5),
(13, 4, 5, 243, 'Brett Lärche 23x120x3000', 5),
(14, 4, 14, 345, 'Brett Lärche  23x120x4000', 4),
(15, 4, 15, 234, 'Brett Lärche  23x120x5000', 4.5),
(16, 4, 9, 23, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(17, 4, 8, 1, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4),
(18, 4, 1, 234, 'Nagel 100mm', 0.03),
(19, 4, 4, 4, 'Nagel 160mm', 0.06),
(20, 5, 17, 12, 'Schraube M16x40', 0.4),
(21, 5, 16, 423, 'Schraube M16x50', 0.42),
(22, 5, 18, 345, 'Schraube M16x60', 0.46),
(23, 5, 19, 999, 'Spanplatte 38x1800x1000', 15),
(24, 5, 20, 999, 'Spanplatte 38x1800x500', 10),
(25, 8, 15, 10, 'Brett Lärche  23x120x5000', 4.5),
(26, 8, 9, 6, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(27, 8, 1, 11, 'Nagel 100mm', 0.03),
(28, 10, 12, 18, 'Brett Lärche  23x120x2500', 2.5),
(29, 11, 1, 2, 'Nagel 100mm', 0.03),
(30, 11, 3, 6, 'Nagel 140mm', 0.05),
(31, 11, 5, 2, 'Brett Lärche 23x120x3000', 5),
(32, 11, 6, 3, 'Brett Fichte 40x200x3000', 6),
(33, 11, 7, 2, 'Brett Fichte 40x200x1000', 2),
(34, 11, 9, 1, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(35, 11, 11, 10, 'Kantholz Fichte / Tanne sägerau  78x78x5000', 4.5),
(36, 11, 16, 7, 'Schraube M16x50', 0.42),
(37, 11, 17, 5, 'Schraube M16x40', 0.4),
(38, 11, 18, 11, 'Schraube M16x60', 0.46),
(39, 11, 19, 5, 'Spanplatte 38x1800x1000', 15),
(40, 12, 7, 2, 'Brett Fichte 40x200x1000', 2),
(41, 12, 13, 1, 'Brett Lärche  23x120x2000', 2),
(42, 12, 15, 6, 'Brett Lärche  23x120x5000', 4.5),
(43, 12, 9, 3, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(44, 12, 10, 3, 'Kantholz Fichte / Tanne sägerau  78x78x2500', 2.2),
(45, 12, 8, 4, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4),
(46, 12, 1, 3, 'Nagel 100mm', 0.03),
(47, 12, 2, 2, 'Nagel 120mm', 0.04),
(48, 12, 3, 5, 'Nagel 140mm', 0.05),
(49, 12, 17, 10, 'Schraube M16x40', 0.4),
(50, 12, 16, 11, 'Schraube M16x50', 0.42),
(51, 12, 19, 3, 'Spanplatte 38x1800x1000', 15),
(52, 12, 20, 1, 'Spanplatte 38x1800x500', 10),
(53, 13, 7, 999, 'Brett Fichte 40x200x1000', 2),
(54, 13, 6, 34, 'Brett Fichte 40x200x3000', 6),
(55, 13, 13, 999, 'Brett Lärche  23x120x2000', 2),
(56, 13, 12, 4, 'Brett Lärche  23x120x2500', 2.5),
(57, 13, 14, 99, 'Brett Lärche  23x120x4000', 4),
(58, 13, 15, 345, 'Brett Lärche  23x120x5000', 4.5),
(59, 13, 5, 12, 'Brett Lärche 23x120x3000', 5),
(60, 13, 9, 300, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(61, 13, 10, 100, 'Kantholz Fichte / Tanne sägerau  78x78x2500', 2.2),
(62, 13, 11, 899, 'Kantholz Fichte / Tanne sägerau  78x78x5000', 4.5),
(63, 13, 8, 7, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4),
(64, 13, 1, 999, 'Nagel 100mm', 0.03),
(65, 13, 2, 234, 'Nagel 120mm', 0.04),
(66, 13, 3, 999, 'Nagel 140mm', 0.05),
(67, 13, 4, 999, 'Nagel 160mm', 0.06),
(68, 13, 17, 100, 'Schraube M16x40', 0.4),
(69, 13, 16, 200, 'Schraube M16x50', 0.42),
(70, 13, 18, 900, 'Schraube M16x60', 0.46),
(71, 13, 19, 1, 'Spanplatte 38x1800x1000', 15),
(72, 13, 20, 10, 'Spanplatte 38x1800x500', 10),
(73, 14, 11, 4, 'Kantholz Fichte / Tanne sägerau  78x78x5000', 4.5),
(74, 14, 8, 4, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4),
(75, 14, 1, 4, 'Nagel 100mm', 0.03),
(76, 14, 3, 1, 'Nagel 140mm', 0.05),
(77, 15, 7, 20, 'Brett Fichte 40x200x1000', 2),
(78, 15, 12, 22, 'Brett Lärche  23x120x2500', 2.5),
(79, 15, 14, 26, 'Brett Lärche  23x120x4000', 4),
(80, 16, 7, 4, 'Brett Fichte 40x200x1000', 2),
(81, 16, 6, 3, 'Brett Fichte 40x200x3000', 6),
(82, 16, 9, 4, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(83, 17, 7, 6, 'Brett Fichte 40x200x1000', 2),
(84, 17, 9, 4, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3),
(85, 17, 1, 100, 'Nagel 100mm', 0.03),
(86, 18, 5, 13, 'Brett Lärche 23x120x3000', 5),
(87, 18, 8, 567, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4),
(88, 18, 3, 567, 'Nagel 140mm', 0.05),
(89, 19, 12, 11, 'Brett Lärche  23x120x2500', 2.5),
(90, 19, 16, 57, 'Schraube M16x50', 0.42),
(91, 19, 20, 45, 'Spanplatte 38x1800x500', 10),
(92, 20, 7, 1, 'Brett Fichte 40x200x1000', 2),
(93, 21, 7, 1, 'Brett Fichte 40x200x1000', 2),
(94, 22, 7, 6, 'Brett Fichte 40x200x1000', 2),
(95, 22, 14, 8, 'Brett Lärche  23x120x4000', 4),
(96, 23, 2, 6, 'Nagel 120mm', 0.04),
(97, 23, 17, 9, 'Schraube M16x40', 0.4),
(98, 24, 7, 8, 'Brett Fichte 40x200x1000', 2),
(99, 24, 14, 2, 'Brett Lärche  23x120x4000', 4),
(100, 24, 4, 8, 'Nagel 160mm', 0.06),
(101, 25, 12, 10, 'Brett Lärche  23x120x2500', 2.5),
(102, 25, 10, 10, 'Kantholz Fichte / Tanne sägerau  78x78x2500', 2.2),
(103, 26, 7, 12, 'Brett Fichte 40x200x1000', 2),
(104, 26, 13, 1, 'Brett Lärche  23x120x2000', 2),
(105, 26, 39, 2, 'JavaUltraIDE', 129.99),
(106, 27, 35, 1, 'Brot2', 2),
(107, 27, 5, 3, 'Brett Lärche 23x120x3000', 5),
(108, 27, 41, 4, 'JavaUltraIDE Education Edition', 50),
(109, 27, 13, 1, 'Brett Lärche  23x120x2000', 2),
(110, 32, 5, 1, 'Brett Lärche 23x120x3000', 5),
(111, 32, 7, 2, 'Brett Fichte 40x200x1000', 2),
(112, 32, 13, 1, 'Brett Lärche  23x120x2000', 2),
(113, 33, 42, 20, 'Mineralwasser', 0.5),
(114, 33, 39, 3, 'JavaUltraIDE', 129.99),
(115, 33, 41, 2, 'JavaUltraIDE Education Edition', 50),
(116, 33, 35, 10, 'Brot2', 2),
(117, 33, 38, 5, 'Cola', 1),
(118, 34, 15, 1, 'Brett Lärche  23x120x5000', 4.5),
(119, 34, 38, 20, 'Cola', 1),
(120, 35, 7, 1, 'Brett Fichte 40x200x1000', 2),
(121, 35, 38, 10000000, 'Cola', 1),
(122, 36, 38, 100, 'Cola', 1),
(123, 36, 7, 100, 'Brett Fichte 40x200x1000', 2),
(124, 37, 38, 5, 'Cola', 1),
(125, 38, 43, 1, 'Bacardi', 11.5),
(126, 39, 43, 2, 'Bacardi', 11.5),
(127, 39, 7, 1, 'Brett Fichte 40x200x1000', 2),
(128, 40, 43, 1, 'Bacardi', 11.5),
(129, 41, 43, 1, 'Bacardi', 11.5),
(130, 42, 43, 1, 'Bacardi', 11.5),
(131, 42, 7, 1, 'Brett Fichte 40x200x1000', 2),
(132, 42, 22, 9, 'Brot', 5),
(133, 43, 43, 1, 'Bacardi', 11.5),
(134, 43, 7, 1, 'Brett Fichte 40x200x1000', 2),
(135, 43, 12, 1, 'Brett Lärche  23x120x2500', 2.5),
(136, 44, 43, 1, 'Bacardi', 11.5),
(137, 44, 7, 1, 'Brett Fichte 40x200x1000', 2),
(138, 44, 12, 1, 'Brett Lärche  23x120x2500', 2.5),
(139, 46, 22, 7, 'Brot', 5),
(140, 47, 43, 2, 'Bacardi', 11.5),
(141, 49, 43, 1, 'Bacardi', 11.5),
(142, 49, 7, 1, 'Brett Fichte 40x200x1000', 2),
(144, 51, 43, 1, 'Bacardi', 11.5),
(145, 51, 7, 1, 'Brett Fichte 40x200x1000', 2),
(147, 52, 7, 4, 'Brett Fichte 40x200x1000', 2),
(148, 52, 43, 1, 'Bacardi', 11.5),
(150, 53, 43, 4, 'Bacardi', 11.5),
(151, 55, 43, 1, 'Bacardi', 11.5),
(152, 56, 43, 1, 'Bacardi', 11.5),
(153, 56, 17, 1, 'Schraube M16x40', 0.4),
(155, 57, 7, 1, 'Brett Fichte 40x200x1000', 2),
(156, 57, 13, 1, 'Brett Lärche  23x120x2000', 2),
(158, 58, 43, 1, 'Bacardi', 11.5),
(159, 58, 35, 1, 'Brot2', 2),
(160, 58, 36, 2, 'Wurst', 1.15),
(161, 59, 39, 1, 'JavaUltraIDE', 129.99),
(162, 60, 43, 1, 'Bacardi', 11.5);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `bestellung`
--

CREATE TABLE `bestellung` (
  `BID` int(11) NOT NULL,
  `UID` int(11) NOT NULL,
  `Datum` date NOT NULL,
  `Uhrzeit` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `bestellung`
--

INSERT INTO `bestellung` (`BID`, `UID`, `Datum`, `Uhrzeit`) VALUES
(1, 6, '2019-11-25', '00:00:00'),
(2, 11, '2019-11-25', '00:00:00'),
(3, 11, '2019-11-25', '00:00:00'),
(4, 11, '2019-11-25', '00:00:00'),
(5, 6, '2019-11-25', '00:00:00'),
(8, 7, '2019-11-26', '08:39:36'),
(10, 7, '2019-11-26', '09:59:59'),
(11, 13, '2019-12-03', '09:58:15'),
(12, 13, '2019-12-03', '10:58:53'),
(13, 13, '2019-12-03', '11:02:56'),
(14, 13, '2019-12-06', '15:22:06'),
(15, 6, '2019-12-09', '20:27:04'),
(16, 15, '2019-12-17', '15:18:22'),
(17, 16, '2019-12-17', '21:28:24'),
(18, 19, '2019-12-20', '16:06:19'),
(19, 6, '2020-01-04', '19:38:38'),
(20, 22, '2020-01-08', '11:35:43'),
(21, 23, '2020-01-21', '11:13:55'),
(22, 6, '2020-01-25', '08:55:47'),
(23, 6, '2020-01-25', '10:05:05'),
(24, 6, '2020-01-25', '11:53:21'),
(25, 6, '2020-01-25', '12:00:31'),
(26, 6, '2020-02-15', '23:04:37'),
(27, 6, '2020-02-16', '18:00:02'),
(28, 24, '2020-02-19', '12:47:51'),
(29, 24, '2020-02-19', '12:48:01'),
(30, 6, '2020-02-19', '12:52:08'),
(31, 6, '2020-02-19', '12:54:54'),
(32, 6, '2020-02-19', '12:55:24'),
(33, 24, '2020-02-19', '12:59:29'),
(34, 25, '2020-02-19', '13:17:49'),
(35, 26, '2020-02-21', '12:18:56'),
(36, 26, '2020-02-21', '13:41:21'),
(37, 29, '2020-03-01', '20:14:30'),
(38, 26, '2020-03-03', '11:05:18'),
(39, 7, '2020-03-07', '17:14:22'),
(40, 6, '2020-03-21', '22:46:36'),
(41, 6, '2020-03-21', '22:46:56'),
(42, 6, '2020-03-24', '15:36:25'),
(43, 6, '2020-03-24', '15:43:52'),
(44, 6, '2020-03-24', '15:44:52'),
(45, 0, '2020-03-24', '15:57:32'),
(46, 6, '2020-03-24', '15:59:58'),
(47, 6, '2020-03-25', '13:44:15'),
(48, 17, '2020-03-25', '13:46:32'),
(49, 6, '2020-03-25', '13:50:10'),
(50, 6, '2020-03-25', '13:51:07'),
(51, 6, '2020-03-25', '13:53:11'),
(52, 6, '2020-03-25', '13:53:51'),
(53, 6, '2020-03-25', '13:54:11'),
(54, 36, '2020-03-25', '14:07:29'),
(55, 36, '2020-03-25', '14:08:02'),
(56, 39, '2020-03-25', '16:12:51'),
(57, 39, '2020-03-25', '16:26:03'),
(58, 6, '2020-03-25', '18:21:24'),
(59, 6, '2020-06-24', '11:57:16'),
(60, 6, '2020-11-05', '08:46:30');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `cart`
--

CREATE TABLE `cart` (
  `CIID` int(11) NOT NULL COMMENT 'cartitem-id',
  `CID` int(11) NOT NULL,
  `PID` int(11) NOT NULL,
  `Num` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `cart`
--

INSERT INTO `cart` (`CIID`, `CID`, `PID`, `Num`) VALUES
(2, 1, 43, 1),
(3, 1, 7, 1),
(4, 1, 22, 9),
(5, 2, 43, 11),
(6, 2, 7, 1),
(7, 3, 43, 1),
(8, 3, 7, 1),
(9, 4, 43, 1),
(33, 6, 7, 7),
(34, 7, 43, 6),
(35, 8, 43, 7),
(36, 9, 38, 1),
(37, 8, 7, 1),
(38, 10, 43, 1),
(39, 11, 43, 1),
(40, 12, 43, 1),
(46, 14, 22, 7),
(48, 16, 7, 1),
(49, 16, 13, 2),
(50, 16, 35, 3),
(59, 17, 22, 4),
(61, 18, 43, 1),
(62, 18, 7, 1),
(63, 19, 43, 3);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `category`
--

CREATE TABLE `category` (
  `CID` int(11) NOT NULL,
  `Name` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `category`
--

INSERT INTO `category` (`CID`, `Name`) VALUES
(1, 'Heimwerkerbedarf'),
(2, 'Lebensmittel'),
(3, 'diverses'),
(5, 'Software');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `countries`
--

CREATE TABLE `countries` (
  `code` char(2) CHARACTER SET utf8 NOT NULL,
  `en` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `de` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `es` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `fr` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `it` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `ru` varchar(100) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Daten für Tabelle `countries`
--

INSERT INTO `countries` (`code`, `en`, `de`, `es`, `fr`, `it`, `ru`) VALUES
('AD', 'Andorra', 'Andorra', 'Andorra', 'ANDORRE', 'Andorra ', 'Андорра'),
('AE', 'United Arab Emirates', 'Vereinigte Arabische Emirate', 'Emiratos Árabes Unidos', 'ÉMIRATS ARABES UNIS', 'Emirati Arabi Uniti ', 'ОАЭ'),
('AF', 'Afghanistan', 'Afghanistan', 'Afganistán', 'AFGHANISTAN', 'Afghanistan', 'Афганистан'),
('AG', 'Antigua and Barbuda', 'Antigua und Barbuda', 'Antigua y Barbuda', 'ANTIGUA-ET-BARBUDA', 'Antigua e Barbuda', 'Антигуа и Барбуда'),
('AI', 'Anguilla', 'Anguilla', 'Anguila', 'ANGUILLA', 'Anguilla', 'Ангилья'),
('AL', 'Albania', 'Albanien', 'Albania', 'ALBANIE', 'Albania ', 'Албания'),
('AM', 'Armenia', 'Armenien', 'Armenia', 'ARMÉNIE', 'Armenia ', 'Армения'),
('AN', 'Netherlands Antilles', 'Niederländische Antillen', 'Antillas Neerlandesas', '', '', ''),
('AO', 'Angola', 'Angola', 'Angola', 'ANGOLA', 'Angola ', 'Ангола'),
('AQ', 'Antarctica', 'Antarktis', 'Antártida', 'ANTARCTIQUE', 'Antartide ', 'Антарктида'),
('AR', 'Argentina', 'Argentinien', 'Argentina', 'ARGENTINE', 'Argentina ', 'Аргентина'),
('AS', 'American Samoa', 'Amerikanisch-Samoa', 'Samoa Americana', 'SAMOA AMÉRICAINES', 'Samoa Americane', 'Американское Самоа'),
('AT', 'Austria', 'Österreich', 'Austria', 'AUTRICHE', 'Austria', 'Австрия'),
('AU', 'Australia', 'Australien', 'Australia', 'AUSTRALIE', 'Australia', 'Австралия'),
('AW', 'Aruba', 'Aruba', 'Aruba', 'ARUBA', 'Aruba', 'Аруба'),
('AX', 'Aland Islands', 'Åland', 'Islas Áland', 'ÅLAND, ÎLES', 'Isole Åland', 'Аландские острова'),
('AZ', 'Azerbaijan', 'Aserbaidschan', 'Azerbaiyán', 'AZERBAÏDJAN', 'Azerbaigian', 'Азербайджан'),
('BA', 'Bosnia and Herzegovina', 'Bosnien und Herzegowina', 'Bosnia y Herzegovina', 'BOSNIE-HERZÉGOVINE', 'Bosnia ed Erzegovina', 'Босния и Герцеговина'),
('BB', 'Barbados', 'Barbados', 'Barbados', 'BARBADE', 'Barbados', 'Барбадос'),
('BD', 'Bangladesh', 'Bangladesch', 'Bangladesh', 'BANGLADESH', 'Bangladesh', 'Бангладеш'),
('BE', 'Belgium', 'Belgien', 'Bélgica', 'BELGIQUE', 'Belgio', 'Бельгия'),
('BF', 'Burkina Faso', 'Burkina Faso', 'Burkina Faso', 'BURKINA FASO', 'Burkina Faso', 'Буркина-Фасо'),
('BG', 'Bulgaria', 'Bulgarien', 'Bulgaria', 'BULGARIE', 'Bulgaria', 'Болгария'),
('BH', 'Bahrain', 'Bahrain', 'Bahréin', 'BAHREÏN', 'Bahrein', 'Бахрейн'),
('BI', 'Burundi', 'Burundi', 'Burundi', 'BURUNDI', 'Burundi', 'Бурунди'),
('BJ', 'Benin', 'Benin', 'Benin', 'BÉNIN', 'Benin', 'Бенин'),
('BM', 'Bermuda', 'Bermuda', 'Bermudas', 'BERMUDES', 'Bermuda', 'Бермуды'),
('BN', 'Brunei', 'Brunei Darussalam', 'Brunéi', 'BRUNÉI DARUSSALAM', 'Brunei', 'Бруней'),
('BO', 'Bolivia', 'Bolivien', 'Bolivia', 'BOLIVIE, ÉTAT PLURINATIONAL DE', 'Bolivia', 'Боливия'),
('BR', 'Brazil', 'Brasilien', 'Brasil', 'BRÉSIL', 'Brasile', 'Бразилия'),
('BS', 'Bahamas', 'Bahamas', 'Bahamas', 'BAHAMAS', 'Bahamas', 'Багамы'),
('BT', 'Bhutan', 'Bhutan', 'Bhután', 'BHOUTAN', 'Bhutan', 'Бутан'),
('BV', 'Bouvet Island', 'Bouvetinsel', 'Isla Bouvet', 'BOUVET, ÎLE', 'Isola Bouvet', 'Остров Буве'),
('BW', 'Botswana', 'Botswana', 'Botsuana', 'BOTSWANA', 'Botswana', 'Ботсвана'),
('BY', 'Belarus', 'Belarus (Weißrussland)', 'Belarús', 'BÉLARUS', 'Bielorussia', 'Белоруссия'),
('BZ', 'Belize', 'Belize', 'Belice', 'BELIZE', 'Belize', 'Белиз'),
('CA', 'Canada', 'Kanada', 'Canadá', 'CANADA', 'Canada', 'Канада'),
('CC', 'Cocos (Keeling) Islands', 'Kokosinseln (Keelinginseln)', 'Islas Cocos', 'COCOS (KEELING), ÎLES', 'Isole Cocos (Keeling)', 'Кокосовые острова'),
('CD', 'Congo (Kinshasa)', 'Kongo', 'Congo', 'CONGO, LA RÉPUBLIQUE DÉMOCRATIQUE DU', 'RD del Congo', 'Демократическая Республика Конго'),
('CF', 'Central African Republic', 'Zentralafrikanische Republik', 'República Centro-Africana', 'CENTRAFRICAINE, RÉPUBLIQUE', 'Rep. Centrafricana', 'ЦАР'),
('CG', 'Congo (Brazzaville)', 'Republik Kongo', 'Congo', 'CONGO', 'Rep. del Congo', 'Республика Конго'),
('CH', 'Switzerland', 'Schweiz', 'Suiza', 'SUISSE', 'Svizzera', 'Швейцария'),
('CI', 'Ivory Coast', 'Elfenbeinküste', 'Costa de Marfil', 'CÔTE D’IVOIRE', 'Costa d\'Avorio', 'Кот-д’Ивуар'),
('CK', 'Cook Islands', 'Cookinseln', 'Islas Cook', 'COOK, ÎLES', 'Isole Cook', 'Острова Кука'),
('CL', 'Chile', 'Chile', 'Chile', 'CHILI', 'Cile', 'Чили'),
('CM', 'Cameroon', 'Kamerun', 'Camerún', 'CAMEROUN', 'Camerun', 'Камерун'),
('CN', 'China', 'China, Volksrepublik', 'China', 'CHINE', 'Cina', 'КНР (Китайская Народная Республика)'),
('CO', 'Colombia', 'Kolumbien', 'Colombia', 'COLOMBIE', 'Colombia', 'Колумбия'),
('CR', 'Costa Rica', 'Costa Rica', 'Costa Rica', 'COSTA RICA', 'Costa Rica', 'Коста-Рика'),
('CU', 'Cuba', 'Kuba', 'Cuba', 'CUBA', 'Cuba', 'Куба'),
('CV', 'Cape Verde', 'Kap Verde', 'Cabo Verde', 'CABO VERDE', 'Capo Verde', 'Кабо-Верде'),
('CX', 'Christmas Island', 'Weihnachtsinsel', 'Islas Christmas', 'CHRISTMAS, ÎLE', 'Isola di Natale', 'Остров Рождества'),
('CY', 'Cyprus', 'Zypern', 'Chipre', 'CHYPRE', 'Cipro', 'Кипр'),
('CZ', 'Czech Republic', 'Tschechische Republik', 'República Checa', 'TCHÈQUE, RÉPUBLIQUE', 'Rep. Ceca', 'Чехия'),
('DE', 'Germany', 'Deutschland', 'Alemania', 'ALLEMAGNE', 'Germania', 'Германия'),
('DJ', 'Djibouti', 'Dschibuti', 'Yibuti', 'DJIBOUTI', 'Gibuti', 'Джибути'),
('DK', 'Denmark', 'Dänemark', 'Dinamarca', 'DANEMARK', 'Danimarca', 'Дания'),
('DM', 'Dominica', 'Dominica', 'Domínica', 'DOMINIQUE', 'Dominica', 'Доминика'),
('DO', 'Dominican Republic', 'Dominikanische Republik', 'República Dominicana', 'DOMINICAINE, RÉPUBLIQUE', 'Rep. Dominicana', 'Доминиканская Республика'),
('DZ', 'Algeria', 'Algerien', 'Argelia', 'ALGÉRIE', 'Algeria', 'Алжир'),
('EC', 'Ecuador', 'Ecuador', 'Ecuador', 'ÉQUATEUR', 'Ecuador', 'Эквадор'),
('EE', 'Estonia', 'Estland (Reval)', 'Estonia', 'ESTONIE', 'Estonia', 'Эстония'),
('EG', 'Egypt', 'Ägypten', 'Egipto', 'ÉGYPTE', 'Egitto', 'Египет'),
('EH', 'Western Sahara', 'Westsahara', 'Sahara Occidental', 'SAHARA OCCIDENTAL', 'Sahara Occidentale', 'САДР'),
('ER', 'Eritrea', 'Eritrea', 'Eritrea', 'ÉRYTHRÉE', 'Eritrea', 'Эритрея'),
('ES', 'Spain', 'Spanien', 'España', 'ESPAGNE', 'Spagna', 'Испания'),
('ET', 'Ethiopia', 'Äthiopien', 'Etiopía', 'ÉTHIOPIE', 'Etiopia', 'Эфиопия'),
('FI', 'Finland', 'Finnland', 'Finlandia', 'FINLANDE', 'Finlandia', 'Финляндия'),
('FJ', 'Fiji', 'Fidschi', 'Fiji', 'FIDJI', 'Figi', 'Фиджи'),
('FK', 'Falkland Islands', 'Falklandinseln (Malwinen)', 'Islas Malvinas', 'FALKLAND, ÎLES (MALVINAS)', 'Isole Falkland', 'Фолклендские острова'),
('FM', 'Micronesia', 'Mikronesien', 'Micronesia', 'MICRONÉSIE, ÉTATS FÉDÉRÉS DE', 'Micronesia', 'Микронезия'),
('FO', 'Faroe Islands', 'Färöer', 'Islas Faroe', 'FÉROÉ, ÎLES', 'Fær Øer', 'Фареры'),
('FR', 'France', 'Frankreich', 'Francia', 'FRANCE', 'Francia', 'Франция'),
('GA', 'Gabon', 'Gabun', 'Gabón', 'GABON', 'Gabon', 'Габон'),
('GB', 'United Kingdom', 'Großbritannien und Nordirland', 'Reino Unido', 'ROYAUME-UNI', 'Regno Unito', 'Великобритания'),
('GD', 'Grenada', 'Grenada', 'Granada', 'GRENADE', 'Grenada', 'Гренада'),
('GE', 'Georgia', 'Georgien', 'Georgia', 'GÉORGIE', 'Georgia', 'Грузия'),
('GF', 'French Guiana', 'Französisch-Guayana', 'Guayana Francesa', 'GUYANE FRANÇAISE', 'Guyana francese', 'Гвиана'),
('GG', 'Guernsey', 'Guernsey (Kanalinsel)', 'Guernsey', 'GUERNESEY', 'Guernsey', 'Гернси'),
('GH', 'Ghana', 'Ghana', 'Ghana', 'GHANA', 'Ghana', 'Гана'),
('GI', 'Gibraltar', 'Gibraltar', 'Gibraltar', 'GIBRALTAR', 'Gibilterra', 'Гибралтар'),
('GL', 'Greenland', 'Grönland', 'Groenlandia', 'GROENLAND', 'Groenlandia', 'Гренландия'),
('GM', 'Gambia', 'Gambia', 'Gambia', 'GAMBIE', 'Gambia', 'Гамбия'),
('GN', 'Guinea', 'Guinea', 'Guinea', 'GUINÉE', 'Guinea', 'Гвинея'),
('GP', 'Guadeloupe', 'Guadeloupe', 'Guadalupe', 'GUADELOUPE', 'Guadalupa', 'Гваделупа'),
('GQ', 'Equatorial Guinea', 'Äquatorialguinea', 'Guinea Ecuatorial', 'GUINÉE ÉQUATORIALE', 'Guinea Equatoriale', 'Экваториальная Гвинея'),
('GR', 'Greece', 'Griechenland', 'Grecia', 'GRÈCE', 'Grecia ', 'Греция'),
('GS', 'South Georgia and the South Sandwich Islands', 'Südgeorgien und die Südl. Sandwichinseln', 'Georgia del Sur e Islas Sandwich del Sur', 'GÉORGIE DU SUD ET LES ÎLES SANDWICH DU SUD', 'Georgia del Sud e isole Sandwich meridionali', 'Южная Георгия и Южные Сандвичевы Острова'),
('GT', 'Guatemala', 'Guatemala', 'Guatemala', 'GUATEMALA', 'Guatemala', 'Гватемала'),
('GU', 'Guam', 'Guam', 'Guam', 'GUAM', 'Guam', 'Гуам'),
('GW', 'Guinea-Bissau', 'Guinea-Bissau', 'Guinea-Bissau', 'GUINÉE-BISSAU', 'Guinea-Bissau', 'Гвинея-Бисау'),
('GY', 'Guyana', 'Guyana', 'Guayana', 'GUYANA', 'Guyana', 'Гайана'),
('HK', 'Hong Kong S.A.R., China', 'Hongkong', 'Hong Kong', 'HONG KONG', 'Hong Kong', 'Гонконг'),
('HM', 'Heard Island and McDonald Islands', 'Heard- und McDonald-Inseln', 'Islas Heard y McDonald', 'HEARD ET MACDONALD, ÎLES', 'Isole Heard e McDonald', 'Херд и Макдональд'),
('HN', 'Honduras', 'Honduras', 'Honduras', 'HONDURAS', 'Honduras', 'Гондурас'),
('HR', 'Croatia', 'Kroatien', 'Croacia', 'CROATIE', 'Croazia', 'Хорватия'),
('HT', 'Haiti', 'Haiti', 'Haití', 'HAÏTI', 'Haiti ', 'Гаити'),
('HU', 'Hungary', 'Ungarn', 'Hungría', 'HONGRIE', 'Ungheria', 'Венгрия'),
('ID', 'Indonesia', 'Indonesien', 'Indonesia', 'INDONÉSIE', 'Indonesia', 'Индонезия'),
('IE', 'Ireland', 'Irland', 'Irlanda', 'IRLANDE', 'Irlanda ', 'Флаг Ирландии Ирландия'),
('IL', 'Israel', 'Israel', 'Israel', 'ISRAËL', 'Israele ', 'Израиль'),
('IM', 'Isle of Man', 'Insel Man', 'Isla de Man', 'ÎLE DE MAN', 'Isola di Man', 'Остров Мэн'),
('IN', 'India', 'Indien', 'India', 'INDE', 'India ', 'Индия Индия'),
('IO', 'British Indian Ocean Territory', 'Britisches Territorium im Indischen Ozean', 'Territorio Británico del Océano Índico', 'OCÉAN INDIEN, TERRITOIRE BRITANNIQUE DE L\'', 'Territorio britannico dell\'oceano', 'Британская территория в Индийском океане'),
('IQ', 'Iraq', 'Irak', 'Irak', 'IRAQ', 'Iraq ', 'Ирак'),
('IR', 'Iran', 'Iran', 'Irán', 'IRAN, RÉPUBLIQUE ISLAMIQUE D\'', 'Iran ', 'Иран'),
('IS', 'Iceland', 'Island', 'Islandia', 'ISLANDE', 'Islanda ', 'Исландия'),
('IT', 'Italy', 'Italien', 'Italia', 'ITALIE', 'Italia ', 'Италия'),
('JE', 'Jersey', 'Jersey (Kanalinsel)', 'Jersey', 'JERSEY', 'Jersey ', 'Джерси'),
('JM', 'Jamaica', 'Jamaika', 'Jamaica', 'JAMAÏQUE', 'Giamaica', 'Ямайка'),
('JO', 'Jordan', 'Jordanien', 'Jordania', 'JORDANIE', 'Giordania ', 'Иордания'),
('JP', 'Japan', 'Japan', 'Japón', 'JAPON', 'Giappone ', 'Япония'),
('KE', 'Kenya', 'Kenia', 'Kenia', 'KENYA', 'Kenya ', 'Кения'),
('KG', 'Kyrgyzstan', 'Kirgisistan', 'Kirguistán', 'KIRGHIZISTAN', 'Kirghizistan', 'Киргизия'),
('KH', 'Cambodia', 'Kambodscha', 'Camboya', 'CAMBODGE', 'Cambogia ', 'Камбоджа'),
('KI', 'Kiribati', 'Kiribati', 'Kiribati', 'KIRIBATI', 'Kiribati ', 'Кирибати'),
('KM', 'Comoros', 'Komoren', 'Comoros', 'COMORES', 'Comore ', 'Коморы'),
('KN', 'Saint Kitts and Nevis', 'St. Kitts und Nevis', 'San Cristóbal y Nieves', 'SAINT-KITTS-ET-NEVIS', 'Saint Kitts e Nevis', 'Сент-Китс и Невис'),
('KP', 'North Korea', 'Nordkorea', 'Corea del Norte', 'CORÉE, RÉPUBLIQUE POPULAIRE DÉMOCRATIQUE DE', 'Corea del Nord ', 'КНДР (Корейская Народно-Демократическая Республика)'),
('KR', 'South Korea', 'Südkorea', 'Corea del Sur', 'CORÉE, RÉPUBLIQUE DE', 'Corea del Sud ', 'Республика Корея'),
('KW', 'Kuwait', 'Kuwait', 'Kuwait', 'KOWEÏT', 'Kuwait ', 'Кувейт'),
('KY', 'Cayman Islands', 'Kaimaninseln', 'Islas Caimán', 'CAÏMANES, ÎLES', 'Isole Cayman', 'Острова Кайман'),
('KZ', 'Kazakhstan', 'Kasachstan', 'Kazajstán', 'KAZAKHSTAN', 'Kazakistan ', 'Казахстан'),
('LA', 'Laos', 'Laos', 'Laos', 'LAO, RÉPUBLIQUE DÉMOCRATIQUE POPULAIRE', 'Laos ', 'Лаос'),
('LB', 'Lebanon', 'Libanon', 'Líbano', 'LIBAN', 'Libano', 'Ливан'),
('LC', 'Saint Lucia', 'St. Lucia', 'Santa Lucía', 'SAINTE-LUCIE', 'Santa Lucia', 'Сент-Люсия'),
('LI', 'Liechtenstein', 'Liechtenstein', 'Liechtenstein', 'LIECHTENSTEIN', 'Liechtenstein', 'Лихтенштейн'),
('LK', 'Sri Lanka', 'Sri Lanka', 'Sri Lanka', 'SRI LANKA', 'Sri Lanka ', 'Шри-Ланка'),
('LR', 'Liberia', 'Liberia', 'Liberia', 'LIBÉRIA', 'Liberia ', 'Либерия'),
('LS', 'Lesotho', 'Lesotho', 'Lesotho', 'LESOTHO', 'Lesotho ', 'Лесото'),
('LT', 'Lithuania', 'Litauen', 'Lituania', 'LITUANIE', 'Lituania', 'Литва'),
('LU', 'Luxembourg', 'Luxemburg', 'Luxemburgo', 'LUXEMBOURG', 'Lussemburgo', 'Люксембург'),
('LV', 'Latvia', 'Lettland', 'Letonia', 'LETTONIE', 'Lettonia ', 'Латвия'),
('LY', 'Libya', 'Libyen', 'Libia', 'LIBYE', 'Libia ', 'Ливия'),
('MA', 'Morocco', 'Marokko', 'Marruecos', 'MAROC', 'Marocco', 'Марокко'),
('MC', 'Monaco', 'Monaco', 'Mónaco', 'MONACO', 'Monaco ', 'Монако'),
('MD', 'Moldova', 'Moldawien', 'Moldova', 'MOLDOVA', 'Moldavia', 'Молдавия'),
('MG', 'Madagascar', 'Madagaskar', 'Madagascar', 'MADAGASCAR', 'Madagascar ', 'Мадагаскар'),
('MH', 'Marshall Islands', 'Marshallinseln', 'Islas Marshall', 'MARSHALL, ÎLES', 'Isole Marshall', 'Маршалловы Острова'),
('MK', 'Macedonia', 'Mazedonien', 'Macedonia', 'MACÉDOINE, L\'EX-RÉPUBLIQUE YOUGOSLAVE DE', 'Macedonia ', 'Македония'),
('ML', 'Mali', 'Mali', 'Mali', 'MALI', 'Mali ', 'Мали'),
('MM', 'Myanmar', 'Myanmar (Burma)', 'Myanmar', 'MYANMAR', 'Birmania', 'Мьянма'),
('MN', 'Mongolia', 'Mongolei', 'Mongolia', 'MONGOLIE', 'Mongolia', 'Монголия'),
('MO', 'Macao S.A.R., China', 'Macau', 'Macao', 'MACAO', 'Macao ', 'Макао'),
('MP', 'Northern Mariana Islands', 'Nördliche Marianen', 'Islas Marianas del Norte', 'MARIANNES DU NORD, ÎLES', 'Isole Marianne Settentrionali', 'Северные Марианские острова'),
('MQ', 'Martinique', 'Martinique', 'Martinica', 'MARTINIQUE', 'Martinica', 'Мартиника'),
('MR', 'Mauritania', 'Mauretanien', 'Mauritania', 'MAURITANIE', 'Mauritania', 'Мавритания'),
('MS', 'Montserrat', 'Montserrat', 'Montserrat', 'MONTSERRAT', 'Montserrat', 'Монтсеррат'),
('MT', 'Malta', 'Malta', 'Malta', 'MALTE', 'Malta ', 'Мальта'),
('MU', 'Mauritius', 'Mauritius', 'Mauricio', 'MAURICE', 'Mauritius', 'Маврикий'),
('MV', 'Maldives', 'Malediven', 'Maldivas', 'MALDIVES', 'Maldive ', 'Мальдивы'),
('MW', 'Malawi', 'Malawi', 'Malawi', 'MALAWI', 'Malawi ', 'Малави'),
('MX', 'Mexico', 'Mexiko', 'México', 'MEXIQUE', 'Messico ', 'Мексика'),
('MY', 'Malaysia', 'Malaysia', 'Malasia', 'MALAISIE', 'Malesia ', 'Малайзия'),
('MZ', 'Mozambique', 'Mosambik', 'Mozambique', 'MOZAMBIQUE', 'Mozambico', 'Мозамбик'),
('NA', 'Namibia', 'Namibia', 'Namibia', 'NAMIBIE', 'Namibia ', 'Намибия'),
('NC', 'New Caledonia', 'Neukaledonien', 'Nueva Caledonia', 'NOUVELLE-CALÉDONIE', 'Nuova Caledonia', 'Новая Каледония'),
('NE', 'Niger', 'Niger', 'Níger', 'NIGER', 'Niger ', 'Нигер'),
('NF', 'Norfolk Island', 'Norfolkinsel', 'Islas Norkfolk', 'NORFOLK, ÎLE', 'Isola Norfolk', 'Остров Норфолк'),
('NG', 'Nigeria', 'Nigeria', 'Nigeria', 'NIGÉRIA', 'Nigeria ', 'Нигерия'),
('NI', 'Nicaragua', 'Nicaragua', 'Nicaragua', 'NICARAGUA', 'Nicaragua', 'Никарагуа'),
('NL', 'Netherlands', 'Niederlande', 'Países Bajos', 'PAYS-BAS', 'Paesi Bassi', 'Нидерланды'),
('NO', 'Norway', 'Norwegen', 'Noruega', 'NORVÈGE', 'Norvegia ', 'Норвегия'),
('NP', 'Nepal', 'Nepal', 'Nepal', 'NÉPAL', 'Nepal ', 'Непал'),
('NR', 'Nauru', 'Nauru', 'Nauru', 'NAURU', 'Nauru ', 'Науру'),
('NU', 'Niue', 'Niue', 'Niue', 'NIUÉ', 'Niue ', 'Ниуэ'),
('NZ', 'New Zealand', 'Neuseeland', 'Nueva Zelanda', 'NOUVELLE-ZÉLANDE', 'Nuova Zelanda', 'Новая Зеландия'),
('OM', 'Oman', 'Oman', 'Omán', 'OMAN', 'Oman ', 'Оман'),
('PA', 'Panama', 'Panama', 'Panamá', 'PANAMA', 'Panamá', 'Панама'),
('PE', 'Peru', 'Peru', 'Perú', 'PÉROU', 'Perù ', 'Перу'),
('PF', 'French Polynesia', 'Französisch-Polynesien', 'Polinesia Francesa', 'POLYNÉSIE FRANÇAISE', 'Polinesia Francese ', 'Французская Полинезия'),
('PG', 'Papua New Guinea', 'Papua-Neuguinea', 'Papúa Nueva Guinea', 'PAPOUASIE-NOUVELLE-GUINÉE', 'Papua Nuova Guinea ', 'Папуа — Новая Гвинея'),
('PH', 'Philippines', 'Philippinen', 'Filipinas', 'PHILIPPINES', 'Filippine ', 'Филиппины'),
('PK', 'Pakistan', 'Pakistan', 'Pakistán', 'PAKISTAN', 'Pakistan ', 'Пакистан'),
('PL', 'Poland', 'Polen', 'Polonia', 'POLOGNE', 'Polonia ', 'Польша'),
('PM', 'Saint Pierre and Miquelon', 'St. Pierre und Miquelon', 'San Pedro y Miquelón', 'SAINT-PIERRE-ET-MIQUELON', 'Saint-Pierre e Miquelon', 'Сен-Пьер и Микелон'),
('PN', 'Pitcairn', 'Pitcairninseln', 'Islas Pitcairn', 'PITCAIRN', 'Isole Pitcairn ', 'Острова Питкэрн'),
('PR', 'Puerto Rico', 'Puerto Rico', 'Puerto Rico', 'PORTO RICO', 'Porto Rico ', 'Пуэрто-Рико'),
('PS', 'Palestine', 'Palästina', 'Palestina', 'ÉTAT DE PALESTINE', 'Palestina ', 'Государство Палестина'),
('PT', 'Portugal', 'Portugal', 'Portugal', 'PORTUGAL', 'Portogallo ', 'Португалия'),
('PW', 'Palau', 'Palau', 'Islas Palaos', 'PALAOS', 'Palau ', 'Палау'),
('PY', 'Paraguay', 'Paraguay', 'Paraguay', 'PARAGUAY', 'Paraguay ', 'Парагвай'),
('QA', 'Qatar', 'Katar', 'Qatar', 'QATAR', 'Qatar ', 'Катар'),
('RE', 'Reunion', 'Réunion', 'Reunión', 'RÉUNION', 'Riunione ', 'Реюньон'),
('RO', 'Romania', 'Rumänien', 'Rumanía', 'ROUMANIE', 'Romania ', 'Румыния'),
('RU', 'Russia', 'Russische Föderation', 'Rusia', 'RUSSIE, FÉDÉRATION DE', 'Russia ', 'Россия'),
('RW', 'Rwanda', 'Ruanda', 'Ruanda', 'RWANDA', 'Ruanda ', 'Руанда'),
('SA', 'Saudi Arabia', 'Saudi-Arabien', 'Arabia Saudita', 'ARABIE SAOUDITE', 'Arabia Saudita', 'Саудовская Аравия'),
('SB', 'Solomon Islands', 'Salomonen', 'Islas Solomón', 'SALOMON, ÎLES', 'Isole Salomone', 'Соломоновы Острова'),
('SC', 'Seychelles', 'Seychellen', 'Seychelles', 'SEYCHELLES', 'Seychelles', 'Сейшельские Острова'),
('SD', 'Sudan', 'Sudan', 'Sudán', 'SOUDAN', 'Sudan ', 'Судан'),
('SE', 'Sweden', 'Schweden', 'Suecia', 'SUÈDE', 'Svezia', 'Швеция'),
('SG', 'Singapore', 'Singapur', 'Singapur', 'SINGAPOUR', 'Singapore', 'Сингапур'),
('SH', 'Saint Helena', 'St. Helena', 'Santa Elena', 'SAINTE-HÉLÈNE, ASCENSION ET TRISTAN DA CUNHA', 'Sant\'Elena, Ascensione e Tristan da Cunha', 'Острова Святой Елены, Вознесения и Тристан-да-Кунья'),
('SI', 'Slovenia', 'Slowenien', 'Eslovenia', 'SLOVÉNIE', 'Slovenia Slovenia', 'Словения'),
('SJ', 'Svalbard and Jan Mayen', 'Svalbard und Jan Mayen', 'Islas Svalbard y Jan Mayen', 'SVALBARD ET ÎLE JAN MAYEN', 'Svalbard e Jan Mayen', 'Флаг Шпицбергена и Ян-Майена Шпицберген и Ян-Майен'),
('SK', 'Slovakia', 'Slowakei', 'Eslovaquia', 'SLOVAQUIE', 'Slovacchia ', 'Словакия'),
('SL', 'Sierra Leone', 'Sierra Leone', 'Sierra Leona', 'SIERRA LEONE', 'Sierra Leone', 'Сьерра-Леоне'),
('SM', 'San Marino', 'San Marino', 'San Marino', 'SAINT-MARIN', 'San Marino ', 'Сан-Марино'),
('SN', 'Senegal', 'Senegal', 'Senegal', 'SÉNÉGAL', 'Senegal ', 'Сенегал'),
('SO', 'Somalia', 'Somalia', 'Somalia', 'SOMALIE', 'Somalia ', 'Сомали'),
('SR', 'Suriname', 'Suriname', 'Surinam', 'SURINAME', 'Suriname', 'Суринам'),
('ST', 'Sao Tome and Principe', 'São Tomé und Príncipe', 'Santo Tomé y Príncipe', 'SAO TOMÉ-ET-PRINCIPE', 'São Tomé e Príncipe', 'Сан-Томе и Принсипи'),
('SV', 'El Salvador', 'El Salvador', 'El Salvador', 'EL SALVADOR', 'El Salvador ', 'Сальвадор'),
('SY', 'Syria', 'Syrien', 'Siria', 'SYRIENNE, RÉPUBLIQUE ARABE', 'Siria ', 'Сирия'),
('SZ', 'Swaziland', 'Swasiland', 'Suazilandia', 'SWAZILAND', 'Swaziland', 'Свазиленд'),
('TC', 'Turks and Caicos Islands', 'Turks- und Caicosinseln', 'Islas Turcas y Caicos', 'TURKS ET CAÏQUES, ÎLES', 'Turks e Caicos ', 'Тёркс и Кайкос'),
('TD', 'Chad', 'Tschad', 'Chad', 'TCHAD', 'Ciad ', 'Чад'),
('TF', 'French Southern Territories', 'Französische Süd- und Antarktisgebiete', 'Territorios Australes Franceses', 'TERRES AUSTRALES FRANÇAISES', 'Terre australi e antartiche francesi', 'Французские Южные и Антарктические Территории'),
('TG', 'Togo', 'Togo', 'Togo', 'TOGO', 'Togo ', 'Того'),
('TH', 'Thailand', 'Thailand', 'Tailandia', 'THAÏLANDE', 'Thailandia', 'Таиланд'),
('TJ', 'Tajikistan', 'Tadschikistan', 'Tayikistán', 'TADJIKISTAN', 'Tagikistan', 'Таджикистан'),
('TK', 'Tokelau', 'Tokelau', 'Tokelau', 'TOKELAU', 'Tokelau ', 'Токелау'),
('TL', 'East Timor', 'Timor-Leste', 'Timor-Leste', 'TIMOR-LESTE', 'Timor Est', 'Восточный Тимор'),
('TM', 'Turkmenistan', 'Turkmenistan', 'Turkmenistán', 'TURKMÉNISTAN', 'Turkmenistan', 'Туркмения'),
('TN', 'Tunisia', 'Tunesien', 'Túnez', 'TUNISIE', 'Tunisia ', 'Тунис'),
('TO', 'Tonga', 'Tonga', 'Tonga', 'TONGA', 'Tonga ', 'Тонга'),
('TR', 'Turkey', 'Türkei', 'Turquía', 'TURQUIE', 'Turchia', 'Турция'),
('TT', 'Trinidad and Tobago', 'Trinidad und Tobago', 'Trinidad y Tobago', 'TRINITÉ-ET-TOBAGO', 'Trinidad e Tobago', 'Тринидад и Тобаго'),
('TV', 'Tuvalu', 'Tuvalu', 'Tuvalu', 'TUVALU', 'Tuvalu ', 'Тувалу'),
('TW', 'Taiwan', 'Taiwan', 'Taiwán', 'TAÏWAN, PROVINCE DE CHINE', 'Taiwan ', 'Китайская Республика'),
('TZ', 'Tanzania', 'Tansania', 'Tanzania', 'TANZANIE, RÉPUBLIQUE UNIE DE', 'Tanzania ', 'Танзания'),
('UA', 'Ukraine', 'Ukraine', 'Ucrania', 'UKRAINE', 'Ucraina ', 'Украина'),
('UG', 'Uganda', 'Uganda', 'Uganda', 'OUGANDA', 'Uganda ', 'Уганда'),
('UM', 'United States Minor Outlying Islands', 'Amerikanisch-Ozeanien', 'Islas menores periféricas de los Estados Unidos', 'ÎLES MINEURES ÉLOIGNÉES DES ÉTATS-UNIS', 'Isole minori esterne degli Stati Uniti', 'Внешние малые острова (США)'),
('US', 'United States', 'Vereinigte Staaten von Amerika', 'Estados Unidos de América', 'ÉTATS-UNIS', 'Stati Uniti', 'США'),
('UY', 'Uruguay', 'Uruguay', 'Uruguay', 'URUGUAY', 'Uruguay ', 'Уругвай'),
('UZ', 'Uzbekistan', 'Usbekistan', 'Uzbekistán', 'OUZBÉKISTAN', 'Uzbekistan', 'Узбекистан'),
('VA', 'Vatican', 'Vatikanstadt', 'Ciudad del Vaticano', 'SAINT-SIÈGE (ÉTAT DE LA CITÉ DU VATICAN)', 'Città del Vaticano', 'Ватикан'),
('VC', 'Saint Vincent and the Grenadines', 'St. Vincent und die Grenadinen', 'San Vicente y las Granadinas', 'SAINT-VINCENT-ET-LES-GRENADINES', 'Saint Vincent e Grenadine', 'Сент-Винсент и Гренадины'),
('VE', 'Venezuela', 'Venezuela', 'Venezuela', 'VENEZUELA, RÉPUBLIQUE BOLIVARIENNE DU', 'Venezuela ', 'Венесуэла'),
('VG', 'British Virgin Islands', 'Britische Jungferninseln', 'Islas Vírgenes Británicas', 'ÎLES VIERGES BRITANNIQUES', 'Isole Vergini britanniche ', 'Британские Виргинские острова'),
('VI', 'U.S. Virgin Islands', 'Amerikanische Jungferninseln', 'Islas Vírgenes de los Estados Unidos de América', 'ÎLES VIERGES DES ÉTATS-UNIS', 'Isole Vergini americane ', 'Виргинские Острова (США)'),
('VN', 'Vietnam', 'Vietnam', 'Vietnam', 'VIET NAM', 'Vietnam', 'Вьетнам'),
('VU', 'Vanuatu', 'Vanuatu', 'Vanuatu', 'VANUATU', 'Vanuatu', 'Вануату'),
('WF', 'Wallis and Futuna', 'Wallis und Futuna', 'Wallis y Futuna', 'WALLIS-ET-FUTUNA', 'Wallis e Futuna', 'Уоллис и Футуна'),
('WS', 'Samoa', 'Samoa', 'Samoa', 'SAMOA', 'Samoa ', 'Самоа'),
('YE', 'Yemen', 'Jemen', 'Yemen', 'YÉMEN', 'Yemen ', 'Йемен'),
('YT', 'Mayotte', 'Mayotte', 'Mayotte', 'MAYOTTE', 'Mayotte ', 'Майотта'),
('ZA', 'South Africa', 'Südafrika', 'Sudáfrica', 'AFRIQUE DU SUD', 'Sudafrica ', 'ЮАР'),
('ZM', 'Zambia', 'Sambia', 'Zambia', 'ZAMBIE', 'Zambia ', 'Замбия'),
('ZW', 'Zimbabwe', 'Simbabwe', 'Zimbabue', 'ZIMBABWE', 'Zimbabwe', 'Зимбабве'),
('RS', 'Serbia', 'Serbien', 'Serbia', 'SERBIE', 'Serbia ', 'Сербия'),
('ME', 'Montenegro', 'Montenegro', 'Montenegro', 'MONTÉNÉGRO', 'Montenegro', 'Черногория'),
('BL', 'Saint Barthelemy !Saint Barthélemy', 'Saint-Barthélemy', 'Saint Barthélemy', 'SAINT-BARTHÉLEMY', 'Saint-Barthélemy', 'Сен-Бартелеми'),
('BQ', 'Bonaire, Sint Eustatius and Saba', 'Bonaire, Sint Eustatius und Saba', 'Bonaire, San Eustaquio y Saba', 'BONAIRE, SAINT-EUSTACHE ET SABA', 'Isole BES', 'Синт-Эстатиус и Саба'),
('CW', 'Curacao !Curaçao', 'Curaçao', 'Curaçao', 'CURAÇAO', 'Curaçao', 'Кюрасао'),
('MF', 'Saint Martin (French part)', 'Saint-Martin (franz. Teil)', 'Saint Martin (parte francesa)', 'SAINT-MARTIN (PARTIE FRANÇAISE)', 'Saint-Martin', 'Сен-Мартен'),
('SX', 'Sint Maarten (Dutch part)', 'Sint Maarten (niederl. Teil)', 'Sint Maarten (parte neerlandesa)', 'SAINT-MARTIN (PARTIE NÉERLANDAISE)', 'Sint Maarten ', 'Синт-Мартен'),
('SS', 'South Sudan', 'Sudsudan!Südsudan', 'Sudán del Sur', 'SOUDAN DU SUD', 'Sudan del Sud', 'Южный Судан');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `notverifieduser`
--

CREATE TABLE `notverifieduser` (
  `UID` int(11) NOT NULL,
  `Username` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Vorname` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Nachname` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Password` varchar(255) CHARACTER SET utf8 NOT NULL,
  `EMail` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Land` varchar(10) CHARACTER SET utf8 NOT NULL,
  `Ort` varchar(255) CHARACTER SET utf8 NOT NULL,
  `PLZ` int(11) NOT NULL,
  `Strasse` varchar(255) CHARACTER SET utf8 NOT NULL,
  `HausNr` int(11) NOT NULL,
  `verificationCode` varchar(255) CHARACTER SET utf8 NOT NULL,
  `creationDate` date NOT NULL,
  `creationTime` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `notverifieduser`
--

INSERT INTO `notverifieduser` (`UID`, `Username`, `Vorname`, `Nachname`, `Password`, `EMail`, `Land`, `Ort`, `PLZ`, `Strasse`, `HausNr`, `verificationCode`, `creationDate`, `creationTime`) VALUES
(53, 'hgjkhklajsdlka', '', '', '$2y$12$mx2v1X2j2L7YAnoLzFp0Qew6bktr28GTxxChHwuillWyCPP.io9g6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '17:11:25'),
(54, 'khjkhjkhjkhkjhkj', '', '', '$2y$12$O/8fVD2axhTEj5LbPj6AmOC3aL2IneTsAuseQcDqK6Th1gKbu1M8a', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '17:12:29'),
(55, 'hlhjkahskjdfh', '', '', '$2y$12$xUWJN2U1lLGLL1o8yqk5COR4CFNxjFHnP/UDUoq0.wIkRNtkjv1q2', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:23:20'),
(56, 'hgasdhjkgajhsd', '', '', '$2y$12$kIhsI4U6k4mhDi.uT8E83eLYemTfgygdcW24S2c793KzSgCPUXf5K', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:25:22'),
(57, 'khkjhkhkjhkjhk', '', '', '$2y$12$kc3nh6EssPRsE5dPSOCkvOXjqaa/Zzwaj1qrQbPQtAJErj/BL9fc.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:27:12'),
(58, 'wrwerwerwe', '', '', '$2y$12$9WVtOYP6Bz2fD8KSF8fuee0v9d61gV5x/8mO43m36vvOAMuevTbKq', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:30:33'),
(59, 'hkjghjgasjhkgfajk', '', '', '$2y$12$DFHxevjgZ/40K0O7bPLPdePpGPzMmRM6CGGVq5Y0q931CpcwUrhOS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:33:02'),
(60, 'jhjlhajkfhdlkah', '', '', '$2y$12$FPmAJk/nKrPKJxEK3XehneLxJUdrpoY1weILZLb/Fuhg8dk6J6fDu', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '20:39:22'),
(61, 'khkjhkjahksdhkja', '', '', '$2y$12$rdw//FHv9yulXf5jl1FkrOaM02HDP/CTsfi5utd4n04lIU3jpmoTC', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '22:39:23'),
(62, 'rztrtzrtzrztr', '', '', '$2y$12$ldBGOl5TFC2nKkraclxyLe/pEUhN.aclnw.Io7ZJ.DYyGBj7UMarK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:15:50'),
(63, 'gjgjhgjhgjh', '', '', '$2y$12$jnn5sTEnZW7yooU9.X5PSuInhdUrA9WS18KyyGtCXf5Z49dNJ8Eau', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:19:10'),
(64, 'jhlakhdfkjl', '', '', '$2y$12$1JUYAK/JofHl0d9DPmwoGOyk.KBkNf7t7m1HlWgOKzH7hNY90fyma', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:31:06'),
(65, 'fjgfgjfhgfhf', '', '', '$2y$12$/Iz0kNUDgr1ptE96foGBW.9lFCwP4KG258.NO2P6vn3XaLh3PNIKS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:36:03'),
(66, 'jkhdlkjahsf', '', '', '$2y$12$t5TJa72neBzHjZJ0yJENtuWAAu1ugzQsKofD2RbNb.9zuS5afPOmK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:37:54'),
(67, 'adfadfadf', '', '', '$2y$12$Jm7HRZMXF/PqOIHeuYeokO3XveVU3yA7abDJ9993P6lMDPhEzro9C', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:42:01'),
(68, 'fkufhjfgjhkg', '', '', '$2y$12$uedjCA82zmPFYoTcsq9ch.U94bBnhDUxdKbcLsqmwoIQ5FE9h4XWS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:46:33'),
(69, 'hkhjkhkjhjkhkhk', '', '', '$2y$12$8KsZjZIpKCxQWo9yfoeJMOaSCQ2/ucWyXbMCL0gPUQ.79apds/7Ja', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:48:27'),
(70, 'hlkhjhjkhadf', '', '', '$2y$12$/i8auPlxciTT/fCTABGqyeCY63WsYjcImQpl00a5jl/SJ1JxhZ6Xi', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-23', '23:55:19'),
(71, 'lhjklkjlkas', '', '', '$2y$12$vCRXD0FhY.0.21q2tkcNB.mOkq/pB0uPYzigs.nSYs.bTdmx5LTdW', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:26:35'),
(72, 'asddasda', '', '', '$2y$12$QHSKvg6/mUknFgbCNFUpieBfvZCvN3QPGytG/YEjLbQEG./K9fhO6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:28:18'),
(73, 'sdfgaga', '', '', '$2y$12$JYMAj5jzZXb9BucfsqLQoOgtXb1aYf3wHH1xPn6d1CbGrcMiucK5u', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:31:30'),
(74, 'sdfhslkdfjal', '', '', '$2y$12$2hGg0dRxpohoOUHT0u8xTOSlgtxOv.N6HRkap1013ZSVPe/x12jym', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:33:57'),
(75, 'zukqgksgakhs', '', '', '$2y$12$44tO1gy7YJd1SFuhBTnNkOrZxRu1/mRUqqeh1i5zJnxeW8qQvNO4.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:37:23'),
(76, 'lkuewhlhkshaj', '', '', '$2y$12$K1b5cDQYiZub.OlPqHL94.nTQW8DKeJKZzrGd4e0W/eHGk0PbCsaS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:44:07'),
(77, 'asdafsdf', '', '', '$2y$12$CLTi8jB1/WfnBnG.aEuIyOrTXP/.sXiINPFDpb6cguSxQeTCPw9tC', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:44:46'),
(78, 'ajgdshjkagsd', '', '', '$2y$12$E1lOPPC1gZvej8eD.qGG1.Jb8tgnTIW6E.zvPT7eTc7tuW6z6mzym', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:47:10'),
(79, 'jkdhlsajfh', '', '', '$2y$12$PnPl/mf6vrzdNRexSlqrv.pgHGP.R0WU.zNXg8.0enhNmv2uPuCOa', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:50:24'),
(80, 'jkhghjkagdfsk', '', '', '$2y$12$Q8Xj2umQYwsCy5tpGpJGh.MiuJsD1tUsSQRSGV.4YzOI3CCC4Yj8K', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:51:49'),
(81, 'uizasduk', '', '', '$2y$12$CrE859FWQU/jZXFSb0nEj.PSI75jAjcRADGaFGVn2PgqMgTUcDTOW', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:52:34'),
(82, 'qwdlksah.k', '', '', '$2y$12$QTStrlfbpT8agEqX/gyexejaioNp8SkZ6EPtIvf6hj9v1qNakp.B6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:54:46'),
(83, 'khkjashdkja', '', '', '$2y$12$C3BCT5Jjl8KzbmHYLuQ.luGTatk6qYYtwqFmaG/YL5cQlSrsEq9OS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '16:56:32'),
(84, 'uihkjhkajhd', '', '', '$2y$12$HGtpGxnlPEG6s/Mq1CS7g.U/SK0hwzYTaSJKFLoS5noimzocTPxBK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '17:05:43'),
(85, 'kjhkjhskjfd', '', '', '$2y$12$Q7S3RM8mNQtSiJyoALGfIelKnJ6rYJGOtxDSPhw.gKw.blaXHj6s.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '17:07:12'),
(86, 'hdsjfkajdhf', '', '', '$2y$12$SlqsRFX6ONJOIKJYbBrXTuurWCs8GCID/e5MPRmmIrnt0gDGcD0PO', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '17:09:31'),
(87, 'adafasfdad', '', '', '$2y$12$QXrNzS9Iaj.3ctQx.zMFS.G12xgpTwiaS1GLdnxSm2YBphBEJYUY2', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '17:10:00'),
(88, 'qawdasdasd', '', '', '$2y$12$KgvVjDjLY.l1iXPV06ETF.KjxNMsgBmcPt4cJ/6dkw94OZJ2h5X/S', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '17:10:52'),
(89, 'hjkkjhkjhkjhjkasd', '', '', '$2y$12$Uim3/c0QMMcHotqdXvoTHuTdy2HAX9zde0WFgeKArDtAerPECWo7S', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '18:01:00'),
(90, 'ghjghjgjahsgd', '', '', '$2y$12$3qI874D0nZXhznLgxKLdyOB.KjEAr2kkQwFhpTaT1IC4uBSPI4dAK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-28', '18:05:43'),
(91, 'kukauhliahdsa', '', '', '$2y$12$SsqMh40eAqCY5YAoqfJuqugZjC7Kal45Q9am6DiDfPrhT6xtyLie2', 'stefanjkf.test@gmail.com', 'AR', 'akjhaklhrekjf', 1231231, 'jkhaljkdhfglkjah', 123, '8d89df423904789dd9f3a09ee9b5b0d3', '2019-12-28', '18:06:58'),
(92, 'etuizquoezui', '', '', '$2y$12$4vhXTJBwxncHzwXJ/rX2C.d8RAY7mNn.DXnW.2I/ayYJ.Cm3SA8zG', 'stefanjkf.test@gmail.com', 'AQ', 'kqhlrgq', 67824378, 'djlskjf', 12341, 'fa501054640a7b9ac7d92da8a65b42dd', '2019-12-28', '18:10:07'),
(93, 'jkgjgjhgjghk', '', '', '$2y$12$kg2oPRa38ejQ.GuTvZAswuCRqmSqNvXh62wz5HjrOV3BUQjCzwlC2', 'a.a@a.com', '', '', 0, '', 0, '', '2019-12-29', '11:45:56'),
(94, 'rsafgakhkj', '', '', '$2y$12$SY26//STpYKnK63nKGgHUeFaxUYIyg0KRJkFY4ialoVYoWs.AIp.i', 'a.a@a.com', '', '', 0, '', 0, '', '2019-12-29', '11:49:05'),
(95, '', '', '', '', 'stefanjkf.test@gmail.com', 'AQ', 'dsfds', 123, 'sdfsdfs', 1231, 'd24f71c870ab4a6635166475f1fc898c', '2019-12-29', '11:52:07'),
(96, '', '', '', '', 'stefanjkf.test@gmail.com', 'AO', 'jhjahkjhksd', 32131, 'dfagdsgs', 1231, '8c219f1b3ef3d345fe28639ff3560988', '2019-12-29', '11:54:20'),
(97, 'hfghgjg', '', '', '1231231', 'stefanjkf.test@gmail.com', 'AD', 'afehgajhdga', 123, 'adfgsaf', 123, '0012446fd938283c2a4068fe85ee4140', '2019-12-29', '11:58:42'),
(98, 'hkjgsajdghjags', '', '', '$2y$12$lGnPGPK0Erlo9Sap2ETqI.tHCJAT.PZg5rnL1u9/DGEueqa/.T4I6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:03:17'),
(99, 'rfasadfadfs', '', '', '$2y$12$xXk0aLhWnbAJ/OG8xs2xbu0T2tXS1iArlAJRmjBcNAIBDzmFsquGq', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:03:23'),
(100, 'hgadjsgakjhfga', '', '', '$2y$12$Nuxk2ZNiC06xXHXxQIDiXOagss1RWrgumqq2zbNe7p1aJH4EnPA4m', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:04:19'),
(101, 'hgjdjasgdjhgjH', '', '', '$2y$12$ION2lb8h4k11bwVFt2lWxOwZ2Vw5ZNfIO0ZOppQpzt0YGbrSVd0KK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:07:01'),
(102, 'jhasgdfhg', '', '', '$2y$12$2oOUhv4VJJurhmpPA0YJbe3Rd5QXkZ21uCvMJ87OObhrxVQ/uyQrG', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:11:40'),
(103, 'hjkkhajkhjk', '', '', '$2y$12$go5ZsuYkABPts4wKLZajBOdb7EmXmXT2Nk7EVutHwa1FEPCoIwNhu', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:14:03'),
(104, 'sgdzuagkzd', '', '', '$2y$12$SZz84Pgyk.bU95MwQVsswOTEVXARdJAXSWoKwcoP8yXdxcDu5QNGq', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:16:18'),
(105, 'ahgfdkajgj', '', '', '$2y$12$CSulGzxA0l3Ctw6LU/X09OCeHRM4pYrvPUIkXdohFBAMq27w.SXTu', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:17:46'),
(106, 'uhajsdghfs', '', '', '$2y$12$E7vwIqdHsheyHqYGuC484OW3b.sCHGuaCTZACaB9HZuQMf5.CIGlu', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:19:38'),
(107, 'adfadfadff', '', '', '$2y$12$B4gZbJ1CwDsy6Ka/ACi9Z.d.ETI1OfqfFPqQTDog8Cc7v0Y26SbMG', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:25:36'),
(108, 'jbfhjadgfakhjgf', '', '', '$2y$12$umeE0xGNL0sBg9wPeHw4Uu96l8M.Dves0Y0f/e31n9Ai/uqedoGWy', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:25:57'),
(109, 'zgdjagshdjgajh', '', '', '$2y$12$a0LsUMNT7FT5ECwyuXr6tOaeW2kXZIxJxv0Gs1V4ZXeDKTcfpwVza', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:26:39'),
(110, 'afdadfsagkhja', '', '', '$2y$12$WICFrxypmZd1lrN/9DsLeeRqZCk1sMjwL3n3vEjehwsCvoN1iOw/2', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:27:51'),
(111, 'agdsjhgjhgj', '', '', '$2y$12$wkXGWhNlFD1FLo95ihrXueUK2QKvQt8PRbj07BwwRydDYjmBgmUqS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:29:06'),
(112, 'jhsdgfsgdfhj', '', '', '$2y$12$McsoOt4Jwlodiul.8UHIduHE4dw.SIX1SVCDw3xxhNX4NabgzpKRe', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:29:38'),
(113, 'hgjkagjg', '', '', '$2y$12$SfrCEA0qvG12/QCKXhL/E.fZmqcZZpVvb6jvAESESnIWKvFmTKo4y', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:30:04'),
(114, 'ghfajfajghds', '', '', '$2y$12$7aEnQFvmg8e2x19sjhd0IeUEvXq6SAMJSfv4iVgF/ojzOffmDZVI2', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:47:00'),
(115, 'hgfgfjgakdsa', '', '', '$2y$12$eTAf6eMLa17biUaKOksjHeSYfgLA7HKGgJsL411IaAqiMw7WkXvP6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:47:57'),
(116, 'kjhlhjshKLHSDAL', '', '', '$2y$12$PhmNWp8xNZwO8guq4OFohOUywGIbaniUQ1/9gV2puyXSIT2hntpxy', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '12:49:07'),
(117, 'jhjkhsadkjhkaj', '', '', '123123', 'stefanjkf.test@gmail.com', 'DZ', 'awdada', 12312, 'awsdfa', 123, 'be03504a6a1b4c998df38434a81c369f', '2019-12-29', '13:17:42'),
(118, 'wefakfhelkh', '', '', '$2y$12$wu0EEZPLaJONqMIe2gJOBeky5fxiJ6EpFqgVTWLXvkt4Dm1wfJ19i', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '13:18:18'),
(119, 'nbvdmvbnvm', '', '', '$2y$12$jQhqcPfmEBNvWSCC7iv6N.FkGTQUCUKZ9Z8etn2.VBMlbsbC.gptq', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '13:19:44'),
(120, 'sdjbHJDSBHFKhj', '', '', '$2y$12$oD6IkZlld6OlrtSNGul6Z.LZ3eJjtzNFKQUJsB6CJIIVUnuFcQA.q', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2019-12-29', '13:21:17'),
(121, 'suiasdziu', '', '', '123123', 'stefanjkf.test@gmail.com', 'AD', 'uzasdtfuzadtiauzti', 123, 'asdaff', 1231, 'cfc601259622a2146fd61cbc5e93d873', '2019-12-29', '13:22:04'),
(128, 'sdfsdf', '', '', '$2y$12$prCxwhBHZjLc0tNNeZLGKOCZOtKpqc2Qe0kZwyy1FkFyuZn4K2Dpy', 'stefanjkf.test@gmail.com', 'AD', 'qwqew', 123, 'qweqwe', 213, '28b034cd3b3f4051213283ded8c9f1f4', '2020-02-23', '11:47:11'),
(129, 'kahsdjklahskld', '', '', '$2y$12$HH55Rg9XwyRW0U6wlKEM9ewYas.v33kFJoAOuwigjjvO2NQgl6GBm', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:36:41'),
(130, 'hjhalkjd', '', '', '$2y$12$mfaIHkYtX9gxZuLqh6MAKuZ2fjIhKfx03W.loMLOvlIMGhKcWiYvK', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:38:14'),
(131, 'uouio', '', '', '$2y$12$WFgafSqqlGIaASofh5bABOKpK0IFNl/aQokgCgBAvbd54wiq49r5G', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:38:52'),
(132, 'adsasd', '', '', '$2y$12$2swAUe4tNAOFlDylxFoMMO68b/aajGbQuMbO58VlszCnUN7AcNiwe', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:40:24'),
(133, 'sfdsfsdf', '', '', '$2y$12$m88eJ3RwcD6uoJrPpD20F.mOVuMjylvhXwVHsNjwDx5dGz1cCo0oq', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:41:31'),
(134, 'gasdghsjag', '', '', '$2y$12$GeTqCu1UqqEtkubhvET7V.NU.yeppH0Z7MVrvHnHlk9hEjobqY4.q', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-02-24', '14:41:54'),
(135, 'hkjhkjh', '', '', '$2y$12$v8rasBptHqhuy9ttDGipxe0A5W79pNZDIa8XUlAh/uy0vu9nhTw5q', 'stefanjkf.test@gmail.com', 'AS', 'dsffdsfds', 234, 'sdfsd', 234, 'e610a36153be9511242ef7eb57f0fbff', '2020-02-24', '14:43:49'),
(136, 'yfdgyfs', '', '', '$2y$12$56fVft89v0shkJcvInIj..x9bDKbSfbis2pQrVNEp9I76lCxsBkoS', 'stefanjkf.test@gmail.com', 'DZ', 'weqe', 123, 'qweq', 1231, '648686a0b1e7cf5501312b483279e59b', '2020-02-24', '14:44:58'),
(138, 'sadsasd', '', '', '$2y$12$RaSRJg7OnGg3wcK5cwCG2.qsB1GFfCtJ8KpsFmo/hlFB2kwX.IOvu', 'stefanjkf.test@gmail.com', 'DZ', 'qweq', 123, 'qeq', 123, '7aee6b4e31e6bad78bc34b33d6519c21', '2020-02-26', '13:27:55'),
(140, 'rwerwerwre', '', '', '$2y$12$IYZHFQpfaGibNYNcwIO/EuFMSwEqcbRMixeqzm57kTjOm04B76yD6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-01', '19:57:06'),
(141, 'wtregsdfsgf', '', '', '$2y$12$05NH3pNwwA0F20HPGdnkre7204BWis/N.ExvM/INk1./Om8xmfaPG', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-01', '19:57:26'),
(143, 'naqibamini', '', '', '$2y$12$icZCqu5KHVSyJA3CGcyhWuJMsCV7gUBzp7cdmMz/mwCRz2qxqV5OK', 'naqibamini96@gmail.com', '', '', 0, '', 0, '', '2020-03-02', '09:09:56'),
(144, 'sdasda', '', '', '$2y$12$a4y9Z6oWft5RDB6MFvJt2.m7BrYqB5yuJ0cpcOPKcc7VYxFTEOuzq', 'stefanjkf.test@gmail.com', 'AD', 'qweqwe', 123, 'qewq', 123, '2d921bd5193b7b8139e73047037acc9a', '2020-03-02', '09:15:03'),
(147, '', '', '', '$2y$12$j8PDLY0JOkTC68nFIcMhM.vXJT41xXoEMMIN7yiM56taTdXcJljVa', '', '', '', 0, '', 0, '', '2020-03-21', '16:16:02'),
(148, 'gfdghdgfdhfd', '', '', '$2y$12$mbhm4z6HU79O2CNLX1gLxeuESJvQbYUOCANR9Jlz5HgeK94yO/cM2', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '16:29:21'),
(149, 'gfdghdgfdhfd', '', '', '$2y$12$vIG0dagslJjwphyACPYu6.z80FPMKUiXcXF.3ZjdMfGZZtZTMVjv6', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '16:38:25'),
(150, 'ajhgahjsdgjah', '', '', '$2y$12$oSRDSMoY4F69eU1xcfRWFOACC9VdlmJldJ1ipEmf4ediV2SKGMGsu', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:30:04'),
(151, 'jhgjhagsdkjhagsd', '', '', '$2y$12$RE6tPXehh04kaSjoI5td6ObyJQOqIz4ZRvJ2ioDyEz1fDxvh3wSv.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:31:36'),
(152, 'hagsdkjahgs', '', '', '$2y$12$zlTf8MdotuiC4GSQyIJWQurUI.XhczWWESblypKhJNoUfblwEfTK.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:33:24'),
(153, 'hgkjhgkajsdghf', '', '', '$2y$12$tisSa4yLyII.YIMvV8h8OO5YEgGnoJBkkxe85WKADTTarMT2svT8a', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:34:13'),
(154, '', '', '', '$2y$12$4zdCiUi4QQUvFJ0b0zsMHuCJb5JpovFWxt8S/ltrJUDo3l5c9WmVy', '', '', '', 0, '', 0, '', '2020-03-21', '17:41:54'),
(155, 'gjghjghj', '', '', '$2y$12$iSJlwwM7QJJTrwQrK3KILe5XOmR7YPfNBaB00vQQhwgtIXwKL1qwC', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:57:26'),
(156, 'ghajgsdhjag', '', '', '$2y$12$6oKxr.sYxHiasMXd0AbeIuf7ow7BA0SnV/lr1GP5TQRHahE1cxFpa', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '17:57:48'),
(157, 'gkjhgkhjgakhjgsdk', '', '', '$2y$12$MdDFZCyU3uVkAvnDas3e1ed5oXqlTZxRpCrzZBKg0xnxvu/KapO1O', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:28:19'),
(158, 'hlhjkhalskjhdla', '', '', '$2y$12$XfIPCLFjQECNx24uZZz1.unlzbcEBEiVjKh8AzuZmxkxKKUfdQ7s.', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:30:12'),
(159, 'hgjhagdhjashjd', '', '', '$2y$12$fSJbIZiykPjU1DPM1JxSH.FgAYNBlwype5IjAeJECs4GoANT7zcsm', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:31:39'),
(160, 'uuizouizoui', '', '', '$2y$12$0nc57JfwzY0Dq7hOAyi2quRG11L3stj1Y1ZlOt27hdcRz.n57g1/u', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:32:13'),
(161, 'hjkjhljasdjhlj', '', '', '$2y$12$rNnn0B4D1/wGhu/sywvmC.Nv.f5MYpiqn.6s/Mw7UVOTQksieI/3a', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:33:02'),
(162, 'ghjgkggkagsdk', '', '', '$2y$12$nZwh.9p.3hOrbudIjHxQ4uM30OvDxEoEPmMnCYXd2tGcxikbEnjFG', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-21', '18:33:41'),
(163, 'hjhlahdls', '', '', '$2y$12$N1uHo0PiRu1Rhr2PcUpg/uy0gNMGBmgbufu7FBF2433C4qRIjPK8u', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-23', '16:57:32'),
(164, 'dadfsdsdfs', '', '', '$2y$12$68ggiYhXCqie/I/B0MyqS.jVwKZma.0MSbHi2oJWjHUUyNVdM3USG', 'stefanjkf.test@gmail.com', 'AO', 'asdasd', 123, 'asdasd', 12, 'cce392c2a0b3e1c1b91a5be840a304e7', '2020-03-23', '16:58:48'),
(166, 'sdfsdfs', '', '', '$2y$12$hnbmLb9oFTPnWTOIC34JIOe7X/LLlr4oYHC5XdPw2xTp5m05h5FcO', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-23', '17:51:11'),
(167, 'sdflhajkdsf', '', '', '$2y$12$5TWL1uweoAhSMZU.xQSZa.iUg1/go18WpPe33x/S6Wik.T7/plP1G', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-23', '17:52:03'),
(168, 'hasljkdfha', '', '', '$2y$12$7heT.91JclEV0j1VA5HZMOrfIXZmbEWQN4qS6ascl67wnLq8KGcJS', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-24', '17:50:48'),
(169, 'asdfa', 'adfadsadf', 'asdasda', '$2y$12$54Lk31RN/Fe8dP7BH5fkyeTMPton4VJYksz0/8aCuJNulxR916qZy', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-24', '17:52:44'),
(170, 'sfsdfsdfsd', 'asdasda', 'asdasd', '$2y$12$txBKp8ZRQrEVHcPcRH303O8RNKb3duPMODGZvACfuvhyf7HMtgLcW', 'stefanjkf.test@gmail.com', '', '', 0, '', 0, '', '2020-03-24', '17:56:48'),
(171, 'asasdasd', 'asdasd', 'adsasd', '$2y$12$YTFANMtH5Ki5xhCarlrYIOoevfJLhWJeKYGGKxs3njni689xQtAoq', 'stefanjkf.test@gmail.com', '$land', '$ort', 5, '$street', 5, '$verificationCode', '2020-03-24', '17:58:20');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `productimage`
--

CREATE TABLE `productimage` (
  `PIID` int(11) NOT NULL,
  `path` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `productimage`
--

INSERT INTO `productimage` (`PIID`, `path`) VALUES
(1, 'pictures/nail1.jfif'),
(2, 'pictures/plank1.jfif'),
(3, 'pictures/plank2.jfif'),
(4, 'pictures/staffel1.jfif'),
(5, 'pictures/schraube1.jfif'),
(6, 'pictures/spanplatte1.jfif'),
(7, 'pictures/Toast.jpg'),
(8, 'pictures/Brot.jpg'),
(9, 'pictures/Brot2.jpg'),
(12, 'pictures/Wurst.jpg'),
(13, 'pictures/Cola.png'),
(14, 'pictures/JavaUltraIDE.jpg'),
(15, 'pictures/Mineralwasser.jpg'),
(16, 'pictures/Fanta.jpg'),
(17, 'pictures/Bacardi.jpg');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `produkt`
--

CREATE TABLE `produkt` (
  `PID` int(11) NOT NULL,
  `Bez` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Preis` double NOT NULL,
  `Gewicht` double NOT NULL,
  `Volumen` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Beschreibung` varchar(10000) CHARACTER SET utf8 DEFAULT NULL,
  `ImgSource` varchar(255) CHARACTER SET utf8 NOT NULL,
  `PIID` int(11) NOT NULL,
  `CID` int(11) NOT NULL,
  `SCID` int(11) NOT NULL,
  `creationDate` date NOT NULL,
  `creationTime` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `produkt`
--

INSERT INTO `produkt` (`PID`, `Bez`, `Preis`, `Gewicht`, `Volumen`, `Beschreibung`, `ImgSource`, `PIID`, `CID`, `SCID`, `creationDate`, `creationTime`) VALUES
(1, 'Nagel 100mm', 0.03, 0, '', '<html>\r\n  <head>\r\n    \r\n  </head>\r\n  <body>\r\n    <p style=\"margin-top: 300\">\r\n      Hier k&#246;nnte Ihre Beschreibung stehen\r\n    </p>\r\n    <p>\r\n      &#55357;&#56860;\r\n    </p>\r\n  </body>\r\n</html>\r\n', 'pictures/nail1.jfif', 1, 1, 2, '2019-12-31', '12:00:00'),
(2, 'Nagel 120mm', 0.04, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/nail1.jfif', 1, 1, 2, '2019-12-31', '12:00:00'),
(3, 'Nagel 140mm', 0.05, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/nail1.jfif', 1, 1, 2, '2019-12-31', '12:00:00'),
(4, 'Nagel 160mm', 0.06, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/nail1.jfif', 1, 1, 2, '2019-12-31', '12:00:00'),
(5, 'Brett Lärche 23x120x3000', 5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank1.jfif', 2, 1, 1, '2019-12-31', '12:00:00'),
(6, 'Brett Fichte 40x200x3000', 6, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank2.jfif', 3, 1, 1, '2019-12-31', '12:00:00'),
(7, 'Brett Fichte 40x200x1000', 2, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank2.jfif', 3, 1, 1, '2019-12-31', '12:00:00'),
(8, 'Kantholz Fichte / Tanne sägerau 78x78x4000', 4, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/staffel1.jfif', 4, 1, 7, '2019-12-31', '12:00:00'),
(9, 'Kantholz Fichte / Tanne sägerau  78x78x3000', 3, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/staffel1.jfif', 4, 1, 7, '2019-12-31', '12:00:00'),
(10, 'Kantholz Fichte / Tanne sägerau  78x78x2500', 2.2, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/staffel1.jfif', 4, 1, 7, '2019-12-31', '12:00:00'),
(11, 'Kantholz Fichte / Tanne sägerau  78x78x5000', 4.5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/staffel1.jfif', 4, 1, 7, '2019-12-31', '12:00:00'),
(12, 'Brett Lärche  23x120x2500', 2.5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank1.jfif', 2, 1, 1, '2019-12-31', '12:00:00'),
(13, 'Brett Lärche  23x120x2000', 2, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank1.jfif', 2, 1, 1, '2019-12-31', '12:00:00'),
(14, 'Brett Lärche  23x120x4000', 4, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank1.jfif', 2, 1, 1, '2019-12-31', '12:00:00'),
(15, 'Brett Lärche  23x120x5000', 4.5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/plank1.jfif', 2, 1, 1, '2019-12-31', '12:00:00'),
(16, 'Schraube M16x50', 0.42, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/schraube1.jfif', 5, 1, 5, '2019-12-31', '12:00:00'),
(17, 'Schraube M16x40', 0.4, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/schraube1.jfif', 5, 1, 5, '2019-12-31', '12:00:00'),
(18, 'Schraube M16x60', 0.46, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/schraube1.jfif', 5, 1, 5, '2019-12-31', '12:00:00'),
(19, 'Spanplatte 38x1800x1000', 15, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/spanplatte1.jfif', 6, 1, 6, '2019-12-31', '12:00:00'),
(20, 'Spanplatte 38x1800x500', 10, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/spanplatte1.jfif', 6, 1, 6, '2019-12-31', '12:00:00'),
(21, 'Toast', 1.5, 0, '', 'Eisackla, Schuibuamtratza, Großkopfada, schau, dass di schleichst, Kittlschliaffa, gscherta Hamml, Fliedschal, Zeeefix, Dipfalscheißa, Schnointreiba, oide Schäsn, Ratschkathl, Biaschdal, Fünferl, schdaubiga Bruada, Umstandskrama, boaniga, glei foid da Wadschnbam um, Zefix, no amoi, Aff, Klobürschdn, misdiga Lausbua, Kircharutschn, Dreeghamml, Pfundsau, Hockableiba, Katzlmacha, Hopfastanga, Neidhamml, Knedlfressa, Fieschkoobf, Karfreidogsratschn, Vieh mit Haxn, Hoibschaariga, Krautara, Aushuifsbaya, Presssack, Beitlschneida, Bauernschädl, Hundsgribbe, Zefix, no amoi, Randstoamare, Auftreiwa, Bauernfünfa, Hampara, Pfundsau, Pfundsau, varreckter Hund, varreckter Hund, dreckata Drek!\n', 'pictures/Toast.jpg', 7, 2, 10, '2019-12-31', '12:00:00'),
(22, 'Brot', 5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.<br>Wir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/Brot.jpg', 8, 2, 10, '2019-12-31', '12:00:00'),
(35, 'Brot2', 2, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', 'pictures/Brot2.jpg', 9, 2, 10, '2019-12-31', '12:00:00'),
(36, 'Wurst', 1.15, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 12, 2, 12, '2019-12-31', '12:00:00'),
(38, 'Cola', 1, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 13, 2, 3, '2019-12-31', '12:00:00'),
(39, 'JavaUltraIDE', 129.99, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 14, 5, 11, '2019-12-31', '12:00:00'),
(40, 'Fanta', 1.2, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 16, 2, 3, '2020-02-14', '13:49:59'),
(41, 'JavaUltraIDE Education Edition', 50, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 14, 5, 11, '2020-02-14', '14:04:07'),
(42, 'Mineralwasser', 0.5, 0, '', 'Kurzem Ipsum, vielen vielen Dank. Das werden wir uns anschauen wenn es soweit ist. Am Ende des Tages gilt: Meine Haltung ist klar. Wir \r\nmüssen den Wirtschaftsstandort Österreich stärken. Genug ist genug. Das beste aus beiden Welten miteinander verbinden. Meine Position ist hier klar. Am Ende des Tages gilt: Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Wir werden alles tun um die Menschen zu entlasten. Genug ist genug. Am Ende des Tages gilt: Das beste aus beiden Welten miteinander verbinden. So haben wir das im Regierungsprogramm festgelegt. Lassen sie mich den Gedanken noch zu Ende führen.\r\n\r\nWir leben in einem Rechtsstaat. Das werden wir uns anschauen wenn es soweit ist. So haben wir das im Regierungsprogramm festgelegt. So haben wir das im Regierungsprogramm festgelegt. Sehr geehrte Damen und Herren: Wir müssen als starke Stimme in Europa auftreten. Vielen, vielen Dank. Wir werden niemanden zurücklassen. Ich vertrete hier immer schon diese Meinung. ', '', 15, 2, 3, '2020-02-18', '10:31:17'),
(43, 'Bacardi', 11.5, 0, '', 'Bavaria ipsum dolor sit amet mei Blosmusi Charivari, amoi dahoam von. Hoid Ohrwaschl Zidern von hoam Buam singd wann griagd ma nacha wos z’dringa sowos scheans, kumm geh. Oans, zwoa, gsuffa Spotzerl gfreit mi Klampfn Trachtnhuat wui wiavui iabaroi. Luja i sog ja nix, i red ja bloß nois muass so Habedehre Foidweg wann griagd ma nacha wos z’dringa wuid Gschicht des basd scho! Fensdaln zünftig Spuiratz Enzian eana. Oans do ghupft wia gsprunga kimmt mim Hetschapfah gwiss Gidarn Haberertanz. Is des liab moand gschmeidig Broadwurschtbudn hea blärrd Baamwach mim Radl foahn owe kloan i. Breihaus jo leck mi ghupft wia gsprunga kummd, mehra nois aba. Trihöleridi dijidiholleri Broadwurschtbudn Haferl anbandeln sauba zwoa, hod. Bittschön sammawiedaguad Goaßmaß, hinter’m Berg san a no Leit. ', '', 17, 2, 4, '2020-03-03', '10:15:35'),
(44, 'Kornspitz', 0, 0, '', '<html>\r\n  <head>\r\n    \r\n  </head>\r\n  <body>\r\n  </body>\r\n</html>\r\n', '', 0, 2, 10, '2020-03-19', '17:49:20');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `review`
--

CREATE TABLE `review` (
  `RID` int(11) NOT NULL,
  `PID` int(11) NOT NULL,
  `UID` int(11) NOT NULL,
  `Rating` int(11) NOT NULL,
  `ReviewText` varchar(4000) CHARACTER SET utf8 NOT NULL,
  `ReviewDate` date NOT NULL,
  `ReviewTime` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `review`
--

INSERT INTO `review` (`RID`, `PID`, `UID`, `Rating`, `ReviewText`, `ReviewDate`, `ReviewTime`) VALUES
(1, 1, 6, 5, 'Toll', '2020-02-24', '00:00:00'),
(2, 1, 6, 1, 'Nicht so toll', '2020-02-24', '00:00:00'),
(3, 1, 6, 2, 'Dreck', '2020-02-24', '00:00:00'),
(6, 13, 6, 4, 'asd', '2020-02-28', '12:19:42'),
(7, 7, 6, 3, 'asd', '2020-02-28', '12:22:29'),
(8, 7, 6, 1, '', '2020-02-28', '12:26:30'),
(9, 7, 26, 5, 'Alles in allem ein sehr gutes Produkt. Sehr preiswert, kann ich jedem empfehlen!', '2020-02-28', '12:35:22'),
(11, 6, 28, 1, 'Unsauber verarbeitet! Mein Holz hat auf einer Seite geschimmelt und wurde nicht zurückerstattet! Wo wurde das gelagert und was ist das für ein Kundenservice?!\n\nNicht empfehlenswert!', '2020-02-28', '12:36:39'),
(12, 39, 28, 5, 'Super tolle IDE! Schön übersichtlich und vor allem gut für Einsteiger und Profis! Kann ich nur weiterempfehlen!', '2020-02-28', '12:38:28'),
(13, 41, 28, 3, 'Für Schüler perfekt, jedoch für Profis eher nicht geeignet, da einige Funktionen wie Syntaxhighlighting bei SQL und co fehlen!\n\n', '2020-02-28', '12:39:48'),
(14, 7, 6, 3, '', '2020-02-28', '12:39:49'),
(16, 7, 6, 3, '', '2020-02-28', '12:43:11'),
(17, 7, 6, 5, '', '2020-02-28', '15:42:53'),
(18, 38, 29, 1, 'ungsund', '2020-03-01', '20:14:08'),
(19, 12, 6, 5, 'tolles Produkt!\nKann ich jedem weiterempfehlen!', '2020-03-01', '21:27:41'),
(20, 12, 30, 5, '', '2020-03-02', '09:19:23'),
(21, 7, 30, 5, 'SUPER', '2020-03-02', '09:22:39'),
(22, 38, 31, 5, 'Da ich jeden Tag über 25l Cola zu mir nehme habe ich endlich eine preiswerte Alternative zu der im Supermarkt gefunden, kann leider kein Latein und somit verstehe ich die Info zu dem Produkt nicht, bitte um Verbesserung. Sonst TOP! Moin Meister', '2020-03-02', '09:28:21'),
(24, 42, 31, 3, 'Schmeckt sehr nussig\n', '2020-03-02', '09:30:16'),
(25, 36, 26, 5, 'Produkt ist nun in richtiger Kategorie.\n', '2020-03-03', '11:03:59'),
(26, 43, 26, 5, 'Kann den Kauf jedem empfehlen!', '2020-03-03', '11:05:08'),
(27, 35, 31, 5, 'Perfekt für meine jährlichen Hamsterkäufe!', '2020-03-03', '11:06:54'),
(28, 43, 31, 5, 'Ballert!', '2020-03-03', '11:07:10'),
(29, 43, 7, 5, 'Perfekt', '2020-03-04', '09:29:42'),
(30, 7, 6, 4, 'Tolles Produkt', '2020-03-05', '08:52:19'),
(31, 7, 6, 5, '', '2020-03-05', '08:53:46'),
(32, 43, 6, 5, '', '2020-03-05', '08:54:23'),
(33, 43, 6, 5, '', '2020-03-05', '08:54:30'),
(34, 7, 6, 5, '', '2020-03-05', '08:55:20'),
(35, 7, 6, 5, '', '2020-03-05', '09:03:29'),
(36, 43, 6, 5, '', '2020-03-05', '09:05:59'),
(37, 7, 6, 5, '', '2020-03-05', '09:13:40'),
(38, 7, 6, 4, '', '2020-03-05', '09:15:31'),
(39, 7, 6, 5, '', '2020-03-05', '09:20:23'),
(40, 7, 6, 5, '', '2020-03-05', '09:20:39'),
(41, 7, 6, 5, '', '2020-03-05', '09:28:35'),
(42, 7, 6, 1, '', '2020-03-05', '09:30:00'),
(43, 7, 6, 4, '', '2020-03-05', '09:39:34'),
(44, 7, 6, 5, '', '2020-03-05', '09:40:46'),
(45, 7, 6, 5, '', '2020-03-05', '11:32:03'),
(46, 7, 6, 3, '', '2020-03-05', '11:32:39'),
(47, 7, 6, 5, '', '2020-03-05', '11:33:50'),
(48, 7, 6, 3, '', '2020-03-05', '11:34:36'),
(49, 7, 6, 5, '', '2020-03-05', '11:35:30'),
(50, 7, 6, 3, '', '2020-03-05', '11:36:49'),
(51, 7, 6, 5, '', '2020-03-05', '11:42:07'),
(52, 7, 6, 2, '', '2020-03-05', '11:50:42'),
(53, 7, 6, 2, '', '2020-03-05', '11:57:29'),
(54, 7, 6, 5, '', '2020-03-05', '12:02:09'),
(55, 7, 6, 4, '', '2020-03-05', '12:04:29'),
(56, 7, 6, 4, '', '2020-03-05', '12:04:36'),
(57, 7, 6, 4, '', '2020-03-05', '12:05:22'),
(58, 7, 6, 5, '', '2020-03-05', '12:05:36'),
(59, 7, 6, 1, '', '2020-03-05', '17:51:15'),
(60, 7, 6, 2, '', '2020-03-05', '17:51:26'),
(61, 7, 6, 4, '', '2020-03-05', '18:19:47'),
(62, 7, 6, 3, '', '2020-03-05', '18:35:32'),
(63, 7, 6, 4, '', '2020-03-05', '18:52:46'),
(64, 7, 6, 4, '', '2020-03-05', '19:04:15'),
(65, 7, 7, 2, 'test', '2020-03-07', '11:33:08'),
(66, 43, 7, 3, '', '2020-03-10', '15:19:59'),
(67, 43, 7, 4, '', '2020-03-10', '16:22:45');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `subcategory`
--

CREATE TABLE `subcategory` (
  `SCID` int(11) NOT NULL,
  `CID` int(11) NOT NULL,
  `Name` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `subcategory`
--

INSERT INTO `subcategory` (`SCID`, `CID`, `Name`) VALUES
(1, 1, 'Bretter'),
(2, 1, 'Nägel'),
(3, 2, 'alkoholfreie Getränke'),
(4, 2, 'Spirituosen'),
(5, 1, 'Schrauben'),
(6, 1, 'Spanplatten'),
(7, 1, 'Latten\r\n'),
(9, 3, 'test'),
(10, 2, 'Gebäck'),
(11, 5, 'IDEs'),
(12, 2, 'Fleischprodukte');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user`
--

CREATE TABLE `user` (
  `UID` int(11) NOT NULL,
  `Username` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Vorname` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Nachname` varchar(30) CHARACTER SET utf8 NOT NULL,
  `Password` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Email` varchar(255) CHARACTER SET utf8 NOT NULL,
  `PasswortResetCode` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Land` varchar(255) CHARACTER SET utf8 NOT NULL,
  `Ort` varchar(255) CHARACTER SET utf8 NOT NULL,
  `PLZ` int(11) NOT NULL,
  `Strasse` varchar(255) CHARACTER SET utf8 NOT NULL,
  `HausNr` int(11) NOT NULL,
  `creationDate` date NOT NULL,
  `creationTime` time NOT NULL,
  `cartId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_german2_ci;

--
-- Daten für Tabelle `user`
--

INSERT INTO `user` (`UID`, `Username`, `Vorname`, `Nachname`, `Password`, `Email`, `PasswortResetCode`, `Land`, `Ort`, `PLZ`, `Strasse`, `HausNr`, `creationDate`, `creationTime`, `cartId`) VALUES
(6, 'user1', 'Stefan', 'Schlaghuber', '$2y$12$LIY6BaIQxefgKsTGz70i0.RjaoNok/Fbat9nHc5UMedCaAtieM8Pm', 'stefanjkf.test@gmail.com', 'd030be3a6e17adc2181a598f274e1786', 'AT', 'Ringendorf', 2002, 'Hausnummer', 45, '0000-00-00', '00:00:00', 20),
(7, 'stefan', '', '', '$2y$12$KQ0gVD3deB4uoDVe62KlKORPRKdKgfKAuOt/lB6SCiwdLEw9fbeq.', 'stefanjkf.test@gmail.com', 'b8178049cf9f7ea19950263a57b5d9ca', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(8, 'david', '', '', '$2y$12$ZuMmiK88f.LkjcPu.5jJjO/wH2PNZId1mRB1EUcbQEEDVFar2GucK', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(9, 'Prager', '', '', '$2y$12$42yDug4Hqy8roGaYlL2UIepOeqo4dwxInsmyJk6ZYZxOw.ibaNaZG', 'stefanjkf.test@gmail.com', '', '', 'Musterdorf', 2000, 'Musterstrasse', 500, '0000-00-00', '00:00:00', NULL),
(10, 'test', '', '', '$2y$12$NK7F4tr025BaSMkzhQDLTukBuq4RqYN2w2Aw02WHD8JfFR7Wf/hce', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(11, 'test123', '', '', '$2y$12$JYWGDz/Z5RiiZKAuKcr4q.Ylz89e7Wc5oYdrmGkwQINE4OW4wi3eO', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(12, 'test1234', '', '', '$2y$12$icGKHPcf13YuoyAp2BjO3OhykjmP0IFT8p62DI5RjplYtt3JMKiyu', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(13, 'MaxPrager', '', '', '$2y$12$y3GNYUyJt/rqzgO9lklIxe6A/AdB7PNlU6t.yAiiOAreD4lUsUTh6', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(14, 'abcdef', '', '', '$2y$12$gSEPq3QS8q4OxspohRf57uuhCEsq7CPwqZX2a.UqSiUKM1uR3m1S6', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(15, 'naqibleo', '', '', '$2y$12$BpFncRHq8TfPVTRr.PL6Nu9Plmzp39kDdne5sB.kxdQLqErxM2Mme', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(16, 'ich', '', '', '$2y$12$.PuCGWXerLk9Go1ScxXnj.iHPWZJAoX1eBKe2mpwMWIEoa9BQByh.', 'ich@mail.me', '', 'AT', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(17, 'test12321', '', '', '$2y$12$9LgFPDaP.ltOzrAB39ne0OTKDdKhszxyP6vOrLkgbcTB62uBTtz4W', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', 0),
(18, 'teste9876', '', '', '$2y$12$YmzQ.oPIB3sFtC8M2BpMaeLIV.PNm0Oyc/Mx6.UwUF24dEAQ14gka', 'stefanjkf.test@gmail.com', '', 'AI', 'adasd', 23213, 'asdasd', 1231, '0000-00-00', '00:00:00', NULL),
(19, 'Juli0112', '', '', '$2y$12$P1BbrFNCHgoCv7YMUs6Nz.1vv51Gk3pyel/1o.u4pJLpWf55Vn1DK', 'stefanjkf.test@gmail.com', '', 'AT', 'Retz', 2070, 'Am Anger', 44, '2019-12-20', '16:02:32', NULL),
(20, 'hjagahjsgdhjagdjh', '', '', '$2y$12$fl/8wGjEaHpejAOg77DKDuMLeqE38qfX80rh64I6QVQBlC2sQIPSm', 'stefanjkf.test@gmail.com', '', 'AM', 'adfsafdsads', 2342, 'asdfagf', 234, '2019-12-23', '11:24:37', NULL),
(21, 'uazdgagdkhjgakjd', '', '', '$2y$12$vVbRRV.fRgFp0h0KG7NSs.z/IAd7bwu1Wd9709m1D3eyzL81EHRmC', 'stefanjkf.test@gmail.com', '', 'AS', 'zgtatuiatiuztud', 123, 'wfdasfad', 123, '2019-12-29', '13:23:39', NULL),
(22, 'prager1', '', '', '$2y$12$1fafLKqOAg3OHFe3lGTzD.hN2l82iJpo6TVYahUhbklyFxbYPz17y', 'stefanjkf.test@gmail.com', '', 'AT', 'Musterort', 5587, 'Musterstrasse', 21, '2020-01-08', '11:33:54', NULL),
(23, 'teset', '', '', '$2y$12$iuMSTkDfF6uCuAC1bwFxguJdEkWerCxVu2LdEew1ttNcBvOqledNe', 'stefanjkf.test@gmail.com', '1b77b965ff77122220125dfd4c9d80e7', 'AD', 'tzut', 123, 'wefwe', 1231, '2020-01-21', '11:11:50', NULL),
(31, 'waslmeier', '', '', '$2y$12$JE1RbXoLfT4wIj8VJXwyH.AYK0fr/3Ly6m8/pxNHmNOtWc4h0Mr3W', 'mw5waslmeier@gmail.com', '', 'IR', 'fbdg', 3456, '37', 23456, '2020-03-02', '09:19:21', NULL),
(32, 'abcdefgabc', '', '', '$2y$12$X3Y2NdNoXdhrX7UG.6W8PeCLWuL8vZNiDTNPuJhmBgFKopekIq1MC', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', 11),
(33, 'kjahgd', '', '', '$2y$12$6tF8w09T26.z2PZ./8QNDe86Eyp7LymmmX6vp1Y49Lya5aaAuOrSC', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', NULL),
(34, 'jhakhdka', '', '', '$2y$12$lTkj8V2ZMNmgx47C9oB3Te4/aX1W880Yje5tqzDYDlNOioJx/uwf6', 'stefanjkf.test@gmail.com', '', 'AT', 'asda', 123, 'asdasd', 123, '2020-03-23', '17:00:33', NULL),
(35, 'adsfadfsadasd', 'sfgsdfgsf', 'adsaa', '$2y$12$9hm6bCWeV9JuqtQ2HaAk4ugaQS9.QdeVGK.ui74Zpadxm.0hMC.0O', 'stefanjkf.test@gmail.com', '', 'AX', '', 0, '', 0, '2020-03-24', '18:01:52', NULL),
(36, 'regina75', 'Regina', 'Schlags', '$2y$12$0sO4H/PRMeLydycT5ajLQeJ8yw.XaeJwkB7s67PSuebZwExGYUJrK', '', '', 'AT', 'Ringendorf', 2002, 'Hausnummer', 45, '0000-00-00', '00:00:00', 0),
(37, 'hjkhasjkdhaksdh', '', '', '$2y$12$kbM37Qjgq7gV.w29I9j0A.b5YDAG.Beu2.Vg.4BqS012B9zlQbOy.', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', 18),
(38, 'sdfsdf', '', '', '$2y$12$oQk1sMn21Wx8EidgLy13q.3y6eKnNTWPfzh32Jlap4K9oHeH/abrW', '', '', '', '', 0, '', 0, '0000-00-00', '00:00:00', 19),
(39, 'abcdefgh', 'abcd', 'abcd', '$2y$12$50X/dk1y.lLISeMKrxeAZe2IQuXAArKGgWKaCDq3st2fWxEEMRD6W', '', '', 'AX', 'abcd', 1234, 'abcd', 123, '0000-00-00', '00:00:00', 0);

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `bestellposition`
--
ALTER TABLE `bestellposition`
  ADD PRIMARY KEY (`BPID`);

--
-- Indizes für die Tabelle `bestellung`
--
ALTER TABLE `bestellung`
  ADD PRIMARY KEY (`BID`);

--
-- Indizes für die Tabelle `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`CIID`);

--
-- Indizes für die Tabelle `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`CID`);

--
-- Indizes für die Tabelle `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`code`),
  ADD KEY `de` (`de`),
  ADD KEY `en` (`en`);

--
-- Indizes für die Tabelle `notverifieduser`
--
ALTER TABLE `notverifieduser`
  ADD PRIMARY KEY (`UID`);

--
-- Indizes für die Tabelle `productimage`
--
ALTER TABLE `productimage`
  ADD PRIMARY KEY (`PIID`);

--
-- Indizes für die Tabelle `produkt`
--
ALTER TABLE `produkt`
  ADD PRIMARY KEY (`PID`);

--
-- Indizes für die Tabelle `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`RID`);

--
-- Indizes für die Tabelle `subcategory`
--
ALTER TABLE `subcategory`
  ADD PRIMARY KEY (`SCID`);

--
-- Indizes für die Tabelle `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`UID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `bestellposition`
--
ALTER TABLE `bestellposition`
  MODIFY `BPID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;

--
-- AUTO_INCREMENT für Tabelle `bestellung`
--
ALTER TABLE `bestellung`
  MODIFY `BID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT für Tabelle `cart`
--
ALTER TABLE `cart`
  MODIFY `CIID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'cartitem-id', AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT für Tabelle `category`
--
ALTER TABLE `category`
  MODIFY `CID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT für Tabelle `notverifieduser`
--
ALTER TABLE `notverifieduser`
  MODIFY `UID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=173;

--
-- AUTO_INCREMENT für Tabelle `productimage`
--
ALTER TABLE `productimage`
  MODIFY `PIID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT für Tabelle `produkt`
--
ALTER TABLE `produkt`
  MODIFY `PID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT für Tabelle `review`
--
ALTER TABLE `review`
  MODIFY `RID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT für Tabelle `subcategory`
--
ALTER TABLE `subcategory`
  MODIFY `SCID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT für Tabelle `user`
--
ALTER TABLE `user`
  MODIFY `UID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
