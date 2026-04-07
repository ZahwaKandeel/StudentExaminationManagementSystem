-- Setup Base Dependencies
INSERT INTO Department (DepartmentName, Location) VALUES ('IT', 'Cairo');
INSERT INTO Course (CourseName, MinDegree, MaxDegree) VALUES ('SQL Basics', 50, 100);

-- Test InsertStudent
CALL InsertStudent('Alice Johnson', 'alice@example.com', '01012345678');

-- Test InsertInstructor (Uses Department ID 1)
CALL InsertInstructor('Dr. Ahmed', 'ahmed@university.edu', 1);

-- Verify
SELECT * FROM Student;
SELECT * FROM Instructor;


-- Test UpdateStudent (Changing only the email)
CALL UpdateStudent(1, NULL, 'alice_new@example.com', NULL);
SELECT * FROM Student;

-- Test UpdateInstructor (Changing Name and Department)
CALL UpdateInstructor(1, 'Dr. Ahmed Ali', NULL, 1);
SELECT * FROM Instructor;

-- Test DeleteStudent (Should work)
CALL DeleteStudent(1);
SELECT * FROM Student;

-- Test DeleteStudent (Should FAIL with custom error: Student with ID 999 not found)
CALL DeleteStudent(999);
SELECT * FROM Student;

-- First, ensure we have a Track to assign to
INSERT INTO Track (TrackName, DepartmentID) VALUES ('Data Science', 1);
-- Re-insert a student since we deleted the previous one
CALL InsertStudent('Bob Smith', 'bob@example.com', '01122334455');

-- Test AssignStudentToTrack (Student 2, Track 1)
CALL AssignStudentToTrack(2, 1);

-- Test AssignInstructorToCourse (Instructor 1, Course 1)
CALL AssignInstructorToCourse(1, 1);

-- Verify Assignments
SELECT * FROM Student_Track;
SELECT * FROM Instructor_Course;