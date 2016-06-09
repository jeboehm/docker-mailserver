# ************************************************************
# Sequel Pro SQL dump
# Version 4499
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.6.29-76.2)
# Datenbank: test
# Erstellt am: 2016-06-01 21:11:41 +0000
# ************************************************************

use mailserver;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Export von Tabelle domain_admins
# ------------------------------------------------------------

CREATE TABLE `domain_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `domain_admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `virtual_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `domain_admins` WRITE;
/*!40000 ALTER TABLE `domain_admins` DISABLE KEYS */;

INSERT INTO `domain_admins` (`id`, `domain_id`, `user_id`)
VALUES
	(1,0,1);

/*!40000 ALTER TABLE `domain_admins` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle languages
# ------------------------------------------------------------

CREATE TABLE `languages` (
  `id` int(3) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;

INSERT INTO `languages` (`id`, `name`, `active`)
VALUES
	(1,'English',1);

/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle text
# ------------------------------------------------------------

CREATE TABLE `text` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `mid` int(10) NOT NULL,
  `language_id` int(3) NOT NULL,
  `text` longtext CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `text_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `text` WRITE;
/*!40000 ALTER TABLE `text` DISABLE KEYS */;

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(1,1,1,'Email adress'),
	(3,2,1,'Password'),
	(5,3,1,'is logged in as'),
	(7,4,1,'No domain name.'),
	(9,5,1,'Domain name is not valid. Please check the rules for domain names.'),
	(11,6,1,'Domain name did not change.'),
	(13,7,1,'New domain name '),
	(15,8,1,' is not valid. Please check the rules for domain names.'),
	(17,9,1,'A virtual domain with this name already exists in the database.'),
	(19,10,1,'No name for new virtual user.'),
	(21,11,1,'New name '),
	(23,12,1,' is not valid. Please check the rules for names in email addresses.'),
	(25,13,1,'Password '),
	(27,14,1,' is not valid. Please check the rules for passwords.'),
	(29,15,1,'A virtual user with this name already exists in this domain.'),
	(31,16,1,'No name for new virtual user.'),
	(33,17,1,'No password for new virtual user.'),
	(35,18,1,'Really delete virtual domain '),
	(37,19,1,'Users of this virtual domain also will be deleted recursivly.'),
	(39,20,1,'Really delete user: '),
	(41,21,1,'Really save changes to virtual domain'),
	(43,22,1,'Users adresses of this virtual domain also will be changed recursivly.');

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(45,23,1,'Manage virtual domains'),
	(47,24,1,'Manage virtual users'),
	(49,25,1,'Virtual Domain Manager'),
	(51,26,1,'Number of domains:'),
	(53,27,1,'Number of users:'),
	(55,28,1,'Add new virtual domain'),
	(57,29,1,'New virtual domain'),
	(59,30,1,'Name of domain (FQDN):'),
	(61,31,1,'Save new virtual domain'),
	(63,32,1,'with validation of name'),
	(65,33,1,'Virtual domain list'),
	(67,34,1,'Action'),
	(69,35,1,'Virtual domain name'),
	(71,36,1,'Save changes'),
	(73,37,1,'Edit'),
	(75,38,1,'Delete'),
	(77,39,1,'Virtual User Manager'),
	(79,40,1,'Select a virtual domain:'),
	(81,41,1,'Select DomainMasters'),
	(83,42,1,'Add new virtual user to selected domain'),
	(85,43,1,'DomainMaster?'),
	(87,44,1,'Virtual users email address'),
	(89,45,1,'Save DomainMasters'),
	(91,46,1,'New virtual user'),
	(93,47,1,'Name of virtual user:'),
	(95,48,1,'Password (default auto):'),
	(97,49,1,'Save new virtual user'),
	(99,50,1,'Create New password'),
	(102,51,1,'Information on how to use Mail Manager');

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(104,52,1,'Common informations'),
	(106,53,1,'With this interface virtual domains and th correspondending users ca be managed.<br>A user with the role of a MailMaster can create, edit or delete virtual domains and their users. He also can decide about who can manage the single domains in the role of a DomainMaster. So the administration of the single domains can be done by the owners of the domain.<br><br>This software is published under GPL license and comes without any warranty.'),
	(108,54,1,'Managing virtual domains'),
	(110,55,1,'The usage of this section is permitted only to MailMasters.<br><br>When creating a new virtual domain, the given name is checked against the platform rules. If problems with the name appear the check can be disabled. If you disable the name check please check the correctness by yourself, otherwise the domain may not function correctly.<br><br>Allowed chars are a-z, A-Z, 0-9 and -. There have to be at least 3 chars before the dot 2-3 chars after the dot.<br><br>If a virtual domain is changed, all of the registered email adresses of this domain are changed too automatically. Also when a domain is deleted, alln users are deleted too.<br>');

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(112,56,1,'Manage virtual users'),
	(114,57,1,'Usage of this section is peritted to MailMasters and DomainMasters. One DomainMaster can manage 1 or more domains.<br><br>To wok with the user manager first you have to select a virtual domain. After selection of a domain, you will be able to manage DomainMasters and the users of the selected domain. Users can be created, edited or deleted.<br><br>Given name and passwords will be checked against the rules of this platform.<br>Allowed chars for names are a-z, A-Z, 0-9 . and -. A name has to have between 3 and 30 chars.<br>Allowed chars for passwords are a-z, A-Z, 0-9 $ and @. A password has to have between 8 and 15 chars.<br>If you create or edit a virtual user, a generated password will be given. You can overwrite this password but still matching the rules.'),
	(115,58,1,'Sorry, no permission to this administration area.'),
	(117,59,1,'No user with this data. Check your entries.'),
	(119,60,1,'No password.');

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(121,61,1,'No email adress.'),
	(123,62,1,'Manage virtual aliases'),
	(125,63,1,'Invalid email'),
	(127,64,1,'Invalid domain.'),
	(129,65,1,'Invalid name in email.'),
	(131,66,1,'You really want to delete this alias?'),
	(133,67,1,'This section is permitted to every validated email user.<br><br>You can edit your username and change your password. The corresponding email addresses will be fixed recursivly.<br>You also can add, edit or delete virtual aliases. Every input is validated against the rules and changes are made recursivly.'),
	(135,68,1,'Select a virtual user'),
	(137,69,1,' on domain '),
	(139,70,1,'Email alias'),
	(141,71,1,'Forwardings for '),
	(143,72,1,'Add virtual alias'),
	(145,73,1,'New alias'),
	(147,74,1,'Save new alias'),
	(149,75,1,'Virtual user name'),
	(151,76,1,'Forwarded to'),
	(153,77,1,'Email address'),
	(155,78,1,'Add forwarding'),
	(157,79,1,'New forwarding'),
	(159,80,1,'Save new forwarding'),
	(161,81,1,'Virtual alias');

INSERT INTO `text` (`id`, `mid`, `language_id`, `text`)
VALUES
	(163,82,1,'User email'),
	(165,83,1,'New alias'),
	(167,84,1,'Alias name'),
	(169,85,1,'Emails forward to'),
	(171,86,1,'Virtual aliases for '),
	(173,87,1,' on virtual domain '),
	(175,88,1,'Really want to delete this email forwarding?'),
	(177,89,1,'This alias is already in use.'),
	(179,90,1,'Please insert an alias name.');

/*!40000 ALTER TABLE `text` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle virtual_aliases
# ------------------------------------------------------------

CREATE TABLE `virtual_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL,
  `source` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `domain_id` (`domain_id`),
  CONSTRAINT `virtual_aliases_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `virtual_domains` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `virtual_aliases` WRITE;
/*!40000 ALTER TABLE `virtual_aliases` DISABLE KEYS */;

INSERT INTO `virtual_aliases` (`id`, `domain_id`, `source`, `destination`)
VALUES
	(1,1,'admin@example.com','admin@example.com');

/*!40000 ALTER TABLE `virtual_aliases` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle virtual_domains
# ------------------------------------------------------------

CREATE TABLE `virtual_domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `virtual_domains` WRITE;
/*!40000 ALTER TABLE `virtual_domains` DISABLE KEYS */;

INSERT INTO `virtual_domains` (`id`, `name`)
VALUES
	(1,'example.com');

/*!40000 ALTER TABLE `virtual_domains` ENABLE KEYS */;
UNLOCK TABLES;


# Export von Tabelle virtual_users
# ------------------------------------------------------------

CREATE TABLE `virtual_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `domain_id` (`domain_id`),
  CONSTRAINT `virtual_users_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `virtual_domains` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `virtual_users` WRITE;
/*!40000 ALTER TABLE `virtual_users` DISABLE KEYS */;

INSERT INTO `virtual_users` (`id`, `domain_id`, `email`, `password`)
VALUES
	(1,1,'admin@example.com','$5$rounds=5000$buS8AUYLR937.LsZ$evgq1GkFfLNTlIChhF6yvBB5ny1IEEHWy/ah8pO5zCA');

/*!40000 ALTER TABLE `virtual_users` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

