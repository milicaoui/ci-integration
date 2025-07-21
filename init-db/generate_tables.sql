CREATE DATABASE IF NOT EXISTS `upmonth-query-db`;

-- `upmonth-query-db`.shortcodes definition
DROP TABLE IF EXISTS `upmonth-query-db`.shortcodes;

CREATE TABLE `upmonth-query-db`.shortcodes (
	`type` varchar(200) NOT NULL,
	name varchar(200) NOT NULL,
	shortcode varchar(200) NULL,
	category varchar(200) NULL,
	doc_group_code varchar(200) NULL,
	`date` varchar(100) NULL,
	search_shortcuts BOOL NULL,
	synonyms TEXT NULL,
	CONSTRAINT shortcodes_PK PRIMARY KEY (`type`,name)
);


-- `upmonth-query-db`.activity_log definition
DROP TABLE IF EXISTS `upmonth-query-db`.activity_log;

CREATE TABLE `upmonth-query-db`.activity_log (
	`utc_timestamp` DATETIME NULL,
	query TEXT NULL,
	user_id int NULL,
	log_level varchar(200) NULL,
	log_detail TEXT NULL
);