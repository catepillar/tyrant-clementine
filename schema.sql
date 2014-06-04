-- MySQL dump 10.13  Distrib 5.5.31, for Linux (x86_64)
--
-- Host: localhost    Database: tyrant
-- ------------------------------------------------------
-- Server version	5.5.31

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
-- Table structure for table `access_users`
--

DROP TABLE IF EXISTS `access_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_users` (
  `user_id` int(10) unsigned NOT NULL,
  `local_id` int(10) unsigned NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `local_id` (`local_id`),
  CONSTRAINT `access_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tyrant_users` (`user_id`),
  CONSTRAINT `access_users_ibfk_2` FOREIGN KEY (`local_id`) REFERENCES `web_users` (`local_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conquest`
--

DROP TABLE IF EXISTS `conquest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conquest` (
  `system_id` smallint(5) unsigned DEFAULT NULL,
  `x` tinyint(4) DEFAULT NULL,
  `y` tinyint(4) DEFAULT NULL,
  `effect` bit(1) DEFAULT NULL,
  `faction_id` int(10) unsigned DEFAULT NULL,
  `attacking_faction_id` int(10) unsigned DEFAULT NULL,
  `protection_end_time` int(10) unsigned DEFAULT NULL,
  `attack_end_time` int(10) unsigned DEFAULT NULL,
  UNIQUE KEY `system_id` (`system_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conquest_irc`
--

DROP TABLE IF EXISTS `conquest_irc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conquest_irc` (
  `user_id` int(10) unsigned NOT NULL,
  `room` varchar(20) NOT NULL,
  `faction_id` int(10) unsigned NOT NULL,
  UNIQUE KEY `room` (`room`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `conquest_irc_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tyrant_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `factions`
--

DROP TABLE IF EXISTS `factions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factions` (
  `id` int(10) unsigned NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  `creator_id` int(10) unsigned DEFAULT '0',
  `level` tinyint(3) unsigned DEFAULT '1',
  `rating` smallint(5) unsigned DEFAULT '0',
  `wins` smallint(5) unsigned DEFAULT NULL,
  `losses` smallint(5) unsigned DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `disband_time` int(11) DEFAULT '0',
  `tiles` int(11) DEFAULT NULL,
  `members` int(11) DEFAULT NULL,
  `activity_level` int(11) DEFAULT NULL,
  `next_update` int(11) DEFAULT '0',
  `infamy_time` int(11) DEFAULT NULL,
  `infamy` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `factions_irc`
--

DROP TABLE IF EXISTS `factions_irc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factions_irc` (
  `user_id` int(10) unsigned NOT NULL,
  `room` varchar(20) NOT NULL,
  `faction_id` int(10) unsigned NOT NULL,
  `faction_name` varchar(20) NOT NULL,
  `protection` tinyint(4) DEFAULT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `pass` varchar(32) DEFAULT NULL,
  UNIQUE KEY `room` (`room`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `factions_irc_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tyrant_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `player_wars`
--

DROP TABLE IF EXISTS `player_wars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_wars` (
  `user_id` int(10) unsigned DEFAULT NULL,
  `war_id` int(10) unsigned DEFAULT NULL,
  `wins` smallint(5) unsigned DEFAULT NULL,
  `losses` smallint(5) unsigned DEFAULT NULL,
  `points` smallint(5) unsigned DEFAULT NULL,
  `points_against` smallint(5) unsigned DEFAULT NULL,
  `battles` smallint(5) unsigned DEFAULT NULL,
  UNIQUE KEY `user_id` (`user_id`,`war_id`),
  KEY `war_id` (`war_id`),
  KEY `user_id_2` (`user_id`,`war_id`),
  CONSTRAINT `player_wars_ibfk_1` FOREIGN KEY (`war_id`) REFERENCES `wars` (`war_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `slot`
--

DROP TABLE IF EXISTS `slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `slot` (
  `health` smallint(6) DEFAULT NULL,
  `defeated` tinyint(1) DEFAULT NULL,
  `commander_id` smallint(5) unsigned DEFAULT NULL,
  `deck` varchar(33) DEFAULT NULL,
  `time` int(10) unsigned DEFAULT NULL,
  `prev_decks` blob NOT NULL,
  `attack_results` blob,
  `owner` varchar(16) DEFAULT NULL,
  `attack_end_time` int(10) unsigned DEFAULT NULL,
  `system_slot_time` varchar(20) DEFAULT NULL,
  `max_health` smallint(6) DEFAULT NULL,
  `attack_decks` blob NOT NULL,
  `claimer` varchar(16) DEFAULT NULL,
  `stuck` blob NOT NULL,
  UNIQUE KEY `system_slot_time` (`system_slot_time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tyrant_users`
--

DROP TABLE IF EXISTS `tyrant_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tyrant_users` (
  `user_id` int(10) unsigned NOT NULL,
  `server` varchar(12) NOT NULL,
  `auth_token` char(64) NOT NULL,
  `flashcode` char(32) NOT NULL,
  `client_code` int(10) unsigned DEFAULT NULL,
  `issue` tinyint(3) unsigned DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wars`
--

DROP TABLE IF EXISTS `wars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wars` (
  `war_id` int(10) unsigned DEFAULT NULL,
  `attacker_faction_id` int(10) unsigned DEFAULT NULL,
  `defender_faction_id` int(10) unsigned DEFAULT NULL,
  `attacker_points` mediumint(8) unsigned DEFAULT NULL,
  `defender_points` mediumint(8) unsigned DEFAULT NULL,
  `attacker_wins` smallint(5) unsigned DEFAULT NULL,
  `defender_wins` smallint(5) unsigned DEFAULT NULL,
  `attacker_rating_change` tinyint(4) DEFAULT NULL,
  `defender_rating_change` tinyint(4) DEFAULT NULL,
  `victor` int(10) unsigned DEFAULT NULL,
  `start_time` int(10) unsigned DEFAULT NULL,
  UNIQUE KEY `war_id` (`war_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_users`
--

DROP TABLE IF EXISTS `web_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_users` (
  `local_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `password` varchar(32) DEFAULT NULL,
  `name` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`local_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-02-01 13:32:12
