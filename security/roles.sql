-- CREATE ROLE admin/instructor/student
--GRANT EXECUTE on procedures
--REVOKE direct table access

--set database name as university for now


--=================================================================================

--  Admin role
--=================================================================================


CREATE ROLE adminUser WITH LOGIN PASSWORD 'Admin1234' LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin_user;


--=================================================================================
--  Instructor role
--=================================================================================
CREATE ROLE Instructor WITH LOGIN PASSWORD 'Student1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE university TO Instructor;
GRANT USAGE ON SCHEMA public TO Instructor;

--=====================================================
-- Grant the ability to generate exams
--=====================================================
GRANT EXECUTE ON PROCEDURE -procedure name- TO Instructor

--====================================================
--  Grant all the available procedures on the question table
--====================================================
GRANT EXECUTE ON PROCEDURE InsertQuestion TO Instructor
GRANT EXECUTE ON PROCEDURE UpdateQuestion TO Instructor
GRANT EXECUTE ON PROCEDURE DeleteQuestion TO Instructor
GRANT EXECUTE ON PROCEDURE SelectQuestionsByCourse TO Instructor

--====================================================
--  Grant all the available procedures on the choice table
--====================================================
GRANT EXECUTE ON PROCEDURE InsertOption TO Instructor
GRANT EXECUTE ON PROCEDURE UpdateOption TO Instructor
GRANT EXECUTE ON PROCEDURE DeleteOption TO Instructor
GRANT EXECUTE ON PROCEDURE SelectOptionsByQuestion TO Instructor

--====================================================
--  Grant all the available procedures on the model Answer table
--====================================================
GRANT EXECUTE ON PROCEDURE SetModelAnswer TO Instructor

--=================================================================================
--  Student role
--=================================================================================
CREATE ROLE Student WITH LOGIN PASSWORD 'Student1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE university TO Student;
GRANT USAGE ON SCHEMA public TO Student;

-- give the user the access to the procedures available for him

-- 2- use view results procedure 
--======================================================
-- Student can submit exam answer 
--======================================================
GRANT EXECUTE ON PROCEDURE SubmitExamAnswers TO Student

--======================================================
-- Student can display his exam grades
--======================================================
GRANT EXECUTE ON PROCEDURE Report_StudentGrades TO Student
