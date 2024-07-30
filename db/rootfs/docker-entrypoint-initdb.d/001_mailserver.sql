/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `mail_aliases`;
CREATE TABLE `mail_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `destination` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alias_idx` (`domain_id`,`name`,`destination`),
  KEY `IDX_85AF3A56115F0EE5` (`domain_id`),
  CONSTRAINT `FK_5F12BB39115F0EE5` FOREIGN KEY (`domain_id`) REFERENCES `mail_domains` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `mail_domains`;
CREATE TABLE `mail_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `dkim_enabled` tinyint(1) NOT NULL,
  `dkim_selector` varchar(255) NOT NULL,
  `dkim_private_key` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_56C63EF25E237E06` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `mail_users`;
CREATE TABLE `mail_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `send_only` tinyint(1) NOT NULL,
  `quota` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_idx` (`name`,`domain_id`),
  KEY `IDX_20400786115F0EE5` (`domain_id`),
  CONSTRAINT `FK_1483A5E9115F0EE5` FOREIGN KEY (`domain_id`) REFERENCES `mail_domains` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `migration_versions`;
CREATE TABLE `migration_versions` (
  `version` varchar(191) NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB;

INSERT INTO `migration_versions` (`version`, `executed_at`, `execution_time`) VALUES
('DoctrineMigrations\\Version20180320164351', NOW(), 0),
('DoctrineMigrations\\Version20180320171339', NOW(), 0),
('DoctrineMigrations\\Version20180322081734', NOW(), 0),
('DoctrineMigrations\\Version20180520173959', NOW(), 0),
('DoctrineMigrations\\Version20190610121554', NOW(), 0);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
