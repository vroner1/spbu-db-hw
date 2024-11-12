CREATE TABLE IF NOT EXISTS courses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  is_exam BOOLEAN,
  min_grade NUMERIC(3,2),
  max_grade NUMERIC(3,2)
);


CREATE TABLE IF NOT EXISTS groups (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(10),
  short_name VARCHAR(10),
  students_ids INTEGER[]
);



CREATE TABLE IF NOT EXISTS students (
id SERIAL PRIMARY KEY,
first_name VARCHAR(255),
last_name VARCHAR(255),
group_id INTEGER REFERENCES groups(id),
courses_ids INTEGER[]
);

CREATE TABLE IF NOT EXISTS first_course (
student_id INTEGER REFERENCES students(id),
grade NUMERIC(3,2),
grade_str VARCHAR(20)

);


INSERT INTO courses (id, name, is_exam, min_grade, max_grade)
VALUES 
(1, 'Основы машинного обучения', TRUE, 3.00, 5.00),
(2, 'Технологии систем управления базами данных', FALSE, 2.50, 4.50),
(3, 'Английский язык', TRUE, 3.25, 4.75),
(4, 'Технологии искусственного интеллекта', FALSE, 2.00, 4.00),
(5, 'Теория байесовских сетей', TRUE, 3.50, 5.00);

INSERT INTO groups (id, full_name, short_name, students_ids)
VALUES 
(1, 'Группа 101', '101', ARRAY[1]),
(2, 'Группа 202', '202', ARRAY[2]),
(3, 'Группа 303', '303', ARRAY[3]),
(4, 'Группа 404', '404', ARRAY[4]),
(5, 'Группа 505', '505', ARRAY[5]);

INSERT INTO students (id, first_name, last_name, group_id, courses_ids)
VALUES 
(101, 'Иван', 'Иванов', 1, ARRAY[1, 2, 3, 4, 5]),
(102, 'Петр', 'Петров', 1, ARRAY[1, 2, 3, 4, 5]),
(103, 'Алина', 'Сидорова', 4, ARRAY[1, 2, 3, 4, 5]),
(204, 'Мария', 'Маркина', 3, ARRAY[2, 3, 4, 5]),
(205, 'Елена', 'Андреева', 2, ARRAY[2, 3, 4, 5]),
(206, 'Елена', 'Кузнецова', 2, ARRAY[2, 3, 4, 5]);

INSERT INTO first_course (student_id, grade, grade_str)
VALUES 
(101,  4.20, 'Хорошо'),
(102, 3.50, 'Хорошо'),
(103, 3.00, 'Удовлетворительно'),
(204, 5.00, 'Отлично'),
(205, 2.20, 'Неудовлетворительно'),
(206, 3.40, 'Удовлетворительно');

SELECT * FROM students WHERE first_name = 'Елена';

SELECT AVG(grade)
FROM first_course;

SELECT COUNT(*) AS students_with_average_grade 
FROM first_course
WHERE grade_str = 'Удовлетворительно';

SELECT *
FROM students s
JOIN first_course fc ON s.id = fc.student_id
WHERE s.group_id = 1;



