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




