-- =============================================================================
-- STUDENT
-- =============================================================================

--=========================================
--procedure Name: InsertStudent 
--Description: Adds new student
--Parameters:
--		s_name : student name
--		s_email : student email
--		s_phone : student phone
--=========================================

CREATE OR REPLACE PROCEDURE InsertStudent(s_name TEXT, s_email TEXT, s_phone TEXT DEFAULT NULL)
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
--procedure Name: UpdateStudent
--Description: Updates existing student
--Parameters:
--		s_id : student ID
--		s_name : student name
--		s_email : student email
--      s_phone: student phone
--=========================================

CREATE OR REPLACE PROCEDURE UpdateStudent(s_id INT, s_name TEXT DEFAULT NULL, s_email TEXT DEFAULT NULL, s_phone TEXT DEFAULT NULL)
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
--procedure Name: DeleteStudent
--Description: Deletes existing student
--Parameters:
--		s_id : student id
--=========================================

CREATE OR REPLACE PROCEDURE DeleteStudent(s_id INT)
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
--function Name: SelectStudent
--Description: Retrieve student data according to sent params
--Parameters:
--      result: output parameter
--		s_id : student ID
--		s_name : student name
--		s_email : student email
--      s_phone: student phone
-- call example : 
                --BEGIN;
                --CALL SelectStudent('result');
                --FETCH ALL FROM result;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SelectStudent(INOUT result REFCURSOR, s_id INT DEFAULT NULL, s_name TEXT DEFAULT NULL, s_email TEXT DEFAULT NULL, s_phone TEXT DEFAULT NULL)
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

--=========================================
--procedure Name: AssignStudentToTrack
--Description: assign student to track
--Parameters:
--		s_id : student id
--      t_id : track id
--=========================================

CREATE OR REPLACE PROCEDURE AssignStudentToTrack(s_id INT, t_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Student_Track VALUES (s_id, t_id);
    EXCEPTION 
    WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Student or Track ID does not exist.';
    WHEN unique_violation THEN
    RAISE EXCEPTION 'This student is already assigned to this track.';
END;
$$;

-- =============================================================================
-- INSTRUCTOR
-- =============================================================================

--=========================================
--procedure Name: InsertInstructor
--Description: Adds new instructor
--Parameters:
--		i_name : instructor name
--		i_email : instructor email
--		i_department : instructor department
--=========================================

CREATE OR REPLACE PROCEDURE InsertInstructor(i_name TEXT, i_email TEXT, i_department INT )
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
--procedure Name: UpdateInstructor
--Description: Updates existing instructor
--Parameters:
--		i_id : instructor ID
--		i_name : instructor name
--		i_email : instructor email
--      i_department: instructor department
--=========================================

CREATE OR REPLACE PROCEDURE UpdateInstructor(i_id INT, i_name TEXT DEFAULT NULL, i_email TEXT DEFAULT NULL, i_department INT DEFAULT NULL)
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
--procedure Name: DeleteInstructor
--Description: Deletes existing instructor
--Parameters:
--		i_id : instructor ID
--=========================================

CREATE OR REPLACE PROCEDURE DeleteInstructor(i_id INT)
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
--procedure Name: AssignInstructorToCourse
--Description: Deletes existing instructor
--Parameters:
--		i_id : instructor ID
--=========================================

CREATE OR REPLACE PROCEDURE AssignInstructorToCourse(i_id INT, c_id INT)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO Instructor_Course VALUES (i_id, c_id);
    EXCEPTION 
    WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Instructor or Course ID does not exist.';
    WHEN unique_violation THEN
    RAISE EXCEPTION 'This Instructor is already assigned to this Course.';
END;
$$;


--=========================================
--function Name: SelectInstructor
--Description: Retrieve instructor data according to sent params
--Parameters:
--      result: output parameter
--		i_id : instructor ID
--		i_name : instructor name
--		i_email : instructor email
--      i_department: instructor department
-- call example : 
                --BEGIN;
                --CALL SelectInstructor('result');
                --FETCH ALL FROM result;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SelectInstructor(INOUT result REFCURSOR, i_id INT DEFAULT NULL, i_name TEXT DEFAULT NULL, i_email TEXT DEFAULT NULL, i_department INT DEFAULT NULL)
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