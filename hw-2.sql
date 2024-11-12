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



CREATE TABLE IF NOT EXISTS student_courses (
id SERIAL PRIMARY KEY,
student_id INTEGER REFERENCES students(id),
course_id INTEGER REFERENCES courses(id),
UNIQUE(student_id, course_id)
)


CREATE TABLE IF NOT EXISTS group_courses (
id SERIAL PRIMARY KEY,
group_id INTEGER REFERENCES groups(id),
course_id INTEGER REFERENCES courses(id),
UNIQUE(group_id, course_id)
)

INSERT INTO student_courses (id, student_id, course_id)
VALUES 
(1, 101, 1), 
(2, 101, 2),
(3, 101, 3),
(4, 101, 4),
(5, 101, 5),
(6, 102, 1),
(7, 102, 2),
(8, 102, 3),
(9, 102, 4),
(10, 102, 5),
(11, 103, 1),
(12, 103, 2),
(13, 103, 3),
(14, 103, 4),
(15, 103, 5),
(16, 204, 2),
(17, 204, 3),
(18, 204, 4),
(19, 204, 5),
(20, 205, 2),
(21, 205, 3),
(22, 205, 4),
(23, 205, 5),
(24, 206, 2),
(25, 206, 3),
(26, 206, 4),
(27, 206, 5);

INSERT INTO group_courses(id, group_id, course_id)
VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 2, 2),
(7, 2, 3),
(8, 2, 4),
(9, 2, 5),
(10, 4, 1),
(11, 4, 2),
(12, 4, 3),
(13, 4, 4),
(14, 4, 5),
(15, 3, 2),
(16, 3, 3),
(17, 3, 4),
(18, 3, 5);

ALTER TABLE students
DROP COLUMN courses_ids;

ALTER TABLE groups
DROP COLUMN students_ids;

ALTER TABLE courses
ADD CONSTRAINT UC_courses_name UNIQUE (name); 

CREATE INDEX id_students_group_id ON students(group_id);

-- несмотря на то, что поле group_id уже является частью первичного ключа и обеспечивает
-- доступ к элементу группы, дополнительный индекс может может быть полезен в случаях, где
-- часто выполняются соединения JOIN конкретно по этому столбцу, при большом объеме данных 
-- некоторые запросы могут выполняться более оптимально, а также если используется частая 
-- фильтрация по этому конкретному столбцу.

SELECT s.first_name,
	   s.last_name, 
	   c.name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id
LIMIT 30;

	   
WITH student_grades AS (

SELECT DISTINCT s.first_name,
	   s.last_name,
	   g.short_name,
	   fc.grade
FROM students s
JOIN first_course fc ON s.id = fc.student_id
JOIN group_courses gc ON s.group_id = gc.group_id
JOIN GROUPS g ON g.id = gc.group_id),

max_grade_groups AS (

SELECT  g.short_name,
		MAX(fc.grade) AS max_grade_in_group
FROM students s
JOIN first_course fc ON s.id = fc.student_id
JOIN group_courses gc ON s.group_id = gc.group_id
JOIN GROUPS g ON g.id = gc.group_id
GROUP BY g.short_name)

SELECT DISTINCT sg.first_name,
	   sg.last_name
FROM student_grades sg
JOIN max_grade_groups mgg ON sg.short_name = mgg.short_name
WHERE sg.grade = mgg.max_grade_in_group; -- не поняла, как через HAVING сделать :(

SELECT c.name,
COUNT(sc.student_id)
FROM courses c
INNER JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.name;

-- А как найти среднюю оценку на каждом курсе, если мы знаем только максимальную и минимальную?
