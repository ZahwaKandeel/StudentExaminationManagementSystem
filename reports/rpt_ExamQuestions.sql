-- ============================================================
-- PROCEDURE : Report_ExamQuestions
-- PURPOSE   : Returns all questions and their choices for a
--             given exam. One row per choice (question info
--             repeats across its choices). The correct choice
--             is flagged with is_correct = TRUE.
-- PARAMETERS: p_examid INT  – the target exam ID
-- RETURNS   : Result set via RETURN QUERY
-- ============================================================

CREATE OR REPLACE FUNCTION Report_ExamQuestions(p_examid INT)
RETURNS TABLE (
    exam_id          INT,
    exam_name        TEXT,
    question_order   INT,
    question_id      INT,
    question_text    TEXT,
    question_type    TEXT,
    question_points  INT,
    option_id        INT,
    option_order     INT,
    option_text      TEXT,
    is_correct       BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

	IF NOT EXISTS (SELECT 1 FROM exam WHERE examid = p_examid) THEN
	RAISE EXCEPTION 'Exam with ID % does not exist.', p_examid;
	END IF;

    RETURN QUERY
    SELECT
        e.examid                            AS exam_id,
        e.examname                          AS exam_name,
        eq.orderno                          AS question_order,
        q.questionid                        AS question_id,
        q.questiontext                      AS question_text,
        q.type                              AS question_type,
        q.points                            AS question_points,
        c.optionid                          AS option_id,
        c.optionorder                       AS option_order,
        c.optiontext                        AS option_text,
        (c.optionid = ma.correctoptionid)   AS is_correct
    FROM exam e
    JOIN examquestion  eq  ON eq.examid    = e.examid
    JOIN question      q   ON q.questionid = eq.questionid
    JOIN choice        c   ON c.questionid = q.questionid
    LEFT JOIN modelanswer ma ON ma.questionid = q.questionid
    WHERE e.examid = p_examid
    ORDER BY
        eq.orderno   ASC,   
        c.optionorder ASC;  
END;
$$;
