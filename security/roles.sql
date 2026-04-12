-- CREATE ROLE admin/instructor/student
--GRANT EXECUTE on procedures
--REVOKE direct table access

--set database name as university for now

--=============================================
--  Prevent any direct table operations
--=============================================

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM public;

-- Revoke default PUBLIC execute grant on all procedures
-- so that only explicitly GRANTed roles can call them
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA public FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON PROCEDURES FROM PUBLIC;
--=================================================================================
--  Admin role
--=================================================================================
REASSIGN OWNED BY Instructor TO postgres;
DROP OWNED BY Instructor;
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
REASSIGN OWNED BY Student TO postgres;
DROP OWNED BY Student;
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


-- =============================================================
-- SECURITY DEFINER: All procedures run with owner (postgres)
-- privileges so they can access tables even when the calling
-- role has no direct table access.
-- =============================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT p.proname, n.nspname
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.prokind = 'p'          -- only procedures
    LOOP
        EXECUTE format(
            'ALTER PROCEDURE %I.%I SECURITY DEFINER',
            r.nspname, r.proname
        );
    END LOOP;
    RAISE NOTICE 'All procedures set to SECURITY DEFINER.';
END;
$$;
