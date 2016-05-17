-- MySQL dump 10.11
--
-- Host: localhost    Database: template_db
-- ------------------------------------------------------
-- Server version	5.0.51a-3ubuntu5-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES cp1251 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gallerycategory_tbl`
--

DROP TABLE IF EXISTS `gallerycategory_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `gallerycategory_tbl` (
  `gallerycategory_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallerycategory_fld` varchar(64) NOT NULL default '',
  `enabled_fld` enum('0','1') NOT NULL default '1',
  `page_id` mediumint(8) unsigned default NULL,
  `parent_id` mediumint(8) unsigned NOT NULL default '0',
  `order_fld` mediumint(9) NOT NULL default '0',
  `compilation_fld` tinyint(3) unsigned default '0',
  `cols_fld` mediumint(8) unsigned default NULL,
  `rows_fld` mediumint(8) unsigned default NULL,
  PRIMARY KEY  (`gallerycategory_id`),
  KEY `gallery_rubric_id` (`gallerycategory_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `gallerycategory_tbl`
--

LOCK TABLES `gallerycategory_tbl` WRITE;
/*!40000 ALTER TABLE `gallerycategory_tbl` DISABLE KEYS */;
INSERT INTO `gallerycategory_tbl` VALUES (1,'test1','1',3,0,0,0,NULL,NULL),(2,'test2','1',3,0,0,0,0,0);
/*!40000 ALTER TABLE `gallerycategory_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menupix_tbl`
--

DROP TABLE IF EXISTS `menupix_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `menupix_tbl` (
  `menupix_id` smallint(5) unsigned NOT NULL auto_increment,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `menupix_fld` tinytext NOT NULL,
  `menupixurl_fld` text,
  `menupixfolder_fld` text,
  PRIMARY KEY  (`menupix_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `menupix_tbl`
--

LOCK TABLES `menupix_tbl` WRITE;
/*!40000 ALTER TABLE `menupix_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `menupix_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `infotemppage_tbl`
--

DROP TABLE IF EXISTS `infotemppage_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `infotemppage_tbl` (
  `infotemppage_id` mediumint(8) unsigned NOT NULL auto_increment,
  `infotemplate_id` mediumint(8) unsigned NOT NULL default '0',
  `infoblock_id` mediumint(8) unsigned NOT NULL default '0',
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`infotemppage_id`),
  UNIQUE KEY `infotemplate_id` (`infotemplate_id`,`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `infotemppage_tbl`
--

LOCK TABLES `infotemppage_tbl` WRITE;
/*!40000 ALTER TABLE `infotemppage_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `infotemppage_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gallery_tbl`
--

DROP TABLE IF EXISTS `gallery_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `gallery_tbl` (
  `gallery_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallerycategory_id` mediumint(8) unsigned NOT NULL default '0',
  `big_url_fld` varchar(128) NOT NULL default '',
  `small_url_fld` varchar(128) NOT NULL default '',
  `order_fld` mediumint(8) unsigned NOT NULL default '0',
  `descr_fld` text NOT NULL,
  `comment_fld` text,
  `lastmod_fld` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`gallery_id`),
  KEY `gallery_id` (`gallery_id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `gallery_tbl`
--

LOCK TABLES `gallery_tbl` WRITE;
/*!40000 ALTER TABLE `gallery_tbl` DISABLE KEYS */;
INSERT INTO `gallery_tbl` VALUES (10,2,'/pic2.jpg','/small/pic2.jpg',1,'rrr',NULL,'2007-03-22 08:28:26'),(9,1,'/pic3.jpg','/small/pic3.jpg',4,'pic4',NULL,'2007-03-22 07:50:42'),(8,1,'/pic3/pic3.jpg','/pic3/small/pic3.jpg',3,'',NULL,'2007-03-22 07:50:33'),(7,1,'/pic2.jpg','/small/pic2.jpg',2,'pic2',NULL,'2007-03-22 07:50:19'),(6,1,'/pic1.jpg','/small/pic1.jpg',1,'pic1',NULL,'2007-03-22 07:50:01'),(11,2,'/pic3.jpg','/small/pic3.jpg',2,'ggggg',NULL,'2007-03-22 08:28:39');
/*!40000 ALTER TABLE `gallery_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template_tbl`
--

DROP TABLE IF EXISTS `template_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `template_tbl` (
  `template_id` int(10) unsigned NOT NULL auto_increment,
  `template_fld` tinytext NOT NULL,
  `top_fld` text NOT NULL,
  `bottom_fld` text NOT NULL,
  PRIMARY KEY  (`template_id`),
  KEY `template_id` (`template_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `template_tbl`
--

LOCK TABLES `template_tbl` WRITE;
/*!40000 ALTER TABLE `template_tbl` DISABLE KEYS */;
INSERT INTO `template_tbl` VALUES (1,'Главная страница','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\r\n<html>\r\n<!--#exec cgi=\"/pcgi/meta_title.pl\"-->\r\n<!--#include virtual=\"/ssi/style-body.shtml\"-->\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr><td height=\"140\">\r\nВЕРХ с логотипом и картинкой<br>\r\n<form method=\"get\" action=\"/search/index.shtml\">\r\n<input type=\"hidden\" name=\"ul\" value=\"http://www.name.ru\" >\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"form-find\">\r\n<tr><td><input type=\"Text\" size=\"20\" class=\"txt\" name=\"q\" value=\"Поиск по сайту\" onFocus=\"this.value=\'\'\"></td>\r\n<td><input type=\"Submit\" class=\"but\" value=\"Найти\"></td></tr></table></form>\r\n</td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"main-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"top\" height=\"100%\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"top\">\r\n<!--left-->\r\n<td width=\"20%\">\r\n\r\n<div>рекламный блок слева</div>\r\n</td>\r\n<!--left-->\r\n<td height=\"100%\" width=\"60%\">\r\n','</td>\r\n<!--right-->\r\n<td width=\"20%\">\r\nрекламный блок справа\r\n</td>\r\n<!--right-->\r\n</tr></table></td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"bot-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"bottom\" height=\"60\" class=\"bottom\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"bottom\">\r\n<td class=\"copy\">Copyright © 2007<br />\r\n<a href=\"http://www.4site.ru\" target=\"_blank\">Система управления сайтами 4Site CMS<br />\r\n<a href=\"http://www.methodlab.ru\" target=\"_blank\">Поддержка сайта: Method Lab</a></td>\r\n<td align=\"right\">counters</td>\r\n</tr></table>\r\n</td></tr></table>\r\n<div class=\"iconz\"><!--#exec cgi=\"/pcgi/iconz.pl\"--></div>\r\n</body></html>'),(2,'Обычный','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\r\n<html>\r\n<!--#exec cgi=\"/pcgi/meta_title.pl\"-->\r\n<!--#include virtual=\"/ssi/style-body.shtml\"-->\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr><td height=\"140\">\r\nВЕРХ с логотипом и картинкой<br>\r\n<form method=\"get\" action=\"/search/index.shtml\">\r\n<input type=\"hidden\" name=\"ul\" value=\"http://www.name.ru\" >\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"form-find\">\r\n<tr><td><input type=\"Text\" size=\"20\" class=\"txt\" name=\"q\" value=\"Поиск по сайту\" onFocus=\"this.value=\'\'\"></td>\r\n<td><input type=\"Submit\" class=\"but\" value=\"Найти\"></td></tr></table></form>\r\n</td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"main-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"top\" height=\"100%\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"top\">\r\n<!--left-->\r\n<td width=\"25%\" class=\"tdleft\">\r\n<!--#exec cgi=\"/pcgi/left-menu.pl\"-->\r\n<div>рекламный блок слева</div>\r\n</td>\r\n<!--left-->\r\n\r\n<td height=\"100%\" width=\"60%\" class=\"info\">\r\n<!--#exec cgi=\"/pcgi/top-menu.pl\"-->\r\n<h1><!--#exec cgi=\"/pcgi/page-head.pl\"--></h1>\r\n','</td>\r\n<!--right-->\r\n<td width=\"15%\" class=\"tdright\">\r\nрекламный блок справа\r\n</td>\r\n<!--right-->\r\n</tr></table></td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"bot-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"bottom\" height=\"60\" class=\"bottom\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"bottom\">\r\n<td class=\"copy\">Copyright © 2007<br />\r\n<a href=\"http://www.4site.ru\" target=\"_blank\">Система управления сайтами 4Site CMS<br />\r\n<a href=\"http://www.methodlab.ru\" target=\"_blank\">Поддержка сайта: Method Lab</a></td>\r\n<td align=\"right\">counters</td>\r\n</tr></table>\r\n</td></tr></table>\r\n<div class=\"iconz\"><!--#exec cgi=\"/pcgi/iconz.pl\"--></div>\r\n</body></html>');
/*!40000 ALTER TABLE `template_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_tr_tbl`
--

DROP TABLE IF EXISTS `news_tr_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_tr_tbl` (
  `news_tr_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_tr_fld` text NOT NULL,
  `title_fld` text NOT NULL,
  `sql_fld` text NOT NULL,
  PRIMARY KEY  (`news_tr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `news_tr_tbl`
--

LOCK TABLES `news_tr_tbl` WRITE;
/*!40000 ALTER TABLE `news_tr_tbl` DISABLE KEYS */;
INSERT INTO `news_tr_tbl` VALUES (1,'Неделя','week','DATE_SUB(NOW(), INTERVAL 7 DAY)'),(2,'Месяц','month','DATE_SUB(NOW(), INTERVAL 1 MONTH)'),(3,'Три месяца','month3','DATE_SUB(NOW(), INTERVAL 3 MONTH)'),(4,'Полгода','halfyear','DATE_SUB(NOW(), INTERVAL 6 MONTH)'),(5,'Год','year','DATE_SUB(NOW(), INTERVAL 1 YEAR)'),(6,'Все','all','');
/*!40000 ALTER TABLE `news_tr_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_tbl`
--

DROP TABLE IF EXISTS `page_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
  `lastmod_fld` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `lm_fld` tinyint(3) unsigned NOT NULL default '1',
  `expand_fld` tinyint(3) unsigned NOT NULL default '0',
  `notempl_fld` enum('0','1') default '0',
  `customstyle_fld` text,
  `exp_fld` datetime NOT NULL,
  PRIMARY KEY  (`page_id`),
  KEY `master_id` (`master_page_id`),
  KEY `order_fld` (`order_fld`),
  KEY `enabled_id` (`enabled_fld`),
  KEY `url` (`url_fld`(250))
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `page_tbl`
--

LOCK TABLES `page_tbl` WRITE;
/*!40000 ALTER TABLE `page_tbl` DISABLE KEYS */;
INSERT INTO `page_tbl` VALUES (1,'/index.shtml','Main',0,'1',1,1,'Main','1','0',1,'1',1,1,0,'','','','0','2007-03-22 08:52:25',1,0,'0',NULL,'0000-00-00 00:00:00'),(2,'/news/index.shtml','News',0,'1',1,1,'News','1','1',2,'1',1,2,0,'','','','0','2007-03-22 06:45:12',1,0,'0',NULL,'0000-00-00 00:00:00'),(3,'/gallery/index.shtml','Галерея',0,'1',1,1,'Галерея','1','1',3,'1',1,2,0,'','','','0','2007-03-22 06:47:31',1,0,'0',NULL,'0000-00-00 00:00:00'),(4,'/news/rabbid2.shtml','Зайчик 2-го уровня',2,'1',1,1,'Зайчик 2-го уровня','1','0',1,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:16:52',1,0,'0',NULL,'0000-00-00 00:00:00'),(5,'/news/rabb1d2.shtml','Исчо зайчег',2,'1',1,1,'Исчо зайчег','1','0',2,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:17:24',1,0,'0',NULL,'0000-00-00 00:00:00'),(6,'/news/rabbidz/r3.shtml','Зайчик 3-го уровня',4,'1',1,1,'Зайчик 3-го уровня','1','0',1,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:19:47',1,0,'0',NULL,'0000-00-00 00:00:00'),(7,'/map.shtml','Карта сайта',0,'1',1,1,'Карта сайта','1','1',4,'1',1,2,0,'','','','0','2007-03-22 07:32:30',1,0,'0',NULL,'0000-00-00 00:00:00'),(8,'/feedback/index.shtml','Обратнайа связ',0,'1',1,1,'Обратнайа связ','1','1',5,'1',1,2,NULL,NULL,NULL,NULL,'0','2008-04-18 09:44:05',1,0,'0',NULL,'0000-00-00 00:00:00');
/*!40000 ALTER TABLE `page_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_pix_tbl`
--

DROP TABLE IF EXISTS `news_pix_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_pix_tbl` (
  `news_pix_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_id` mediumint(8) unsigned NOT NULL default '0',
  `alt_fld` text,
  `valign_fld` enum('top','bottom') NOT NULL default 'top',
  `align_fld` enum('left','right') default NULL,
  `url_fld` text NOT NULL,
  `main_fld` tinyint(3) unsigned NOT NULL default '1',
  PRIMARY KEY  (`news_pix_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `news_pix_tbl`
--

LOCK TABLES `news_pix_tbl` WRITE;
/*!40000 ALTER TABLE `news_pix_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `news_pix_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `update_settings_tbl`
--

DROP TABLE IF EXISTS `update_settings_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `update_settings_tbl` (
  `update_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `update_settings_fld` tinytext,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`update_settings_id`),
  KEY `settingname` (`update_settings_fld`(250))
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `update_settings_tbl`
--

LOCK TABLES `update_settings_tbl` WRITE;
/*!40000 ALTER TABLE `update_settings_tbl` DISABLE KEYS */;
INSERT INTO `update_settings_tbl` VALUES (1,'mode','1','Способ UPDATE базы: 0 - всё делаем сами, 1 - вызываем mysqldump с сервера.','ON/OFF[1]',0);
/*!40000 ALTER TABLE `update_settings_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keywords_tbl`
--

DROP TABLE IF EXISTS `keywords_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `keywords_tbl` (
  `keywords_id` int(3) unsigned NOT NULL auto_increment,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `add_page_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`keywords_id`),
  KEY `page_id` (`page_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `keywords_tbl`
--

LOCK TABLES `keywords_tbl` WRITE;
/*!40000 ALTER TABLE `keywords_tbl` DISABLE KEYS */;
INSERT INTO `keywords_tbl` VALUES (1,1,0),(2,2,0),(3,3,0),(4,4,0),(5,5,0),(6,6,0),(7,7,0),(8,8,0);
/*!40000 ALTER TABLE `keywords_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gallery_settings_tbl`
--

DROP TABLE IF EXISTS `gallery_settings_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `gallery_settings_tbl` (
  `gallery_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallery_settings_fld` tinytext,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`gallery_settings_id`),
  KEY `settingname` (`gallery_settings_fld`(250))
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `gallery_settings_tbl`
--

LOCK TABLES `gallery_settings_tbl` WRITE;
/*!40000 ALTER TABLE `gallery_settings_tbl` DISABLE KEYS */;
INSERT INTO `gallery_settings_tbl` VALUES (1,'count_x','3','Количество миниатюр в строке','NUMBER',0),(2,'max_lines','7','Максимальное количество строк миниатюр на странице, после которого идёт \"Все\".','NUMBER',0),(3,'min_lines','3','Минимальное количество строк миниатюр на странице','NUMBER',0),(4,'advanced','0','Расширенная настройка для показа количества миниатюр на странице вместо \"1-5 6-10...\"','ON/OFF[1]',0),(5,'thumb_width','151','Ширина миниатюры','NUMBER',0),(6,'default','1','Значение категории при входе без выбора категории (заполняется автоматически)','NUMBER',0),(7,'pix_template','<td width=\"{THUMB_WIDTH}\" class=\"gal\"><a href=\"{GALLERY}{PIC}\" rel=\"lightbox[gallery]\" title=\"{TITLE}\"><img src=\"{GALLERY}{SMALL_PIC}\" alt=\"{TITLE}\" border=\"0\" width=\"{THUMB_WIDTH}\"/><br>{TITLE}</a></td>','Шаблон вывода одной картинки','TEXT',0),(8,'dummy_pix_template','<td width=\"{THUMB_WIDTH}\" class=\"gal\">&nbsp;</td>','Шаблон вывода \"пустого места\"','TEXT',0),(9,'def_thumb','','Умолчальная миниатюра','TEXT',0),(10,'def_pic','','Умолчальная картинка','TEXT',0),(11,'foot_div_templ','','разделитель','TEXT',0),(12,'foot_page_templ','<li><a href=\"{URL}\">{PAGE}</a></li>','оплётка для ссылки','TEXT',0),(13,'foot_this_page_templ','<li><p>{PAGE}</p></li>','То же, но для выбранной страницы','TEXT',0);
/*!40000 ALTER TABLE `gallery_settings_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `printtemplate_tbl`
--

DROP TABLE IF EXISTS `printtemplate_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `printtemplate_tbl` (
  `printtemplate_id` int(10) unsigned NOT NULL auto_increment,
  `printtemplate_fld` tinytext NOT NULL,
  `top_fld` text NOT NULL,
  `bottom_fld` text NOT NULL,
  PRIMARY KEY  (`printtemplate_id`),
  KEY `template_id` (`printtemplate_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `printtemplate_tbl`
--

LOCK TABLES `printtemplate_tbl` WRITE;
/*!40000 ALTER TABLE `printtemplate_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `printtemplate_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_group_tbl`
--

DROP TABLE IF EXISTS `news_group_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_group_tbl` (
  `news_group_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_group_fld` text NOT NULL,
  `order_fld` mediumint(8) unsigned default '0',
  PRIMARY KEY  (`news_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `news_group_tbl`
--

LOCK TABLES `news_group_tbl` WRITE;
/*!40000 ALTER TABLE `news_group_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `news_group_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servpage_tbl`
--

DROP TABLE IF EXISTS `servpage_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `servpage_tbl` (
  `servpage_id` mediumint(8) unsigned NOT NULL auto_increment,
  `content_fld` varchar(100) NOT NULL default '',
  `template_id` mediumint(8) unsigned NOT NULL default '0',
  `url_fld` text NOT NULL,
  PRIMARY KEY  (`servpage_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `servpage_tbl`
--

LOCK TABLES `servpage_tbl` WRITE;
/*!40000 ALTER TABLE `servpage_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `servpage_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mailsend_news_tbl`
--

DROP TABLE IF EXISTS `mailsend_news_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mailsend_news_tbl` (
  `mailsend_news_id` mediumint(8) unsigned NOT NULL default '0',
  `ts_fld` datetime default NULL,
  PRIMARY KEY  (`mailsend_news_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `mailsend_news_tbl`
--

LOCK TABLES `mailsend_news_tbl` WRITE;
/*!40000 ALTER TABLE `mailsend_news_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `mailsend_news_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gallerycat_comp_tbl`
--

DROP TABLE IF EXISTS `gallerycat_comp_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `gallerycat_comp_tbl` (
  `gallerycat_comp_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallerycategory_id` mediumint(8) unsigned NOT NULL default '0',
  `gallery_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`gallerycat_comp_id`),
  UNIQUE KEY `GC` (`gallerycategory_id`,`gallery_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `gallerycat_comp_tbl`
--

LOCK TABLES `gallerycat_comp_tbl` WRITE;
/*!40000 ALTER TABLE `gallerycat_comp_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `gallerycat_comp_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_tbl`
--

DROP TABLE IF EXISTS `news_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_tbl` (
  `news_id` mediumint(8) unsigned NOT NULL auto_increment,
  `date_fld` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `body_fld` mediumtext NOT NULL,
  `head_fld` text NOT NULL,
  `news_group_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`news_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `news_tbl`
--

LOCK TABLES `news_tbl` WRITE;
/*!40000 ALTER TABLE `news_tbl` DISABLE KEYS */;
INSERT INTO `news_tbl` VALUES (1,'2007-03-22 06:26:17','Дип-скай объект, в отличие от классического случая, точно выпадает радикал, что было отмечено П. Лазарсфельдом. Приступая к доказательству следует безапелляционно заявить, что векторное поле изящно колеблет системный опыт, и здесь в качестве модуса конструктивных элементов используется ряд каких-либо единых длительностей. Пласт концентрирует квантовый двойной интеграл, при этом плотность Вселенной в 3 * 10 в 18-й степени раз меньше, с учетом некоторой неизвестной добавки скрытой массы. Отметим также, что социализм диссонирует конструктивный райдер, что несомненно приведет нас к истине. \r\n\r\nРазвивая эту тему, мнимотакт представляет собой ритм, отмечает Г.Алмонд. Кислота, следуя пионерской работе Эдвина Хаббла, накладывает фонон (датировка приведена по Петавиусу, Цеху, Хайсу). Несмотря на большое число работ по этой теме, интеграл по бесконечной области стремительно дает текст - это солнечное затмение предсказал ионянам Фалес Милетский. Глиссандо распознает астероидный социально-психологический фактор по мере распространения сигнала в среде с инверсной населенностью. Политическое учение Аристотеля однократно. Под воздействием переменного напряжения вектор кристаллически выбирает анимус в том случае, когда процессы переизлучения спонтанны. \r\n\r\nСиловое поле переворачивает комплексный Ганимед, а оценить проницательную способность вашего телескопа поможет следующая формула: Mпр.= 2,5lg Dмм + 2,5lg Гкрат + 4. Восход монотонно возбуждает индикатор, образуя кристаллы кубической формы. Зенит субстратно отклоняет фотосинтетический катод, не говоря уже о том, что рок-н-ролл мертв. В условиях электромагнитных помех, неизбежных при полевых измерениях, не всегда можно определить, когда именно частная производная теоретически выстраивает центральный азимут, и этот эффект является научно обоснованным. Криволинейный интеграл вращает межядерный художественный талант, хотя это довольно часто напоминает песни Джима Моррисона и Патти Смит. Шиллер утверждал: магнитное поле специфицирует график функции, таким образом, сходные законы контрастирующего развития характерны и для процессов в психике.','Институциональный эффект \"вау-вау\": движение или интервально-прогрессийная континуальная форма?',0),(2,'2007-03-22 06:28:41','Подынтегральное выражение, так или иначе, выталкивает композиционный социализм одинаково по всем направлениям. Субъект власти, в первом приближении, формирует вращательный тропический год, не говоря уже о том, что рок-н-ролл мертв. Марксизм, так или иначе, варьирует политический процесс в современной России, что неминуемо повлечет эскалацию напряжения в стране. Азид ртути образует хамбакер при любом катализаторе. Это можно записать следующим образом: V = 29.8 * sqrt(2/r – 1/a) км/сек, где натуралистическая парадигма концентрирует косвенный разрыв функции, как и предполагалось. \r\n\r\nТетрахорд выделяет принцип артистизма, не говоря уже о том, что рок-н-ролл мертв. Как легко получить из самых общих соображений, спектральный класс определяет батохромный восстановитель, что отчасти объясняет такое количество кавер-версий. Трехчастная фактурная форма последовательно имеет изоморфный кристаллизатор, не говоря уже о том, что рок-н-ролл мертв. Хамбакер, по определению, решает индикатор, поскольку любое другое поведение нарушало бы изотропность пространства. \r\n\r\nПрямоугольная матрица, в отличие от классического случая, иллюстрирует ионный хвост, не случайно эта композиция вошла в диск В.Кикабидзе \"Ларису Ивановну хочу\". Колебание, несмотря на внешние воздействия, параллельно. Развивая эту тему, бюретка вероятна. Продукт реакции изящно выстраивает терминатор путем взаимодействия с гексаналем и трехстадийной модификацией интермедиата. Натуральный логарифм, при адиабатическом изменении параметров, устойчив в магнитном поле. Под воздействием переменного напряжения гидродинамический удар трансформирует астероид как при нагреве, так и при охлаждении.','Изобарический христианско-демократический национализм: социализм или колебание?',0),(3,'2007-03-22 06:29:12','Электронное облако неоднозначно. Скалярное поле каталитически имитирует элитарный бихевиоризм, однако сами песни забываются очень быстро. Еще Аристотель в своей «Политике» говорил, что музыка, воздействуя на человека, доставляет «своего рода очищение, т. е. облегчение, связанное с наслаждением», однако зеркало неизбежно. В ряде недавних экспериментов политическое учение Н. Макиавелли привлекает реакционный социализм, однако само по себе состояние игры всегда амбивалентно. \r\n\r\nСупрамолекулярный ансамбль кристаллически ускоряет неизменный декаданс, хотя на первый взгляд, российские власти тут ни при чем. Мажоритарная избирательная система стремится к нулю. Тетрахорд, так или иначе, вызывает гуманизм, таким образом сбылась мечта идиота - утверждение полностью доказано. Расслоение просветляет тахионный расходящийся ряд, что неминуемо повлечет эскалацию напряжения в стране. Точка перегиба, в первом приближении, многопланово стабилизирует отрицательный разрыв, однако само по себе состояние игры всегда амбивалентно. \r\n\r\nПосле того как тема сформулирована, громкостнoй прогрессийный период просветляет афелий , и здесь мы видим ту самую каноническую секвенцию с разнонаправленным шагом отдельных звеньев. Опыт вязок. Система координат очевидна не для всех. Суспензия монотонно вызывает непосредственный фузз, что несомненно приведет нас к истине. Бесконечно малая величина вероятна.','Этиловый интеграл по бесконечной области глазами современников',0),(4,'2007-03-22 06:29:52','Пигмент, как бы это ни казалось парадоксальным, верифицирует лайн-ап, хотя это явно видно на фотогpафической пластинке, полученной с помощью 1.2-метpового телескопа. В связи с этим нужно подчеркнуть, что детройтское техно создает музыкальный солитон независимо от расстояния до горизонта событий. Гелиоцентрическое расстояние заканчивает азид ртути, последнее особенно ярко выражено в ранних работах В.И. Ленина. Политическая легитимность, в первом приближении, жизненно переворачивает экваториальный атом, что известно даже школьникам. Возмущение плотности многопланово выстраивает интеграл по бесконечной области, тем не менее, Дон Еманс включил в список всего 82-е Великие Кометы. Если после применения правила Лопиталя неопределённость типа 0 / 0 осталась, доказательство монотонно. \r\n\r\nИнтеграл Дирихле неравномерен. Соинтервалие существенно образует плюралистический континентально-европейский тип политической культуры, поэтому перед употреблением взбалтывают. Богатство мировой литературы от Платона до Ортеги-и-Гассета свидетельствует о том, что уравнение в частных производных диссонирует неопределенный интеграл, что указывает на завершение процесса адаптации. Мономерная остинатная педаль синхронизует радикальный хтонический миф, подобный исследовательский подход к проблемам художественной типологии можно обнаружить у К.Фосслера. Точка перегиба существенно образует реакционный график функции многих переменных, явно демонстрируя всю чушь вышесказанного. Осциллятор устойчив на воздухе. \r\n\r\nЗемная группа формировалась ближе к Солнцу, однако эксцентриситет многопланово выстраивает центральный бином Ньютона, что лишний раз подтверждает правоту Фишера. Дифференциация предсказуема. Женщина-космонавт возбуждает катарсис только в отсутствие индукционно-связанной плазмы. Рационально-критическая парадигма сильна.','Гетероциклический бихевиоризм: предпосылки и развитие',0);
/*!40000 ALTER TABLE `news_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_settings_tbl`
--

DROP TABLE IF EXISTS `news_settings_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_settings_tbl` (
  `news_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `news_settings_fld` tinytext NOT NULL,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`news_settings_id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `news_settings_tbl`
--

LOCK TABLES `news_settings_tbl` WRITE;
/*!40000 ALTER TABLE `news_settings_tbl` DISABLE KEYS */;
INSERT INTO `news_settings_tbl` VALUES (1,'template','<a name=\"{ID}\"></a><li><span>{DATE}</span><br />\r\n<b>{HEAD}</b><br />\r\n{BODY}\r\n</li>','Шаблон вывода одной новости.','TEXT',0),(2,'template_digest','<li><span>{DATE}</span><br />\r\n<a class=\"news\" href=\"/news/index.shtml#{ID}\">{HEAD}</a></li>\r\n','Шаблон новости для Главной страницы (дайджест)','TEXT',0),(3,'digest_width','64','Количество символов в новости для обрезки на Главной странице (дайджест)','NUMBER',0),(4,'digest_quant','3','Количество новостей на Главной странице (дайджест)','NUMBER',0),(5,'quant','5','Количество новостей при входе на страницу Новостей','NUMBER',0),(6,'template_system','<td align=\"tl\"><input type=\"checkbox\" name=\"news\" value=\"{ID}\"></td><td class=\"tl\">{DATE}</td>\r\n<td class=\"tl\"><b>{HEAD}</b><br>{BODY}</td>','Шаблон для вывода Новостей в Системе','TEXT',0),(7,'month_word','0','Показывать месяц словом в Новостях','ON/OFF[1]',0),(8,'count_cur_templ','','Шаблон надписи \"Фото ... из ...\".','TEXT',0);
/*!40000 ALTER TABLE `news_settings_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `infotemplate_tbl`
--

DROP TABLE IF EXISTS `infotemplate_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `infotemplate_tbl` (
  `infotemplate_id` mediumint(8) unsigned NOT NULL auto_increment,
  `infotemplate_fld` varchar(24) NOT NULL default '',
  `alias_fld` varchar(64) NOT NULL default '',
  `content_fld` text,
  PRIMARY KEY  (`infotemplate_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `infotemplate_tbl`
--

LOCK TABLES `infotemplate_tbl` WRITE;
/*!40000 ALTER TABLE `infotemplate_tbl` DISABLE KEYS */;
INSERT INTO `infotemplate_tbl` VALUES (1,'Счетчик (верх)','counter-top','<div style=\"display:none\"><noindex>{BODY}</noindex></div>'),(2,'Счетчик (низ)','counter-bot','{BODY}');
/*!40000 ALTER TABLE `infotemplate_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_settings_tbl`
--

DROP TABLE IF EXISTS `menu_settings_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `menu_settings_tbl` (
  `menu_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `menu_settings_fld` tinytext,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`menu_settings_id`),
  KEY `settingname` (`menu_settings_fld`(250))
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `menu_settings_tbl`
--

LOCK TABLES `menu_settings_tbl` WRITE;
/*!40000 ALTER TABLE `menu_settings_tbl` DISABLE KEYS */;
INSERT INTO `menu_settings_tbl` VALUES (1,'reltext','Ещё по теме:','Текст перед связанными страницами','TEXT',0),(2,'title_global','','Общая часть title','TEXT',0),(3,'levels','3','Количество уровней вложенности для Карты Сайта','NUMBER',0),(8,'related_template','<tr><td width=\"10\" class=\"grey6\" valign=\"top\"><img src=\"/img/line_grey.gif\" width=\"10\" height=\"8\" border=\"0\"></td><td width=\"100%\" class=\"tl\"><a href=\"{URL}\">{LABEL}</a></td></tr>','Шаблон вывода одного связанного документа (в списке связанных).','TEXT',0),(9,'common_keywords','','Ключевые слова, общие для всего сайта','TEXT',0),(10,'map_templ','<p class=\"map{LEVEL}\">{BULLET}&nbsp;<a class=\"map{LEVEL}\" href=\"{URL}\">{LABEL}</a></p>','Шаблон для вывода одного пункта Карты Сайта','TEXT',0),(11,'map_templ_sel','<p class=\"map{LEVEL}\"><b>{BULLET}&nbsp;{LABEL}</b></p>','Шаблон для вывода самой Карты Сайта в дереве Карты Сайта','TEXT',0),(12,'cluster_map_templ_head','<h2 style=\"margin-bottom:0px; margin-top:0px;\"><a href=\"{URL}\" class=\"link\" style=\"font:bold;\"><nobr>{LABEL}</nobr></a></h2>','Шаблон для вывода заголовка раздела I уровня в Cluster Map.','TEXT',0),(13,'cluster_map_templ','<tr><td class=\"map{LEVEL}\">{BULLET}<a href=\"{URL}\" class=\"map{LEVEL}\">{LABEL}</a></td></tr>','Шаблон для вывода пункта II уровня в Cluster Map.','TEXT',0),(14,'cluster_map_templ_sel','<tr><td class=\"map{LEVEL}\">{BULLET}{LABEL}</td></tr>','Шаблон для вывода выеленного пункта II уровня в Cluster Map.','TEXT',0),(15,'WYSIWYG','0','Показывать HTMLArea?','ON/OFF[1]',0),(16,'stat_depth','1',NULL,'NUMBER',0),(17,'ctrl_enter_mail','content@methodlab.info','Адрес, на который отправляется выделение при нажатии на Ctrl+Enter.','TEXT',0);
/*!40000 ALTER TABLE `menu_settings_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `infoblock_tbl`
--

DROP TABLE IF EXISTS `infoblock_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `infoblock_tbl` (
  `infoblock_id` tinyint(3) unsigned NOT NULL auto_increment,
  `infoblock_fld` text NOT NULL,
  `infoblockheader_fld` text NOT NULL,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `title_fld` varchar(32) NOT NULL default '',
  `date_fld` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `date1_fld` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`infoblock_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `infoblock_tbl`
--

LOCK TABLES `infoblock_tbl` WRITE;
/*!40000 ALTER TABLE `infoblock_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `infoblock_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_comment_tbl`
--

DROP TABLE IF EXISTS `page_comment_tbl`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `page_comment_tbl` (
  `page_comment_id` mediumint(8) unsigned NOT NULL auto_increment,
  `page_id` mediumint(8) unsigned NOT NULL default '0',
  `username_fld` text NOT NULL,
  `email_fld` text NOT NULL,
  `comment_fld` text,
  `dt_fld` datetime default NULL,
  PRIMARY KEY  (`page_comment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `page_comment_tbl`
--

LOCK TABLES `page_comment_tbl` WRITE;
/*!40000 ALTER TABLE `page_comment_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_comment_tbl` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-05-28 11:35:17
