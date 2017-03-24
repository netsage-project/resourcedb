-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: resourcedb
-- ------------------------------------------------------
-- Server version	5.1.73

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
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country` (
  `country_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `country_code` char(2) NOT NULL,
  `continent_code` char(2) DEFAULT NULL,
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `country_code` (`country_code`),
  KEY `country_continent_fk` (`continent_code`),
  CONSTRAINT `country_continent_fk` FOREIGN KEY (`continent_code`) REFERENCES `continent` (`continent_code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country`
--

LOCK TABLES `country` WRITE;
/*!40000 ALTER TABLE `country` DISABLE KEYS */;
INSERT INTO `country` VALUES (1,'Greenland','GL','NA'),(2,'Djibouti','DJ','AF'),(3,'Jamaica','JM','NA'),(4,'Papua New Guinea','PG','OC'),(5,'Austria','AT','EU'),(6,'Kiribati','KI','OC'),(7,'Swaziland','SZ','AF'),(8,'Mayotte','YT','AF'),(9,'Brunei Darussalam','BN','AS'),(10,'Zambia','ZM','AF'),(11,'Congo, The Democratic Republic of the','CD','AF'),(12,'Botswana','BW','AF'),(13,'Angola','AO','AF'),(14,'Zimbabwe','ZW','AF'),(15,'Saint Vincent and the Grenadines','VC','NA'),(16,'Puerto Rico','PR','NA'),(17,'Japan','JP','AS'),(18,'Namibia','NA','AF'),(19,'Saint Helena','SH','AF'),(20,'Tajikistan','TJ','AS'),(21,'Saint Lucia','LC','NA'),(22,'Morocco','MA','AF'),(23,'Vanuatu','VU','OC'),(24,'El Salvador','SV','NA'),(25,'Malta','MT','EU'),(26,'Mongolia','MN','AS'),(27,'Northern Mariana Islands','MP','OC'),(28,'Italy','IT','EU'),(29,'Reunion','RE','AF'),(30,'Samoa','WS','OC'),(31,'France','FR','EU'),(32,'Egypt','EG','AF'),(33,'Curacao','CW','NA'),(34,'Uzbekistan','UZ','AS'),(35,'Palau','PW','OC'),(36,'Tokelau','TK','OC'),(37,'Liberia','LR','AF'),(38,'Rwanda','RW','AF'),(39,'United States Minor Outlying Islands','UM','OC'),(40,'Tunisia','TN','AF'),(41,'Belgium','BE','EU'),(42,'Estonia','EE','EU'),(43,'Cook Islands','CK','OC'),(44,'Belarus','BY','EU'),(45,'Saudi Arabia','SA','AS'),(46,'Norway','NO','EU'),(47,'Lesotho','LS','AF'),(48,'Korea, Republic of','KR','AS'),(49,'South Africa','ZA','AF'),(50,'Portugal','PT','EU'),(51,'Burkina Faso','BF','AF'),(52,'Canada','CA','NA'),(53,'Armenia','AM','AS'),(54,'Cameroon','CM','AF'),(55,'Suriname','SR','SA'),(56,'Madagascar','MG','AF'),(57,'Nepal','NP','AS'),(58,'Bhutan','BT','AS'),(59,'Poland','PL','EU'),(60,'Turkmenistan','TM','AS'),(61,'Gabon','GA','AF'),(62,'Central African Republic','CF','AF'),(63,'United Arab Emirates','AE','AS'),(64,'Bosnia and Herzegovina','BA','EU'),(65,'Thailand','TH','AS'),(66,'Cayman Islands','KY','NA'),(67,'Lao People\'s Democratic Republic','LA','AS'),(68,'Philippines','PH','AS'),(69,'Cocos (Keeling) Islands','CC','AS'),(70,'Nicaragua','NI','NA'),(71,'French Southern Territories','TF','AN'),(72,'New Caledonia','NC','OC'),(73,'Guam','GU','OC'),(74,'Kazakhstan','KZ','AS'),(75,'Svalbard and Jan Mayen','SJ','EU'),(76,'Myanmar','MM','AS'),(77,'Nauru','NR','OC'),(78,'Niger','NE','AF'),(79,'Dominica','DM','NA'),(80,'Europe','EU','EU'),(81,'Tonga','TO','OC'),(82,'Mauritania','MR','AF'),(83,'Andorra','AD','EU'),(84,'Sweden','SE','EU'),(85,'Azerbaijan','AZ','AS'),(86,'Afghanistan','AF','AS'),(87,'Nigeria','NG','AF'),(88,'South Georgia and the South Sandwich Islands','GS','AN'),(89,'Kenya','KE','AF'),(90,'Benin','BJ','AF'),(91,'Montenegro','ME','EU'),(92,'Oman','OM','AS'),(93,'Aland Islands','AX','EU'),(94,'Vietnam','VN','AS'),(95,'Virgin Islands, British','VG','NA'),(96,'Yemen','YE','AS'),(97,'Cote d\'Ivoire','CI','AF'),(98,'Algeria','DZ','AF'),(99,'Sri Lanka','LK','AS'),(100,'Indonesia','ID','AS'),(101,'Micronesia, Federated States of','FM','OC'),(102,'Georgia','GE','AS'),(103,'Gambia','GM','AF'),(104,'Christmas Island','CX','AS'),(105,'Latvia','LV','EU'),(106,'Russian Federation','RU','EU'),(107,'Lebanon','LB','AS'),(108,'Falkland Islands (Malvinas)','FK','SA'),(109,'Finland','FI','EU'),(110,'Germany','DE','EU'),(111,'Maldives','MV','AS'),(112,'Luxembourg','LU','EU'),(113,'Venezuela','VE','SA'),(114,'Pitcairn','PN','OC'),(115,'Bahrain','BH','AS'),(116,'Gibraltar','GI','EU'),(117,'Wallis and Futuna','WF','OC'),(118,'Romania','RO','EU'),(119,'Virgin Islands, U.S.','VI','NA'),(120,'Tuvalu','TV','OC'),(121,'India','IN','AS'),(122,'Guadeloupe','GP','NA'),(123,'Argentina','AR','SA'),(124,'Senegal','SN','AF'),(125,'Mexico','MX','NA'),(126,'Faroe Islands','FO','EU'),(127,'Aruba','AW','NA'),(128,'Monaco','MC','EU'),(129,'Honduras','HN','NA'),(130,'Brazil','BR','SA'),(131,'Israel','IL','AS'),(132,'Guernsey','GG','EU'),(133,'Solomon Islands','SB','OC'),(134,'Palestinian Territory','PS','AS'),(135,'New Zealand','NZ','OC'),(136,'Hungary','HU','EU'),(137,'Dominican Republic','DO','NA'),(138,'Uganda','UG','AF'),(139,'Sint Maarten','SX','NA'),(140,'Bonaire, Saint Eustatius and Saba','BQ','NA'),(141,'Cambodia','KH','AS'),(142,'Togo','TG','AF'),(143,'United Kingdom','GB','EU'),(144,'Barbados','BB','NA'),(145,'Jersey','JE','EU'),(146,'Haiti','HT','NA'),(147,'Denmark','DK','EU'),(148,'Panama','PA','NA'),(149,'Qatar','QA','AS'),(150,'Cape Verde','CV','AF'),(151,'Grenada','GD','NA'),(152,'South Sudan','SS','AF'),(153,'Macao','MO','AS'),(154,'French Guiana','GF','SA'),(155,'Comoros','KM','AF'),(156,'Saint Martin','MF','NA'),(157,'Croatia','HR','EU'),(158,'Kuwait','KW','AS'),(159,'Turks and Caicos Islands','TC','NA'),(160,'Martinique','MQ','NA'),(161,'Czech Republic','CZ','EU'),(162,'Mozambique','MZ','AF'),(163,'Saint Bartelemey','BL','NA'),(164,'Spain','ES','EU'),(165,'Bolivia','BO','SA'),(166,'Sao Tome and Principe','ST','AF'),(167,'Australia','AU','OC'),(168,'Albania','AL','EU'),(169,'Iran, Islamic Republic of','IR','AS'),(170,'Congo','CG','AF'),(171,'Turkey','TR','EU'),(172,'Moldova, Republic of','MD','EU'),(173,'Burundi','BI','AF'),(174,'Guinea','GN','AF'),(175,'Guinea-Bissau','GW','AF'),(176,'Macedonia','MK','EU'),(177,'Greece','GR','EU'),(178,'Antigua and Barbuda','AG','NA'),(179,'Slovenia','SI','EU'),(180,'Asia/Pacific Region','AP','AS'),(181,'Colombia','CO','SA'),(182,'Anguilla','AI','NA'),(183,'Antarctica','AQ','AN'),(184,'Jordan','JO','AS'),(185,'San Marino','SM','EU'),(186,'Ukraine','UA','EU'),(187,'Chile','CL','SA'),(188,'Cuba','CU','NA'),(189,'Western Sahara','EH','AF'),(190,'Mali','ML','AF'),(191,'Saint Kitts and Nevis','KN','NA'),(192,'Seychelles','SC','AF'),(193,'Ethiopia','ET','AF'),(194,'Iceland','IS','EU'),(195,'Netherlands','NL','EU'),(196,'Montserrat','MS','NA'),(197,'Ecuador','EC','SA'),(198,'Hong Kong','HK','AS'),(199,'Malaysia','MY','AS'),(200,'Costa Rica','CR','NA'),(201,'Holy See (Vatican City State)','VA','EU'),(202,'British Indian Ocean Territory','IO','AS'),(203,'Sudan','SD','AF'),(204,'Serbia','RS','EU'),(205,'China','CN','AS'),(206,'Marshall Islands','MH','OC'),(207,'Bulgaria','BG','EU'),(208,'Uruguay','UY','SA'),(209,'Paraguay','PY','SA'),(210,'Bahamas','BS','NA'),(211,'Timor-Leste','TL','AS'),(212,'Mauritius','MU','AF'),(213,'Liechtenstein','LI','EU'),(214,'Switzerland','CH','EU'),(215,'Ghana','GH','AF'),(216,'Kyrgyzstan','KG','AS'),(217,'Niue','NU','OC'),(218,'United States','US','NA'),(219,'Peru','PE','SA'),(220,'Sierra Leone','SL','AF'),(221,'Belize','BZ','NA'),(222,'Cyprus','CY','AS'),(223,'Fiji','FJ','OC'),(224,'Isle of Man','IM','EU'),(225,'Ireland','IE','EU'),(226,'Taiwan','TW','AS'),(227,'Korea, Democratic People\'s Republic of','KP','AS'),(228,'French Polynesia','PF','OC'),(229,'Eritrea','ER','AF'),(230,'Iraq','IQ','AS'),(231,'American Samoa','AS','OC'),(232,'Tanzania, United Republic of','TZ','AF'),(233,'Malawi','MW','AF'),(234,'Libyan Arab Jamahiriya','LY','AF'),(235,'Guatemala','GT','NA'),(236,'Guyana','GY','SA'),(237,'Bermuda','BM','NA'),(238,'Pakistan','PK','AS'),(239,'Equatorial Guinea','GQ','AF'),(240,'Bouvet Island','BV','AN'),(241,'Lithuania','LT','EU'),(242,'Singapore','SG','AS'),(243,'Saint Pierre and Miquelon','PM','NA'),(244,'Trinidad and Tobago','TT','NA'),(245,'Norfolk Island','NF','OC'),(246,'Chad','TD','AF'),(247,'Somalia','SO','AF'),(248,'Syrian Arab Republic','SY','AS'),(249,'Slovakia','SK','EU'),(250,'Bangladesh','BD','AS'),(251,'Heard Island and McDonald Islands','HM','AN');
/*!40000 ALTER TABLE `country` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `continent`
--

DROP TABLE IF EXISTS `continent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `continent` (
  `continent_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `continent_code` char(2) NOT NULL,
  PRIMARY KEY (`continent_id`),
  UNIQUE KEY `continent_code` (`continent_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `continent`
--

LOCK TABLES `continent` WRITE;
/*!40000 ALTER TABLE `continent` DISABLE KEYS */;
INSERT INTO `continent` VALUES (1,'Antarctica','AN'),(2,'South America','SA'),(3,'Oceania','OC'),(4,'Asia','AS'),(5,'Africa','AF'),(6,'Europe','EU'),(7,'North America','NA');
/*!40000 ALTER TABLE `continent` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-03-24 18:00:01
