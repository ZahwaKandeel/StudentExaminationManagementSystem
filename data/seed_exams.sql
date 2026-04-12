-- =============================================================
-- File    : data/seed_exams.sql
-- Purpose : Generate exams for existing courses using GenerateExam
--           Creates exam + examquestion rows for report testing
-- Run after: sample_data.sql (needs questions + courses populated)
-- Usage   : psql -d exam_db -f data/seed_exams.sql
-- =============================================================

DO $$
DECLARE
    v_course_db   INT;
    v_course_py   INT;
    v_course_web  INT;
    v_course_dsa  INT;
    v_course_net  INT;
    v_examid1     INT;
    v_examid2     INT;
    v_examid3     INT;
    v_examid4     INT;
    v_examid5     INT;
BEGIN

    -- Resolve course IDs by name
    SELECT courseid INTO v_course_db  FROM course WHERE coursename = 'Database Design & SQL';
    SELECT courseid INTO v_course_py  FROM course WHERE coursename = 'Python Programming';
    SELECT courseid INTO v_course_web FROM course WHERE coursename = 'Web Technologies (HTML/CSS)';
    SELECT courseid INTO v_course_dsa FROM course WHERE coursename = 'Data Structures & Algorithms';
    SELECT courseid INTO v_course_net FROM course WHERE coursename = 'Network Fundamentals';

    -- -------------------------------------------------------
    -- Exam 1: DB Design & SQL — Midterm (3 MCQ + 2 TF = 5 Qs)
    -- -------------------------------------------------------
    CALL GenerateExam(v_course_db, 'DB Design Midterm', 3, 2, v_examid1);
    RAISE NOTICE 'Created exam: DB Design Midterm (ID: %)', v_examid1;

    -- -------------------------------------------------------
    -- Exam 2: Python Programming — Final (4 MCQ + 2 TF = 6 Qs)
    -- -------------------------------------------------------
    CALL GenerateExam(v_course_py, 'Python Final Exam', 4, 2, v_examid2);
    RAISE NOTICE 'Created exam: Python Final Exam (ID: %)', v_examid2;

    -- -------------------------------------------------------
    -- Exam 3: Web Technologies — Midterm (3 MCQ + 2 TF = 5 Qs)
    -- -------------------------------------------------------
    CALL GenerateExam(v_course_web, 'Web Tech Midterm', 3, 2, v_examid3);
    RAISE NOTICE 'Created exam: Web Tech Midterm (ID: %)', v_examid3;

    -- -------------------------------------------------------
    -- Exam 4: Data Structures — Final (3 MCQ + 2 TF = 5 Qs)
    -- -------------------------------------------------------
    CALL GenerateExam(v_course_dsa, 'DSA Final Exam', 3, 2, v_examid4);
    RAISE NOTICE 'Created exam: DSA Final Exam (ID: %)', v_examid4;

    -- -------------------------------------------------------
    -- Exam 5: Network Fundamentals — Midterm (2 MCQ + 2 TF = 4 Qs)
    -- -------------------------------------------------------
    CALL GenerateExam(v_course_net, 'Network Midterm', 2, 2, v_examid5);
    RAISE NOTICE 'Created exam: Network Midterm (ID: %)', v_examid5;

END;
$$;

-- -------------------------------------------------------
-- Verify exams were created
-- -------------------------------------------------------
SELECT e.examid, e.examname, c.coursename, e.totalquestions, e.createddate
FROM exam e
JOIN course c ON e.courseid = c.courseid
ORDER BY e.examid;

-- -------------------------------------------------------
-- Verify exam questions
-- -------------------------------------------------------
SELECT eq.examid, e.examname, q.questionid, q.type, q.points, eq.orderno
FROM examquestion eq
JOIN exam e ON eq.examid = e.examid
JOIN question q ON eq.questionid = q.questionid
ORDER BY eq.examid, eq.orderno;
