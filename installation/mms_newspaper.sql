CREATE TABLE `mms_newspaper` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`title` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`picture` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`firstname` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`lastname` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`pn` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2
;
