CREATE TABLE if not exists Client (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name varchar(255) NOT NULL,
	email varchar(150) NOT NULL UNIQUE,
	contact varchar(12)
) DEFAULT CHARSET = utf8;

CREATE TABLE if not exists TypeOfRoom (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	num_vacancy ENUM('4', '8', '12') NOT NULL,
	bathroom BOOLEAN NOT NULL
) DEFAULT CHARSET = utf8;

CREATE TABLE if not exists Reservation (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	client_id INT NOT NULL,
	checkin_date TIMESTAMP,
	checkout_date TIMESTAMP,
	payment_status ENUM('pending', 'payment_checked', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
	total_value DECIMAL(11, 2),
	reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES Client (id)
) DEFAULT CHARSET = utf8;

CREATE TABLE if not exists Room (
	room_number INT NOT NULL PRIMARY KEY,
	room_type INT NOT NULL,
	CONSTRAINT fk_room_type FOREIGN KEY (room_type) REFERENCES TypeOfRoom (id)
) DEFAULT CHARSET = utf8;

CREATE TABLE if not exists Vacancy (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	description TEXT,
	room_number INT NOT NULL,
	valuePerDiary DECIMAL(11, 2) NOT NULL DEFAULT '0',
	CONSTRAINT fk_room_number FOREIGN KEY (room_number) REFERENCES Room (room_number)
) DEFAULT CHARSET = utf8;

CREATE TABLE if not exists Reservation_Vacancy  (
	reservation_id INT NOT NULL,
	vacancy_id INT NOT NULL,
	CONSTRAINT pk_reserv_vacanc PRIMARY KEY (reservation_id, vacancy_id),
	CONSTRAINT fk_reserv FOREIGN KEY (reservation_id) REFERENCES Reservation (id),
	CONSTRAINT fk_vacanc FOREIGN KEY (vacancy_id) REFERENCES Vacancy (id)
) DEFAULT CHARSET = utf8;


--- INSERTES ---
INSERT INTO Client (name, email, contact) VALUES ('João Silva', 'joao@email.com', '12345678901');
INSERT INTO TypeOfRoom (num_vacancy, bathroom) VALUES ('8', TRUE);
INSERT INTO Reservation (client_id, checkin_date, checkout_date, payment_status, total_value) VALUES (1, '2025-07-10 14:00:00', '2025-07-15 12:00:00', 'pending', 1500.00);
INSERT INTO Room (room_number, room_type) VALUES (101, 1);
INSERT INTO Reservation_Vacancy (reservation_id, vacancy_id) VALUES (1, 1);
INSERT INTO Vacancy (description, room_number, valuePerDiary) VALUES ('Cama no quarto 101', 101, 100.00);

--- UPDATES ---
UPDATE Client SET name = 'João S. Oliveira', contact = '10987654321' WHERE id = 1;
UPDATE TypeOfRoom SET bathroom = FALSE WHERE id = 1;
UPDATE Reservation SET payment_status = 'completed' WHERE id = 1;
UPDATE Room SET room_type = 2 WHERE room_number = 101;
-- (Reservationvacancy não tem UPDATE)
UPDATE Vacancy SET valuePerDiary = 120.00 WHERE id = 1;


--- DELETES ---
DELETE FROM Client WHERE id = 1;
DELETE FROM TypeOfRoom WHERE id = 1;
DELETE FROM Reservation WHERE id = 1;
DELETE FROM Room WHERE room_number = 101;
DELETE FROM Reservation_Vacancy WHERE reservation_id = 1 AND vacancy_id = 1;
DELETE FROM Vacancy WHERE id = 1;

--- SELECTS DE TODOS OS REGISTROS ---

SELECT * FROM Client;
SELECT * FROM TypeOfRoom;
SELECT * FROM Reservation;
SELECT * FROM Room;
SELECT * FROM Vacancy;
SELECT * FROM Reservation_Vacancy;

--- SELECT DE UM REGISTRO PARA CADA TABELA

SELECT * FROM Client WHERE id = 1;
SELECT * FROM TypeOfRoom WHERE id = 1;
SELECT * FROM Reservation WHERE id = 1;
SELECT * FROM Room WHERE room_number = 101;
SELECT * FROM Vacancy WHERE id = 1;
SELECT * FROM Reservation_Vacancy WHERE reservation_id = 1 AND vacancy_id = 1;

--- script de mostrar as vagas disponíveis em determinado dia e as camas já reservadas. ---

SET @data_consulta = '2025-07-12';

-- vagas ocupadas no dia
SELECT v.id AS vacancy_id, v.description, r.checkin_date, r.checkout_date, c.name AS client_name
FROM Vacancy v
JOIN Reservation_Vacancy rv ON v.id = rv.vacancy_id
JOIN Reservation r ON rv.reservation_id = r.id
JOIN Client c ON r.client_id = c.id
WHERE @data_consulta BETWEEN DATE(r.checkin_date) AND DATE(r.checkout_date);

-- vagas disponíveis no dia
SELECT v.id AS vacancy_id, v.description
FROM Vacancy v
WHERE v.id NOT IN (
    SELECT rv.vacancy_id
    FROM Reservation_Vacancy rv
    JOIN Reservation r ON rv.reservation_id = r.id
    WHERE @data_consulta BETWEEN DATE(r.checkin_date) AND DATE(r.checkout_date)
);
