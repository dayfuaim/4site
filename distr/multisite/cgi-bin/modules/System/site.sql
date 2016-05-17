-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
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
-- Table structure for table `searchengines_tbl`
--

DROP TABLE IF EXISTS `searchengines_tbl`;
CREATE TABLE `searchengines_tbl` (
  `searchengines_id` mediumint(8) unsigned NOT NULL auto_increment,
  `name_fld` varchar(32) NOT NULL default '',
  `url_fld` text NOT NULL,
  `countregexp_fld` varchar(128) NOT NULL default '',
  `foundregexp_fld` varchar(255) NOT NULL default '',
  `unicode_fld` tinyint(4) NOT NULL default '0',
  `pagecode_fld` text NOT NULL,
  `text_fld` varchar(128) default NULL,
  PRIMARY KEY  (`searchengines_id`),
  KEY `NAME` (`name_fld`)
) TYPE=MyISAM;

--
-- Dumping data for table `searchengines_tbl`
--


/*!40000 ALTER TABLE `searchengines_tbl` DISABLE KEYS */;
LOCK TABLES `searchengines_tbl` WRITE;
INSERT INTO `searchengines_tbl` VALUES (1,'google','http://www.google.com/search?{ARG}&lr=&ie=UTF-8&btnG=%D0%9F%D0%BE%D0%B8%D1%81%D0%BA+%D0%B2+Google&q=','<p\\sclass=g><a\\sclass=l\\shref=\"[^\"]+\"\\s','<br><font\\scolor=\\#008000>(?:<span\\sdir=ltr>)?',1,'sub {\n	my $i = shift;\n	my $p = get_setting(\"seo\",\"page\");\n	return qq{num=$p&start=}.($p*$i)\n}','q(?:=(?:([^&]+)&|(.+)$))'),(2,'yandex','http://www.yandex.ru/yand{ARG}','<li\\svalue=(\\d+)>','<span\\sstyle=\"color:\\s#006600;\">\\s',1,'sub {\n	my $i = shift;\n	my $ret = ($i)?qq{page?p=$i&q=$qq&ag=d&qs=stype%3Dwww%26text%3D}:qq{search?stype=www&text=};\n	return $ret\n}','text(?:=(?:([^&]+)&|(.+)$)|%3D(?:(.+)%26|(.+)$))'),(3,'mail.ru','http://go.mail.ru/search?{ARG}&use_morph=y&q=','<td\\swidth=40\\svalign=top\\sclass=num>(\\d+)\\.','<a\\starget=\"_blank\"\\shref=\"/click\\?url=http\\%3A\\%2F\\%2F',0,'sub {\n	my $i = shift;\n	my $p = get_setting(\"seo\",\"page\");\n	return qq{sf=}.($p*$i)\n}','q(?:=(?:([^&]+)&|(.+)$))'),(4,'rambler','http://search.rambler.ru/srch?{ARG}&words=','<li><div\\sclass=\"ttl\"><a\\sonclick=\"[^\"]+\"\\shref=\"([^\"]+)\"','<li><div\\sclass=\"ttl\"><a\\sonclick=\"[^\"]+\"\\shref=\"([^\"]+)\"',0,'sub {\n	my $i = shift;\n	my $p = get_setting(\"seo\",\"page\");\n	return qq{limit=$p&start=}.($p*$i+1)\n}','words(?:=(?:([^&]+)&|(.+)$))');
UNLOCK TABLES;
/*!40000 ALTER TABLE `searchengines_tbl` ENABLE KEYS */;

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
-- Table structure for table `module_tbl`
--

DROP TABLE IF EXISTS `module_tbl`;
CREATE TABLE `module_tbl` (
  `module_id` mediumint(8) unsigned NOT NULL auto_increment,
  `module_fld` varchar(64) NOT NULL default '',
  `descr_fld` text,
  `enabled_fld` enum('0','1') NOT NULL default '0',
  `uses_fld` varchar(64) default NULL,
  PRIMARY KEY  (`module_id`)
) TYPE=MyISAM;

--
-- Dumping data for table `module_tbl`
--


/*!40000 ALTER TABLE `module_tbl` DISABLE KEYS */;
LOCK TABLES `module_tbl` WRITE;
INSERT INTO `module_tbl` VALUES (1,'Objects','Модуль функций обработки объектов (объектной структуры)','1',NULL),(7,'Gallery',NULL,'1',NULL),(9,'Infoblock',NULL,'1',NULL),(17,'Banner',NULL,'1',NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `module_tbl` ENABLE KEYS */;

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
-- MySQL dump 10.9
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	4.1.13
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,MYSQL40' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
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
-- Table structure for table `actionstat_tbl`
--

DROP TABLE IF EXISTS `actionstat_tbl`;
CREATE TABLE `actionstat_tbl` (
  `actionstat_id` bigint(20) unsigned NOT NULL auto_increment,
  `user_fld` mediumint(8) unsigned NOT NULL default '0',
  `hostfrom_fld` int(10) unsigned NOT NULL default '0',
  `site_fld` mediumint(8) unsigned NOT NULL default '0',
  `module_fld` mediumint(8) unsigned NOT NULL default '0',
  `form_fld` mediumint(8) unsigned NOT NULL default '0',
  `act_fld` text,
  `formhash_fld` text,
  `datetime_fld` datetime default NULL,
  PRIMARY KEY  (`actionstat_id`),
  KEY `UI` (`user_fld`),
  KEY `SI` (`site_fld`),
  KEY `MI` (`module_fld`),
  KEY `HFI` (`hostfrom_fld`),
  KEY `FI` (`form_fld`)
) TYPE=MyISAM;

--
-- Dumping data for table `actionstat_tbl`
--


/*!40000 ALTER TABLE `actionstat_tbl` DISABLE KEYS */;
LOCK TABLES `actionstat_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `actionstat_tbl` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

