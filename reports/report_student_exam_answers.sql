-- =============================================================
-- File    : reports/rpt_student_exam_answers.sql
-- Purpose : Show a student's answers for one exam attempt
--           Does NOT reveal the correct answer — only IsCorrect
-- REQ     : REQ-14 optional — Report_StudentExamAnswers
-- NFR     : NFR-05 — model answers hidden from student role
-- Returns :
--   orderno, questiontext, questiontype,
--   chosenanswer, iscorrect, pointsearned, maxpoints
-- =============================================================

CREATE OR REPLACE PROCEDURE Report_StudentExamAnswers(
    p_examid    INT,
    p_studentid INT, into result REFCURSOR
)

LANGUAGE plpgsql
AS $$
DECLARE
    v_studentexamid INT;
BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM exam WHERE examid = p_examid
    ) THEN
        RAISE EXCEPTION 'Exam with ID % does not exist.', p_examid;
    END IF;

    
    IF NOT EXISTS (
        SELECT 1 FROM student WHERE studentid = p_studentid
    ) THEN
        RAISE EXCEPTION 'Student with ID % does not exist.', p_studentid;
    END IF;

   
    SELECT studentexamid INTO v_studentexamid
    FROM studentexam
    WHERE examid    = p_examid
      AND studentid = p_studentid;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Student % has no submission record for exam %.
             They may not have taken this exam yet.',
            p_studentid, p_examid;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM studentexam
        WHERE studentexamid = v_studentexamid
          AND totalgrade IS NOT NULL
    ) THEN
        RAISE EXCEPTION
            'Exam has not been corrected yet for student %.
             Run CorrectExam first before viewing results.',
            p_studentid;
    END IF;

    RETURN QUERY
    SELECT
       
        eq.orderno::INT,

        
        q.questiontext::TEXT,

        
        q.type::TEXT                        AS questiontype,

        COALESCE(c.optiontext, 'Not answered')::TEXT AS chosenanswer,

        CASE
            WHEN sa.chosenoptionid IS NULL          THEN NULL
            WHEN sa.chosenoptionid = ma.correctoptionid THEN TRUE
            ELSE FALSE
        END                                 AS iscorrect,

        CASE
            WHEN sa.chosenoptionid = ma.correctoptionid THEN q.points
            ELSE 0
        END::INT                            AS pointsearned,

       
        q.points::INT                       AS maxpoints

    FROM examquestion eq

    JOIN question q
        ON eq.questionid = q.questionid

    JOIN modelanswer ma
        ON q.questionid = ma.questionid

    LEFT JOIN studentanswer sa
        ON sa.questionid    = q.questionid
       AND sa.studentexamid = v_studentexamid

    LEFT JOIN choice c
        ON sa.chosenoptionid = c.optionid

    WHERE eq.examid = p_examid

    ORDER BY eq.orderno;

END;
$$;

