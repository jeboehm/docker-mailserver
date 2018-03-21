/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Export von Tabelle mail_aliases
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mail_aliases`;

CREATE TABLE `mail_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `destination` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alias_idx` (`domain_id`,`name`,`destination`),
  KEY `IDX_85AF3A56115F0EE5` (`domain_id`),
  CONSTRAINT `FK_5F12BB39115F0EE5` FOREIGN KEY (`domain_id`) REFERENCES `mail_domains` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

LOCK TABLES `mail_aliases` WRITE;
/*!40000 ALTER TABLE `mail_aliases` DISABLE KEYS */;

INSERT INTO `mail_aliases` (`id`, `domain_id`, `name`, `destination`)
VALUES
	(1,1,'foo','admin@example.com');

/*!40000 ALTER TABLE `mail_aliases` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle mail_domains
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mail_domains`;

CREATE TABLE `mail_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_56C63EF25E237E06` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `mail_domains` WRITE;
/*!40000 ALTER TABLE `mail_domains` DISABLE KEYS */;

INSERT INTO `mail_domains` (`id`, `name`)
VALUES
	(1,'example.com');

/*!40000 ALTER TABLE `mail_domains` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle mail_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mail_users`;

CREATE TABLE `mail_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_idx` (`name`,`domain_id`),
  KEY `IDX_20400786115F0EE5` (`domain_id`),
  CONSTRAINT `FK_1483A5E9115F0EE5` FOREIGN KEY (`domain_id`) REFERENCES `mail_domains` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

LOCK TABLES `mail_users` WRITE;
/*!40000 ALTER TABLE `mail_users` DISABLE KEYS */;

INSERT INTO `mail_users` (`id`, `domain_id`, `name`, `password`)
VALUES
	(1,1,'admin','$5$rounds=5000$buS8AUYLR937.LsZ$evgq1GkFfLNTlIChhF6yvBB5ny1IEEHWy/ah8pO5zCA');

/*!40000 ALTER TABLE `mail_users` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle migration_versions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `migration_versions`;

CREATE TABLE `migration_versions` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

LOCK TABLES `migration_versions` WRITE;
/*!40000 ALTER TABLE `migration_versions` DISABLE KEYS */;

INSERT INTO `migration_versions` (`version`)
VALUES
	('20180320164351'),
	('20180320171339');

/*!40000 ALTER TABLE `migration_versions` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
