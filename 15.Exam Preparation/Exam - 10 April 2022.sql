CREATE DATABASE softuni_imdb’s; 

#Section 1: Data Definition Language (DDL) – 40 pts

CREATE TABLE countries (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL UNIQUE,
continent VARCHAR(30) NOT NULL,
currency VARCHAR(5) NOT NULL
);

CREATE TABLE genres(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE actors(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
birthdate DATE NOT NULL,
height INT,
awards INT,
country_id INT NOT NULL
);

CREATE TABLE movies_additional_info(
id INT PRIMARY KEY AUTO_INCREMENT,
rating DECIMAL(10,2) NOT NULL,
runtime INT NOT NULL,
picture_url VARCHAR(80) NOT NULL,
budget DECIMAL(10,2),
release_date DATE NOT NULL,
has_subtitles TINYINT(1),
description TEXT
);

CREATE TABLE movies(
id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(70) NOT NULL UNIQUE,
country_id INT NOT NULL,
movie_info_id INT NOT NULL UNIQUE
);

CREATE TABLE movies_actors(
movie_id INT,
actor_id INT
);

CREATE TABLE genres_movies(
genre_id INT,
movie_id INT
);

ALTER TABLE genres_movies
ADD CONSTRAINT fk_genres_movies_genres
FOREIGN KEY (genre_id)
REFERENCES genres(id),

ADD CONSTRAINT fk_genres_movies_movies
FOREIGN KEY (movie_id)
REFERENCES movies(id)
;

ALTER TABLE  movies
ADD CONSTRAINT fk_movies_movies_info
FOREIGN KEY (movie_info_id)
REFERENCES movies_additional_info(id),

ADD CONSTRAINT fk_movies_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
;
ALTER TABLE movies_actors 
ADD CONSTRAINT fk_actors_movies
FOREIGN KEY (movie_id)
REFERENCES movies(id),

ADD CONSTRAINT fk_movies_actors
FOREIGN KEY (actor_id)
REFERENCES actors(id)
;

ALTER TABLE actors
ADD CONSTRAINT fk_actors_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
;

#Section 2: Data Manipulation Language (DML) – 30 pts

INSERT INTO  actors (first_name,last_name ,birthdate ,height ,awards , country_id )
SELECT REVERSE(first_name),
 REVERSE(last_name),
 SUBDATE(DATE(birthdate),INTERVAL 2 DAY),
 height + 10,
 country_id,
 3
 FROM actors
 WHERE id <=10
 ;
 
 UPDATE movies_additional_info
 SET runtime = runtime - 10
 WHERE id BETWEEN 15 AND 25
 ;
 
 DELETE c FROM countries AS c
 LEFT JOIN movies AS m ON c.id = m.country_id
 WHERE m.country_id IS NULL
 ;
 
 #Section 3: Querying – 50 pts
 
 SELECT * FROM countries
 ORDER BY currency DESC, id
 ;
 
 SELECT mi.id,m.title,mi.runtime,mi.budget,mi.release_date
 FROM movies_additional_info AS mi
 JOIN movies AS m ON m.movie_info_id = mi.id
 WHERE YEAR(release_date) BETWEEN 1996 AND 1999
 ORDER BY runtime,id
 LIMIT 20
 ;
 
 select CONCAT(first_name," ",last_name) AS full_name,
 CONCAT(REVERSE(last_name),CHAR_LENGTH(last_name),'@cast.com') AS email,
 2022 - YEAR(birthdate) AS age,
 height
 FROM actors AS a
 LEFT JOIN movies_actors AS ma ON ma.actor_id = a.id
 WHERE ma.actor_id IS NULL
 ORDER BY height 
 ;
 
 SELECT c.name , COUNT(m.title) AS movies_count  
 FROM countries AS c
 JOIN movies AS m ON c.id = m.country_id
 GROUP BY c.name 
 HAVING movies_count >=7
 ORDER BY name DESC;
 
 SELECT m.title AS title,
 CASE
     WHEN mi.rating <=4 THEN 'poor'
     WHEN mi.rating <=7 THEN 'good'
     ELSE 'excellent'
 END AS rating,
 IF(mi.has_subtitles = 1,'english','-') AS subtitles,
 budget AS budget
 FROM movies AS m
 JOIN movies_additional_info AS mi ON m.movie_info_id = mi.id
 ORDER BY budget DESC
 ;
 
 DELIMITER $
 CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
 RETURNS INT
 DETERMINISTIC
 BEGIN
 DECLARE history_movie_count INT;
   SET history_movie_count :=(
   SELECT COUNT(m.title)
   FROM actors AS a
   JOIN movies_actors AS ma ON ma.actor_id = a.id
   JOIN movies AS m ON ma.movie_id = m.id
   JOIN genres_movies AS ga ON m.id = ga.movie_id
   JOIN genres AS g ON ga.genre_id = g.id
   WHERE CONCAT(a.first_name,' ',a.last_name) = full_name 
   AND g.name = 'History'
   );
   RETURN history_movie_count;
 END$
 DELIMITER ;
 
 DELIMITER $
 
 CREATE PROCEDURE udp_award_movie (movie_title VARCHAR(50))
 
 BEGIN
 UPDATE actors AS a
 JOIN movies_actors AS ma ON ma.actor_id = a.id
 JOIN movies AS m ON ma.movie_id = m.id
 SET a.awards = a.awards + 1
 WHERE m.title = movie_title;
 
 END$
 DELIMITER ;
 
 
 
 
 
 
 
 

 
 
 




