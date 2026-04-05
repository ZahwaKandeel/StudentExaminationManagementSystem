# Database Dictionary — ITI Exam Management System

## How to use this file

Each developer fills in the tables they own (assigned in the roadmap).
Copy the template block below for each new table.
Follow the constraints_reference.md for FK and CHECK decisions.

---

## TEMPLATE (copy this block for each table)

### Table: `table_name`

**Purpose:** One sentence describing what this table stores.
**Owner:** Dev X
**Schema file:** schema/0X_filename.sql

#### Columns

| Column | Type   | Nullable | Default | Collation | Description |
| ------ | ------ | -------- | ------- | --------- | ----------- |
| id     | SERIAL | NO       | auto    | —         | Primary key |

#### Constraints

| Type | Name              | Definition                              |
| ---- | ----------------- | --------------------------------------- |
| PK   | pk_tablename      | (id)                                    |
| FK   | fk_tablename_col  | col → other_table(col) ON DELETE ACTION |
| UQ   | uq_tablename_col  | (col)                                   |
| CHK  | chk_tablename_col | col condition                           |

#### Indexes

| Name              | Column(s) | Type  | Reason            |
| ----------------- | --------- | ----- | ----------------- |
| idx_tablename_col | col       | BTREE | Speeds up X query |

#### Notes

- Any special behavior worth documenting

---

## FILLED EXAMPLE

### Table: `question`

**Purpose:** Stores all exam questions linked to a course,
supporting MCQ (4 choices) and True/False types.
**Owner:** Mostafa Abd Elqawy
**Schema file:** schema/03_exam.sql

#### Columns

| Column       | Type   | Nullable | Default | Collation  | Description                           |
| ------------ | ------ | -------- | ------- | ---------- | ------------------------------------- |
| questionid   | SERIAL | NO       | auto    | —          | Primary key                           |
| courseid     | INT    | NO       | —       | —          | FK to course table                    |
| questiontext | TEXT   | NO       | —       | arabic_icu | Full question body, Arabic or English |
| type         | TEXT   | NO       | —       | —          | 'MCQ' or 'TF' only                    |
| points       | INT    | NO       | 1       | —          | Score if answered correctly           |

#### Constraints

| Type | Name                | Definition                                     |
| ---- | ------------------- | ---------------------------------------------- |
| PK   | pk_question         | (questionid)                                   |
| FK   | fk_question_course  | courseid → course(courseid) ON DELETE RESTRICT |
| CHK  | chk_question_type   | type IN ('MCQ', 'TF')                          |
| CHK  | chk_question_points | points > 0                                     |

#### Indexes

| Name                  | Column(s) | Type  | Reason                                     |
| --------------------- | --------- | ----- | ------------------------------------------ |
| idx_question_courseid | courseid  | BTREE | Fast lookup during GenerateExam            |
| idx_question_type     | type      | BTREE | Filter by MCQ or TF during exam generation |

#### Notes

- questiontext uses arabic_icu collation to support Arabic text
- When type = 'TF', exactly 2 choices must exist in the choice table
- When type = 'MCQ', exactly 4 choices must exist

### Table: `student`

**Purpose:** Stores personal and contact information for students enrolled in the system.
**Owner:** Ayman Mohamed
**Schema file:** schema/02_people.sql

#### Columns

| Column    | Type   | Nullable | Default | Collation | Description                                               |
| --------- | ------ | -------- | ------- | --------- | --------------------------------------------------------- |
| studentid | SERIAL | NO       | auto    | —         | Primary key, auto-incremented student identifier          |
| name      | TEXT   | NO       | —       | —         | Full name of the student                                  |
| email     | TEXT   | NO       | —       | —         | Student email address, must be unique across all students |
| phone     | TEXT   | YES      | NULL    | —         | Optional contact phone number                             |

#### Constraints

| Type | Name             | Definition  |
| ---- | ---------------- | ----------- |
| PK   | pk_student       | (studentid) |
| UQ   | uq_student_email | (email)     |

#### Indexes

| Name              | Column(s) | Type  | Reason                                                |
| ----------------- | --------- | ----- | ----------------------------------------------------- |
| idx_student_email | email     | BTREE | Fast uniqueness enforcement and login/lookup by email |

#### Notes

- `phone` is the only nullable column; all other fields are required at registration
- `email` uniqueness is enforced at the DB level via `UNIQUE` constraint; application layer should also validate format

---

### Table: `instructor`

**Purpose:** Stores instructor profiles and their assignment to a department.
**Owner:** Ayman Mohamed
**Schema file:** schema/02_people.sql

#### Columns

| Column       | Type   | Nullable | Default | Collation | Description                                                   |
| ------------ | ------ | -------- | ------- | --------- | ------------------------------------------------------------- |
| instructorid | SERIAL | NO       | auto    | —         | Primary key, auto-incremented instructor identifier           |
| name         | TEXT   | NO       | —       | —         | Full name of the instructor                                   |
| email        | TEXT   | NO       | —       | —         | Institutional email address, must be unique                   |
| departmentno | INT    | NO       | —       | —         | FK to department table; department this instructor belongs to |

#### Constraints

| Type | Name                     | Definition                                                                   |
| ---- | ------------------------ | ---------------------------------------------------------------------------- |
| PK   | pk_instructor            | (instructorid)                                                               |
| UQ   | uq_instructor_email      | (email)                                                                      |
| FK   | fk_instructor_department | departmentno → department(departmentid) ON DELETE SET NULL ON UPDATE CASCADE |

#### Indexes

| Name                        | Column(s)    | Type  | Reason                                          |
| --------------------------- | ------------ | ----- | ----------------------------------------------- |
| idx_instructor_email        | email        | BTREE | Fast uniqueness enforcement and lookup by email |
| idx_instructor_departmentno | departmentno | BTREE | Fast filter of instructors by department        |

#### Notes

- `ON DELETE SET NULL` Instructor stays even if dept removed
- An instructor can teach multiple courses via `instructor_course`; courses are not stored on this table

---

### Table: `student_track`

**Purpose:** Junction table resolving the many-to-many relationship between students and tracks. A student may be enrolled in more than one track.
**Owner:** Ayman Mohamed
**Schema file:** schema/02_people.sql

#### Columns

| Column    | Type | Nullable | Default | Collation | Description                                    |
| --------- | ---- | -------- | ------- | --------- | ---------------------------------------------- |
| studentid | INT  | NO       | —       | —         | FK to student table; the enrolled student      |
| trackid   | INT  | NO       | —       | —         | FK to track table; the track being enrolled in |

#### Constraints

| Type | Name             | Definition                                                          |
| ---- | ---------------- | ------------------------------------------------------------------- |
| PK   | pk_student_track | (studentid, trackid)                                                |
| FK   | fk_st_student    | studentid → student(studentid) ON DELETE RESTRICT ON UPDATE CASCADE |
| FK   | fk_st_track      | trackid → track(trackid) ON DELETE RESTRICT ON UPDATE CASCADE       |

#### Indexes

| Name             | Column(s) | Type  | Reason                                          |
| ---------------- | --------- | ----- | ----------------------------------------------- |
| idx_st_studentid | studentid | BTREE | Retrieve all tracks for a given student         |
| idx_st_trackid   | trackid   | BTREE | Retrieve all students enrolled in a given track |

#### Notes

- Composite PK `(studentid, trackid)` prevents duplicate enrollment records
- `ON DELETE RESTRICT` on both FKs Don't silently remove.

---

### Table: `instructor_course`

**Purpose:** Junction table resolving the many-to-many relationship between instructors and courses. An instructor may teach multiple courses, and a course may have multiple instructors.
**Owner:** Ayman Mohamed
**Schema file:** schema/02_people.sql

#### Columns

| Column       | Type | Nullable | Default | Collation | Description                                     |
| ------------ | ---- | -------- | ------- | --------- | ----------------------------------------------- |
| instructorid | INT  | NO       | —       | —         | FK to instructor table; the assigned instructor |
| courseid     | INT  | NO       | —       | —         | FK to course table; the course being taught     |

#### Constraints

| Type | Name                 | Definition                                                                  |
| ---- | -------------------- | --------------------------------------------------------------------------- |
| PK   | pk_instructor_course | (instructorid, courseid)                                                    |
| FK   | fk_ic_instructor     | instructorid → instructor(instructorid) ON DELETE CASCADE ON UPDATE CASCADE |
| FK   | fk_ic_course         | courseid → course(courseid) ON DELETE CASCADE ON UPDATE CASCADE             |

#### Indexes

| Name                | Column(s)    | Type  | Reason                                              |
| ------------------- | ------------ | ----- | --------------------------------------------------- |
| idx_ic_instructorid | instructorid | BTREE | Retrieve all courses taught by a given instructor   |
| idx_ic_courseid     | courseid     | BTREE | Retrieve all instructors assigned to a given course |

#### Notes

- Composite PK `(instructorid, courseid)` prevents duplicate assignments
- `ON DELETE CASCADE` on both FKs cleans up assignment rows automatically when an instructor or course is deleted

---

### Table: `Course`

**Purpose:** Stores information about courses including their names and grading.
**Owner:** Zahwa Kandeel
**Schema file:** schema/01_org.sql

#### Columns

| Column    | Type   | Nullable | Default | Collation | Description                                               |
| --------- | ------ | -------- | ------- | --------- | --------------------------------------------------------- |
| CourseID  | SERIAL | NO       | auto    | —         | Primary key, auto-incremented Course identifier           |
| CourseName| TEXT   | NO       | —       | —         | Name of the course                                        |
| MinDegree | INT    | NO       | —       | —         | Minimum degree allowed for the course                     |
| MaxDegree | INT    | NO       | —       | —         | Maximum degree allowed for the course                     |

#### Constraints

| Type | Name             | Definition                               |
| ---- | ---------------- | -----------------------------------------|
| PK   | pk_course        |  (CourseID)                              |
| CHK  | chk_course_degree|(MinDegree >= 0 AND MaxDegree > MinDegree)|

#### Indexes

| Name              | Column(s) | Type  | Reason                                                |
| ----------------- | --------- | ----- | ----------------------------------------------------- |

#### Notes

- All fields are required at adding new course.

---

### Table: `Department`

**Purpose:** Stores information about departments including their names and locations.
**Owner:** Zahwa Kandeel
**Schema file:** schema/01_org.sql

#### Columns

|    Column    | Type   | Nullable | Default | Collation | Description                                               |
| ------------ | ------ | -------- | ------- | --------- | --------------------------------------------------------- |
| DepartmentID | SERIAL | NO       | auto    | —         | Primary key, auto-incremented department identifier       |
|DepartmentName| TEXT   | NO       | —       | —         | Name of the department                                    |
|   Location   | TEXT   | YES      | —       | —         | Location for the department                               |

#### Constraints

| Type | Name             | Definition                               |
| ---- | ---------------- | -----------------------------------------|
| PK   | pk_department    |  (DepartmentID)                          |

#### Indexes

| Name              | Column(s) | Type  | Reason                                                |
| ----------------- | --------- | ----- | ----------------------------------------------------- |

#### Notes

- 'Location` is the only nullable column; all other fields are required at adding the department.

---

### Table: `Track`

**Purpose:** Stores information about tracks including their name and departments.
**Owner:** Zahwa Kandeel
**Schema file:** schema/01_org.sql

#### Columns

|    Column    | Type   | Nullable | Default | Collation | Description                                               |
| ------------ | ------ | -------- | ------- | --------- | --------------------------------------------------------- |
|  TrackID     | SERIAL | NO       | auto    | —         | Primary key, auto-incremented track identifier            |
|  TrackName   | TEXT   | NO       | —       | —         | Name of the track                                         |
| DepartmentID | INT    | YES      | —       | —         | References the department this track belongs to           |

#### Constraints

| Type | Name              | Definition                                              |
| ---- | ----------------- | --------------------------------------------------------|
| PK   | pk_track          |  (TrackID)                                              |
| FK   |fk_track_department|DepartmentID → Department(DepartmentID) ON DELETE CASCADE|

#### Indexes

| Name              | Column(s) | Type  | Reason                                                |
| ----------------- | --------- | ----- | ----------------------------------------------------- |

#### Notes

- Each track belongs to a department.
- ON DELETE CASCADE means deleting a department will delete its tracks automatically.

---


### Table: `Track_Course`

**Purpose:** Junction table that links tracks with courses (many-to-many relationship).
**Owner:** Zahwa Kandeel
**Schema file:** schema/01_org.sql

#### Columns

|    Column    | Type   | Nullable | Default | Collation | Description                                               |
| ------------ | ------ | -------- | ------- | --------- | --------------------------------------------------------- |
|  TrackID     |  INT   | NO       | auto    | —         | References a track                                        |
|  CourseID    |  INT   | NO       | —       | —         | References a course                                       |

#### Constraints

| Type | Name              | Definition                                              |
| ---- | ----------------- | --------------------------------------------------------|
| PK   | pk_track_course   | (TrackID,CourseID)                                      |
| FK   | fk_tc_track       | TrackID → Track(TrackID) ON DELETE CASCADE              |
| FK   | fk_tc_course      | CourseID → Course(CourseID) ON DELETE CASCADE              |

#### Indexes

| Name              | Column(s) | Type  | Reason                                                |
| ----------------- | --------- | ----- | ----------------------------------------------------- |

#### Notes

- This table implements a many-to-many relationship between Track and Course.
- Composite primary key ensures no duplicate pair of (TrackID, CourseID).
- ON DELETE CASCADE ensures:
1.Deleting a track removes related records.
2.Deleting a course removes related records.

---
# Database Dictionary — 03_exam.sql
**File:** `schema/03_exam.sql`
**Author:** Mostafa Abd Elqawy
**Depends on:** `01_org.sql` (course table), `02_people.sql` (student table)
**Last updated:** 2026-04-05

---

## Table of Contents
- [question](#table-question)
- [choice](#table-choice)
- [modelanswer](#table-modelanswer)
- [exam](#table-exam)
- [examquestion](#table-examquestion)
- [studentexam](#table-studentexam)
- [studentanswer](#table-studentanswer)

---

## Table: `question`

**Purpose:** Stores all exam questions belonging to a course. Each question is either MCQ (4 choices) or True/False (2 choices). Supports Arabic and English text.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `course` table from `01_org.sql`

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `questionid` | `SERIAL` | NO | auto | — | Primary key. Auto-incremented. |
| `courseid` | `INT` | NO | — | — | FK → `course(courseid)`. The course this question belongs to. |
| `questiontext` | `TEXT` | NO | — | `arabic_icu` | Full question body. Supports Arabic and English text. |
| `type` | `TEXT` | NO | — | — | Must be `'MCQ'` or `'TF'`. Enforced by CHECK constraint. |
| `points` | `INT` | NO | `1` | — | Score awarded if student answers correctly. Must be > 0. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_question` | `(questionid)` | Unique identifier per question |
| FK | `fk_question_course` | `courseid → course(courseid) ON DELETE RESTRICT` | Cannot delete a course that still has questions |
| CHK | `chk_question_type` | `type IN ('MCQ', 'TF')` | Only two valid question types allowed |
| CHK | `chk_question_points` | `points > 0` | Zero or negative points make no sense |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_question_courseid` | `courseid` | BTREE | `GenerateExam` filters questions by courseid on every call |
| `idx_question_type` | `type` | BTREE | `GenerateExam` selects MCQ and TF separately using LIMIT |

### Notes
- `questiontext` uses `arabic_icu` collation — required for correct Arabic sorting and comparison.
- For `TF` questions: exactly 2 rows must exist in `choice` (`optionorder = 1` = True, `optionorder = 2` = False).
- For `MCQ` questions: exactly 4 rows must exist in `choice`.
- The 2-choice / 4-choice rule is enforced by the `InsertQuestion` stored procedure, not at table level.

---

## Table: `choice`

**Purpose:** Stores the answer options for each question. MCQ questions have 4 choices, True/False questions have 2 choices. Supports Arabic and English text.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `question` table

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `optionid` | `SERIAL` | NO | auto | — | Primary key. Auto-incremented. |
| `questionid` | `INT` | NO | — | — | FK → `question(questionid)`. The question this choice belongs to. |
| `optiontext` | `TEXT` | NO | — | `arabic_icu` | The text of this answer option. Supports Arabic and English. |
| `optionorder` | `INT` | NO | — | — | Display order. 1–4 for MCQ. 1–2 for TF (1 = True, 2 = False). |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_choice` | `(optionid)` | Unique identifier per choice |
| FK | `fk_choice_question` | `questionid → question(questionid) ON DELETE CASCADE` | Choices are meaningless without their parent question |
| UQ | `uq_choice_order` | `(questionid, optionorder)` | Prevents two choices having the same order number for one question |
| CHK | `chk_choice_order` | `optionorder BETWEEN 1 AND 4` | Covers both MCQ (1–4) and TF (1–2) in one rule |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_choice_questionid` | `questionid` | BTREE | `CorrectExam` and report procedures look up all choices per question frequently |

### Notes
- `ON DELETE CASCADE` — deleting a question automatically removes all its choices.
- `optiontext` uses `arabic_icu` collation to support Arabic answer text.
- The convention for TF questions: `optionorder = 1` always means **True**, `optionorder = 2` always means **False**. This is a team convention enforced by the `InsertQuestion` procedure, not by the database.

---

## Table: `modelanswer`

**Purpose:** Stores exactly one correct answer per question. Used exclusively by the `CorrectExam` procedure to calculate student scores. Must be hidden from the student role.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `question` table, `choice` table

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `questionid` | `INT` | NO | — | — | PK and FK → `question(questionid)`. One row per question enforced by PK. |
| `correctoptionid` | `INT` | NO | — | — | FK → `choice(optionid)`. The correct answer choice for this question. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_modelanswer` | `(questionid)` | Using questionid as PK enforces one correct answer per question at DB level |
| FK | `fk_modelanswer_question` | `questionid → question(questionid) ON DELETE CASCADE` | Model answer is meaningless if the question is deleted |
| FK | `fk_modelanswer_choice` | `correctoptionid → choice(optionid) ON DELETE CASCADE` | Model answer is invalid if the correct choice is deleted |

### Indexes

> No additional indexes needed. `questionid` is the PK and is indexed automatically by PostgreSQL.

### Notes
- Using `questionid` as the PRIMARY KEY (not a SERIAL) is intentional — it makes it structurally impossible to insert two correct answers for the same question.
- **Important:** PostgreSQL does NOT verify that `correctoptionid` belongs to the same `questionid`. This cross-check must be performed inside the `SetModelAnswer` stored procedure before inserting.
- The student role must be denied `SELECT` access on this table entirely. Enforced in `security/roles.sql`.
- Both FKs use `CASCADE` — if either the question or its correct choice is deleted, the model answer row is removed automatically.

---

## Table: `exam`

**Purpose:** Represents a single exam instance generated for a course. One exam can be taken by many students. Created by the `GenerateExam` procedure.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `course` table from `01_org.sql`

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `examid` | `SERIAL` | NO | auto | — | Primary key. Auto-incremented. |
| `examname` | `TEXT` | NO | — | `arabic_icu` | Human-readable exam name. Supports Arabic and English. |
| `courseid` | `INT` | NO | — | — | FK → `course(courseid)`. Which course this exam covers. |
| `createddate` | `TIMESTAMP` | NO | `NOW()` | — | Timestamp when `GenerateExam` was called. Auto-set. |
| `totalquestions` | `INT` | NO | — | — | Total number of questions. Must equal actual `examquestion` row count. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_exam` | `(examid)` | Unique identifier per exam |
| FK | `fk_exam_course` | `courseid → course(courseid) ON DELETE RESTRICT` | Cannot delete a course that has existing exams |
| CHK | `chk_exam_totalquestions` | `totalquestions > 0` | An exam with zero questions is invalid |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_exam_courseid` | `courseid` | BTREE | `Report_InstructorCourses` and `Report_StudentGrades` join on courseid frequently |

### Notes
- `totalquestions` is set by `GenerateExam` as `@NumMCQ + @NumTF`. It should always equal the actual count of rows in `examquestion` for this exam.
- `createddate` defaults to `NOW()` so `GenerateExam` does not need to pass it as a parameter.
- `ON DELETE RESTRICT` on `courseid` protects historical exam data from accidental loss if a course is removed.

---

## Table: `examquestion`

**Purpose:** Junction table linking exams to their questions with a display order number. Populated by `GenerateExam` using random selection. The composite PK prevents duplicate questions per exam automatically.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `exam` table, `question` table

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `examid` | `INT` | NO | — | — | Part of composite PK. FK → `exam(examid)`. ON DELETE CASCADE. |
| `questionid` | `INT` | NO | — | — | Part of composite PK. FK → `question(questionid)`. ON DELETE RESTRICT. |
| `orderno` | `INT` | NO | — | — | Display order of this question within the exam. Must be unique per exam. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_examquestion` | `(examid, questionid)` | Composite PK prevents the same question appearing twice in one exam |
| FK | `fk_examquestion_exam` | `examid → exam(examid) ON DELETE CASCADE` | Exam deleted = its question list is deleted automatically |
| FK | `fk_examquestion_question` | `questionid → question(questionid) ON DELETE RESTRICT` | Cannot delete a question that is currently used in an exam |
| UQ | `uq_examquestion_order` | `(examid, orderno)` | Two questions in the same exam cannot share the same order number |
| CHK | `chk_examquestion_order` | `orderno > 0` | Order must start from 1, not zero or negative |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_examquestion_examid` | `examid` | BTREE | `Report_ExamQuestions` and `CorrectExam` look up all questions for an exam |

### Notes
- The composite PK `(examid, questionid)` is the primary deduplication mechanism — `GenerateExam` does not need extra logic to prevent duplicates.
- The FK on `questionid` uses `RESTRICT` deliberately — a question that is part of an exam is "in use" and must not be deleted.
- `orderno` is assigned sequentially by `GenerateExam` using `ROW_NUMBER()` after the random question selection step.

---

## Table: `studentexam`

**Purpose:** Records one student attempt at one exam, including start/end times and the final calculated total grade. Created by `SubmitExamAnswers` and updated by `CorrectExam`.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `student` table from `02_people.sql`, `exam` table

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `studentexamid` | `SERIAL` | NO | auto | — | Primary key. Auto-incremented. |
| `studentid` | `INT` | NO | — | — | FK → `student(studentid)`. ON DELETE RESTRICT. |
| `examid` | `INT` | NO | — | — | FK → `exam(examid)`. ON DELETE RESTRICT. |
| `starttime` | `TIMESTAMP` | NO | — | — | When the student started the exam. Passed by `SubmitExamAnswers`. |
| `endtime` | `TIMESTAMP` | **YES** | `NULL` | — | When the student submitted. NULL while exam is still running. |
| `totalgrade` | `INT` | **YES** | `0` | — | Sum of points for correct answers. Updated by `CorrectExam`. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_studentexam` | `(studentexamid)` | Unique identifier per attempt |
| FK | `fk_studentexam_student` | `studentid → student(studentid) ON DELETE RESTRICT` | Preserve exam history — do not delete student with records |
| FK | `fk_studentexam_exam` | `examid → exam(examid) ON DELETE RESTRICT` | Preserve exam history — do not delete exam with attempts |
| UQ | `uq_studentexam` | `(studentid, examid)` | One student can attempt the same exam only once |
| CHK | `chk_studentexam_grade` | `totalgrade >= 0` | Grade cannot be negative |
| CHK | `chk_studentexam_times` | `endtime IS NULL OR endtime > starttime` | Once set, end time must be after start time |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_studentexam_studentid` | `studentid` | BTREE | `Report_StudentGrades` filters by studentid on every call |
| `idx_studentexam_examid` | `examid` | BTREE | `CorrectExam` and report procedures join on examid |

### Notes
- `endtime` is intentionally nullable. It is `NULL` when the row is first created and is set only when `SubmitExamAnswers` completes successfully.
- `totalgrade` defaults to `0` and is overwritten by `CorrectExam` with the actual calculated score. It remains `0` if `CorrectExam` has not been run yet.
- The UNIQUE constraint on `(studentid, examid)` prevents a student from submitting the same exam twice.
- Both FKs use `RESTRICT` to preserve historical records — student and exam data must be archived, not deleted.

---

## Table: `studentanswer`

**Purpose:** Stores one row per question answered by a student in a specific exam attempt. Unanswered questions produce no row and count as 0 points. Used by `CorrectExam` to calculate the score.
**Schema file:** `schema/03_exam.sql`
**Owner:** Mostafa Abd Elqawy
**Depends on:** `studentexam` table, `question` table, `choice` table

### Columns

| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| `studentanswerid` | `SERIAL` | NO | auto | — | Primary key. Auto-incremented. |
| `studentexamid` | `INT` | NO | — | — | FK → `studentexam(studentexamid)`. ON DELETE CASCADE. |
| `questionid` | `INT` | NO | — | — | FK → `question(questionid)`. ON DELETE RESTRICT. |
| `chosenoptionid` | `INT` | NO | — | — | FK → `choice(optionid)`. The option the student selected. ON DELETE RESTRICT. |

### Constraints

| Type | Name | Definition | Reason |
|------|------|------------|--------|
| PK | `pk_studentanswer` | `(studentanswerid)` | Unique identifier per answer row |
| FK | `fk_studentanswer_studentexam` | `studentexamid → studentexam(studentexamid) ON DELETE CASCADE` | Exam attempt deleted = all its answer rows deleted automatically |
| FK | `fk_studentanswer_question` | `questionid → question(questionid) ON DELETE RESTRICT` | Preserve answer history — cannot delete an answered question |
| FK | `fk_studentanswer_choice` | `chosenoptionid → choice(optionid) ON DELETE RESTRICT` | Preserve answer history — cannot delete a chosen option |
| UQ | `uq_studentanswer` | `(studentexamid, questionid)` | One answer per question per exam attempt |

### Indexes

| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| `idx_studentanswer_studentexamid` | `studentexamid` | BTREE | `CorrectExam` iterates all answers for a given attempt in a tight loop |

### Notes
- Unanswered questions produce **no row** in this table. `CorrectExam` treats missing rows as 0 points automatically — no "skipped" flag is needed.
- **Important:** PostgreSQL does NOT verify that `chosenoptionid` belongs to the same `questionid`. This must be validated inside `SubmitExamAnswers` when parsing the JSONB input array.
- `ON DELETE CASCADE` from `studentexam` means deleting an exam attempt automatically cleans up all its answer rows.
- The UNIQUE constraint on `(studentexamid, questionid)` prevents a student from submitting two answers for the same question in one attempt.

