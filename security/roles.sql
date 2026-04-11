-- CREATE ROLE admin/instructor/student
--GRANT EXECUTE on procedures
--REVOKE direct table access

--set database name as university for now

--=============================================
--  Prevent any direct table operations
--=============================================

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM public;
--=================================================================================
--  Admin role
--=================================================================================


CREATE ROLE adminUser WITH LOGIN PASSWORD 'Admin1234' LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA public TO adminUser;


--=================================================================================
--  Instructor role
--=================================================================================
CREATE ROLE Instructor WITH LOGIN PASSWORD 'Instructor1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE exam_db TO Instructor;
GRANT USAGE ON SCHEMA public TO Instructor;

--====================================================
--  Grant all the available procedures on the Exam table
--====================================================
GRANT EXECUTE ON PROCEDURE InsertExam TO Instructor;
GRANT EXECUTE ON PROCEDURE updateExam TO Instructor;
GRANT EXECUTE ON PROCEDURE delete_exam TO Instructor;
GRANT EXECUTE ON PROCEDURE getExamByID TO Instructor;


--====================================================
--  Grant all the available procedures on the question table
--====================================================
GRANT EXECUTE ON PROCEDURE InsertQuestion TO Instructor;
GRANT EXECUTE ON PROCEDURE UpdateQuestion TO Instructor;
GRANT EXECUTE ON PROCEDURE DeleteQuestion TO Instructor;
GRANT EXECUTE ON PROCEDURE SelectQuestionsByCourse TO Instructor;

--====================================================
--  Grant all the available procedures on the Exam question table
--====================================================
GRANT EXECUTE ON PROCEDURE insert_examquestion TO Instructor;
GRANT EXECUTE ON PROCEDURE update_examquestion TO Instructor;
GRANT EXECUTE ON PROCEDURE delete_examquestion TO Instructor;
GRANT EXECUTE ON PROCEDURE get_examquestion_by_id TO Instructor;

--====================================================
--  Grant all the available procedures on the choice table
--====================================================
GRANT EXECUTE ON PROCEDURE InsertOption TO Instructor;
GRANT EXECUTE ON PROCEDURE UpdateOption TO Instructor;
GRANT EXECUTE ON PROCEDURE DeleteOption TO Instructor;
GRANT EXECUTE ON PROCEDURE SelectOptionsByQuestion TO Instructor;

--=====================================================
-- Grant the ability to generate and correct exams
--=====================================================
GRANT EXECUTE ON PROCEDURE GenerateExam TO Instructor;
GRANT EXECUTE ON PROCEDURE CorrectExam TO Instructor;

--====================================================
--  Grant all the available procedures on the model Answer table
--====================================================
GRANT EXECUTE ON PROCEDURE SetModelAnswer TO Instructor;

--====================================================
--  Grant the ability to generate A InstructorCourses  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_InstructorCourses TO Instructor;

--====================================================
--  Grant the ability to generate A InstructorCourses  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_ExamQuestions TO Instructor;

--=================================================================================
--  Student role
--=================================================================================
CREATE ROLE Student WITH LOGIN PASSWORD 'Student1234';

-- give the user main functionalities
GRANT CONNECT ON DATABASE exam_db TO Student;
GRANT USAGE ON SCHEMA public TO Student;

-- give the user the access to the procedures available for him

-- 2- use view results procedure 
--======================================================
-- Student can submit exam answer 
--======================================================
GRANT EXECUTE ON PROCEDURE SubmitExamAnswers TO Student;

--======================================================
-- Student can display his exam grades
--======================================================
GRANT EXECUTE ON PROCEDURE Report_StudentGrades TO Student;

--====================================================
--  Grant the ability to generate A StudentsByDepartment  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_StudentsByDepartment TO Student;
