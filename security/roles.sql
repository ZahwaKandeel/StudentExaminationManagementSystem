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

DROP ROLE IF EXISTS adminUser;  
CREATE ROLE adminUser WITH LOGIN PASSWORD 'Admin1234' SUPERUSER ;
GRANT ALL PRIVILEGES ON SCHEMA public TO adminUser;


--=================================================================================
--  Instructor role
--=================================================================================
DROP ROLE IF EXISTS Instructor;
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
--  Grant the ability to generate The InstructorCourses  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_InstructorCourses TO Instructor;

--====================================================
--  Grant the ability to generate The InstructorCourses  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_ExamQuestions TO Instructor;

--====================================================
--  Grant the ability to generate The StudentExamAnswers  Report
--====================================================
GRANT EXECUTE ON PROCEDURE Report_StudentExamAnswers TO Instructor;



--=================================================================================
--  Student role
--=================================================================================
DROP ROLE IF EXISTS Student;
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
