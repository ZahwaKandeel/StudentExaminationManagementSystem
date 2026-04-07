-- =============================================================================
-- STUDENT
-- =============================================================================

--=========================================
--procedure Name: insert_student
--Description: Adds new student
--Parameters:
--		s_name : student name
--		s_email : student email
--		s_phone : student phone
--=========================================

CREATE OR REPLACE PROCEDURE insert_student(s_name TEXT, s_email TEXT, s_phone TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO student (Name, Email, Phone) VALUES(s_name, s_email, s_phone);

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'A student with email "%" already exists.', s_email;
    WHEN not_null_violation THEN
        RAISE EXCEPTION 'A required field is missing.';
END;
$$;

--=========================================
--procedure Name: update_student
--Description: Updates existing student
--Parameters:
--		s_id : student ID
--		s_name : student name
--		s_email : student email
--      s_phone: student phone
--=========================================

CREATE OR REPLACE PROCEDURE update_student(s_id INT, s_name TEXT DEFAULT NULL, s_email TEXT DEFAULT NULL, s_phone TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = s_id) THEN
        RAISE EXCEPTION 'Student with ID % not found.', s_id;
    END IF;

    UPDATE student
    SET
        Name  = COALESCE(NULLIF(TRIM(s_name),  ''), Name),
        Email = COALESCE(NULLIF(LOWER(TRIM(s_email)), ''), Email),
        Phone = COALESCE(NULLIF(LOWER(TRIM(s_phone)), ''), Phone)
    WHERE StudentID = s_id;

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'A student with email "%" already exists.', s_email;
END;
$$;

--=========================================
--procedure Name: delete_student
--Description: Deletes existing student
--Parameters:
--		s_id : student name
--=========================================

CREATE OR REPLACE PROCEDURE delete_student(s_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = s_id) THEN
        RAISE EXCEPTION 'Student with ID % not found.', s_id;
    END IF;

    DELETE FROM student where StudentID = s_id;
END;
$$;

--=========================================
--function Name: select_student
--Description: Returns student by student name
--Parameters:
--		p_DepartmentName : student name
-- call example : SELECT * FROM SelectDepartmentByName('departmentName');
--=========================================

CREATE OR REPLACE PROCEDURE select_student(INOUT result REFCURSOR, s_id INT DEFAULT NULL, s_name TEXT DEFAULT NULL, s_email TEXT DEFAULT NULL, s_phone TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
    SELECT * from student WHERE
    (s_id IS NULL OR StudentID = s_id) AND
    (s_name IS NULL OR Name ILIKE '%' || s_name || '%') AND
    (s_email IS NULL OR Email = s_email) AND
    (s_phone IS NULL OR Phone = s_phone) ;
END;
$$;


-- =============================================================================
-- INSTRUCTOR
-- =============================================================================

--=========================================
--procedure Name: insert_Instructor
--Description: Adds new instructor
--Parameters:
--		i_name : instructor name
--		i_email : instructor email
--		i_department : instructor department
--=========================================

CREATE OR REPLACE PROCEDURE insert_Instructor(i_name TEXT, i_email TEXT, i_department INT )
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO instructor (Name, Email, DepartmentNo) VALUES(i_name, i_email, i_department);
    
    EXCEPTION
    WHEN not_null_violation THEN
        RAISE EXCEPTION 'A required field is missing.';
    WHEN unique_violation THEN
        RAISE EXCEPTION 'An instructor with email "%" already exists.', i_email;
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Department with ID % does not exist.', i_department;
END;
$$;

--=========================================
--procedure Name: update_instructor
--Description: Updates existing instructor
--Parameters:
--		i_id : instructor ID
--		i_name : instructor name
--		i_email : instructor email
--      i_department: instructor department
--=========================================

CREATE OR REPLACE PROCEDURE update_instructor(i_id INT, i_name TEXT DEFAULT NULL, i_email TEXT DEFAULT NULL, i_department INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = i_id) THEN
        RAISE EXCEPTION 'Instructor with ID % not found.', i_id;
    END IF;

    UPDATE instructor
    SET
        Name  = COALESCE(NULLIF(TRIM(i_name),  ''), Name),
        Email = COALESCE(NULLIF(LOWER(TRIM(i_email)), ''), Email),
        DepartmentNo = COALESCE(i_department, DepartmentNo)
    WHERE InstructorID = i_id;

    EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'An instructor with email "%" already exists.', i_email;
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Department with ID % does not exist.', i_department;
END;
$$;

--=========================================
--procedure Name: delete_instructor
--Description: Deletes existing instructor
--Parameters:
--		i_id : instructor ID
--=========================================

CREATE OR REPLACE PROCEDURE delete_instructor(i_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE InstructorID = i_id) THEN
        RAISE EXCEPTION 'Instructor with ID % not found.', i_id;
    END IF;
    DELETE FROM instructor where InstructorID = i_id;
END;
$$;

--=========================================
--function Name: select_instructor
--Description: Retrieve instructor data according to sent params
--Parameters:
--      result: output parameter
--		i_id : instructor ID
--		i_name : instructor name
--		i_email : instructor email
--      i_department: instructor department
-- call example : 
                --BEGIN;
                --CALL select_instructor('result');
                --FETCH ALL FROM result;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE select_instructor(INOUT result REFCURSOR, i_id INT DEFAULT NULL, i_name TEXT DEFAULT NULL, i_email TEXT DEFAULT NULL, i_department INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN result FOR
    SELECT * from instructor WHERE
    (i_id IS NULL OR InstructorID = i_id) AND
    (i_name IS NULL OR Name ILIKE '%' || i_name || '%') AND
    (i_email IS NULL OR Email = i_email) AND
    (i_department IS NULL OR DepartmentNo = i_department) ;
END;
$$;
