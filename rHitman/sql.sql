INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_hitman','Tueur à gages',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_hitman','Tueur à gages',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_hitman', 'Tueur à gages', 1)
;

INSERT INTO `jobs` (`name`, `label`) VALUES
('hitman', 'Tueur à gages');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('hitman', 0, 'secretaire','Apprenti', 200, 'null', 'null'),
('hitman', 1, 'boss','Tueur à gages', 400, 'null', 'null');

CREATE TABLE `targethitman` (
  `id` int(11) NOT NULL,
  `nametarget` varchar(50) NOT NULL,
  `agetarget` int(10) NOT NULL,
  `numtarget` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `targethitman`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `targethitman`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;