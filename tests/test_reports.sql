-- =============================================================
-- File    : test_reports.sql
-- Purpose : Test all mandatory and optional report stored procedures
-- Run after: all schema, procs, and seed data are loaded
-- =============================================================


-- =============================================================
-- SECTION 1 — Report_StudentsByDepartment
-- =============================================================

-- PASS: dept 1 (Information Technology) — expects students in Web Development and Network & Security tracks
BEGIN;
    CALL Report_StudentsByDepartment(1, 'cur_dept1');
    FETCH ALL IN cur_dept1;
COMMIT;

-- FAIL: dept 9999 does not exist — expects EXCEPTION: "Department not found"
BEGIN;
    CALL Report_StudentsByDepartment(9999, 'cur_dept_err');
    FETCH ALL IN cur_dept_err;
COMMIT;


-- =============================================================
-- SECTION 2 — Report_StudentGrades
-- =============================================================

-- PASS: student 1 (Ayman Mohamed) — expects grades for exams he sat with correct percentage
-- Prerequisite: CorrectExam() must have been run for this student
BEGIN;
    CALL Report_StudentGrades(1, 'cur_grades1');
    FETCH ALL IN cur_grades1;
COMMIT;

-- PASS: student 25 (Yasmine Galal) — has no submissions yet, expects empty result set, no exception
BEGIN;
    CALL Report_StudentGrades(25, 'cur_grades_empty');
    FETCH ALL IN cur_grades_empty;
COMMIT;

-- FAIL: student 9999 does not exist — expects EXCEPTION: "Student with ID 9999 does not exist."
BEGIN;
    CALL Report_StudentGrades(9999, 'cur_grades_err');
    FETCH ALL IN cur_grades_err;
COMMIT;


-- =============================================================
-- SECTION 3 — Report_InstructorCourses
-- =============================================================

-- PASS: instructor 1 (Ahmed Hassan) — teaches DB and Network Fundamentals
-- DB is in 4 tracks, Network Fundamentals in 1 track → expects 5 rows with StudentCount per track
BEGIN;
    CALL Report_InstructorCourses(1, 'cur_inst1');
    FETCH ALL IN cur_inst1;
COMMIT;

-- FAIL: instructor 9999 does not exist — expects EXCEPTION: "Instructor with ID 9999 does not exist."
BEGIN;
    CALL Report_InstructorCourses(9999, 'cur_inst_err1');
    FETCH ALL IN cur_inst_err1;
COMMIT;

-- FAIL: instructor 6 exists in no seed data — expects EXCEPTION: "Instructor with ID 6 does not exist."
BEGIN;
    CALL Report_InstructorCourses(6, 'cur_inst_err2');
    FETCH ALL IN cur_inst_err2;
COMMIT;


-- =============================================================
-- SECTION 4 — Report_ExamQuestions
-- =============================================================

-- PASS: exam 1 — expects questions ordered by question_order, MCQ has 4 choice rows each with
-- exactly one is_correct=TRUE, TF has 2 choice rows each with exactly one is_correct=TRUE
BEGIN;
    CALL Report_ExamQuestions(1, 'cur_examq1');
    FETCH ALL IN cur_examq1;
COMMIT;

-- PASS: is_correct integrity check for exam 1 — expects 0 rows (every question has exactly one correct flag)
SELECT question_id, COUNT(*) FILTER (WHERE is_correct) AS correct_count
FROM (
    SELECT eq.questionid AS question_id,
           (c.optionid = ma.correctoptionid) AS is_correct
    FROM examquestion eq
    JOIN question        q  ON q.questionid  = eq.questionid
    JOIN choice          c  ON c.questionid  = q.questionid
    LEFT JOIN modelanswer ma ON ma.questionid = q.questionid
    WHERE eq.examid = 1
) sub
GROUP BY question_id
HAVING COUNT(*) FILTER (WHERE is_correct) <> 1;

-- FAIL: exam 9999 does not exist — expects EXCEPTION: "Exam with ID 9999 does not exist."
BEGIN;
    CALL Report_ExamQuestions(9999, 'cur_examq_err');
    FETCH ALL IN cur_examq_err;
COMMIT;


-- =============================================================
-- SECTION 5 — Report_StudentExamAnswers
-- =============================================================

-- PASS: student 1 (Ayman Mohamed) answered all questions in exam 1
-- Expects: one row per question, chosenanswer populated, iscorrect TRUE or FALSE
-- NFR-05: confirm output has no CorrectOptionID column — only iscorrect boolean is present
-- Prerequisite: SubmitExamAnswers + CorrectExam already run for (examid=1, studentid=1)
BEGIN;
    CALL Report_StudentExamAnswers(1, 1, 'cur_ans1');
    FETCH ALL IN cur_ans1;
COMMIT;

-- PASS: student 2 (Sarah Ahmed) skipped some questions in exam 1
-- Expects: skipped rows show chosenanswer='Not answered', iscorrect=NULL, pointsearned=0
BEGIN;
    CALL Report_StudentExamAnswers(1, 2, 'cur_ans2');
    FETCH ALL IN cur_ans2;
COMMIT;

-- FAIL: student 25 (Yasmine Galal) never took exam 1
-- Expects EXCEPTION: "Student 25 has no submission record for exam 1."
BEGIN;
    CALL Report_StudentExamAnswers(1, 25, 'cur_ans_err1');
    FETCH ALL IN cur_ans_err1;
COMMIT;

-- FAIL: student 4 (Laila Mahmoud) submitted but CorrectExam not yet run (TotalGrade is NULL)
-- Expects EXCEPTION: "Exam has not been corrected yet for student 4. Run CorrectExam first."
BEGIN;
    CALL Report_StudentExamAnswers(1, 4, 'cur_ans_err2');
    FETCH ALL IN cur_ans_err2;
COMMIT;

-- FAIL: exam 9999 does not exist — expects EXCEPTION: "Exam with ID 9999 does not exist."
BEGIN;
    CALL Report_StudentExamAnswers(9999, 1, 'cur_ans_err3');
    FETCH ALL IN cur_ans_err3;
COMMIT;

-- FAIL: student 9999 does not exist — expects EXCEPTION: "Student with ID 9999 does not exist."
BEGIN;
    CALL Report_StudentExamAnswers(1, 9999, 'cur_ans_err4');
    FETCH ALL IN cur_ans_err4;
COMMIT;


-- =============================================================
-- SECTION 6 — End-to-end integration test
-- Full lifecycle for student 1 (Ayman Mohamed) in exam 1
-- Run each block in order to confirm consistent data across all reports
-- =============================================================

-- Step 1: Ayman appears in dept 1 report under Web Development track
BEGIN;
    CALL Report_StudentsByDepartment(1, 'e2e_cur1');
    FETCH ALL IN e2e_cur1;
COMMIT;

-- Step 2: Ayman's grade for exam 1 appears with correct percentage
BEGIN;
    CALL Report_StudentGrades(1, 'e2e_cur2');
    FETCH ALL IN e2e_cur2;
COMMIT;

-- Step 3: Ahmed Hassan (instructor 1) sees exam 1 course with correct StudentCount
BEGIN;
    CALL Report_InstructorCourses(1, 'e2e_cur3');
    FETCH ALL IN e2e_cur3;
COMMIT;

-- Step 4: Exam 1 question list is complete, ordered correctly, one correct flag per question
BEGIN;
    CALL Report_ExamQuestions(1, 'e2e_cur4');
    FETCH ALL IN e2e_cur4;
COMMIT;

-- Step 5: Ayman's answers for exam 1 are accurate and CorrectOptionID is hidden
BEGIN;
    CALL Report_StudentExamAnswers(1, 1, 'e2e_cur5');
    FETCH ALL IN e2e_cur5;
COMMIT;