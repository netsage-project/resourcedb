-- MySQL dump 10.14  Distrib 5.5.52-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: resourcedb
-- ------------------------------------------------------
-- Server version	5.5.52-MariaDB

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
-- Table structure for table `discipline`
--

DROP TABLE IF EXISTS `discipline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `discipline` (
  `discipline_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`discipline_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Data for table `discipline`
--

LOCK TABLES `discipline` WRITE;
/*!40000 ALTER TABLE `discipline` DISABLE KEYS */;
INSERT INTO `discipline` VALUES (5,'Biomedical','cells, indiv. genes, cancer, medical research'),(6,'Bioinformatics','genomes, *omics, statistics, computational biology'),(7,'Brain and Neurosciences','at the physical level '),(8,'Cognitive Sciences and Psychology','cognition, language, social behavior, etc '),(9,'Environmental Biology','populations, species, ecosystems, ecological studies'),(10,'Other/Unspecified Biology',''),(11,'Computer Intelligence','including computer vision and AI '),(12,'Network Monitoring','network testing like PerfSonar'),(13,'Other/Unspecified IT','including general infrastructure and services, grid computing'),(14,'VLBI (geodetic/astrometric)','(not this if for astronomy)'),(15,'Atmospheric Sciences','observation and modeling of weather, etc. not primarily climate change '),(16,'GeoSpace','observation and modeling of ionosphere, auroras, space weather, the sun'),(17,'Earth Sciences','geology, hydrology, tectonics, etc '),(18,'Remote Sensing','for agriculture, land use, archeology, multiple sciences'),(19,'Other/Unspecified/Multiple Earth-Space','(not astronomy)'),(20,'Energy','R&D related to various forms of energy, including fusion'),(21,'Materials','R&D related to materials '),(22,'Particle Physics','theortical and high energy experimental physics'),(23,'Other/Unspecified Physics',' '),(24,'Astronomy and Astrophysics','observation, theory, incl. cosmic rays, VLBI for astronomy'),(25,'Chemistry',' '),(26,'Mathematics and Statistics','(if not applied to other disciplines)'),(27,'Ocean Sciences',''),(28,'Economics, Business',''),(29,'Sociology, Politics, Culture',' '),(30,'Other',''),(31,'Multiple','used by more than one discipline'),(32,'Unknown',''),(33,'Climate Change (multi-discipline)','(choose Atmospheric Sciences when applicable)'),(34,'Space Operations and Technology','');
/*!40000 ALTER TABLE `discipline` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_block`
--

DROP TABLE IF EXISTS `ip_block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_block` (
  `ip_block_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) not null default '',
  `addr_str` varchar(64) NOT NULL,
  `addr_lower` int(10) DEFAULT NULL,
  `addr_upper` int(10) DEFAULT NULL,
  `mask` int(10) DEFAULT NULL,
  `asn` int(6) DEFAULT NULL,
  `organization_id` int(6) unsigned DEFAULT NULL,
  `country_code` char(2) DEFAULT NULL,
  `country_name` varchar(255) DEFAULT NULL,
  `continent_code` char(2) DEFAULT NULL,
  `continent_name` varchar(255) DEFAULT NULL,
  `postal_code` varchar(50) DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `project_id` int(6) unsigned DEFAULT NULL,
  `discipline_id` int(6) unsigned DEFAULT NULL,
  `role_id` int(6) unsigned DEFAULT NULL,
  PRIMARY KEY (`ip_block_id`),
  KEY `organization_id` (`organization_id`),
  KEY `FK_project` (`project_id`),
  KEY `FK_discipline` (`discipline_id`),
  KEY `FK_role` (`role_id`),
  CONSTRAINT `FK_discipline` FOREIGN KEY (`discipline_id`) REFERENCES `discipline` (`discipline_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `ip_block_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organization` (`organization_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization` (
  `organization_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `project_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `role_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `version`
--

DROP TABLE IF EXISTS `version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `version` (
  `version_id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-02-20 18:26:35
