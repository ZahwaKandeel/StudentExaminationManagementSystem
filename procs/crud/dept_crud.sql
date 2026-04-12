--Department Table CRUD Procedures:

--=========================================
--procedure Name: InsertDepartment
--Description: Adds new department
--Parameters:
--		d_DepartmentName : department name
--		d_Location : department location
--=========================================

CREATE OR REPLACE PROCEDURE InsertDepartment(d_DepartmentName TEXT,d_Location TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF d_DepartmentName IS NULL OR d_DepartmentName = '' THEN
    	RAISE EXCEPTION 'Department name cannot be empty';
	END IF;
	
	INSERT INTO Department(DepartmentName,Location)
	VALUES (d_DepartmentName,d_Location);
 END;
$$;


--=========================================
--procedure Name: UpdateDepartment
--Description: Updates existing department
--Parameters:
--		d_DepartmentID : department ID
--		d_DepartmentName : department name
--		d_Location : department location
--=========================================

CREATE OR REPLACE PROCEDURE UpdateDepartment(d_DepartmentID INT,d_DepartmentName TEXT,d_Location TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = d_DepartmentID) THEN
	RAISE EXCEPTION 'That department id does not exists';
	END IF;

	IF d_DepartmentName IS NULL OR d_DepartmentName = '' THEN
    	RAISE EXCEPTION 'Department name cannot be empty';
	END IF;
	
	UPDATE Department
	SET
		DepartmentName = d_DepartmentName,
		Location = d_Location
	WHERE DepartmentID = d_DepartmentID;
END;
$$;


--=========================================
--procedure Name: DeleteDepartmentByName
--Description: Deletes existing department
--Parameters:
--		d_DepartmentName : department name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteDepartmentByName(d_DepartmentName TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentName = d_DepartmentName) THEN
	RAISE EXCEPTION 'That department name does not exists';
	END IF;

	IF d_DepartmentName IS NULL OR d_DepartmentName = '' THEN
    	RAISE EXCEPTION 'Department name cannot be empty';
	END IF;
	
	DELETE FROM Department
	WHERE DepartmentName = d_DepartmentName;
END;
$$;


--====================================================
--procedure Name: SelectDepartmentByName
--Description: Retrieve departments by name 
--Parameters:
--      ref: output parameter
--		d_id : department ID
--		d_name : department name
--		d_location : department location
-- call example : 
                --BEGIN;
                --CALL SelectDepartmentByName('ref');
                --FETCH ALL FROM ref;
                --COMMIT;
--====================================================

CREATE OR REPLACE PROCEDURE SelectDepartmentByName(INOUT ref REFCURSOR, 
d_id INT DEFAULT NULL, d_name TEXT DEFAULT NULL,d_location TEXT DEFAULT NULL )
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentName = d_name) THEN
	RAISE EXCEPTION 'That department name does not exists';
	END IF;
	
	IF d_name IS NULL OR d_name = '' THEN
    	RAISE EXCEPTION 'Department name cannot be empty';
	END IF;
	
	OPEN ref FOR
	SELECT d.DepartmentID, d.DepartmentName, d.Location
	FROM Department d
	WHERE
		(d_id IS NULL OR DepartmentID = d_id) AND
		(d_name IS NULL OR DepartmentName ILIKE '%' || d_name || '%') AND
		(d_location IS NULL OR Location ILIKE '%' || d_location || '%');
END;
$$;

--==============================================================================================================================================


--Track Table CRUD Procedures:

--=========================================
--procedure Name: InsertTrack
--Description: Adds new track
--Parameters:
--		t_TrackName : track name
--		t_DepartmentID : department id
--=========================================

CREATE OR REPLACE PROCEDURE InsertTrack(t_TrackName TEXT,t_DepartmentID INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF t_TrackName IS NULL OR t_TrackName = '' THEN
    	RAISE EXCEPTION 'Track name cannot be empty';
	END IF;

	IF t_DepartmentID IS NULL THEN
	RAISE EXCEPTION 'Department ID is required';
	END IF;
	
    INSERT INTO Track (TrackName, DepartmentID)
    VALUES (t_TrackName, t_DepartmentID);
END;
$$;


--=========================================
--procedure Name: UpdateTrack
--Description: updates existing track name
--Parameters:
--		t_oldTrackName : old track name
--		t_newTrackName : updated track name
--		t_DepartmentID : department name
--=========================================

CREATE OR REPLACE PROCEDURE UpdateTrack(t_oldTrackName TEXT, t_newTrackName TEXT, t_DepartmentID INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF t_DepartmentID IS NULL THEN
    	RAISE EXCEPTION 'Department id required';
	END IF;

	IF t_oldTrackName IS NULL OR t_newTrackName IS NULL THEN
    	RAISE EXCEPTION 'Track name is required';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID= t_DepartmentID) THEN
	RAISE EXCEPTION 'That department id does not exists';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackName= t_oldTrackName) THEN
	RAISE EXCEPTION 'That track name does not exists';
	END IF;

	UPDATE Track
	SET TrackName = t_newTrackName, DepartmentID = t_DepartmentID
	WHERE TrackName = t_oldTrackName;
END;
$$;


--=========================================
--procedure Name: DeleteTrackByName
--Description: Deletes existing track
--Parameters:
--		t_TrackName : track name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteTrackByName(t_TrackName TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackName = t_TrackName) THEN
	RAISE EXCEPTION 'That track name does not exists';
	END IF;

	IF t_TrackName IS NULL OR t_TrackName = '' THEN
    	RAISE EXCEPTION 'Track name cannot be empty';
	END IF;

	DELETE FROM Track
	WHERE TrackName = t_TrackName;
END;
$$;


--==============================================================
--procedure Name: SelectTrackByDepartment
--Description: Retrieve tracks by department 
--Parameters:
--      ref: output parameter
--		t_TrackName : track name
-- call example : 
                --BEGIN;
                --CALL SelectTrackByDepartment('ref');
                --FETCH ALL FROM ref;
                --COMMIT;
--==============================================================

CREATE OR REPLACE PROCEDURE SelectTrackByDepartment(INOUT ref REFCURSOR, t_DepartmentName TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
	OPEN ref FOR
	SELECT t.TrackName, d.DepartmentName
	FROM Track t
	JOIN Department d ON d.DepartmentID = t.DepartmentID
	WHERE (t_DepartmentName IS NULL OR d.DepartmentName ILIKE '%' || t_DepartmentName || '%');
END;
$$;


--==============================================================================================================================================


--Course Table CRUD Procedures:

--=========================================
--procedure Name: InsertCourse
--Description: Adds new course
--Parameters:
--	c_CourseName : course name
--	c_MinDegree : minimum course degree
--	c_MaxDegree : maximum course degree
--=========================================

CREATE OR REPLACE PROCEDURE InsertCourse(c_CourseName TEXT,c_MinDegree INT,c_MaxDegree INT	)
LANGUAGE plpgsql
AS $$
BEGIN
	IF c_CourseName IS NULL OR c_CourseName = '' THEN
    	RAISE EXCEPTION 'Course name cannot be empty';
	END IF;
	
	IF c_MinDegree IS NULL THEN
    	RAISE EXCEPTION 'Minimum course degree cannot be empty';
	END IF;
	
	IF c_MaxDegree IS NULL THEN
    	RAISE EXCEPTION 'Maximum course degree cannot be empty';
	END IF;
	
	INSERT INTO Course(CourseName,MinDegree,MaxDegree)
	VALUES (c_CourseName,c_MinDegree,c_MaxDegree);

	EXCEPTION
	WHEN check_violation THEN
	RAISE EXCEPTION 'Minimum degree must be less than maximum degree';
END;
$$;


--=================================================================
--procedure Name: UpdateCourseDegrees
--Description: Updates existing course min or max degree
--Parameters:
--		c_CourseName : course name
--		c_MinDegree : course minimum degree
--		c_MaxDegree : course maximum degree
--==================================================================

CREATE OR REPLACE PROCEDURE UpdateCourseDegrees(c_CourseName TEXT,c_MinDegree INT,c_MaxDegree INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF c_CourseName IS NULL OR TRIM(c_CourseName) = '' THEN
    	RAISE EXCEPTION 'Course name cannot be empty';
    	END IF;

	IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseName = c_CourseName) THEN
	RAISE EXCEPTION 'Course "%" does not exist', c_CourseName;
    	END IF;
    	
	IF c_MinDegree IS NULL THEN
    	RAISE EXCEPTION 'Minimum course degree cannot be empty';
	END IF;
	
	IF c_MaxDegree IS NULL THEN
    	RAISE EXCEPTION 'Maximum course degree cannot be empty';
	END IF;
	
	UPDATE Course
	SET MinDegree = c_MinDegree, MaxDegree = c_MaxDegree
	WHERE CourseName = c_CourseName;

	EXCEPTION
	WHEN check_violation THEN
	RAISE EXCEPTION 'Minimum degree must be less than maximum degree';
END;
$$;


--=========================================
--procedure Name: DeleteCourseByName
--Description: Deletes existing course
--Parameters:
--		c_CourseName : course name
--=========================================

CREATE OR REPLACE PROCEDURE DeleteCourseByName(
	c_CourseName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
	IF c_CourseName IS NULL OR TRIM(c_CourseName) = '' THEN
    	RAISE EXCEPTION 'Course name cannot be empty';
    	END IF;
    	
	IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseName = c_CourseName) THEN
	RAISE EXCEPTION 'Course "%" does not exist', c_CourseName;
    	END IF;
    	
	DELETE FROM Course WHERE CourseName = c_CourseName;
END;
$$;


--=========================================
--procedure Name: SelectCourseByTrack
--Description: Returns course by track 
--Parameters:
--      ref: output parameter
--	t_TrackName : track name
-- call example : 
                --BEGIN;
                --CALL SelectCourseByTrack('ref');
                --FETCH ALL FROM ref;
                --COMMIT;
--=========================================

CREATE OR REPLACE PROCEDURE SelectCourseByTrack(t_TrackName TEXT, INOUT c_cursor REFCURSOR)
LANGUAGE plpgsql
AS $$
BEGIN
	IF t_TrackName IS NULL OR TRIM(t_TrackName) = '' THEN
    	RAISE EXCEPTION 'Track name cannot be empty';
    	END IF;

	IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackName = t_TrackName) THEN
	RAISE EXCEPTION 'Course "%" does not exist', t_TrackName;
    	END IF;
	
	OPEN c_cursor FOR
	SELECT c.CourseName, c.MinDegree, c.MaxDegree
	FROM Course c
	JOIN Track_Course tc ON tc.CourseID = c.CourseID
	JOIN Track t ON t.TrackID = tc.TrackID
	WHERE t_TrackName ILIKE t_TrackName;
END;
$$;


CREATE OR REPLACE PROCEDURE AssignCourseToTrack ( t_TrackId INT, c_CourseId INT )
LANGUAGE plpgsql
AS $$
BEGIN

	IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseId = c_CourseId) THEN
	RAISE EXCEPTION 'Course "%" does not exist', c_CourseId;
    	END IF;

	IF NOT EXISTS (SELECT 1 FROM Track WHERE TrackId = t_TrackId) THEN
	RAISE EXCEPTION 'Track "%" does not exist', t_TrackId;
    	END IF;

    INSERT INTO Track_Course VALUES (t_TrackId, c_CourseId);
	
    EXCEPTION 
    WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Track or Course ID does not exist.';
    WHEN unique_violation THEN
    RAISE EXCEPTION 'This Course is already assigned to this Track.';
END;
$$;
