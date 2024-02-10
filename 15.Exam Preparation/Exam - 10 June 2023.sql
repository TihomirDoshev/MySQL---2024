CREATE DATABASE universities_db;

# 1: Data Definition Language (DDL) – 40 pts


CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
); 

CREATE TABLE cities(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE,
population INT,
country_id INT NOT NULL
);
CREATE TABLE universities(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(60) NOT NULL UNIQUE,
address VARCHAR(80) NOT NULL UNIQUE,
tuition_fee DECIMAL(19,2) NOT NULL,
number_of_staff INT,
city_id INT
);
CREATE TABLE students(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(40) NOT NULL,
last_name VARCHAR(40) NOT NULL,
age INT,
phone VARCHAR(20) NOT NULL UNIQUE,
email VARCHAR(255) NOT NULL UNIQUE,
is_graduated TINYINT(1) NOT NULL,
city_id INT
);
CREATE TABLE students_courses(
grade DECIMAL(19,2) NOT NULL,
student_id INT NOT NULL,
course_id INT NOT NULL
);

CREATE TABLE courses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE,
duration_hours DECIMAL(19,2),
start_date DATE,
teacher_name VARCHAR(60) UNIQUE NOT NULL,
description TEXT,
university_id INT
);

ALTER TABLE cities
ADD CONSTRAINT fk_cities_cointries
FOREIGN KEY (country_id)
REFERENCES countries(id)
;
ALTER TABLE universities
ADD CONSTRAINT fk_cuniversities_cities
FOREIGN KEY (city_id)
REFERENCES cities(id)
;
ALTER TABLE students
ADD CONSTRAINT fk_students_cities
FOREIGN KEY (city_id)
REFERENCES cities(id)
;
ALTER TABLE courses
ADD CONSTRAINT fk_courses_universities
FOREIGN KEY (university_id)
REFERENCES universities(id)
;
ALTER TABLE students_courses

ADD CONSTRAINT fk_students_courses_students
FOREIGN KEY (student_id)
REFERENCES students(id),

ADD CONSTRAINT fk_students_courses_courses
FOREIGN KEY (course_id)
REFERENCES courses(id)
;


#  2: Data Manipulation Language (DML) – 30 pts

INSERT INTO courses (name ,duration_hours,start_date,teacher_name ,description,university_id)
SELECT CONCAT(teacher_name,' course'),
LENGTH (name) /10,
ADDDATE(start_date,INTERVAL 5 DAY),
REVERSE(teacher_name),
CONCAT('Course ',teacher_name,REVERSE(description)),
DAY(start_date)
FROM courses
WHERE id <= 5;

#

UPDATE universities
SET tuition_fee = tuition_fee + 300
WHERE id BETWEEN 5 AND 12;

#

DELETE FROM universities
WHERE number_of_staff IS NULL;

#3: Querying – 50 pts

SELECT * FROM cities
ORDER BY population DESC;

#

SELECT first_name,last_name,age,phone,email
FROM students
WHERE age >= 21 
ORDER BY first_name DESC,email,id
LIMIT 10;

#

SELECT CONCAT(s.first_name,' ',s.last_name) AS full_name,
SUBSTRING(s.email,2,10) AS username,
REVERSE(s.phone) AS password 
FROM students AS s
LEFT JOIN students_courses AS sc
ON s.id = sc.student_id
WHERE sc.course_id IS NULL
ORDER BY password DESC;


SELECT COUNT(*) AS students_count,
u.name AS university_name
FROM universities AS u
JOIN courses AS c ON c.university_id = u.id
JOIN students_courses AS sc ON sc.course_id = c.id
GROUP BY university_name
HAVING students_count >=8
ORDER BY students_count DESC , university_name DESC;

SELECT 
u.name AS university_name,
s.name AS city_name,
u.address,
CASE
WHEN u.tuition_fee <=800 THEN 'cheap'
WHEN u.tuition_fee <=1200 THEN 'normal'
WHEN u.tuition_fee <=2500 THEN 'high'
ELSE 'expensive'
END AS price_rank ,
u.tuition_fee

FROM universities AS u
JOIN cities AS s ON u.city_id = s.id
ORDER BY tuition_fee ; 

#Section 4: Programmability – 30 pts

DELIMITER $
CREATE FUNCTION udf_average_alumni_grade_by_course_name(course_name VARCHAR(60))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
DECLARE result DECIMAL(10,2);
	SET result := (SELECT AVG(sc.grade) FROM courses AS c
	JOIN students_courses AS sc ON c.id = sc.course_id
	JOIN students AS s ON s.id = sc.student_id 
	WHERE c.name = course_name AND s.is_graduated = 1
	GROUP BY c.id);
RETURN result ;    
END $

DELIMITER ;

DELIMITER $
CREATE PROCEDURE udp_graduate_all_students_by_year (year_started INT)
BEGIN
	UPDATE students s
    JOIN students_courses sc on s.id = sc.student_id
	JOIN courses c on c.id = sc.course_id
    SET s.is_graduated=1
    WHERE YEAR(c.start_date) = year_started;
END$

DELIMITER ;


















