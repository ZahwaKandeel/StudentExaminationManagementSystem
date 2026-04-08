-- CREATE ROLE admin/instructor/student
--GRANT EXECUTE on procedures
--REVOKE direct table access

--set database name as university for now


--=====================================
--  Admin role
--=====================================

CREATE ROLE adminUser WITH LOGIN PASSWORD 'Admin1234' LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin_user;


--====================================
--  Instructor role
--====================================
CREATE ROLE Instructor WITH LOGIN PASSWORD 'Student1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE university TO Instructor;
GRANT USAGE ON SCHEMA public TO Instructor;

-- give the user the access to the procedures available for him

--sGenerate exams, manage questions/topics Read/Write on relevant tables via procedures
GRANT EXECUTE ON PROCEDURE -procedure name- TO Instructor

--=====================================
--  Student role
--=====================================
CREATE ROLE Student WITH LOGIN PASSWORD 'Student1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE university TO Student;
GRANT USAGE ON SCHEMA public TO Student;

-- give the user the access to the procedures available for him

--student can 1-use take exam procedure 2- use view results procedure 

GRANT EXECUTE ON PROCEDURE -procedure name- TO Student
