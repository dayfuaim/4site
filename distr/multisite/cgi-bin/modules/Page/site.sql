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
-- Table structure for table `printtemplate_tbl`
--

DROP TABLE IF EXISTS `printtemplate_tbl`;
CREATE TABLE `printtemplate_tbl` (
  `printtemplate_id` int(10) unsigned NOT NULL auto_increment,
  `printtemplate_fld` tinytext NOT NULL,
  `top_fld` text NOT NULL,
  `bottom_fld` text NOT NULL,
  PRIMARY KEY  (`printtemplate_id`),
  KEY `template_id` (`printtemplate_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `printtemplate_tbl`
--


/*!40000 ALTER TABLE `printtemplate_tbl` DISABLE KEYS */;
LOCK TABLES `printtemplate_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `printtemplate_tbl` ENABLE KEYS */;

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
-- Table structure for table `menupix_tbl`
--

DROP TABLE IF EXISTS `menupix_tbl`;
CREATE TABLE `menupix_tbl` (
  `menupix_id` smallint(5) unsigned NOT NULL auto_increment,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `menupix_fld` tinytext NOT NULL,
  `menupixurl_fld` text,
  `menupixfolder_fld` text,
  PRIMARY KEY  (`menupix_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `menupix_tbl`
--


/*!40000 ALTER TABLE `menupix_tbl` DISABLE KEYS */;
LOCK TABLES `menupix_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `menupix_tbl` ENABLE KEYS */;

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
-- Table structure for table `template_tbl`
--

DROP TABLE IF EXISTS `template_tbl`;
CREATE TABLE `template_tbl` (
  `template_id` int(10) unsigned NOT NULL auto_increment,
  `template_fld` tinytext NOT NULL,
  `top_fld` text NOT NULL,
  `bottom_fld` text NOT NULL,
  PRIMARY KEY  (`template_id`),
  KEY `template_id` (`template_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `template_tbl`
--


/*!40000 ALTER TABLE `template_tbl` DISABLE KEYS */;
LOCK TABLES `template_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `template_tbl` ENABLE KEYS */;

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
-- Table structure for table `menu_settings_tbl`
--

DROP TABLE IF EXISTS `menu_settings_tbl`;
CREATE TABLE `menu_settings_tbl` (
  `menu_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `menu_settings_fld` tinytext,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`menu_settings_id`),
  KEY `settingname` (`menu_settings_fld`(250))
) TYPE=MyISAM;

--
-- Dumping data for table `menu_settings_tbl`
--


/*!40000 ALTER TABLE `menu_settings_tbl` DISABLE KEYS */;
LOCK TABLES `menu_settings_tbl` WRITE;
INSERT INTO `menu_settings_tbl` VALUES (1,'reltext','Ещё по теме:','Текст перед связанными страницами','TEXT'),(2,'title_global','','Общая часть title','TEXT'),(3,'levels','3','Количество уровней вложенности для Карты Сайта','NUMBER'),(8,'related_template','<tr><td width=\"10\" class=\"grey6\" valign=\"top\"><img src=\"/img/line_grey.gif\" width=\"10\" height=\"8\" border=\"0\"></td><td width=\"100%\" class=\"tl\"><a href=\"{URL}\">{LABEL}</a></td></tr>','Шаблон вывода одного связанного документа (в списке связанных).','TEXT'),(9,'common_keywords','','Ключевые слова, общие для всего сайта','TEXT'),(10,'map_templ','<p class=\"map{LEVEL}\">{BULLET}&nbsp;<a class=\"map{LEVEL}\" href=\"{URL}\">{LABEL}</a></p>','Шаблон для вывода одного пункта Карты Сайта','TEXT'),(11,'map_templ_sel','<p class=\"map{LEVEL}\"><b>{BULLET}&nbsp;{LABEL}</b></p>','Шаблон для вывода самой Карты Сайта в дереве Карты Сайта','TEXT'),(12,'cluster_map_templ_head','<h2 style=\"margin-bottom:0px; margin-top:0px;\"><a href=\"{URL}\" class=\"link\" style=\"font:bold;\"><nobr>{LABEL}</nobr></a></h2>','Шаблон для вывода заголовка раздела I уровня в Cluster Map.','TEXT'),(13,'cluster_map_templ','<tr><td class=\"map{LEVEL}\">{BULLET}<a href=\"{URL}\" class=\"map{LEVEL}\">{LABEL}</a></td></tr>','Шаблон для вывода пункта II уровня в Cluster Map.','TEXT'),(14,'cluster_map_templ_sel','<tr><td class=\"map{LEVEL}\">{BULLET}{LABEL}</td></tr>','Шаблон для вывода выеленного пункта II уровня в Cluster Map.','TEXT'),(15,'WYSIWYG','ON/OFF[1]','Показывать HTMLArea?','ON/OFF[1]'),(16,'stat_depth','1',NULL,'NUMBER');
UNLOCK TABLES;
/*!40000 ALTER TABLE `menu_settings_tbl` ENABLE KEYS */;

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
-- Table structure for table `keywords_tbl`
--

DROP TABLE IF EXISTS `keywords_tbl`;
CREATE TABLE `keywords_tbl` (
  `keywords_id` int(3) unsigned NOT NULL auto_increment,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `add_page_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`keywords_id`),
  KEY `page_id` (`page_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `keywords_tbl`
--


/*!40000 ALTER TABLE `keywords_tbl` DISABLE KEYS */;
LOCK TABLES `keywords_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `keywords_tbl` ENABLE KEYS */;

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
-- Table structure for table `servpage_tbl`
--

DROP TABLE IF EXISTS `servpage_tbl`;
CREATE TABLE `servpage_tbl` (
  `servpage_id` mediumint(8) unsigned NOT NULL auto_increment,
  `content_fld` varchar(100) NOT NULL default '',
  `template_id` mediumint(8) unsigned NOT NULL default '0',
  `url_fld` text NOT NULL,
  PRIMARY KEY  (`servpage_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `servpage_tbl`
--


/*!40000 ALTER TABLE `servpage_tbl` DISABLE KEYS */;
LOCK TABLES `servpage_tbl` WRITE;
INSERT INTO `servpage_tbl` VALUES (1,'kjhafkjhdsfkjhsfkjhe t;liuh e;oih ;toih toih t;oi th;oait h; oihn ;o t\r\n t\r\n[a t\r\n[w 0ti\r\naw[e0ti\r\na',11,'/hhh.shtml'),(3,'kjasfkjhsfkuhs o8i etp98h tep98ha t\r\na t\r\nja \r\nj a6349\r\nh3a 64ha 34\r\np9 a3',1,'/yyy.shtml');
UNLOCK TABLES;
/*!40000 ALTER TABLE `servpage_tbl` ENABLE KEYS */;

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
-- Table structure for table `page_tbl`
--

DROP TABLE IF EXISTS `page_tbl`;
CREATE TABLE `page_tbl` (
  `page_id` mediumint(8) unsigned NOT NULL auto_increment,
  `url_fld` text,
  `label_fld` tinytext,
  `master_page_id` mediumint(8) unsigned NOT NULL default '0',
  `enabled_fld` enum('1','0') NOT NULL default '0',
  `pagesection_id` mediumint(8) unsigned NOT NULL default '1',
  `pagesection_number_fld` mediumint(8) unsigned NOT NULL default '1',
  `fulllabel_fld` tinytext NOT NULL,
  `index_fld` enum('0','1') NOT NULL default '1',
  `mainmenu_fld` enum('0','1') NOT NULL default '0',
  `order_fld` mediumint(8) unsigned NOT NULL default '1',
  `cache_fld` enum('0','1') NOT NULL default '1',
  `expires_fld` tinyint(4) default '1',
  `template_id` int(10) unsigned NOT NULL default '1',
  `printtemplate_id` int(10) unsigned default NULL,
  `keywords_fld` text,
  `title_fld` varchar(255) default NULL,
  `descr_fld` text,
  `alphasort_fld` enum('0','1') default '0',
  `lastmod_fld` timestamp NOT NULL,
  `lm_fld` tinyint(3) unsigned NOT NULL default '1',
  `expand_fld` tinyint(3) unsigned NOT NULL default '0',
  `notempl_fld` enum('0','1') default '0',
  `customstyle_fld` text,
  PRIMARY KEY  (`page_id`),
  KEY `master_id` (`master_page_id`),
  KEY `order_fld` (`order_fld`),
  KEY `enabled_id` (`enabled_fld`),
  KEY `url` (`url_fld`(250))
) TYPE=MyISAM;

--
-- Dumping data for table `page_tbl`
--


/*!40000 ALTER TABLE `page_tbl` DISABLE KEYS */;
LOCK TABLES `page_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `page_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

