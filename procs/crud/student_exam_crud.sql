--=========================================
--      StudentExam CRUD
--=========================================

--=========================================
--procedure Name: InsertStudentExam 
--Description: Adds new studentexam
--Parameters:
--		s_id : student id
--		ex_id : exam id
--		start_time : exam start time
--      end_time : exam end time
--=========================================

CREATE OR REPLACE PROCEDURE InsertStudentExam(s_id INT, ex_id INT, start_time TIMESTAMP , end_time TIMESTAMP DEFAULT NULL )
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO studentexam (studentid, examid, starttime, endtime) VALUES(s_id, ex_id, start_time, end_time);

    EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Student or Exam ID does not exist.';
    WHEN unique_violation THEN
        RAISE EXCEPTION 'This student is already assigned to this exam.';
    WHEN not_null_violation THEN
        RAISE EXCEPTION 'Start time cant be empty.';
    WHEN check_violation THEN
        RAISE EXCEPTION 'End time cant be less tna Start time'
END;
$$;


--=========================================
--procedure Name: UpdateStudentExam
--Description: Updates existing studentexam
--Parameters:
--		sx_id : studentexam id 
--		total_grade : student total grade in this exam

--=========================================

CREATE OR REPLACE PROCEDURE UpdateStudentExam(sx_id INT, t_grade INT DEFAULT 0)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM studentexam WHERE studentexamid = sx_id) THEN
        RAISE EXCEPTION 'studentexam with ID % not found.', sx_id;
    END IF;

    UPDATE studentexam
    SET
        totalgrade  = COALESCE(t_grade , totalgrade),
    WHERE studentexamid = sx_id;

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'A studentexam with email "%" already exists.', s_email;
    WHEN check_violation THEN
        RAISE EXCEPTION 'Total grade cant be less than 0'
END;
$$;

--=========================================
--function Name: select_StudentExam
--Description: Retrieve studentexam data according to sent params
--Parameters:
--      result: output parameter
--		sx_id : studentexam ID
--		s_id : student id
--		ex_id : exam id
--		total_grade : student total grade in this exam
-- call example : 
                --BEGIN;
                --CALL select_StudentExam('result');
                --FETCH ALL FROM result;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SelectStudentExam(INOUT result REFCURSOR, sx_id INT DEFAULT NULL, s_id INT DEFAULT NULL, ex_id INT DEFAULT NULL, t_grade INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
    SELECT * from studentexam WHERE
    (sx_id IS NULL OR studentexamid = sx_id) AND
    (s_id IS NULL OR studentid = s_id) AND
    (ex_id IS NULL OR examid = ex_id) AND
    (total_grade IS NULL OR totalgrade = total_grade) ;
END;
$$;


--=========================================
--      StudentAnswer CRUD
--=========================================

--=========================================
--procedure Name: InsertStudentAnswer
--Description: Adds new StudentAnswer
--Parameters:
--		sx_id : studentExam id
--		q_id : Question id
--	    ch_op_id : Chosen Option Id
--=========================================

CREATE OR REPLACE PROCEDURE InsertStudentAnswer(sx_id INT, q_id INT, ch_op_id INT )
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO studentanswer (studentexamid, questionid, chosenoptionid) VALUES(sx_id, q_id, ch_op_id);

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'This StudentExam is already assigned to this Question.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'StudentExam or Question or ChosenOption ID does not exist.';
END;
$$;



--=========================================
--function Name: SelectStudentAnswer
--Description: Retrieve StudentAnswer data according to sent params
--Parameters:
--      result: output parameter
--		sx_id : studentexam ID
--		sa_id : student Answer id
-- call example : 
                --BEGIN;
                --CALL SelectStudentAnswer('result');
                --FETCH ALL FROM result;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SelectStudentAnswer (INOUT result REFCURSOR, sa_id INT DEFAULT NULL, sx_id INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
    SELECT * from studentanswer WHERE
    (sa_id IS NULL OR studentanswerid = sa_id) AND
    (sx_id IS NULL OR studentexamid  = sx_id) AND
END;
$$;
