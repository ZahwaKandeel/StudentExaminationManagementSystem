--=========================================
--procedure Name: SubmitExamAnswers
--Description: Records student answers for an exam
--             Creates StudentExam record and inserts individual answers from JSONB
--Parameters:
--		s_id   : student id
--		ex_id      : exam id
--		start_time   : exam start time
--		end_time     : exam end time
--		answer     : JSONB array of {question_id, chosen_option_id}
--		Example: '[{"question_id": 1, "chosen_option_id": 3}, {"question_id": 2, "chosen_option_id": 7}]'::jsonb
--Returns:
--		StudentExamID : the newly created studentexam id
--Call Example:
--		BEGIN;
--		CALL SubmitExamAnswers(
--			1,
--			1,
--			'2026-04-08 10:00:00',
--			'2026-04-08 11:00:00',
--			'[{"question_id": 1, "chosen_option_id": 3}, {"question_id": 2, "chosen_option_id": 7}]'::jsonb,
--			'result'
--		);
--		FETCH ALL FROM result;
--		COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SubmitExamAnswers(s_id  INT,ex_id  INT,start_time  TIMESTAMPTZ,end_time  TIMESTAMPTZ,in_answer JSONB,OUT SX_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    QuestionID    INT;
    ChosenOptionID INT;
    Answer        JSONB;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentId = s_id) THEN
        RAISE EXCEPTION 'Student with ID % does not exist.', s_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamId = ex_id) THEN
        RAISE EXCEPTION 'Exam with ID % does not exist.', ex_id;
    END IF;

    IF  (end_time <= start_time) THEN
        RAISE EXCEPTION 'End time cant be lower than Start time';
    END IF;

    CALL InsertStudentExam(SX_id, s_id, ex_id, start_time ,end_time );

    -- Parse JSONB and insert each answer
    FOR Answer IN SELECT jsonb_array_elements(in_answer)
    LOOP
        QuestionID    := (Answer->>'question_id')::INT;
        ChosenOptionID := (Answer->>'chosen_option_id')::INT;

        -- Validate that the chosen option exists
        IF NOT EXISTS (SELECT 1 FROM choice WHERE optionid = ChosenOptionID) THEN
            RAISE EXCEPTION 'Chosen option with ID % does not exist.', ChosenOptionID;
        END IF;

        -- Validate that the chosen option belongs to the specified question
        IF NOT EXISTS (
            SELECT 1 FROM choice
            WHERE questionid = QuestionID AND optionid = ChosenOptionID
        ) THEN
            RAISE EXCEPTION 'Chosen option % does not belong to question %.', ChosenOptionID, QuestionID;
        END IF;

        CALL InsertStudentAnswer(SX_id, questionid, chosenoptionid );
    END LOOP;

END;
$$;