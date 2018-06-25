i-- MySQL dump 10.14  Distrib 5.5.52-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: resourcedb
-- ------------------------------------------------------
-- Server version    5.5.52-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `continent`
--

DROP TABLE IF EXISTS `continent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `continent` (
  `continent_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `continent_code` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`continent_id`),
  UNIQUE KEY `continent_code` (`continent_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `continent`
--

LOCK TABLES `continent` WRITE;
/*!40000 ALTER TABLE `continent` DISABLE KEYS */;
INSERT INTO `continent` VALUES (1,'Antarctica','AN'),(2,'South America','SA'),(3,'Oceania','OC'),(4,'Asia','AS'),(5,'Africa','AF'),(6,'Europe','EU'),(7,'North America','NA');
/*!40000 ALTER TABLE `continent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country` (
  `country_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_code` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `continent_code` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `country_code` (`country_code`),
  KEY `country_continent_fk` (`continent_code`),
  CONSTRAINT `country_continent_fk` FOREIGN KEY (`continent_code`) REFERENCES `continent` (`continent_code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country`
--

LOCK TABLES `country` WRITE;
/*!40000 ALTER TABLE `country` DISABLE KEYS */;
INSERT INTO `country` VALUES (1,'Greenland','GL','NA'),(2,'Djibouti','DJ','AF'),(3,'Jamaica','JM','NA'),(4,'Papua New Guinea','PG','OC'),(5,'Austria','AT','EU'),(6,'Kiribati','KI','OC'),(7,'Swaziland','SZ','AF'),(8,'Mayotte','YT','AF'),(9,'Brunei Darussalam','BN','AS'),(10,'Zambia','ZM','AF'),(11,'Congo, The Democratic Republic of the','CD','AF'),(12,'Botswana','BW','AF'),(13,'Angola','AO','AF'),(14,'Zimbabwe','ZW','AF'),(15,'Saint Vincent and the Grenadines','VC','NA'),(16,'Puerto Rico','PR','NA'),(17,'Japan','JP','AS'),(18,'Namibia','NA','AF'),(19,'Saint Helena','SH','AF'),(20,'Tajikistan','TJ','AS'),(21,'Saint Lucia','LC','NA'),(22,'Morocco','MA','AF'),(23,'Vanuatu','VU','OC'),(24,'El Salvador','SV','NA'),(25,'Malta','MT','EU'),(26,'Mongolia','MN','AS'),(27,'Northern Mariana Islands','MP','OC'),(28,'Italy','IT','EU'),(29,'Reunion','RE','AF'),(30,'Samoa','WS','OC'),(31,'France','FR','EU'),(32,'Egypt','EG','AF'),(33,'Curacao','CW','NA'),(34,'Uzbekistan','UZ','AS'),(35,'Palau','PW','OC'),(36,'Tokelau','TK','OC'),(37,'Liberia','LR','AF'),(38,'Rwanda','RW','AF'),(39,'United States Minor Outlying Islands','UM','OC'),(40,'Tunisia','TN','AF'),(41,'Belgium','BE','EU'),(42,'Estonia','EE','EU'),(43,'Cook Islands','CK','OC'),(44,'Belarus','BY','EU'),(45,'Saudi Arabia','SA','AS'),(46,'Norway','NO','EU'),(47,'Lesotho','LS','AF'),(48,'Korea, Republic of','KR','AS'),(49,'South Africa','ZA','AF'),(50,'Portugal','PT','EU'),(51,'Burkina Faso','BF','AF'),(52,'Canada','CA','NA'),(53,'Armenia','AM','AS'),(54,'Cameroon','CM','AF'),(55,'Suriname','SR','SA'),(56,'Madagascar','MG','AF'),(57,'Nepal','NP','AS'),(58,'Bhutan','BT','AS'),(59,'Poland','PL','EU'),(60,'Turkmenistan','TM','AS'),(61,'Gabon','GA','AF'),(62,'Central African Republic','CF','AF'),(63,'United Arab Emirates','AE','AS'),(64,'Bosnia and Herzegovina','BA','EU'),(65,'Thailand','TH','AS'),(66,'Cayman Islands','KY','NA'),(67,'Lao People\'s Democratic Republic','LA','AS'),(68,'Philippines','PH','AS'),(69,'Cocos (Keeling) Islands','CC','AS'),(70,'Nicaragua','NI','NA'),(71,'French Southern Territories','TF','AN'),(72,'New Caledonia','NC','OC'),(73,'Guam','GU','OC'),(74,'Kazakhstan','KZ','AS'),(75,'Svalbard and Jan Mayen','SJ','EU'),(76,'Myanmar','MM','AS'),(77,'Nauru','NR','OC'),(78,'Niger','NE','AF'),(79,'Dominica','DM','NA'),(80,'Europe','EU','EU'),(81,'Tonga','TO','OC'),(82,'Mauritania','MR','AF'),(83,'Andorra','AD','EU'),(84,'Sweden','SE','EU'),(85,'Azerbaijan','AZ','AS'),(86,'Afghanistan','AF','AS'),(87,'Nigeria','NG','AF'),(88,'South Georgia and the South Sandwich Islands','GS','AN'),(89,'Kenya','KE','AF'),(90,'Benin','BJ','AF'),(91,'Montenegro','ME','EU'),(92,'Oman','OM','AS'),(93,'Aland Islands','AX','EU'),(94,'Vietnam','VN','AS'),(95,'Virgin Islands, British','VG','NA'),(96,'Yemen','YE','AS'),(97,'Cote d\'Ivoire','CI','AF'),(98,'Algeria','DZ','AF'),(99,'Sri Lanka','LK','AS'),(100,'Indonesia','ID','AS'),(101,'Micronesia, Federated States of','FM','OC'),(102,'Georgia','GE','AS'),(103,'Gambia','GM','AF'),(104,'Christmas Island','CX','AS'),(105,'Latvia','LV','EU'),(106,'Russian Federation','RU','EU'),(107,'Lebanon','LB','AS'),(108,'Falkland Islands (Malvinas)','FK','SA'),(109,'Finland','FI','EU'),(110,'Germany','DE','EU'),(111,'Maldives','MV','AS'),(112,'Luxembourg','LU','EU'),(113,'Venezuela','VE','SA'),(114,'Pitcairn','PN','OC'),(115,'Bahrain','BH','AS'),(116,'Gibraltar','GI','EU'),(117,'Wallis and Futuna','WF','OC'),(118,'Romania','RO','EU'),(119,'Virgin Islands, U.S.','VI','NA'),(120,'Tuvalu','TV','OC'),(121,'India','IN','AS'),(122,'Guadeloupe','GP','NA'),(123,'Argentina','AR','SA'),(124,'Senegal','SN','AF'),(125,'Mexico','MX','NA'),(126,'Faroe Islands','FO','EU'),(127,'Aruba','AW','NA'),(128,'Monaco','MC','EU'),(129,'Honduras','HN','NA'),(130,'Brazil','BR','SA'),(131,'Israel','IL','AS'),(132,'Guernsey','GG','EU'),(133,'Solomon Islands','SB','OC'),(134,'Palestinian Territory','PS','AS'),(135,'New Zealand','NZ','OC'),(136,'Hungary','HU','EU'),(137,'Dominican Republic','DO','NA'),(138,'Uganda','UG','AF'),(139,'Sint Maarten','SX','NA'),(140,'Bonaire, Saint Eustatius and Saba','BQ','NA'),(141,'Cambodia','KH','AS'),(142,'Togo','TG','AF'),(143,'United Kingdom','GB','EU'),(144,'Barbados','BB','NA'),(145,'Jersey','JE','EU'),(146,'Haiti','HT','NA'),(147,'Denmark','DK','EU'),(148,'Panama','PA','NA'),(149,'Qatar','QA','AS'),(150,'Cape Verde','CV','AF'),(151,'Grenada','GD','NA'),(152,'South Sudan','SS','AF'),(153,'Macao','MO','AS'),(154,'French Guiana','GF','SA'),(155,'Comoros','KM','AF'),(156,'Saint Martin','MF','NA'),(157,'Croatia','HR','EU'),(158,'Kuwait','KW','AS'),(159,'Turks and Caicos Islands','TC','NA'),(160,'Martinique','MQ','NA'),(161,'Czech Republic','CZ','EU'),(162,'Mozambique','MZ','AF'),(163,'Saint Bartelemey','BL','NA'),(164,'Spain','ES','EU'),(165,'Bolivia','BO','SA'),(166,'Sao Tome and Principe','ST','AF'),(167,'Australia','AU','OC'),(168,'Albania','AL','EU'),(169,'Iran, Islamic Republic of','IR','AS'),(170,'Congo','CG','AF'),(171,'Turkey','TR','EU'),(172,'Moldova, Republic of','MD','EU'),(173,'Burundi','BI','AF'),(174,'Guinea','GN','AF'),(175,'Guinea-Bissau','GW','AF'),(176,'Macedonia','MK','EU'),(177,'Greece','GR','EU'),(178,'Antigua and Barbuda','AG','NA'),(179,'Slovenia','SI','EU'),(180,'Asia/Pacific Region','AP','AS'),(181,'Colombia','CO','SA'),(182,'Anguilla','AI','NA'),(183,'Antarctica','AQ','AN'),(184,'Jordan','JO','AS'),(185,'San Marino','SM','EU'),(186,'Ukraine','UA','EU'),(187,'Chile','CL','SA'),(188,'Cuba','CU','NA'),(189,'Western Sahara','EH','AF'),(190,'Mali','ML','AF'),(191,'Saint Kitts and Nevis','KN','NA'),(192,'Seychelles','SC','AF'),(193,'Ethiopia','ET','AF'),(194,'Iceland','IS','EU'),(195,'Netherlands','NL','EU'),(196,'Montserrat','MS','NA'),(197,'Ecuador','EC','SA'),(198,'Hong Kong','HK','AS'),(199,'Malaysia','MY','AS'),(200,'Costa Rica','CR','NA'),(201,'Holy See (Vatican City State)','VA','EU'),(202,'British Indian Ocean Territory','IO','AS'),(203,'Sudan','SD','AF'),(204,'Serbia','RS','EU'),(205,'China','CN','AS'),(206,'Marshall Islands','MH','OC'),(207,'Bulgaria','BG','EU'),(208,'Uruguay','UY','SA'),(209,'Paraguay','PY','SA'),(210,'Bahamas','BS','NA'),(211,'Timor-Leste','TL','AS'),(212,'Mauritius','MU','AF'),(213,'Liechtenstein','LI','EU'),(214,'Switzerland','CH','EU'),(215,'Ghana','GH','AF'),(216,'Kyrgyzstan','KG','AS'),(217,'Niue','NU','OC'),(218,'United States','US','NA'),(219,'Peru','PE','SA'),(220,'Sierra Leone','SL','AF'),(221,'Belize','BZ','NA'),(222,'Cyprus','CY','AS'),(223,'Fiji','FJ','OC'),(224,'Isle of Man','IM','EU'),(225,'Ireland','IE','EU'),(226,'Taiwan','TW','AS'),(227,'Korea, Democratic People\'s Republic of','KP','AS'),(228,'French Polynesia','PF','OC'),(229,'Eritrea','ER','AF'),(230,'Iraq','IQ','AS'),(231,'American Samoa','AS','OC'),(232,'Tanzania, United Republic of','TZ','AF'),(233,'Malawi','MW','AF'),(234,'Libyan Arab Jamahiriya','LY','AF'),(235,'Guatemala','GT','NA'),(236,'Guyana','GY','SA'),(237,'Bermuda','BM','NA'),(238,'Pakistan','PK','AS'),(239,'Equatorial Guinea','GQ','AF'),(240,'Bouvet Island','BV','AN'),(241,'Lithuania','LT','EU'),(242,'Singapore','SG','AS'),(243,'Saint Pierre and Miquelon','PM','NA'),(244,'Trinidad and Tobago','TT','NA'),(245,'Norfolk Island','NF','OC'),(246,'Chad','TD','AF'),(247,'Somalia','SO','AF'),(248,'Syrian Arab Republic','SY','AS'),(249,'Slovakia','SK','EU'),(250,'Bangladesh','BD','AS'),(251,'Heard Island and McDonald Islands','HM','AN'),(252,'UNKNOWN','??',NULL);
/*!40000 ALTER TABLE `country` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discipline`
--

DROP TABLE IF EXISTS `discipline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discipline` (
  `discipline_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`discipline_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discipline`
--

LOCK TABLES `discipline` WRITE;
/*!40000 ALTER TABLE `discipline` DISABLE KEYS */;
INSERT INTO `discipline` VALUES (5,'Biomedical','Cells, individual genes, cancer, medical research'),(6,'Bioinformatics','Genomes, *omics, statistics, computational biology'),(7,'Brain and Neurosciences','Brain function, modeling'),(8,'Cognitive Sciences and Psychology','Cognition, language, social behavior, etc '),(9,'Environmental Biology','Populations, species, ecosystems, ecological studies'),(10,'Other/Unspecified Biology','Other, unknown, or multiple types of Biology-related research'),(11,'Computer Intelligence','Includes computer vision and AI'),(12,'Network Monitoring','Network testing, e.g., PerfSonar'),(13,'Other/Unspecified IT','Other, unknown, or multiple types of IT research or services, including general infrastructure and services, grid computing'),(14,'VLBI (geodetic/astrometric)','VLBI for positioning, GPS, etc.'),(15,'Atmospheric Sciences','Observation and modeling of atmospheric phenomena and weather, climate change if restricted to atmosphere'),(16,'GeoSpace','Observation and modeling of the ionosphere, auroras, space weather, solar flares, etc.'),(17,'Earth Sciences','Geology, hydrology, tectonics, etc.'),(18,'Remote Sensing','For agriculture, land use, archeology, weather, multiple sciences'),(19,'Other/Unspecified Earth-Space','Other, unknown, or multiple types of Earth and/or Space Science (not including astronomy)'),(20,'Energy','R&D related to various forms of energy, including fusion'),(21,'Materials','R&D related to materials '),(22,'Particle Physics','Theoretical and experimental sub-atomic particle physics'),(23,'Other/Unspecified Physics','Other,  unknown, or multiple types of Physics research '),(24,'Astronomy and Astrophysics','Observation and theory, including cosmic rays and VLBI for astronomy'),(25,'Chemistry','Applied or theoretical '),(26,'Mathematics and Statistics','Where the emphasis is on the math not the application of it'),(27,'Ocean Sciences','Study of the oceans and their contents'),(28,'Economics, Business','Research related to Economics, Business, etc.'),(29,'Sociology, Politics, Culture','Research areas related to human behavior'),(30,'Other','Discipline is known but does not fall into another category'),(31,'Multiple','Resources used by more than one discipline'),(32,'Unknown','no idea'),(33,'Climate Change (multi-discipline)','Choose Atmospheric Sciences or another discipline, when applicable'),(34,'Space Operations and Technology','Related to designing and operating satellites and spacecraft');
/*!40000 ALTER TABLE `discipline` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user` int(11) DEFAULT NULL,
  `message` varchar(140) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_block_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `discipline_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=808 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ip_block`
--

DROP TABLE IF EXISTS `ip_block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_block` (
  `ip_block_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `abbr` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `addr_str` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `addr_lower` int(10) DEFAULT NULL,
  `addr_upper` int(10) DEFAULT NULL,
  `mask` int(10) DEFAULT NULL,
  `asn` int(6) DEFAULT NULL,
  `organization_id` int(6) unsigned DEFAULT NULL,
  `country_code` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `discipline_id` int(6) unsigned DEFAULT NULL,
  `role_id` int(6) unsigned DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`ip_block_id`),
  UNIQUE KEY `abbr` (`abbr`),
  KEY `organization_id` (`organization_id`),
  KEY `FK_discipline` (`discipline_id`),
  KEY `FK_role` (`role_id`),
  CONSTRAINT `FK_discipline` FOREIGN KEY (`discipline_id`) REFERENCES `discipline` (`discipline_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `ip_block_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`organization_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ip_block_project`
--

DROP TABLE IF EXISTS `ip_block_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_block_project` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `ip_block_id` int(6) unsigned NOT NULL,
  `project_id` int(6) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ip_block_project_ip_block_id` (`ip_block_id`),
  KEY `fk_ip_block_project_project_id` (`project_id`),
  CONSTRAINT `fk_ip_block_project_ip_block_id` FOREIGN KEY (`ip_block_id`) REFERENCES `ip_block` (`ip_block_id`),
  CONSTRAINT `fk_ip_block_project_project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization` (
  `organization_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `abbr` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `country_code` char(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `continent_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`organization_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=325 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `project_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `abbr` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`project_id`),
  UNIQUE KEY `abbr` (`abbr`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `role_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  `url` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'Link',NULL,NULL),(2,'Compute',NULL,NULL),(3,'Storage',NULL,NULL),(4,'Instrument',NULL,NULL),(5,'Unknown',NULL,NULL),(6,'Network Testing','eg, PerfSONAR',NULL);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `version`
--

DROP TABLE IF EXISTS `version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `version` (
  `version_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

--
-- Dumping data for table `version`
--

LOCK TABLES `version` WRITE;
/*!40000 ALTER TABLE `version` DISABLE KEYS */;
INSERT INTO `version` VALUES (2,'0.1.0');
/*!40000 ALTER TABLE `version` ENABLE KEYS */;
UNLOCK TABLES;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-06-25 19:49:11
