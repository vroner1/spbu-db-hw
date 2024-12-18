CREATE TABLE IF NOT EXISTS types_of_group_classes (
id SERIAL PRIMARY KEY,
name VARCHAR(255)

);

INSERT INTO types_of_group_classes(name)
VALUES 
('Кардионагрузки'),
('Cиловые тренировки'),
('Функциональные тренировки'),
('Танцевальные занятия'),
('Оздоровительные тренировки');


CREATE TABLE IF NOT EXISTS group_classes (
id SERIAL PRIMARY KEY,
name VARCHAR(255),
is_for_beginners BOOLEAN

);

INSERT INTO group_classes(name, is_for_beginners)
VALUES
('Аэробика', TRUE),
('Плавание', TRUE),
('Йога', TRUE),
('TRX', FALSE),
('Кроссфит', FALSE),
('Бокс', FALSE),
('HIIT', FALSE),
('Растяжка', TRUE),
('Мобильность', TRUE),
('Zumba', FALSE);


CREATE TABLE IF NOT EXISTS group_class_types (
  group_class_id INTEGER REFERENCES group_classes(id),
  type_id INTEGER REFERENCES types_of_group_classes(id),
  UNIQUE(group_class_id, type_id)
);

INSERT INTO group_class_types(group_class_id, type_id)
VALUES 
(1, 1),
(2, 5),
(3, 3),
(4, 3),
(5, 2),
(6, 3),
(7, 3),
(8, 5),
(9, 5),
(10, 4);


CREATE TABLE calendar (
    date DATE NOT NULL
);

INSERT INTO calendar(date)
SELECT generate_series(
        '2024-01-01'::date,
        '2025-12-31'::date,
        '1 day'::interval
      ); -- создаем календарь для расписания занятий

ALTER TABLE calendar
ADD COLUMN id_group_class INTEGER REFERENCES group_classes(id);

UPDATE calendar
SET id_group_class = 4
WHERE EXTRACT(DOW FROM date) = 1
AND date BETWEEN '2024-01-01' AND '2025-12-31'; -- добавляем занятие "TRX" по понедельникам

CREATE TABLE IF NOT EXISTS instructors (
id SERIAL PRIMARY KEY, 
name VARCHAR(255)
);

INSERT INTO instructors(name)
VALUES
('Emily Wilson'),
('Sarah Taylor'), 
('Elizabeth Thompson');

CREATE TABLE IF NOT EXISTS instuctors_classes (
id SERIAL PRIMARY KEY,
id_instructor INTEGER REFERENCES instructors(id),
group_class_id INTEGER REFERENCES group_classes(id),
UNIQUE (id_instructor, group_class_id)

);

INSERT INTO instuctors_classes(id_instructor, group_class_id)
VALUES 
(1, 1),
(1, 3),
(1, 5),
(2, 2),
(2, 7),
(2, 9),
(3, 1),
(3, 2),
(3, 6),
(3, 8);

SELECT c.*,
	   gc.name
FROM calendar c
LEFT JOIN group_classes gc ON gc.id = c.id_group_class 
WHERE EXTRACT(DOW FROM date) = 1
LIMIT 10;

SELECT i.name
FROM instuctors_classes ic 
JOIN instructors i ON ic.id_instructor = i.id
JOIN group_classes gc ON ic.group_class_id = gc.id
WHERE gc.name = 'Плавание';