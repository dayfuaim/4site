-- MySQL dump 10.10
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	5.0.22-Debian_0ubuntu6.06-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gallery_bind_tbl`
--

DROP TABLE IF EXISTS `gallery_bind_tbl`;
CREATE TABLE `gallery_bind_tbl` (
  `gallery_bind_id` mediumint(8) unsigned NOT NULL auto_increment,
  `table_fld` text NOT NULL,
  `id_fld` mediumint(8) unsigned NOT NULL default '0',
  `gallerycategory_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`gallery_bind_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `gallery_bind_tbl`
--


/*!40000 ALTER TABLE `gallery_bind_tbl` DISABLE KEYS */;
LOCK TABLES `gallery_bind_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `gallery_bind_tbl` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.10
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	5.0.22-Debian_0ubuntu6.06-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gallerycat_comp_tbl`
--

DROP TABLE IF EXISTS `gallerycat_comp_tbl`;
CREATE TABLE `gallerycat_comp_tbl` (
  `gallerycat_comp_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallerycategory_id` mediumint(8) unsigned NOT NULL default '0',
  `gallery_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`gallerycat_comp_id`),
  UNIQUE KEY `GC` (`gallerycategory_id`,`gallery_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `gallerycat_comp_tbl`
--


/*!40000 ALTER TABLE `gallerycat_comp_tbl` DISABLE KEYS */;
LOCK TABLES `gallerycat_comp_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `gallerycat_comp_tbl` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.10
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	5.0.22-Debian_0ubuntu6.06-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gallery_settings_tbl`
--

DROP TABLE IF EXISTS `gallery_settings_tbl`;
CREATE TABLE `gallery_settings_tbl` (
  `gallery_settings_id` mediumint(8) unsigned NOT NULL auto_increment,
  `gallery_settings_fld` tinytext,
  `value_fld` text,
  `description_fld` text,
  `type_fld` text,
  `language_id` mediumint(8) unsigned NOT NULL default '0',
  PRIMARY KEY  (`gallery_settings_id`),
  KEY `settingname` (`gallery_settings_fld`(250))
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `gallery_settings_tbl`
--


/*!40000 ALTER TABLE `gallery_settings_tbl` DISABLE KEYS */;
LOCK TABLES `gallery_settings_tbl` WRITE;
INSERT INTO `gallery_settings_tbl` VALUES (1,'count_x','3','Количество миниатюр в строке','NUMBER',0),(2,'max_lines','7','Максимальное количество строк миниатюр на странице, после которого идёт \"Все\".','NUMBER',0),(3,'min_lines','3','Минимальное количество строк миниатюр на странице','NUMBER',0),(4,'advanced','0','Расширенная настройка для показа количества миниатюр на странице вместо \"1-5 6-10...\"','ON/OFF[1]',0),(5,'thumb_width','130','Ширина миниатюры','NUMBER',0),(6,'default','5','Значение категории при входе без выбора категории (заполняется автоматически)','NUMBER',0),(7,'pix_template','','Шаблон вывода одной картинки','TEXT',0),(8,'dummy_pix_template','','Шаблон вывода \"пустого места\"','TEXT',0),(9,'def_thumb',NULL,'Умолчальная миниатюра','TEXT',0),(10,'def_pic',NULL,'Умолчальная картинка','TEXT',0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `gallery_settings_tbl` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.10
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	5.0.22-Debian_0ubuntu6.06-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gallery_tbl`
--

DROP TABLE IF EXISTS `gallery_tbl`;
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
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `gallery_tbl`
--


/*!40000 ALTER TABLE `gallery_tbl` DISABLE KEYS */;
LOCK TABLES `gallery_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `gallery_tbl` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- MySQL dump 10.10
--
-- Host: localhost    Database: dummy_db
-- ------------------------------------------------------
-- Server version	5.0.22-Debian_0ubuntu6.06-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
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
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

--
-- Dumping data for table `gallerycategory_tbl`
--


/*!40000 ALTER TABLE `gallerycategory_tbl` DISABLE KEYS */;
LOCK TABLES `gallerycategory_tbl` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `gallerycategory_tbl` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

