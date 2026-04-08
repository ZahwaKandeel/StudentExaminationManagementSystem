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



-- TEST CASE 1: Get ALL Instructors (All params NULL)
BEGIN;
CALL select_instructor('res_all');
FETCH ALL FROM res_all;
COMMIT;

-- TEST CASE 2: Search by Name Pattern (Partial Match)
-- This should find 'Dr. Ahmed' if you search 'Ahmed'
BEGIN;
CALL select_instructor('res_name', i_name => 'ahmed');
FETCH ALL FROM res_name;
COMMIT;

-- TEST CASE 3: Search by Department ID
BEGIN;
CALL select_instructor('res_dept', i_department => 1);
FETCH ALL FROM res_dept;
COMMIT;

-- TEST CASE 4: Specific Instructor by ID and Email
BEGIN;
CALL select_instructor('res_specific', i_id => 1, i_email => 'ahmed@university.edu');
FETCH ALL FROM res_specific;
COMMIT;




-- TEST CASE 1: Get ALL Students
BEGIN;
CALL select_student('stu_all');
FETCH ALL FROM stu_all;
COMMIT;

-- TEST CASE 2: Search by Name (Case Insensitive)
-- Should find "Alice Johnson" even if you type "ALICE"
BEGIN;
CALL select_student('stu_name', s_name => 'Bob');
FETCH ALL FROM stu_name;
COMMIT;

-- TEST CASE 3: Search by Phone Number
BEGIN;
CALL select_student('stu_phone', s_phone => '01122334455');
FETCH ALL FROM stu_phone;
COMMIT;

-- TEST CASE 4: No Results (Search for non-existent student)
BEGIN;
CALL select_student('stu_none', s_name => 'Zebra');
FETCH ALL FROM stu_none; -- Should return an empty row set
COMMIT;





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