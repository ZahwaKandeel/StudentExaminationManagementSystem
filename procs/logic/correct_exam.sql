--======================================================================================
--procedure Name: CorrectExam
--Description: Calculates exam grade by comparing student answers with model answers
--Parameters:
--		e_StudentExamID : student exam id
--Call Example:
--		CALL CorrectExam(1);
--======================================================================================

CREATE OR REPLACE PROCEDURE CorrectExam(e_StudentExamID INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_grade INT;
BEGIN
    IF NOT EXISTS ( SELECT 1 FROM studentexam WHERE studentexamid = e_StudentExamID) THEN
    RAISE EXCEPTION 'StudentExam with ID % does not exist', e_StudentExamID;
    END IF;

    SELECT COUNT(*) INTO v_total_grade
    FROM studentanswer sa
    JOIN modelanswer ma
        ON sa.questionid = ma.questionid
    WHERE sa.studentexamid = e_StudentExamID
    AND sa.chosenoptionid = ma.correctoptionid;

    UPDATE studentexam
    SET totalgrade = v_total_grade
    WHERE studentexamid = e_StudentExamID;

EXCEPTION
WHEN OTHERS THEN
    RAISE;
END;
$$;
