--=========================================
--procedure Name: Report_StudentsByDepartment
--Description: Returns students in a department with their track and branch
--Parameters:
--		d_DepartmentID : department id
--Call Example:
--		CALL Report_StudentsByDepartment(1);
--=========================================

CREATE OR REPLACE PROCEDURE Report_StudentsByDepartment(d_DepartmentID INT, INOUT ref REFCURSOR)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = d_DepartmentID) THEN
    RAISE EXCEPTION 'Department not found';
    END IF;
    
    OPEN ref FOR
    SELECT 
        s.StudentID,
        s.Name,
        s.Email,
        s.Phone,
        t.TrackName,
        d.DepartmentName AS BranchName
    FROM Student s
    JOIN Student_Track st ON s.StudentID = st.StudentID
    JOIN Track t ON st.TrackID = t.TrackID
    JOIN Department d ON t.DepartmentID = d.DepartmentID
    WHERE d.DepartmentID = d_DepartmentID
    ORDER BY s.StudentID;

END;
$$;
