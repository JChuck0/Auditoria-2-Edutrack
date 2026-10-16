-------------------------------------------------------------------
-------------------- Queries de consulta --------------------------
-------------------------------------------------------------------


-------------------------- INNER JOIN -----------------------------
------------------- Q1 - Listar inscripciones ---------------------

SELECT students.name, courses.title, enrollments.completion_percentage 
FROM enrollments 
INNER JOIN students ON enrollments.student_id = students.id 
INNER JOIN courses ON enrollments.course_id = courses.id;

------------------ Q2 - Mostrar nombre y email ---------------------

SELECT students.name, students.email, courses.title 
FROM enrollments 
INNER JOIN students ON enrollments.student_id = students.id 
INNER JOIN courses ON enrollments.course_id = courses.id
WHERE passed = TRUE;

------------------ Q3 - Calcular porcentaje medio ---------------------

SELECT courses.instructor_name, ROUND(AVG(enrollments.completion_percentage), 2) AS completion_average 
FROM enrollments 
INNER JOIN courses ON enrollments.course_id = courses.id
GROUP BY courses.instructor_name
ORDER BY completion_average DESC;

-------------------------- LEFT JOIN -----------------------------
--------- Q4 - Encontrar estudiantes sin inscripción -------------

SELECT * 
FROM students 
LEFT JOIN enrollments ON enrollments.student_id = students.id
WHERE enrollments.id IS NULL;

------------- Q5 - Encontrar cursos sin inscripción ---------------

SELECT *
FROM courses
LEFT JOIN enrollments on enrollments.course_id = courses.id
WHERE enrollments.id IS NULL;

-------------------------- AGREGATION -----------------------------
------------- Q6 - Conteo de cursos por estudiante ----------------

SELECT students.name, COUNT(enrollments.course_id) AS courses_count
FROM enrollments
INNER JOIN students ON enrollments.student_id = students.id
GROUP BY students.id, students.name
HAVING COUNT(enrollments.course_id) > 1
ORDER BY courses_count DESC;

------------- Q7 - Conteo de cursos por estudiante ----------------

SELECT courses.category, SUM(courses.monthly_fee) AS courses_total_fee
FROM enrollments
INNER JOIN courses ON enrollments.course_id = courses.id
GROUP BY courses.category
ORDER BY courses_total_fee DESC;

------ Q8 - Instructores junto con número de estudiantes ----------

SELECT courses.instructor_name, COUNT(DISTINCT enrollments.student_id) AS total_students
FROM enrollments
INNER JOIN courses ON enrollments.course_id = courses.id
GROUP BY courses.instructor_name
ORDER BY total_students DESC;

-------------------------- DATA INTEGRITY -----------------------------
--------- Q9 - Id de estudiante con estudiante inexistente ------------

SELECT enrollments.id, enrollments.student_id
FROM enrollments
LEFT JOIN students ON enrollments.student_id = students.id
WHERE students.id IS NULL;

-------------- Q10 - Id de curso con curso inexistente ---------------

SELECT enrollments.id, enrollments.course_id
FROM enrollments
LEFT JOIN courses ON enrollments.course_id = courses.id
WHERE courses.id IS NULL;