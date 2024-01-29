CREATE DATABASE `one_to_one`;

#01. One-To-One Relationship

CREATE TABLE `passports`(
`passport_id` INT PRIMARY KEY AUTO_INCREMENT,
`passport_number` VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO `passports` (`passport_id`,`passport_number`)
VALUES (101,"N34FG21B"),
(102,'K65LO4R7'),
(103,"ZE657QP2");

CREATE TABLE `people`(
`person_id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name`VARCHAR(255) NOT NULL,
`salary`DECIMAL(10,2),
`passport_id` INT UNIQUE,
CONSTRAINT fk_people_passports 
FOREIGN KEY (`passport_id`)
REFERENCES `passports`(`passport_id`)

);
INSERT INTO `people`(`person_id`,`first_name`,`salary`,`passport_id`)
VALUES 
(1,"Roberto" , 43300.00,102),                                          
(2,"Tom",56100.00,103),
(3,"Yana",60200.00,101);

#02. One-To-Many Relationship

CREATE TABLE`manufacturers`(
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL UNIQUE,
`established_on` DATE
);
INSERT INTO `manufacturers`(`manufacturer_id`,`name`,`established_on`)
VALUES
(1,'BMW','1916-03-01'),
(2,'Tesla','2003-01-01'),
(3,"Lada","1966-05-01");

CREATE TABLE `models`(
`model_id` INT PRIMARY KEY AUTO_INCREMENT,
`name`VARCHAR(255),
`manufacturer_id`INT,
CONSTRAINT fk_models_manufacturers
FOREIGN KEY (`manufacturer_id`)
REFERENCES `manufacturers`(`manufacturer_id`)

);
INSERT INTO `models` (`model_id`,`name`,`manufacturer_id`)
VALUES(101,'X1',1),
(102,'i6',1),
(103,"Model S",2),
(104,'Model X',2),
(105,'Model 3',2),
(106,'Nova',3);

#03. Many-To-Many Relationship

CREATE TABLE `students`(
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL
);
INSERT INTO`students`(`name`)
VALUES('Mila'),
('Toni'),
('Ron');

CREATE TABLE`exams`(
`exam_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL
);
ALTER TABLE `exams` AUTO_INCREMENT = 101;

INSERT INTO `exams`(`name`)
VALUES('Spring MVC'),
('Neo4j'),
('Oracle 11g');

CREATE TABLE `students_exams`(
`student_id` INT NOT NULL,
`exam_id`INT NOT NULL,
CONSTRAINT pk_students_exams
PRIMARY KEY (`student_id`,`exam_id`),

CONSTRAINT fk_students_exams_students
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`),

CONSTRAINT fk_students_exams_exams
FOREIGN KEY (`exam_id`)
REFERENCES `exams`(`exam_id`)

);
INSERT INTO `students_exams`(`student_id`,`exam_id`)
VALUES (1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103);

#04. Self-Referencing

CREATE TABLE `teachers`(
`teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
`name`VARCHAR(255) NOT NULL,
`manager_id`INT
);
ALTER TABLE `teachers` AUTO_INCREMENT = 101;

INSERT INTO `teachers` (`name`,`manager_id`)
VALUES ('John', NULL),
('Maya',106),
('Silvia',106),
('Ted',105),
('Mark',101),
('Greta',101);

ALTER TABLE `teachers`
ADD CONSTRAINT fk
FOREIGN KEY (`manager_id`)
REFERENCES `teachers`(`teacher_id`);

#05. Online Store Database

CREATE DATABASE `online_store`;

CREATE TABLE `items`(
`item_id` INT (11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`item_type_id` INT(11)
);
CREATE TABLE `item_types`(
`item_type_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);
CREATE TABLE `customers`(
`customer_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`birthday` DATE,
`city_id` INT(11)
);
CREATE TABLE `orders`(
`order_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`customer_id` INT(11) 
);
CREATE TABLE `cities`(
`city_id` int(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);
CREATE TABLE `order_items`(
`order_id` INT(11),
`item_id` INT(11),
CONSTRAINT pk
PRIMARY KEY(`order_id`,`item_id`)
);
ALTER TABLE `customers`
ADD CONSTRAINT `fk_customers_cities`
FOREIGN KEY (`city_id`)
REFERENCES `cities`(city_id);

ALTER TABLE `orders`
ADD CONSTRAINT fk_order_customers
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`customer_id`);

ALTER TABLE `items`
ADD CONSTRAINT fk_items_item_types
FOREIGN KEY (`item_type_id`)
REFERENCES`item_types`(`item_type_id`);

ALTER TABLE `order_items`
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY(`order_id`)
REFERENCES`orders`(order_id),

ADD CONSTRAINT fk_order_items_items
FOREIGN KEY(`item_id`)
REFERENCES `items`(`item_id`);



#06. University Database

CREATE DATABASE `university`;

CREATE TABLE `subjects`(
`subject_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`subject_name` VARCHAR (50)
);

CREATE TABLE `majors`(
`major_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) 
);

CREATE TABLE `payments`(
`payment_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`payment_date` DATE ,
`payment_amount` DECIMAL(8,2),
`student_id` INT(11)
);

CREATE TABLE `students`(
`student_id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`student_number` VARCHAR(12)  UNIQUE,
`student_name` VARCHAR(50) ,
`major_id` INT(11)
);

CREATE TABLE `agenda`(
`student_id` INT(11) ,
`subject_id` INT(11) ,
CONSTRAINT pk
PRIMARY KEY (`student_id`,`subject_id`)

);
ALTER TABLE `payments`
ADD CONSTRAINT fk_payments_students
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`);

ALTER TABLE `students`
ADD CONSTRAINT fk_students_majors
FOREIGN KEY(`major_id`)
REFERENCES `majors`(`major_id`);

ALTER TABLE `agenda`
ADD CONSTRAINT fk_agenda_student
FOREIGN KEY(`student_id`)
REFERENCES `students`(`student_id`),
ADD CONSTRAINT fk_agenda_subject
FOREIGN KEY (`subject_id`)
REFERENCES `subjects`(`subject_id`);

#09. Peaks in Rila

SELECT `mountain_range` ,`peak_name`, `elevation` AS `peak_elevation` 
FROM `mountains`
JOIN `peaks` ON
`mountains`.`id` = `peaks`.`mountain_id`
HAVING `mountain_range` = 'Rila'
ORDER BY `peak_elevation` DESC ;










