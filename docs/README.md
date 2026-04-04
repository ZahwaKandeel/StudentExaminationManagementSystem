# StudentExaminationManagementSystem

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
├── schema/        # CREATE TABLE scripts, constraints, indexes
├── procs/         # All stored procedures (.sql)
├── reports/       # Report views and procedures
├── data/          # Sample data scripts (20+ students, 50+ questions)
├── security/      # Role-based access (student / instructor / admin)
├── tests/         # Test scenario scripts (5 core test cases)
├── scripts/       # pg_dump backup & restore instructions
└── docs/          # ERD (PDF + source), DB dictionary, SRS
```

---

## Setup

```bash
# 1. Create the database
createdb exam_db

# 2. Run schema
psql -d exam_db -f schema/create_tables.sql

# 3. Load stored procedures
psql -d exam_db -f procs/crud.sql
psql -d exam_db -f procs/generate_exam.sql
psql -d exam_db -f procs/submit_answers.sql
psql -d exam_db -f procs/correct_exam.sql

# 4. Load reports & security
psql -d exam_db -f reports/all_reports.sql
psql -d exam_db -f security/roles.sql

# 5. Insert sample data
psql -d exam_db -f data/sample_data.sql
```

---

## Core Procedures

| Procedure | Description |
|-----------|-------------|
| `GenerateExam(CourseID, ExamName, NumMCQ, NumTF)` | Randomly selects questions and creates an exam |
| `SubmitExamAnswers(StudentID, ExamID, StartTime, EndTime, Answers JSONB)` | Records student answers |
| `CorrectExam(StudentExamID)` | Grades the exam and updates TotalGrade |

---

## Reports

```sql
CALL Report_StudentsByDepartment(1);   -- Students per department
CALL Report_StudentGrades(3);          -- Grade summary per student
CALL Report_InstructorCourses(2);      -- Courses & student count per instructor
```

---

## Backup & Restore

```bash
# Backup
pg_dump -U postgres exam_db > scripts/backup.sql

# Restore
psql -U postgres -d exam_db < scripts/backup.sql
```

---

## Team

**Developer 1: Zahwa Kandeel**
- Init repo, folder structure, conventions doc
- Schema SQL: Dept, Track, Course, junctions
- CRUD: Department, Track, Course
- CRUD: Exam, ExamQuestion tables
- GenerateExam proc + exception handling
- CorrectExam proc + transaction safety
- Report_StudentsByDepartment view/proc
- Optional reports: CourseTopics, ExamQuestions
- Full test suite: all 5 test scenarios
- README.md + setup guide + call examples

**Developer 2: Ayman Mohamed**
- ERD design, table definitions draft
- Schema SQL: Student, Instructor, assignments
- CRUD: Student, Instructor, assign procs
- CRUD: StudentExam, StudentAnswer
- SubmitExamAnswers proc + JSONB parsing
- Sample data: 20+ students, 50+ questions
- Report_StudentGrades + percentage calc
- Role-based security: student/instructor/admin roles
- Performance check: NFR-01/02 timing
- DB dictionary finalise + ERD export PDF

**Developer 3: Mostafa Abd El Kawy**
- DB dictionary template, collation & constraints research
- Schema SQL: Question, Choice, ModelAnswer, Exam tables
- CRUD: Question + Choice + SetModelAnswer
- Cross-review all CRUD; fix FK violations
- Sample data: depts, tracks, courses, instructors
- Integration test: generate → submit → correct flow
- Report_InstructorCourses + student count
- Report_StudentExamAnswers + hide model answers
- pg_dump backup script + restore instructions
- Final merge to main, tag release, LinkedIn post

---

