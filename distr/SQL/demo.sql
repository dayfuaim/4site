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
INSERT INTO `template_tbl` VALUES (1,'������� ��������','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\r\n<html>\r\n<!--#exec cgi=\"/pcgi/meta_title.pl\"-->\r\n<!--#include virtual=\"/ssi/style-body.shtml\"-->\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr><td height=\"140\">\r\n���� � ��������� � ���������<br>\r\n<form method=\"get\" action=\"/search/index.shtml\">\r\n<input type=\"hidden\" name=\"ul\" value=\"http://www.name.ru\" >\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"form-find\">\r\n<tr><td><input type=\"Text\" size=\"20\" class=\"txt\" name=\"q\" value=\"����� �� �����\" onFocus=\"this.value=\'\'\"></td>\r\n<td><input type=\"Submit\" class=\"but\" value=\"�����\"></td></tr></table></form>\r\n</td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"main-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"top\" height=\"100%\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"top\">\r\n<!--left-->\r\n<td width=\"20%\">\r\n\r\n<div>��������� ���� �����</div>\r\n</td>\r\n<!--left-->\r\n<td height=\"100%\" width=\"60%\">\r\n','</td>\r\n<!--right-->\r\n<td width=\"20%\">\r\n��������� ���� ������\r\n</td>\r\n<!--right-->\r\n</tr></table></td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"bot-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"bottom\" height=\"60\" class=\"bottom\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"bottom\">\r\n<td class=\"copy\">Copyright�� 2007<br />\r\n<a href=\"http://www.4site.ru\" target=\"_blank\">������� ���������� ������� 4Site CMS<br />\r\n<a href=\"http://www.methodlab.ru\" target=\"_blank\">��������� �����: Method Lab</a></td>\r\n<td align=\"right\">counters</td>\r\n</tr></table>\r\n</td></tr></table>\r\n<div class=\"iconz\"><!--#exec cgi=\"/pcgi/iconz.pl\"--></div>\r\n</body></html>'),(2,'�������','<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\r\n<html>\r\n<!--#exec cgi=\"/pcgi/meta_title.pl\"-->\r\n<!--#include virtual=\"/ssi/style-body.shtml\"-->\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr><td height=\"140\">\r\n���� � ��������� � ���������<br>\r\n<form method=\"get\" action=\"/search/index.shtml\">\r\n<input type=\"hidden\" name=\"ul\" value=\"http://www.name.ru\" >\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"form-find\">\r\n<tr><td><input type=\"Text\" size=\"20\" class=\"txt\" name=\"q\" value=\"����� �� �����\" onFocus=\"this.value=\'\'\"></td>\r\n<td><input type=\"Submit\" class=\"but\" value=\"�����\"></td></tr></table></form>\r\n</td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"main-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"top\" height=\"100%\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"top\">\r\n<!--left-->\r\n<td width=\"25%\" class=\"tdleft\">\r\n<!--#exec cgi=\"/pcgi/left-menu.pl\"-->\r\n<div>��������� ���� �����</div>\r\n</td>\r\n<!--left-->\r\n\r\n<td height=\"100%\" width=\"60%\" class=\"info\">\r\n<!--#exec cgi=\"/pcgi/top-menu.pl\"-->\r\n<h1><!--#exec cgi=\"/pcgi/page-head.pl\"--></h1>\r\n','</td>\r\n<!--right-->\r\n<td width=\"15%\" class=\"tdright\">\r\n��������� ���� ������\r\n</td>\r\n<!--right-->\r\n</tr></table></td></tr>\r\n\r\n<tr><td height=\"23\" align=\"center\" class=\"bot-menu\">\r\n<!--#exec cgi=\"/pcgi/main-menu.pl\"-->\r\n</td></tr>\r\n\r\n<tr><td valign=\"bottom\" height=\"60\" class=\"bottom\">\r\n<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\">\r\n<tr valign=\"bottom\">\r\n<td class=\"copy\">Copyright�� 2007<br />\r\n<a href=\"http://www.4site.ru\" target=\"_blank\">������� ���������� ������� 4Site CMS<br />\r\n<a href=\"http://www.methodlab.ru\" target=\"_blank\">��������� �����: Method Lab</a></td>\r\n<td align=\"right\">counters</td>\r\n</tr></table>\r\n</td></tr></table>\r\n<div class=\"iconz\"><!--#exec cgi=\"/pcgi/iconz.pl\"--></div>\r\n</body></html>');
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
INSERT INTO `news_tr_tbl` VALUES (1,'������','week','DATE_SUB(NOW(), INTERVAL 7 DAY)'),(2,'�����','month','DATE_SUB(NOW(), INTERVAL 1 MONTH)'),(3,'��� ������','month3','DATE_SUB(NOW(), INTERVAL 3 MONTH)'),(4,'�������','halfyear','DATE_SUB(NOW(), INTERVAL 6 MONTH)'),(5,'���','year','DATE_SUB(NOW(), INTERVAL 1 YEAR)'),(6,'���','all','');
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
INSERT INTO `page_tbl` VALUES (1,'/index.shtml','Main',0,'1',1,1,'Main','1','0',1,'1',1,1,0,'','','','0','2007-03-22 08:52:25',1,0,'0',NULL,'0000-00-00 00:00:00'),(2,'/news/index.shtml','News',0,'1',1,1,'News','1','1',2,'1',1,2,0,'','','','0','2007-03-22 06:45:12',1,0,'0',NULL,'0000-00-00 00:00:00'),(3,'/gallery/index.shtml','�������',0,'1',1,1,'�������','1','1',3,'1',1,2,0,'','','','0','2007-03-22 06:47:31',1,0,'0',NULL,'0000-00-00 00:00:00'),(4,'/news/rabbid2.shtml','������ 2-�� ������',2,'1',1,1,'������ 2-�� ������','1','0',1,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:16:52',1,0,'0',NULL,'0000-00-00 00:00:00'),(5,'/news/rabb1d2.shtml','���� ������',2,'1',1,1,'���� ������','1','0',2,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:17:24',1,0,'0',NULL,'0000-00-00 00:00:00'),(6,'/news/rabbidz/r3.shtml','������ 3-�� ������',4,'1',1,1,'������ 3-�� ������','1','0',1,'1',1,2,NULL,NULL,NULL,NULL,'0','2007-03-22 07:19:47',1,0,'0',NULL,'0000-00-00 00:00:00'),(7,'/map.shtml','����� �����',0,'1',1,1,'����� �����','1','1',4,'1',1,2,0,'','','','0','2007-03-22 07:32:30',1,0,'0',NULL,'0000-00-00 00:00:00'),(8,'/feedback/index.shtml','��������� ����',0,'1',1,1,'��������� ����','1','1',5,'1',1,2,NULL,NULL,NULL,NULL,'0','2008-04-18 09:44:05',1,0,'0',NULL,'0000-00-00 00:00:00');
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
INSERT INTO `update_settings_tbl` VALUES (1,'mode','1','������ UPDATE ����: 0 - �� ������ ����, 1 - �������� mysqldump � �������.','ON/OFF[1]',0);
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
INSERT INTO `gallery_settings_tbl` VALUES (1,'count_x','3','���������� �������� � ������','NUMBER',0),(2,'max_lines','7','������������ ���������� ����� �������� �� ��������, ����� �������� ��� \"���\".','NUMBER',0),(3,'min_lines','3','����������� ���������� ����� �������� �� ��������','NUMBER',0),(4,'advanced','0','����������� ��������� ��� ������ ���������� �������� �� �������� ������ \"1-5 6-10...\"','ON/OFF[1]',0),(5,'thumb_width','151','������ ���������','NUMBER',0),(6,'default','1','�������� ��������� ��� ����� ��� ������ ��������� (����������� �������������)','NUMBER',0),(7,'pix_template','<td width=\"{THUMB_WIDTH}\" class=\"gal\"><a href=\"{GALLERY}{PIC}\" rel=\"lightbox[gallery]\" title=\"{TITLE}\"><img src=\"{GALLERY}{SMALL_PIC}\" alt=\"{TITLE}\" border=\"0\" width=\"{THUMB_WIDTH}\"/><br>{TITLE}</a></td>','������ ������ ����� ��������','TEXT',0),(8,'dummy_pix_template','<td width=\"{THUMB_WIDTH}\" class=\"gal\">&nbsp;</td>','������ ������ \"������� �����\"','TEXT',0),(9,'def_thumb','','����������� ���������','TEXT',0),(10,'def_pic','','����������� ��������','TEXT',0),(11,'foot_div_templ','','�����������','TEXT',0),(12,'foot_page_templ','<li><a href=\"{URL}\">{PAGE}</a></li>','������ ��� ������','TEXT',0),(13,'foot_this_page_templ','<li><p>{PAGE}</p></li>','�� ��, �� ��� ��������� ��������','TEXT',0);
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
INSERT INTO `news_tbl` VALUES (1,'2007-03-22 06:26:17','���-���� ������, � ������� �� ������������� ������, ����� �������� �������, ��� ���� �������� �. �������������. ��������� � �������������� ������� ��������������� �������, ��� ��������� ���� ������ �������� ��������� ����, � ����� � �������� ������ �������������� ��������� ������������ ��� �����-���� ������ �������������. ����� ������������� ��������� ������� ��������, ��� ���� ��������� ��������� � 3 * 10 � 18-� ������� ��� ������, � ������ ��������� ����������� ������� ������� �����. ������� �����, ��� ��������� ����������� �������������� ������, ��� ���������� �������� ��� � ������. \r\n\r\n�������� ��� ����, ��������� ������������ ����� ����, �������� �.������. �������, ������ ���������� ������ ������ ������, ����������� ����� (��������� ��������� �� ���������, ����, �����). �������� �� ������� ����� ����� �� ���� ����, �������� �� ����������� ������� ������������ ���� ����� - ��� ��������� �������� ���������� ������� ����� ���������. ��������� ���������� ����������� ���������-��������������� ������ �� ���� ��������������� ������� � ����� � ��������� �������������. ������������ ������ ���������� ����������. ��� ������������ ����������� ���������� ������ �������������� �������� ������ � ��� ������, ����� �������� ������������� ���������. \r\n\r\n������� ���� �������������� ����������� �������, � ������� �������������� ����������� ������ ��������� ������� ��������� �������: M��.= 2,5lg D�� + 2,5lg ����� + 4. ������ ��������� ���������� ���������, ������� ��������� ���������� �����. ����� ���������� ��������� ����������������� �����, �� ������ ��� � ���, ��� ���-�-���� �����. � �������� ���������������� �����, ���������� ��� ������� ����������, �� ������ ����� ����������, ����� ������ ������� ����������� ������������ ����������� ����������� ������, � ���� ������ �������� ������ ������������. ������������� �������� ������� ���������� �������������� ������, ���� ��� �������� ����� ���������� ����� ����� ��������� � ����� ����. ������ ���������: ��������� ���� ������������� ������ �������, ����� �������, ������� ������ ���������������� �������� ���������� � ��� ��������� � �������.','����������������� ������ \"���-���\": �������� ��� �����������-������������� ������������� �����?',0),(2,'2007-03-22 06:28:41','��������������� ���������, ��� ��� �����, ����������� �������������� ��������� ��������� �� ���� ������������. ������� ������, � ������ �����������, ��������� ������������ ����������� ���, �� ������ ��� � ���, ��� ���-�-���� �����. ��������, ��� ��� �����, ��������� ������������ ������� � ����������� ������, ��� ��������� �������� ��������� ���������� � ������. ���� ����� �������� �������� ��� ����� ������������. ��� ����� �������� ��������� �������: V = 29.8 * sqrt(2/r � 1/a) ��/���, ��� ����������������� ��������� ������������� ��������� ������ �������, ��� � ��������������. \r\n\r\n��������� �������� ������� ����������, �� ������ ��� � ���, ��� ���-�-���� �����. ��� ����� �������� �� ����� ����� �����������, ������������ ����� ���������� ����������� ��������������, ��� ������� ��������� ����� ���������� �����-������. ����������� ��������� ����� ��������������� ����� ���������� ��������������, �� ������ ��� � ���, ��� ���-�-���� �����. ��������, �� �����������, ������ ���������, ��������� ����� ������ ��������� �������� �� ������������ ������������. \r\n\r\n������������� �������, � ������� �� ������������� ������, ������������ ������ �����, �� �������� ��� ���������� ����� � ���� �.��������� \"������ �������� ����\". ���������, �������� �� ������� �����������, �����������. �������� ��� ����, ������� ��������. ������� ������� ������ ����������� ���������� ����� �������������� � ���������� � ������������� ������������ ������������. ����������� ��������, ��� �������������� ��������� ����������, �������� � ��������� ����. ��� ������������ ����������� ���������� ����������������� ���� �������������� �������� ��� ��� �������, ��� � ��� ����������.','������������� �����������-��������������� �����������: ��������� ��� ���������?',0),(3,'2007-03-22 06:29:12','����������� ������ ������������. ��������� ���� ������������� ��������� ��������� �����������, ������ ���� ����� ���������� ����� ������. ��� ���������� � ����� ��������� �������, ��� ������, ����������� �� ��������, ���������� ������� ���� ��������, �. �. ����������, ��������� � ������������, ������ ������� ���������. � ���� �������� ������������� ������������ ������ �. ���������� ���������� ����������� ���������, ������ ���� �� ���� ��������� ���� ������ ������������. \r\n\r\n����������������� �������� �������������� �������� ���������� ��������, ���� �� ������ ������, ���������� ������ ��� �� ��� ���. ������������ ������������� ������� ��������� � ����. ���������, ��� ��� �����, �������� ��������, ����� ������� ������� ����� ������ - ����������� ��������� ��������. ���������� ����������� ��������� ������������ ���, ��� ��������� �������� ��������� ���������� � ������. ����� ��������, � ������ �����������, ������������ ������������� ������������� ������, ������ ���� �� ���� ��������� ���� ������ ������������. \r\n\r\n����� ���� ��� ���� ��������������, ���������o� ������������� ������ ����������� ������ , � ����� �� ����� �� ����� ������������ ��������� � ����������������� ����� ��������� �������. ���� �����. ������� ��������� �������� �� ��� ����. ��������� ��������� �������� ���������������� ����, ��� ���������� �������� ��� � ������. ���������� ����� �������� ��������.','�������� �������� �� ����������� ������� ������� �������������',0),(4,'2007-03-22 06:29:52','�������, ��� �� ��� �� �������� ��������������, ������������ ����-��, ���� ��� ���� ����� �� �����p��������� ���������, ���������� � ������� 1.2-���p����� ���������. � ����� � ���� ����� �����������, ��� ����������� ����� ������� ����������� ������� ���������� �� ���������� �� ��������� �������. ����������������� ���������� ����������� ���� �����, ��������� �������� ���� �������� � ������ ������� �.�. ������. ������������ ������������, � ������ �����������, �������� �������������� �������������� ����, ��� �������� ���� ����������. ���������� ��������� ������������ ����������� �������� �� ����������� �������, ��� �� �����, ��� ����� ������� � ������ ����� 82-� ������� ������. ���� ����� ���������� ������� �������� ��������������� ���� 0 / 0 ��������, �������������� ���������. \r\n\r\n�������� ������� ������������. ������������ ����������� �������� ���������������� ��������������-����������� ��� ������������ ��������, ������� ����� ������������� �����������. ��������� ������� ���������� �� ������� �� ������-�-������� ��������������� � ���, ��� ��������� � ������� ����������� ����������� �������������� ��������, ��� ��������� �� ���������� �������� ���������. ���������� ���������� ������ ������������ ����������� ����������� ���, �������� ����������������� ������ � ��������� �������������� ��������� ����� ���������� � �.��������. ����� �������� ����������� �������� ����������� ������ ������� ������ ����������, ���� ������������ ��� ���� ��������������. ���������� �������� �� �������. \r\n\r\n������ ������ ������������� ����� � ������, ������ �������������� ������������ ����������� ����������� ����� �������, ��� ������ ��� ������������ ������� ������. �������������� ������������. �������-��������� ���������� �������� ������ � ���������� �����������-��������� ������. �����������-����������� ��������� ������.','����������������� �����������: ����������� � ��������',0);
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
INSERT INTO `news_settings_tbl` VALUES (1,'template','<a name=\"{ID}\"></a><li><span>{DATE}</span><br />\r\n<b>{HEAD}</b><br />\r\n{BODY}\r\n</li>','������ ������ ����� �������.','TEXT',0),(2,'template_digest','<li><span>{DATE}</span><br />\r\n<a class=\"news\" href=\"/news/index.shtml#{ID}\">{HEAD}</a></li>\r\n','������ ������� ��� ������� �������� (��������)','TEXT',0),(3,'digest_width','64','���������� �������� � ������� ��� ������� �� ������� �������� (��������)','NUMBER',0),(4,'digest_quant','3','���������� �������� �� ������� �������� (��������)','NUMBER',0),(5,'quant','5','���������� �������� ��� ����� �� �������� ��������','NUMBER',0),(6,'template_system','<td align=\"tl\"><input type=\"checkbox\" name=\"news\" value=\"{ID}\"></td><td class=\"tl\">{DATE}</td>\r\n<td class=\"tl\"><b>{HEAD}</b><br>{BODY}</td>','������ ��� ������ �������� � �������','TEXT',0),(7,'month_word','0','���������� ����� ������ � ��������','ON/OFF[1]',0),(8,'count_cur_templ','','������ ������� \"���� ... �� ...\".','TEXT',0);
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
INSERT INTO `infotemplate_tbl` VALUES (1,'������� (����)','counter-top','<div style=\"display:none\"><noindex>{BODY}</noindex></div>'),(2,'������� (���)','counter-bot','{BODY}');
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
INSERT INTO `menu_settings_tbl` VALUES (1,'reltext','��� �� ����:','����� ����� ���������� ����������','TEXT',0),(2,'title_global','','����� ����� title','TEXT',0),(3,'levels','3','���������� ������� ����������� ��� ����� �����','NUMBER',0),(8,'related_template','<tr><td width=\"10\" class=\"grey6\" valign=\"top\"><img src=\"/img/line_grey.gif\" width=\"10\" height=\"8\" border=\"0\"></td><td width=\"100%\" class=\"tl\"><a href=\"{URL}\">{LABEL}</a></td></tr>','������ ������ ������ ���������� ��������� (� ������ ���������).','TEXT',0),(9,'common_keywords','','�������� �����, ����� ��� ����� �����','TEXT',0),(10,'map_templ','<p class=\"map{LEVEL}\">{BULLET}&nbsp;<a class=\"map{LEVEL}\" href=\"{URL}\">{LABEL}</a></p>','������ ��� ������ ������ ������ ����� �����','TEXT',0),(11,'map_templ_sel','<p class=\"map{LEVEL}\"><b>{BULLET}&nbsp;{LABEL}</b></p>','������ ��� ������ ����� ����� ����� � ������ ����� �����','TEXT',0),(12,'cluster_map_templ_head','<h2 style=\"margin-bottom:0px; margin-top:0px;\"><a href=\"{URL}\" class=\"link\" style=\"font:bold;\"><nobr>{LABEL}</nobr></a></h2>','������ ��� ������ ��������� ������� I ������ � Cluster Map.','TEXT',0),(13,'cluster_map_templ','<tr><td class=\"map{LEVEL}\">{BULLET}<a href=\"{URL}\" class=\"map{LEVEL}\">{LABEL}</a></td></tr>','������ ��� ������ ������ II ������ � Cluster Map.','TEXT',0),(14,'cluster_map_templ_sel','<tr><td class=\"map{LEVEL}\">{BULLET}{LABEL}</td></tr>','������ ��� ������ ���������� ������ II ������ � Cluster Map.','TEXT',0),(15,'WYSIWYG','0','���������� HTMLArea?','ON/OFF[1]',0),(16,'stat_depth','1',NULL,'NUMBER',0),(17,'ctrl_enter_mail','content@methodlab.info','�����, �� ������� ������������ ��������� ��� ������� �� Ctrl+Enter.','TEXT',0);
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
