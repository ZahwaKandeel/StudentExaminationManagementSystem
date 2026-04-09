--exam Table CRUD Procedures:

--============================================================
--procedure Name: insertExam
--Description: Adds new exams
--Parameters:
--		i_examname : exam name
--		i_courseid : course id
--		i_totalquestions : number of exam questions
--===========================================================

CREATE OR REPLACE PROCEDURE insertExam(i_examname TEXT,i_courseid INT,i_totalquestions INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF i_totalquestions <= 0 THEN
    RAISE EXCEPTION 'Total questions must be greater than 0';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM course WHERE courseid = i_courseid) THEN
        RAISE EXCEPTION 'Course with id % does not exist', i_courseid;
    END IF;
	
    INSERT INTO exam (examname, courseid, totalquestions)
    VALUES (i_examname, i_courseid, i_totalquestions);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Exam already exists or violates uniqueness constraint';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Invalid course reference';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error inserting exam: %', SQLERRM;
END;
$$;


--============================================================
--procedure Name: updateExam
--Description: update existing exams
--Parameters:
--		i_examid : exam id
--		i_examname : exam name
--		i_courseid : course id
--		i_totalquestions : number of exam questions
--===========================================================

CREATE OR REPLACE PROCEDURE updateExam(i_examid INT,i_examname TEXT,i_courseid INT,i_totalquestions INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF i_totalquestions <= 0 THEN
        RAISE EXCEPTION 'Total questions must be greater than 0';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM exam WHERE examid = i_examid) THEN
        RAISE EXCEPTION 'Exam with id % does not exist', i_examid;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM course WHERE courseid = i_courseid) THEN
        RAISE EXCEPTION 'Course with id % does not exist', i_courseid;
    END IF;

    UPDATE exam
    SET examname = i_examname, courseid = i_courseid, totalquestions = i_totalquestions
    WHERE examid = i_examid;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Invalid course reference';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error updating exam: %', SQLERRM;
END;
$$;


--====================================================
--procedure Name: delete_exam
--Description: Deletes existing exam
--Parameters:
--		i_examid : exam id
--=====================================================

CREATE OR REPLACE PROCEDURE delete_exam(i_examid INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM exam WHERE examid = i_examid) THEN
        RAISE EXCEPTION 'Exam with id % does not exist', i_examid;
    END IF;

    DELETE FROM exam WHERE examid = i_examid;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Cannot delete exam due to related records';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error deleting exam: %', SQLERRM;
END;
$$


--=================================================================
--procedure Name: getExamByID
--Description: Retrieve exams by id 
--Parameters:
--      ref: output parameter
--		p_examid : exam ID
-- call example : 
--			BEGIN;
--			CALL getExamByID(p_examid, 'mycursor');
--			FETCH ALL FROM mycursor;
--			COMMIT;
--=================================================================

CREATE OR REPLACE PROCEDURE getExamByID(IN p_examid INT, INOUT p_cursor REFCURSOR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM exam WHERE examid = p_examid) THEN
        RAISE EXCEPTION 'Exam with id % not found', p_examid;
    END IF;

    OPEN p_cursor FOR
    SELECT e.examid, e.examname, e.courseid, e.createddate, e.totalquestions
    FROM exam e
    WHERE e.examid = p_examid;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error fetching exam: %', SQLERRM;
END;
$$;

-- examquestion Table CRUD Procedures:


--============================================================
--procedure Name: insert_examquestion
--Description: Adds new exam questions
--Parameters:
--		e_examid : exam id
--		e_questionid : question id
--		e_orderno : order number
--===========================================================

CREATE OR REPLACE PROCEDURE insert_examquestion(e_examid INT,e_questionid INT,e_orderno INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF e_orderno <= 0 THEN
	RAISE EXCEPTION 'Order must be greater than 0';
        END IF;

	IF EXISTS (SELECT 1 FROM examquestion WHERE examid = e_examid AND questionid = e_questionid) THEN
	RAISE EXCEPTION 'ExamQuestion already exists';
	END IF;

    INSERT INTO examquestion (examid, questionid, orderno)
    VALUES (e_examid, e_questionid, e_orderno);

EXCEPTION
WHEN unique_violation THEN
    RAISE EXCEPTION 'Duplicate order number for this exam';
WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Invalid examid or questionid';
WHEN OTHERS THEN
    RAISE EXCEPTION '%', SQLERRM;
END;
$$;


--============================================================
--procedure Name: update_examquestion
--Description: update existing exam question
--Parameters:
--		e_examid : exam id
--		e_questionid : question id
--		e_orderno : order number
--===========================================================

CREATE OR REPLACE PROCEDURE update_examquestion(e_examid INT, e_questionid INT,e_orderno INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF e_orderno <= 0 THEN
    RAISE EXCEPTION 'Order must be greater than 0';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM examquestion WHERE examid = e_examid AND questionid = e_questionid) THEN
    RAISE EXCEPTION 'ExamQuestion not found';
    END IF;

    UPDATE examquestion SET orderno = e_orderno
    WHERE examid = e_examid AND questionid = e_questionid;

EXCEPTION
WHEN unique_violation THEN
    RAISE EXCEPTION 'Duplicate order number for this exam';
WHEN OTHERS THEN
    RAISE EXCEPTION '%', SQLERRM;
END;
$$;


--====================================================
--procedure Name: delete_examquestion
--Description: Deletes existing exam question
--Parameters:
--		e_examid : exam id
--		e_questionid : question id
--=====================================================

CREATE OR REPLACE PROCEDURE delete_examquestion(e_examid INT,e_questionid INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM examquestion WHERE examid = e_examid AND questionid = e_questionid) THEN
    RAISE EXCEPTION 'ExamQuestion not found';
    END IF;

    DELETE FROM examquestion WHERE examid = e_examid AND questionid = e_questionid;

EXCEPTION
WHEN OTHERS THEN
    RAISE EXCEPTION '%', SQLERRM;
END;
$$;


--=================================================================
--procedure Name: get_examquestion_by_id
--Description: Retrieve exam questions by id 
--Parameters:
--      ref: output parameter
--		e_examid : exam ID
--		e_questionid : question ID
-- call example : 
--			BEGIN;
--			CALL get_examquestion_by_id(e_examid,e_questionid , 'mycursor');
--			FETCH ALL FROM mycursor;
--			COMMIT;
--=================================================================

CREATE OR REPLACE PROCEDURE get_examquestion_by_id(e_examid INT,e_questionid INT,INOUT ref refcursor)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM examquestion WHERE examid = e_examid AND questionid = e_questionid) THEN
    RAISE EXCEPTION 'ExamQuestion not found';
    END IF;

    OPEN ref FOR
    SELECT eq.examid, eq.questionid, eq.orderno
    FROM examquestion eq
    WHERE eq.examid = e_examid AND eq.questionid = e_questionid;

EXCEPTION
WHEN OTHERS THEN
    RAISE EXCEPTION '%', SQLERRM;
END;
$$;
