# Informe de análisis — EduTrack v2 (Auditoría Q3)

**Para:** Responsable de Operaciones, EduTrack
**De:** Analista de datos (externo)
**Base de datos:** `edutrack_v2.sql` (esquema normalizado)
**Fecha:** 16/10/2026

---

## Resumen ejecutivo

- **Los 7 estudiantes con inscripciones están en más de un curso.** Solo Giulia Romano no tiene ninguna.
- **Email Campaigns** es el único curso sin inscripciones y es candidato a archivarse.
- **Marta López** tiene el mayor porcentaje de completado medio (66,14 %). El curso *UI/UX Fundamentals*, sin instructor asignado, tiene un 0 %.
- **4 estudiantes** han aprobado al menos un curso, con 6 aprobados en total.
- **No hay registros huérfanos.** Las claves foráneas del nuevo esquema garantizan la integridad referencial.
- **Programming** es la categoría que más ingresos genera (409,93 €), más del doble que la segunda.

---

## Consultas — INNER JOIN

### 1. Inscripciones con estudiante, curso y porcentaje de completado

**Resultado:** 16 filas, una por inscripción.

| Estudiante | Curso | Completado |
|---|---|---|
| Emily Watson | Intro to Python | 85 % |
| Emily Watson | Web Design Basics | 60 % |
| Klaus Weber | Intro to Python | 92 % |
| Klaus Weber | Data Analysis with SQL | 78 % |
| Lucia Fernandes | Web Design Basics | 5 % |
| Lucia Fernandes | Digital Marketing 101 | 3 % |
| Marco Rossi | Advanced Python | 95 % |
| Marco Rossi | Intro to Python | 88 % |
| Yuki Nakamura | Data Analysis with SQL | 45 % |
| Yuki Nakamura | UI/UX Fundamentals | 0 % |
| Pierre Dubois | UI/UX Fundamentals | 0 % |
| Priya Sharma | Digital Marketing 101 | 70 % |
| Priya Sharma | Intro to Python | 55 % |
| Pierre Dubois | Data Analysis with SQL | 20 % |
| Emily Watson | Advanced Python | 40 % |
| Lucia Fernandes | Advanced Python | 0 % |

**Observación:** 3 inscripciones tienen un 0 % de completado. Dos de ellas son de *UI/UX Fundamentals*, que no tiene instructor asignado (ver consulta 3).

### 2. Estudiantes que han aprobado al menos un curso

**Resultado:** 6 aprobados de 4 estudiantes distintos.

| Estudiante | Email | Curso aprobado |
|---|---|---|
| Emily Watson | emily.watson@student.edutrack.com | Intro to Python |
| Klaus Weber | klaus.weber@student.edutrack.com | Intro to Python |
| Klaus Weber | klaus.weber@student.edutrack.com | Data Analysis with SQL |
| Marco Rossi | marco.rossi@student.edutrack.com | Advanced Python |
| Marco Rossi | marco.rossi@student.edutrack.com | Intro to Python |
| Priya Sharma | priya.sharma@student.edutrack.com | Digital Marketing 101 |

**Observación:** Klaus Weber y Marco Rossi aparecen dos veces porque han aprobado dos cursos cada uno. Es el comportamiento esperado: cada fila corresponde a un curso aprobado distinto. *Intro to Python* concentra 3 de los 6 aprobados.

### 3. Porcentaje de completado medio por instructor

**Resultado:**

| Instructor | Completado medio |
|---|---|
| Marta López | 66,14 % |
| Carlos Vega | 40,00 % |
| Lucia Prades | 36,50 % |
| Pending assignment | 0,00 % |

**Observaciones:**
- "Pending assignment" no es un instructor real. Es un texto de relleno en `courses.instructor_name` para *UI/UX Fundamentals*. El esquema permite `NULL` en esa columna, que sería la forma correcta de indicar que falta asignar instructor. **Recomendación:** sustituir el texto por `NULL` para que no aparezca como un instructor más en los informes.
- Ninguno de los dos estudiantes de *UI/UX Fundamentals* ha empezado el curso (0 %). Puede tener relación con la falta de instructor.

---

## Consultas — LEFT JOIN (detección de datos faltantes)

### 4. Estudiantes sin ninguna inscripción

**Resultado:** 1 estudiante.

| Estudiante | Email |
|---|---|
| Giulia Romano | giulia.romano@student.edutrack.com |

**Observación:** se registró el 07/05/2024 y no se ha inscrito en ningún curso desde entonces. Podría ser objetivo de una campaña de activación.

### 5. Cursos sin ninguna inscripción

**Resultado:** 1 curso.

| Curso | Instructor |
|---|---|
| Email Campaigns | Lucia Prades |

**Observación:** es el curso más barato del catálogo (19,99 €/mes) y el único sin inscripciones. Es candidato a archivarse, como se planteaba en la solicitud.

---

## Consultas — Agregación entre tablas

### 6. Estudiantes inscritos en más de un curso

**Resultado:** 7 estudiantes.

| Estudiante | Nº de cursos |
|---|---|
| Emily Watson | 3 |
| Lucia Fernandes | 3 |
| Klaus Weber | 2 |
| Marco Rossi | 2 |
| Pierre Dubois | 2 |
| Priya Sharma | 2 |
| Yuki Nakamura | 2 |

**Observación:** **todos** los estudiantes con alguna inscripción están en más de un curso. La única excepción del total de la plataforma es Giulia Romano, que no tiene ninguna (consulta 4). Indica un buen nivel de recurrencia entre los alumnos activos.

### 7. Ingresos totales por categoría (precio actual de `courses`)

**Resultado:**

| Categoría | Ingresos |
|---|---|
| Programming | 409,93 € |
| Data | 179,97 € |
| Design | 169,96 € |
| Marketing | 59,98 € |

**Observaciones:**
- **Programming es la categoría que más ingresos genera**, con más del doble que Data. Combina el curso con más inscripciones (*Intro to Python*, 4) con el más caro (*Advanced Python*, 69,99 €).
- El cálculo usa `courses.monthly_fee`, tal como se pidió. En los datos actuales coincide con `enrollments.monthly_fee_paid` en todas las inscripciones, así que el resultado sería el mismo con cualquiera de las dos columnas. La diferencia aparecerá si los precios cambian en el futuro.
- Se usa `INNER JOIN` para que *Email Campaigns*, sin inscripciones, no sume su precio a Marketing.

### 8. Estudiantes inscritos por instructor

**Resultado:**

| Instructor | Estudiantes distintos | Inscripciones |
|---|---|---|
| Marta López | 6 | 7 |
| Carlos Vega | 3 | 5 |
| Lucia Prades | 2 | 2 |
| Pending assignment | 2 | 2 |

**Observaciones:**
- Se cuentan **estudiantes distintos** (`COUNT(DISTINCT ...)`), no inscripciones. Un estudiante que está en dos cursos del mismo instructor cuenta una sola vez. La columna de inscripciones se incluye solo como referencia.
- **Limitación de los datos:** la tabla `enrollments` no tiene fecha de baja ni estado (activa/finalizada), así que no se puede distinguir qué inscripciones siguen "actuales". Se han contado todas. **Recomendación:** añadir una columna de estado o de fecha de finalización si se quiere medir la actividad actual.

---

## Consultas — Integridad de datos

### 9. Inscripciones con `student_id` huérfano

**Resultado:** 0 filas.

### 10. Inscripciones con `course_id` huérfano

**Resultado:** 0 filas.

**Observaciones (consultas 9 y 10):**
- **No existen registros huérfanos.** Todas las inscripciones apuntan a estudiantes y cursos existentes.
- Este resultado es consecuencia directa de la migración. En el nuevo esquema, `enrollments.student_id` y `enrollments.course_id` tienen restricciones `REFERENCES` (claves foráneas), y la base de datos rechaza cualquier inscripción que apunte a un id inexistente.
- **Verificación:** para confirmar que el resultado vacío es real y no un error en la consulta, se ejecutaron ambas con `IS NOT NULL` en lugar de `IS NULL`. Devolvieron las 16 inscripciones, lo que confirma que el JOIN funciona correctamente.

---
