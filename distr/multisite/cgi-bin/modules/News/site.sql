-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `news_group_tbl`
--

DROP TABLE IF EXISTS `news_group_tbl`;
CREATE TABLE `news_group_tbl` (
  `news_group_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_group_fld` text NOT NULL,
  `order_fld` mediumint(8) unsigned default '0',
  `dateformat_fld` varchar(32) default '',
  `page_id` mediumint(8) unsigned default NULL,
  PRIMARY KEY  (`news_group_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `news_group_tbl`
--


/*!40000 ALTER TABLE `news_group_tbl` DISABLE KEYS */;
LOCK TABLES `news_group_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `news_group_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `news_pix_tbl`
--

DROP TABLE IF EXISTS `news_pix_tbl`;
CREATE TABLE `news_pix_tbl` (
  `news_pix_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_id` mediumint(8) unsigned NOT NULL default '0',
  `alt_fld` text,
  `valign_fld` enum('top','bottom') NOT NULL default 'top',
  `align_fld` enum('left','right') default NULL,
  `url_fld` text NOT NULL,
  `main_fld` tinyint(3) unsigned NOT NULL default '1',
  PRIMARY KEY  (`news_pix_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `news_pix_tbl`
--


/*!40000 ALTER TABLE `news_pix_tbl` DISABLE KEYS */;
LOCK TABLES `news_pix_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `news_pix_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `news_settings_tbl`
--

DROP TABLE IF EXISTS `news_settings_tbl`;
CREATE TABLE `news_settings_tbl` (
  `news_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_settings_fld` tinytext NOT NULL,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`news_settings_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `news_settings_tbl`
--


/*!40000 ALTER TABLE `news_settings_tbl` DISABLE KEYS */;
LOCK TABLES `news_settings_tbl` WRITE;
INSERT INTO `news_settings_tbl` VALUES (1,'template','<tr bgcolor=\"e5e5e5\">\r\n<td><h2 class=\"news\">{HEAD}</h2></td>\r\n<td><h3 class=\"date\">{DATE}</h3></td></tr>\r\n<tr><td colspan=\"2\" class=\"tj\">{BODY}</td></tr>\r\n<tr><td colspan=\"2\" align=\"right\" height=\"40\" style=\"background:url(/img/bottom_line1.gif) repeat-x left top;\" valign=\"top\"><img src=\"/img/bottom_line2.gif\" width=\"52\" height=\"13\" border=\"0\"></td></tr>\r\n','Шаблон вывода одной новости.','TEXT'),(2,'template_digest','<tr><td><img src=\"/img/1pix.gif\" width=\"1\" height=\"1\" border=\"0\"></td>\r\n<td valign=\"top\" class=\"data\">{DATE}</td>\r\n<td valign=\"top\" class=\"tl\"><a href=\"/news/index.shtml#{ID}\"  class=\"link\">{HEAD}</a></td></tr>','Шаблон новости для Главной страницы (дайджест)','TEXT'),(3,'digest_width','64','Количество символов в новости для обрезки на Главной странице (дайджест)','NUMBER'),(4,'digest_quant','3','Количество новостей на Главной странице (дайджест)','NUMBER'),(5,'quant','5','Количество новостей при входе на страницу Новостей','NUMBER'),(6,'template_system','<td align=\"tl\"><input type=\"checkbox\" name=\"news\" value=\"{ID}\"></td><td class=\"tl\">{DATE}</td>\r\n<td class=\"tl\"><b>{HEAD}</b><br>{BODY}</td>','Шаблон для вывода Новостей в Системе','TEXT'),(7,'month_word','1','Показывать месяц словом в Новостях','ON/OFF[1]');
UNLOCK TABLES;
/*!40000 ALTER TABLE `news_settings_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `news_tbl`
--

DROP TABLE IF EXISTS `news_tbl`;
CREATE TABLE `news_tbl` (
  `news_id` mediumint(8) unsigned NOT NULL auto_increment,
  `date_fld` timestamp NOT NULL,
  `body_fld` mediumtext NOT NULL,
  `head_fld` text NOT NULL,
  `news_group_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`news_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `news_tbl`
--


/*!40000 ALTER TABLE `news_tbl` DISABLE KEYS */;
LOCK TABLES `news_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `news_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `mailsend_news_tbl`
--

DROP TABLE IF EXISTS `mailsend_news_tbl`;
CREATE TABLE `mailsend_news_tbl` (
  `mailsend_news_id` mediumint(8) unsigned NOT NULL default '0',
  `ts_fld` datetime default NULL,
  PRIMARY KEY  (`mailsend_news_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `mailsend_news_tbl`
--


/*!40000 ALTER TABLE `mailsend_news_tbl` DISABLE KEYS */;
LOCK TABLES `mailsend_news_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `mailsend_news_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `news_tr_tbl`
--

DROP TABLE IF EXISTS `news_tr_tbl`;
CREATE TABLE `news_tr_tbl` (
  `news_tr_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_tr_fld` text NOT NULL,
  `title_fld` text NOT NULL,
  `sql_fld` text NOT NULL,
  PRIMARY KEY  (`news_tr_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `news_tr_tbl`
--


/*!40000 ALTER TABLE `news_tr_tbl` DISABLE KEYS */;
LOCK TABLES `news_tr_tbl` WRITE;
INSERT INTO `news_tr_tbl` VALUES (1,'Неделя','week','DATE_SUB(NOW(), INTERVAL 7 DAY)'),(2,'Месяц','month','DATE_SUB(NOW(), INTERVAL 1 MONTH)'),(3,'Три месяца','month3','DATE_SUB(NOW(), INTERVAL 3 MONTH)'),(4,'Полгода','halfyear','DATE_SUB(NOW(), INTERVAL 6 MONTH)'),(5,'Год','year','DATE_SUB(NOW(), INTERVAL 1 YEAR)'),(6,'Все','all','');
UNLOCK TABLES;
/*!40000 ALTER TABLE `news_tr_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

