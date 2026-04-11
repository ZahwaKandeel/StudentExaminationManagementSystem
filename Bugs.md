# 📊 Project Audit: Examination System Database

This document outlines the current state, critical vulnerabilities, and required enhancements for the `exam_db` PostgreSQL project.

---

## ✅ What’s Working

- **Robust Schema (13 tables):** Well-designed with proper Primary Keys (PKs), Foreign Keys (FKs), `CHECK` constraints, and indexes across 4 layered SQL files.
- **Complete CRUD Layer:** Procedures for all entities (Departments, Tracks, Courses, Students, etc.) with integrated validation logic.
- **Seed Data:** Comprehensive dataset including 3 departments, 7 tracks, 7 courses, 5 instructors, 60 questions, and 25 students.
- **Documentation:** High-quality `db_dictionary.md` detailing columns, constraints, and indexes.
- **Internationalization:** `arabic_icu` collation properly implemented for localized text support.
- **Reporting:** Core procedures for Student Grades and Exam Questions are functional.

---

## ⚠️ Current Issues & Technical Debt

### 🔴 High Priority (Immediate Fix Required)

| Feature               | Issue                                                                        | Impact                                                                                 |
| :-------------------- | :--------------------------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| **Integration Tests** | Parameter names in `integration_test.sql` do not match procedure signatures. | **Tests crash immediately.** No automated verification possible.                       |
| **Grading Logic**     | `CorrectExam` uses `COUNT(*)` instead of `SUM(points)`.                      | **Incorrect Grades.** A 10pt question is weighted the same as a 1pt question.          |
| **Concurrency**       | `GenerateExam` uses `SELECT MAX(id)`.                                        | **Race Condition.** In a multi-user environment, users will get the wrong Exam IDs.    |
| **Security**          | Incomplete scripts, placeholder syntax, and shared passwords.                | **System Vulnerability.** Unauthorized data access and syntax errors in SQL execution. |

### 🟡 Medium Priority (Logic & UX)

- **`SubmitExamAnswers` Validation:** Lacks a check to ensure `question_id` belongs to the specific `exam_id`.
- **README Accuracy:** File paths for setup scripts are outdated (e.g., `procs/crud.sql` vs actual split files).
- **Error Messaging:** `InsertStudentExam` provides an inverted error message regarding time constraints.
- **Performance:** Missing index on `studentanswer.questionid`, leading to slow joins during grading.

### 🔵 Low Priority (Maintenance)

- **Destructive Testing:** `Test.sql` drops the `public` schema; `ROLLBACK` is ineffective against DDL in this context.
- **Data Exposure:** `Report_ExamQuestions` reveals `is_correct` flags to all users.

---

## 🔲 Missing / Incomplete Features

- [ ] **Role-Based Access Control (RBAC):** `REVOKE` statements on tables and full `GRANT` sets for procedures.
- [ ] **DevOps Scripts:** `backup.sql` is missing despite being referenced in documentation.

---

## 💡 Technical Action Plan

### 1. Fix Grading Logic (`CorrectExam`)

**Change:** Switch from `COUNT` to `SUM`.

```sql
-- Fix: Replace COUNT with SUM of points
SELECT SUM(q.points)
INTO v_total_grade
FROM studentanswer sa
JOIN question q ON sa.questionid = q.questionid
WHERE sa.studentexamid = p_studentexamid AND sa.is_correct = TRUE;
```

### 2. Solve the Race Condition (`GenerateExam`)

**Change:** Use the `RETURNING` clause or `CURRVAL` instead of `MAX()`.

```sql
-- Better approach
INSERT INTO exam (courseid, examname)
VALUES (p_courseid, p_examname)
RETURNING examid INTO v_new_id;
```

### 3. Procedure Signature Alignment

Update `tests/integration_test.sql` to match the actual variable names in your stored procedures:

- Ensure `e_CourseID` matches the variable, not `p_courseid`.
- Remove the `OUT` parameter from the `CALL` statement if the procedure doesn't explicitly define it as `INOUT` or `OUT`.

### 4. Security Hardening

- **Unique Passwords:** Assign unique hashes for `Instructor` and `Student` roles.
- **Schema Privacy:**
  ```sql
  REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
  GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO Instructor;
  ```

### 5. Update Documentation

Synchronize the `README.md` with the actual file structure:

- `procs/crud/` -> (dept, people, exam)
- `procs/logic/` -> (generate, correct, submit)
