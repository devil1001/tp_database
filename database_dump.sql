DROP DATABASE IF EXISTS `db_techopark`;
CREATE DATABASE `db_techopark`;
USE `db_techopark`;
DROP TABLE IF EXISTS `forum`;
CREATE TABLE `forum` (
  `fID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(40) CHARACTER SET utf8 NOT NULL,
  `short_name` char(40) CHARACTER SET utf8 NOT NULL,
  `user` char(30) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`fID`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  UNIQUE KEY `short_name_UNIQUE` (`short_name`),
  KEY `fk_forum_user` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `pID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parent` int(11) DEFAULT NULL,
  `isApproved` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `isHighlighted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `isEdited` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `isSpam` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `isDeleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `date` datetime NOT NULL,
  `message` text CHARACTER SET utf8 NOT NULL,
  `user` char(30) CHARACTER SET utf8 NOT NULL,
  `forum` char(40) CHARACTER SET utf8 NOT NULL,
  `thread` int(11) unsigned NOT NULL,
  `likes` smallint(5) unsigned NOT NULL DEFAULT '0',
  `dislikes` smallint(5) unsigned NOT NULL DEFAULT '0',
  `points` smallint(6) NOT NULL DEFAULT '0',
  `mpath` char(200) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`pID`),
  KEY `user_date` (`user`,`date`),
  KEY `forum_date` (`forum`,`date`),
  KEY `thread_date` (`thread`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;DROP TABLE IF EXISTS `thread`;
CREATE TABLE `thread` (
  `tID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `isDeleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `forum` char(40) CHARACTER SET utf8 NOT NULL,
  `isClosed` tinyint(1) unsigned NOT NULL,
  `user` char(30) CHARACTER SET utf8 NOT NULL,
  `date` datetime NOT NULL,
  `message` text COLLATE utf8_unicode_ci NOT NULL,
  `slug` char(50) CHARACTER SET utf8 NOT NULL,
  `dislikes` smallint(5) unsigned DEFAULT '0',
  `likes` smallint(5) unsigned DEFAULT '0',
  `points` smallint(6) DEFAULT '0',
  `posts` smallint(5) unsigned DEFAULT '0',
  `title` char(50) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`tID`),
  KEY `user_date` (`user`,`date`),
  KEY `forum_date` (`forum`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `uID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `isAnonymous` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `username` char(30) CHARACTER SET utf8 DEFAULT NULL,
  `about` text CHARACTER SET utf8,
  `name` char(50) CHARACTER SET utf8 DEFAULT NULL,
  `email` char(30) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `id` (`uID`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
DROP TABLE IF EXISTS `user_thread`;
CREATE TABLE `user_thread` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user` char(30) NOT NULL,
  `tID` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_tID` (`user`,`tID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `user_user`;
CREATE TABLE `user_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `follower` char(30) NOT NULL,
  `followee` char(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `follower_followee` (`follower`,`followee`),
  KEY `followee_follower` (`followee`,`follower`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `clear`()
BEGIN
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user;
TRUNCATE TABLE forum;
TRUNCATE TABLE thread;
TRUNCATE TABLE post;
TRUNCATE TABLE user_thread;
TRUNCATE TABLE user_user;
SET FOREIGN_KEY_CHECKS = 1;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_post`(_date DATETIME, threadID INT(11), message TEXT, user CHAR(30), forum CHAR(40), parent INT(11), isApproved TINYINT(1), isHighlighted TINYINT(1), isEdited TINYINT(1), isSpam TINYINT(1), isDeleted TINYINT(1))
BEGIN
DECLARE ID INT(8) ZEROFILL;
DECLARE MATPATH CHAR(200);

INSERT INTO post (date, thread, message, user, forum, parent, isApproved, isHighlighted, isEdited, isSpam, isDeleted) VALUES (_date, threadID, message, user, forum, parent, isApproved, isHighlighted, isEdited, isSpam, isDeleted);
SET ID = LAST_INSERT_ID();
SET MATPATH=IF(parent IS NULL, CAST(ID AS CHAR), CONCAT_WS('.', (SELECT mpath FROM post WHERE pID=parent), CAST(ID AS CHAR)));
UPDATE post SET mpath=MATPATH WHERE pID=ID;
CASE isDeleted
  WHEN 0 THEN
    UPDATE thread SET posts=posts+1 WHERE tID = threadID;
  ELSE BEGIN END;
END CASE;

SELECT ID;
END ;;
DELIMITER ;
ALTER DATABASE `db_techopark` CHARACTER SET utf8 COLLATE utf8_general_ci ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `status`()
BEGIN
DECLARE user INT;
DECLARE thread INT;
DECLARE forum INT;
DECLARE post INT;

SELECT COUNT(*) INTO user FROM user;
SELECT COUNT(*) INTO thread FROM thread;
SELECT COUNT(*) INTO forum FROM forum;
SELECT COUNT(*) INTO post FROM post;

SELECT user, thread, forum, post;
END ;;
DELIMITER ;

ALTER DATABASE `db_techopark` CHARACTER SET utf8 COLLATE utf8_unicode_ci ;
