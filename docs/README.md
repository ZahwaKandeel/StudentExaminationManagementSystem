# Student Examination Management System

A PostgreSQL-based system to manage exams, question banks, student answers, grading, and reporting across ITI departments/tracks/courses. All business logic lives in PL/pgSQL stored procedures — no direct table access from clients.

---

## Tech Stack

- **Database:** PostgreSQL
- **Logic Layer:** PL/pgSQL stored procedures
- **Tools:** pgAdmin / DBeaver / psql

---

## Repository Structure

```
StudentExaminationManagementSystem/
├── schema/                          # CREATE TABLE scripts, constraints, indexes
│   ├── 00_collation.sql             # Arabic ICU collation (run first)
│   ├── 01_org.sql                   # Department, Track, Course, Track_Course
│   ├── 02_people.sql                # Student, Instructor, junctions
│   └── 03_exam.sql                  # Question, Choice, ModelAnswer, Exam, ExamQuestion,
│                                    #   StudentExam, StudentAnswer
├── procs/                           # All stored procedures (.sql)
│   ├── crud/                        # Entity CRUD operations
│   │   ├── dept_crud.sql            # Department, Track, Course + AssignCourseToTrack
│   │   ├── people_crud.sql          # Student, Instructor + AssignStudentToTrack,
│   │   │                            #   AssignInstructorToCourse
│   │   ├── question_crud.sql        # Question, Choice, SetModelAnswer
│   │   ├── exam_crud.sql            # Exam, ExamQuestion
│   │   └── student_exam_crud.sql    # StudentExam, StudentAnswer
│   └── logic/                       # Business logic procedures
│       ├── generate_exam.sql        # GenerateExam (random question selection)
│       ├── submit_answers.sql       # SubmitExamAnswers (JSONB answer ingestion)
│       └── correct_exam.sql         # CorrectExam (auto-grading via model answers)
├── reports/                         # Report stored procedures
│   ├── rpt_students_by_dept.sql     # Report_StudentsByDepartment
│   ├── report_student_grades.sql    # Report_StudentGrades
│   ├── report_instructor_courses.sql# Report_InstructorCourses
│   ├── rpt_ExamQuestions.sql        # Report_ExamQuestions
│   └── report_student_exam_answers.sql # Report_StudentExamAnswers
├── data/
│   └── sample_data.sql              # Seed: 3 depts, 7 tracks, 7 courses,
│                                    #   5 instructors, 60+ questions
├── security/
│   └── roles.sql                    # Role-based access: adminUser / Instructor / Student
├── tests/
│   ├── DBReset.sql                  # ⚠️ Destructive — drops public schema (dev only)
│   ├── integration_test.sql         # 8-scenario lifecycle test suite
│   ├── test_reports.sql             # Report procedure test cases
│   └── Performance.sql              # NFR-01/02: 50-question exam perf test
├── scripts/
│   ├── backup.sh                    # Timestamped pg_dump backup script
│   ├── restore.sh                   # Interactive restore from backup
│   └── README_backup.md             # Backup/restore usage documentation
└── docs/
    ├── README.md                    # This file
    ├── db_dictionary.md             # Column-level documentation for all tables
    ├── constraints_reference.md     # FK ON DELETE rules + CHECK constraints
    ├── System ERD.drawio            # ERD source (draw.io)
    └── System ERD.pdf               # ERD export
```

---

## Setup

> **Prerequisite:** PostgreSQL must be installed and running.
> The `icu` extension must be available for Arabic collation support.
> Verify with: `SELECT * FROM pg_available_extensions WHERE name = 'icu';`

```bash
# 1. Create the database
createdb exam_db

# 2. Run schema (in order — collation MUST come first)
psql -d exam_db -f schema/00_collation.sql
psql -d exam_db -f schema/01_org.sql
psql -d exam_db -f schema/02_people.sql
psql -d exam_db -f schema/03_exam.sql

# 3. Load CRUD procedures
psql -d exam_db -f procs/crud/dept_crud.sql
psql -d exam_db -f procs/crud/people_crud.sql
psql -d exam_db -f procs/crud/question_crud.sql
psql -d exam_db -f procs/crud/exam_crud.sql
psql -d exam_db -f procs/crud/student_exam_crud.sql

# 4. Load business logic procedures
psql -d exam_db -f procs/logic/generate_exam.sql
psql -d exam_db -f procs/logic/submit_answers.sql
psql -d exam_db -f procs/logic/correct_exam.sql

# 5. Load reports
psql -d exam_db -f reports/rpt_students_by_dept.sql
psql -d exam_db -f reports/report_student_grades.sql
psql -d exam_db -f reports/report_instructor_courses.sql
psql -d exam_db -f reports/rpt_ExamQuestions.sql
psql -d exam_db -f reports/report_student_exam_answers.sql

# 6. Set up roles & security
psql -d exam_db -f security/roles.sql

# 7. Load sample seed data
psql -d exam_db -f data/sample_data.sql
```

> **Note:** If database name differs from `exam_db`, update it everywhere
> including `scripts/backup.sh` and `scripts/restore.sh` (default: `iti_exam`).

---

## Core Procedures

### Exam Lifecycle

| Procedure | Signature | Description |
|-----------|-----------|-------------|
| `GenerateExam` | `(e_CourseID INT, e_ExamName TEXT, e_NumMCQ INT, e_NumTF INT, OUT new_examid INT)` | Creates an exam and randomly selects MCQ + TF questions from the course question bank |
| `SubmitExamAnswers` | `(s_id INT, ex_id INT, start_time TIMESTAMPTZ, end_time TIMESTAMPTZ, in_answer JSONB, OUT SX_id INT)` | Creates a StudentExam record and inserts individual answers from a JSONB array |
| `CorrectExam` | `(e_StudentExamID INT)` | Grades the exam by comparing student answers with model answers, writes TotalGrade (weighted by `SUM(points)`) |

### JSONB Answer Format

```json
[
  {"question_id": 1, "chosen_option_id": 3},
  {"question_id": 2, "chosen_option_id": 7}
]
```

### Example: Full Lifecycle

```sql
-- 1. Generate an exam (3 MCQ + 2 TF from course 1)
CALL GenerateExam(1, 'DB Midterm', 3, 2, v_examid);
-- → v_examid = 1

-- 2. Student submits answers
CALL SubmitExamAnswers(
    1,                                              -- student id
    1,                                              -- exam id
    '2026-04-08 10:00:00'::timestamptz,            -- start
    '2026-04-08 11:00:00'::timestamptz,            -- end
    '[{"question_id": 10, "chosen_option_id": 40},
      {"question_id": 11, "chosen_option_id": 44}]'::jsonb,
    v_sx_id
);

-- 3. Auto-grade the exam
CALL CorrectExam(v_sx_id);
```

### CRUD Procedures

All entity CRUD procedures follow the same naming pattern:
`Insert<Entity>`, `Update<Entity>`, `Delete<Entity>`, `Select<Entity>By...`

| Category | File | Key Procedures |
|----------|------|----------------|
| Department / Track / Course | `procs/crud/dept_crud.sql` | `InsertDepartment`, `InsertTrack`, `InsertCourse`, `AssignCourseToTrack` |
| Student / Instructor | `procs/crud/people_crud.sql` | `InsertStudent`, `InsertInstructor`, `AssignStudentToTrack`, `AssignInstructorToCourse` |
| Question / Choice / ModelAnswer | `procs/crud/question_crud.sql` | `InsertQuestion`, `InsertOption`, `SetModelAnswer` |
| Exam / ExamQuestion | `procs/crud/exam_crud.sql` | `insertExam`, `insert_examquestion` |
| StudentExam / StudentAnswer | `procs/crud/student_exam_crud.sql` | `InsertStudentExam`, `InsertStudentAnswer` |

---

## Reports

All reports return data via `INOUT REFCURSOR`. Call pattern:

```sql
BEGIN;
CALL Report_ProcName(args, 'my_cursor');
FETCH ALL FROM my_cursor;
COMMIT;
```

| Procedure | Parameters | Returns | Granted To |
|-----------|------------|---------|------------|
| `Report_StudentsByDepartment` | `(d_DepartmentID INT, INOUT ref REFCURSOR)` | Students with tracks per department | Student |
| `Report_StudentGrades` | `(s_id INT, INOUT result REFCURSOR)` | Exam grades with percentage per student | Student |
| `Report_InstructorCourses` | `(p_instructorid INT, INOUT result REFCURSOR)` | Courses + student count per track for an instructor | Instructor |
| `Report_ExamQuestions` | `(p_examid INT, INOUT ref REFCURSOR)` | All questions + choices for an exam (includes `is_correct` flag) | Instructor |
| `Report_StudentExamAnswers` | `(p_examid INT, p_studentid INT, INOUT result REFCURSOR)` | A student's answers with correctness (hides model answers) | — *Instructor* |

### Examples

```sql
CALL Report_StudentsByDepartment(1, 'cur');  -- Students in dept 1
CALL Report_StudentGrades(1, 'cur');         -- Grades for student 1
CALL Report_InstructorCourses(1, 'cur');     -- Courses taught by instructor 1
CALL Report_ExamQuestions(1, 'cur');         -- Full exam 1 question list
CALL Report_StudentExamAnswers(1, 1, 'cur'); -- Student 1's answers for exam 1
```

---

## Backup & Restore

### Using Scripts (Recommended)

```bash
# Create a timestamped backup
bash scripts/backup.sh

# Restore from a backup (interactive — asks for confirmation)
bash scripts/restore.sh backups/exam_db_development.sql
```

Backup files are saved to `backups/` with timestamps.
Each run appends to `backups/backup_log.txt`.

> **Note:** Backup scripts default to database name `iti_exam`.
> Update `DB_NAME` in `scripts/backup.sh` and `scripts/restore.sh`
> to match your database (`exam_db` or otherwise).

### Manual Commands

```bash
# Backup
pg_dump -h localhost -p 5432 -U postgres -d exam_db \
  --clean --if-exists --no-owner -F p -f backups/manual.sql

# Restore
psql -h localhost -p 5432 -U postgres -d exam_db \
  -v ON_ERROR_STOP=1 -f backups/manual.sql
```

### Fresh Database Restore

```bash
# Create a blank database
psql -U postgres -c "CREATE DATABASE exam_db ENCODING 'UTF8' TEMPLATE template0;"

# Restore into it
psql -U postgres -d exam_db -f backups/exam_db_development.sql
```

---

## Security

Three roles are defined in `security/roles.sql`:

| Role | Access |
|------|--------|
| `adminUser` | Superuser — full access to everything |
| `Instructor` | Can manage exams, questions, model answers, and run instructor reports |
| `Student` | Can submit exam answers and view their own grades |

Direct table access is revoked for all roles. All interaction must go through stored procedures.


---

## Testing

```bash
# Run the full integration test suite (8 scenarios)
psql -d exam_db -f tests/integration_test.sql

# Test all report procedures
psql -d exam_db -f tests/test_reports.sql

# Performance test — 50-question exam generation + correction timing
psql -d exam_db -f tests/Performance.sql

# ⚠️ WARNING: DBReset.sql drops the entire public schema
# Only run this on a fresh dev database you can afford to lose
psql -d exam_db -f tests/DBReset.sql
```

---

## Team

**Developer 1: Zahwa Kandeel**
- Init repo, folder structure, conventions doc
- Schema: Department, Track, Course, Track_Course (`01_org.sql`)
- CRUD: Department, Track, Course + `AssignCourseToTrack`
- CRUD: Exam, ExamQuestion (`exam_crud.sql`)
- `GenerateExam` proc + exception handling
- `CorrectExam` proc + transaction safety
- `Report_StudentsByDepartment`
- `Report_ExamQuestions`
- Integration test suite (8 scenarios) + Performance test
- README + setup guide + call examples

**Developer 2: Ayman Mohamed**
- ERD design, table definitions draft
- Schema: Student, Instructor, Student_Track, Instructor_Course (`02_people.sql`)
- CRUD: Student, Instructor + `AssignStudentToTrack`, `AssignInstructorToCourse`
- CRUD: StudentExam, StudentAnswer (`student_exam_crud.sql`)
- `SubmitExamAnswers` proc + JSONB parsing
- `Report_StudentGrades` + percentage calculation
- Role-based security: `roles.sql` (student/instructor/admin roles)
- Performance validation: NFR-01/02 timing
- DB dictionary finalise + ERD export PDF

**Developer 3: Mostafa Abd El Kawy**
- DB dictionary template, collation & constraints research
- Schema: Question, Choice, ModelAnswer, Exam, ExamQuestion, StudentExam, StudentAnswer (`03_exam.sql`)
- CRUD: Question, Choice, `SetModelAnswer` (`question_crud.sql`)
- Cross-review all CRUD; fix FK violations
- Sample data: departments, tracks, courses, instructors, 60+ questions
- Integration test: generate → submit → correct flow
- `Report_InstructorCourses` + student count
- `Report_StudentExamAnswers` + model answer hiding (NFR-05)
- Backup/restore shell scripts + documentation
- Final merge to main, tag release, LinkedIn post

---

