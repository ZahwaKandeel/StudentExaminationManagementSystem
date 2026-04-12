-- =============================================================
-- File    : data/seed_reports.sql
-- Purpose : Master seed file — runs exams + submissions seeding,
--           then executes ALL 5 report procedures to verify they
--           return meaningful data
-- Run after: sample_data.sql + all procedures loaded
-- Usage   : psql -d exam_db -f data/seed_reports.sql
-- =============================================================

-- -------------------------------------------------------
-- STEP 1: Seed exams (GenerateExam calls)
-- -------------------------------------------------------
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '  STEP 1 — Generating exams...'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\i data/seed_exams.sql

-- -------------------------------------------------------
-- STEP 2: Seed student submissions (assign + submit + correct)
-- -------------------------------------------------------
\echo ''
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '  STEP 2 — Submitting student answers...'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\i data/seed_student_submissions.sql

-- ============================================================
-- STEP 3: Run all 5 reports to verify data
-- ============================================================
\echo ''
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '  STEP 3 — Running all reports...'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

-- -------------------------------------------------------
-- REPORT 1: Report_StudentsByDepartment
--   Needs: students enrolled in tracks linked to departments
-- -------------------------------------------------------
\echo ''
\echo '>>> REPORT 1 — Students by Department (Dept ID = 1: IT)'
\echo '---------------------------------------------------------'
BEGIN;
CALL Report_StudentsByDepartment(1, 'r1');
FETCH ALL FROM r1;
COMMIT;

\echo ''
\echo '>>> REPORT 1 — Students by Department (Dept ID = 2: CS)'
\echo '---------------------------------------------------------'
BEGIN;
CALL Report_StudentsByDepartment(2, 'r1b');
FETCH ALL FROM r1b;
COMMIT;

\echo ''
\echo '>>> REPORT 1 — Students by Department (Dept ID = 3: DS&AI)'
\echo '------------------------------------------------------------'
BEGIN;
CALL Report_StudentsByDepartment(3, 'r1c');
FETCH ALL FROM r1c;
COMMIT;

-- -------------------------------------------------------
-- REPORT 2: Report_StudentGrades
--   Needs: studentexam rows with totalgrade (corrected)
-- -------------------------------------------------------
\echo ''
\echo '>>> REPORT 2 — Student Grades (Student ID = 1: Ayman)'
\echo '-------------------------------------------------------'
BEGIN;
CALL Report_StudentGrades(1, 'r2');
FETCH ALL FROM r2;
COMMIT;

\echo ''
\echo '>>> REPORT 2 — Student Grades (Student ID = 2: Sarah)'
\echo '-------------------------------------------------------'
BEGIN;
CALL Report_StudentGrades(2, 'r2b');
FETCH ALL FROM r2b;
COMMIT;

\echo ''
\echo '>>> REPORT 2 — Student Grades (Student ID = 3: Omar)'
\echo '------------------------------------------------------'
BEGIN;
CALL Report_StudentGrades(3, 'r2c');
FETCH ALL FROM r2c;
COMMIT;

-- -------------------------------------------------------
-- REPORT 3: Report_InstructorCourses
--   Needs: instructor→course + track→course + student→track
-- -------------------------------------------------------
\echo ''
\echo '>>> REPORT 3 — Instructor Courses (Instructor ID = 1: Ahmed Hassan)'
\echo '--------------------------------------------------------------------'
BEGIN;
CALL Report_InstructorCourses(1, 'r3');
FETCH ALL FROM r3;
COMMIT;

\echo ''
\echo '>>> REPORT 3 — Instructor Courses (Instructor ID = 2: Nour El-Din)'
\echo '-------------------------------------------------------------------'
BEGIN;
CALL Report_InstructorCourses(2, 'r3b');
FETCH ALL FROM r3b;
COMMIT;

\echo ''
\echo '>>> REPORT 3 — Instructor Courses (Instructor ID = 3: Sara Mohamed)'
\echo '--------------------------------------------------------------------'
BEGIN;
CALL Report_InstructorCourses(3, 'r3c');
FETCH ALL FROM r3c;
COMMIT;

-- -------------------------------------------------------
-- REPORT 4: Report_ExamQuestions
--   Needs: exam + examquestion + choice + modelanswer
-- -------------------------------------------------------
\echo ''
\echo '>>> REPORT 4 — Exam Questions (Exam ID = 1: DB Design Midterm)'
\echo '---------------------------------------------------------------'
BEGIN;
CALL Report_ExamQuestions(1, 'r4');
FETCH ALL FROM r4;
COMMIT;

\echo ''
\echo '>>> REPORT 4 — Exam Questions (Exam ID = 2: Python Final Exam)'
\echo '---------------------------------------------------------------'
BEGIN;
CALL Report_ExamQuestions(2, 'r4b');
FETCH ALL FROM r4b;
COMMIT;

-- -------------------------------------------------------
-- REPORT 5: Report_StudentExamAnswers
--   Needs: corrected student exam with answers
-- -------------------------------------------------------
\echo ''
\echo '>>> REPORT 5 — Student Exam Answers (Student 1, Exam 1)'
\echo '--------------------------------------------------------'
BEGIN;
CALL Report_StudentExamAnswers(1, 1, 'r5');
FETCH ALL FROM r5;
COMMIT;

\echo ''
\echo '>>> REPORT 5 — Student Exam Answers (Student 1, Exam 2 — mixed results)'
\echo '------------------------------------------------------------------------'
BEGIN;
CALL Report_StudentExamAnswers(2, 1, 'r5b');
FETCH ALL FROM r5b;
COMMIT;

\echo ''
\echo '>>> REPORT 5 — Student Exam Answers (Student 2, Exam 1 — partial submission)'
\echo '-----------------------------------------------------------------------------'
BEGIN;
CALL Report_StudentExamAnswers(1, 2, 'r5c');
FETCH ALL FROM r5c;
COMMIT;

-- ============================================================
-- FINAL SUMMARY
-- ============================================================
\echo ''
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '  SUMMARY — Data overview'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 'Exams'                     AS entity, COUNT(*) AS count FROM exam
UNION ALL
SELECT 'Exam Questions',                    COUNT(*) FROM examquestion
UNION ALL
SELECT 'Student Exam Sessions',             COUNT(*) FROM studentexam
UNION ALL
SELECT 'Student Answers',                   COUNT(*) FROM studentanswer
UNION ALL
SELECT 'Student-Track Assignments',         COUNT(*) FROM student_track
UNION ALL
SELECT 'Instructor-Course Assignments',     COUNT(*) FROM instructor_course;

\echo ''
\echo '✅ All seeds and reports executed successfully.'
