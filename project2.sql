SELECT * 
FROM types_of_group_classes
WHERE name IS NULL; -- проверка целостности 

SELECT ic.id_instructor, gc.id 
FROM instuctors_classes ic 
JOIN group_classes gc ON ic.group_class_id = gc.id 
WHERE ic.id_instructor IS NULL OR gc.id IS NULL; -- проверка связей между инструкторами и групповыми классами 

SELECT id_instructor, 
	    group_class_id, 
		COUNT(*) as duplicate_count
FROM instuctors_classes
GROUP BY id_instructor, group_class_id
HAVING COUNT(*) > 1; --  проверка уникальности комбинаций id_instructor и group_class_id


UPDATE calendar
SET id_group_class = 6
WHERE EXTRACT(DOW FROM date) = 2
AND date BETWEEN '2024-01-01' AND '2025-12-31'; -- добавляем занятие "Бокс" по вторникам



CREATE VIEW upcoming_classes AS
SELECT 
    c.date,
    gc.name AS class_name,
    i.name AS instructor_name
FROM 
    calendar c
JOIN 
    group_class_types gct ON c.id_group_class = gct.group_class_id
JOIN 
    group_classes gc ON gct.group_class_id = gc.id
LEFT JOIN 
    instuctors_classes ic ON gc.id = ic.group_class_id
LEFT JOIN 
    instructors i ON ic.id_instructor = i.id
WHERE 
    c.date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'; -- список предстоящих занятий на следующую неделю
    

SELECT *
FROM upcoming_classes
WHERE class_name = 'Бокс'; -- находим в расписании занятие "Бокс"

CREATE VIEW class_distribution AS
SELECT 
    EXTRACT(DOW FROM c.date) AS day_of_week,
    gc.name AS class_name,
    COUNT(DISTINCT c.date) AS total_classes,
    COUNT(DISTINCT i.id) AS unique_instructors
FROM 
    calendar c
JOIN 
    group_class_types gct ON c.id_group_class = gct.group_class_id
JOIN 
    group_classes gc ON gct.group_class_id = gc.id
LEFT JOIN 
    instuctors_classes ic ON gc.id = ic.group_class_id
LEFT JOIN 
    instructors i ON ic.id_instructor = i.id
GROUP BY 
    EXTRACT(DOW FROM c.date), gc.name; 
    

SELECT *
FROM class_distribution; -- распределение групповых классов по дням недели и количество уникальных инструкторов для каждого класса
