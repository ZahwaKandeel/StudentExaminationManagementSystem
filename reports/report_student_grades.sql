--=====================================================================
-- Report Student Grades With Student ID 
-- Result : Report contains all the student exams grades 
--======================================================================

CREATE OR REPLACE PROCEDURE Report_StudentGrades(s_id INT,INTO result REFCURSOR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM student WHERE StudentID = s_id) THEN
        RAISE EXCEPTION 'Student with ID % does not exist.' s_id;
    END IF;

    OPEN result FOR
    SELECT C.CourseName, E.ExamName,  SX.TotalGrade, C.MaxDegree,  (SX.TotalGrade::FLOAT / C.MaxDegree * 100) AS Percentage
    from Course C
    JOIN Exam E ON C.CourseID = E.CourseID
    JOIN StudentExam SX ON SX.ExamId = E.ExamId
    WHERE SX.StudentId = s_id;
END;
$$

