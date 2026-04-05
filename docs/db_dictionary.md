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
