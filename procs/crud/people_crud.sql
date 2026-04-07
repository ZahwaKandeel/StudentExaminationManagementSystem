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
    INSERT INTO Student_Track VALUES (s_id, t_id)
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

    INSERT INTO Instructor_Course VALUES (i_id, c_id)
    EXCEPTION 
    WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Instructor or Course ID does not exist.';
    WHEN unique_violation THEN
    RAISE EXCEPTION 'This Instructor is already assigned to this Course.';
END;
$$;
