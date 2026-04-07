--Department Table CRUD Procedures:

--=========================================
--procedure Name: InsertDepartment
--Description: Adds new department
--Parameters:
--		p_DepartmentName : department name
--		p_Location : department location
--=========================================

CREATE OR REPLACE PROCEDURE InsertDepartment(
	p_DepartmentName TEXT,
	p_Location TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO Department(DepartmentName,Location)
	VALUES (p_DepartmentName,p_Location);
END;
$$;


--=========================================
--procedure Name: UpdateDepartment
--Description: Updates existing department
--Parameters:
--		p_DepartmentID : department ID
--		p_DepartmentName : department name
--		p_Location : department location
--=========================================

CREATE OR REPLACE PROCEDURE UpdateDepartment(
	p_DepartmentID INT,
	p_DepartmentName TEXT,
	p_Location TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE Department
	SET
		DepartmentName = p_DepartmentName,
		Location = p_Location
	WHERE DepartmentID = p_DepartmentID;
END;
$$;


--=========================================
--procedure Name: DeleteDepartmentByName
--Description: Deletes existing department
--Parameters:
--		p_DepartmentName : department name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteDepartmentByName(
	p_DepartmentName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM Department
	WHERE DepartmentName = p_DepartmentName;
END;
$$;


--=========================================
--function Name: SelectDepartmentByName
--Description: Returns department by department name
--Parameters:
--		p_DepartmentName : department name
-- call example : SELECT * FROM SelectDepartmentByName('departmentName');
--=========================================

CREATE OR REPLACE FUNCTION SelectDepartmentByName(
	p_DepartmentName TEXT
)
RETURNS TABLE (
    DepartmentID INT,
    DepartmentName TEXT,
    Location TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT d.DepartmentID, d.DepartmentName, d.Location
	FROM Department d
	WHERE d.DepartmentName = p_DepartmentName;
END;
$$;


--=========================================
--function Name: SelectAllDepartments
--Description: Returns all departments
-- call example : SELECT * FROM SelectAllDepartments()
--=========================================

CREATE OR REPLACE FUNCTION SelectAllDepartments()
RETURNS TABLE (
    DepartmentID INT,
    DepartmentName TEXT,
    Location TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT d.DepartmentID, d.DepartmentName, d.Location
	FROM Department d;
END;
$$;

--================================================================================================================================================


--Track Table CRUD Procedures:

--=========================================
--procedure Name: InsertTrack
--Description: Adds new track
--Parameters:
--		p_TrackName : track name
--		p_DepartmentName : department name
--=========================================

CREATE OR REPLACE PROCEDURE InsertTrack(
    p_TrackName TEXT,
    p_DepartmentName TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_DepartmentID INT;
BEGIN
    SELECT DepartmentID
    INTO v_DepartmentID
    FROM Department
    WHERE DepartmentName = p_DepartmentName;

    INSERT INTO Track (TrackName, DepartmentID)
    VALUES (p_TrackName, v_DepartmentID);
END;
$$;


--=========================================
--procedure Name: UpdateTrack
--Description: updates existing track name
--Parameters:
--		p_oldTrackName : old track name
--		p_newTrackName : updated track name
--		p_DepartmentName : department name
--=========================================

CREATE OR REPLACE PROCEDURE UpdateTrack(
	p_oldTrackName TEXT,
	p_newTrackName TEXT,
	p_DepartmentName TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_DepartmentID INT;
BEGIN
    SELECT DepartmentID
    INTO v_DepartmentID
    FROM Department
    WHERE DepartmentName = p_DepartmentName;

	IF v_DepartmentID IS NULL THEN
    	RAISE EXCEPTION 'Department not found';
	END IF;

	UPDATE Track
	SET
		TrackName = p_newTrackName,
		DepartmentID = v_DepartmentID
	WHERE TrackName = p_oldTrackName;
END;
$$;


--=========================================
--procedure Name: DeleteTrackByName
--Description: Deletes existing track
--Parameters:
--		p_TrackName : track name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteTrackByName(
	p_TrackName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM Track
	WHERE TrackName = p_TrackName;
END;
$$;


--=========================================
--function Name: SelectTrackByName
--Description: Returns track by track name
--Parameters:
--		TrackName : track name
--		DepartmentName : department name
-- call example : SELECT * FROM SelectTrackByName('trackName');
--=========================================

CREATE OR REPLACE FUNCTION SelectTrackByName(
	p_TrackName TEXT
)
RETURNS TABLE (
    TrackName TEXT,
    DepartmentName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT t.TrackName, d.DepartmentName
	FROM Track t
	JOIN Department d ON d.DepartmentID = t.DepartmentID
	WHERE t.TrackName = p_TrackName;
END;
$$;


--=========================================
--function Name: SelectAllTracks
--Description: Returns all tracks
-- call example : SELECT * FROM SelectAllTracks()
--=========================================

CREATE OR REPLACE FUNCTION SelectAllTracks()
RETURNS TABLE (
    TrackName TEXT,
    DepartmentName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.TrackName, d.DepartmentName
    FROM Track t
    JOIN Department d ON d.DepartmentID = t.DepartmentID;
END;
$$;

--==============================================================================================================================================


--Course Table CRUD Procedures:

--=========================================
--procedure Name: InsertCourse
--Description: Adds new course
--Parameters:
--	p_CourseName : course name
--	p_MinDegree : minimum course degree
--	p_MaxDegree : maximum course degree
--=========================================

CREATE OR REPLACE PROCEDURE InsertCourse(
	p_CourseName TEXT,
	p_MinDegree INT,
	p_MaxDegree INT
	
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO Course(CourseName,MinDegree,MaxDegree)
	VALUES (p_CourseName,p_MinDegree,p_MaxDegree);
END;
$$;


--=========================================
--procedure Name: UpdateCourseDegrees
--Description: Updates existing course
--Parameters:
--		p_CourseName : course name
--		p_MinDegree : course minimum degree
--		p_MaxDegree : course maximum degree
--=========================================

CREATE OR REPLACE PROCEDURE UpdateCourseDegrees(
	p_CourseName TEXT,
	p_MinDegree INT,
	p_MaxDegree INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE Course
	SET
		MinDegree = p_MinDegree,
		MaxDegree = p_MaxDegree
	WHERE CourseName = p_CourseName;
END;
$$;


--=========================================
--procedure Name: DeleteCourseByName
--Description: Deletes existing course
--Parameters:
--		p_CourseName : course name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteCourseByName(
	p_CourseName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM Course
	WHERE CourseName = p_CourseName;
END;
$$;


--=========================================
--function Name: SelectCourseByName
--Description: Returns course by track course
--Parameters:
--		p_CourseName : course name
-- call example : SELECT * FROM SelectCourseByName('course name');
--=========================================

CREATE OR REPLACE FUNCTION SelectCourseByName(
	p_CourseName TEXT
)
RETURNS TABLE (
    CourseName TEXT,
	MinDegree INT,
	MaxDegree INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT c.CourseName, c.MinDegree, c.MaxDegree
	FROM Course c
	WHERE c.CourseName = p_CourseName;
END;
$$;


--=========================================
--function Name: SelectAllCourses
--Description: Returns all courses
-- call example : SELECT * FROM SelectAllCourses()
--=========================================

CREATE OR REPLACE FUNCTION SelectAllCourses()
RETURNS TABLE (
    CourseName TEXT,
	MinDegree INT,
	MaxDegree INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  c.CourseName, c.MinDegree, c.MaxDegree
	FROM Course c;
END;
$$;

