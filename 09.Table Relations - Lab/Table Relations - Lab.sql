#1. Mountains and Peaks

CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL
);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL,
`mountain_id` INT NOT NULL,
CONSTRAINT `fk_mountains_id_peaks_mountains_id`
FOREIGN KEY (`mountain_id`)
REFERENCES`mountains`(`id`)
);


#2. Trip Organization

  SELECT `vehicles`.`driver_id`,
 `vehicles`.`vehicle_type`, 
 CONCAT(`campers`.`first_name`," ",`campers`.`last_name`) AS `driver_name`
 FROM `vehicles` JOIN `campers` ON 
 `vehicles`.`driver_id`=`campers`.`id`;
 
 #3. SoftUni Hiking
 
 SELECT `routes`.`starting_point` AS `route_starting_point`,
 `routes`.`end_point` AS `route_ending_point`,
 `routes`.`leader_id`,
 CONCAT(`campers`.`first_name`," ",`campers`.`last_name`) AS `leader_name`
 FROM `routes` JOIN `campers` ON
 `routes`.`leader_id` = `campers`.`id`;
 
 #4. Delete Mountains
 
     CREATE TABLE mountains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);
 
 CREATE TABLE peaks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    mountain_id INT,
    CONSTRAINT fk_peaks_mountains FOREIGN KEY (mountain_id)
        REFERENCES mountains (id)
        ON DELETE CASCADE
);

#5.Project Management DB*

CREATE DATABASE project_management;

CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
client_name VARCHAR(100) NOT NULL
);

CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    project_lead_id INT,
    CONSTRAINT fk_projects_client_id_clients_id FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30),
last_name VARCHAR(30),
project_id INT,
CONSTRAINT fk_projects_project_id_projects_id
FOREIGN KEY (project_id)
REFERENCES projects(id)
);

ALTER TABLE projects
ADD CONSTRAINT fk_projects_project_lead_id_employees_id
FOREIGN KEY (project_lead_id)
REFERENCES employees(id);
 
 
 
 
  



