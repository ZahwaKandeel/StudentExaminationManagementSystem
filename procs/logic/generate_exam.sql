--============================================================================
--procedure Name: GenerateExam
--Description: Creates a new exam and assigns random questions
--             Inserts exam using insertExam procedure
--             Selects random MCQ and TF questions without duplication
--             Inserts selected questions into examquestion with order
--Parameters:
--		e_CourseID : course id
--		e_ExamName : exam name
--		e_NumMCQ   : number of MCQ questions
--		e_NumTF    : number of True/False questions
--Call Example:
--		CALL GenerateExam(2, 'Final Exam', 2, 2);
--============================================================================


CREATE OR REPLACE PROCEDURE GenerateExam(e_CourseID INT, e_ExamName TEXT, e_NumMCQ INT, e_NumTF INT)
LANGUAGE plpgsql
AS $$
DECLARE     
	v_examid INT; v_total INT; v_available_mcq INT;
    v_available_tf INT; v_counter INT := 1; rec RECORD;
BEGIN
	v_total := e_NumMCQ + e_NumTF;
	
	IF v_total <= 0 THEN
	RAISE EXCEPTION 'You need at least 1 question';
	END IF;

	SELECT COUNT(*) INTO v_available_mcq
    FROM question
    WHERE courseid = e_CourseID AND type = 'MCQ';

    SELECT COUNT(*) INTO v_available_tf
    FROM question
    WHERE courseid = e_CourseID AND type = 'TF';

	IF v_available_mcq < e_nummcq OR v_available_tf < e_NumTF THEN
    RAISE EXCEPTION 'Not enough questions available';
    END IF;

	CALL insertExam(e_ExamName, e_CourseID, v_total);

	SELECT MAX(examid) INTO v_examid FROM exam;

	FOR rec IN 
	SELECT questionid FROM question
    WHERE courseid = e_CourseID AND type = 'MCQ'
    ORDER BY RANDOM() LIMIT e_NumMCQ
    LOOP
    CALL insert_examquestion(v_examid, rec.questionid, v_counter);
    v_counter := v_counter + 1;
    END LOOP;

    FOR rec IN 
	SELECT questionid FROM question
    WHERE courseid = e_CourseID AND type = 'TF'
    ORDER BY RANDOM() LIMIT e_NumTF
    LOOP
    CALL insert_examquestion(v_examid, rec.questionid, v_counter);
    v_counter := v_counter + 1;
    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    RAISE;
END;
$$;
