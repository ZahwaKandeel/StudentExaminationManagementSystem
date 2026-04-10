-- =============================================================
-- File    : data/seed_org.sql
-- Purpose : Seed departments, tracks, courses, instructors
--           Uses stored procedures — no direct table inserts
-- Run after: all schema files + all CRUD procedures loaded
-- =============================================================

-- -------------------------------------------------------
-- RESET (development only — remove before final submission)
-- -------------------------------------------------------
TRUNCATE TABLE
    studentanswer,
    studentexam,
    examquestion,
    exam,
    modelanswer,
    choice,
    question,
    instructor_course,
    student_track,
    track_course,
    instructor,
    student,
    track,
    course,
    department
RESTART IDENTITY CASCADE;

-- ========================
-- DEPARTMENTS
-- ========================
DO $$
DECLARE
    v_id INT;
BEGIN
    CALL InsertDepartment('Information Technology', 'Cairo Branch',       v_id);
    CALL InsertDepartment('Computer Science',       'Alexandria Branch',  v_id);
    CALL InsertDepartment('Data Science & AI',      'Giza Branch',        v_id);
    
END;
$$;

-- Verify
SELECT departmentid, departmentname, location FROM department;

-- ========================
-- TRACKS
-- ========================
DO $$
DECLARE
    v_id    INT;
    v_dept  INT;
BEGIN
    -- IT Department tracks
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Information Technology';
    CALL InsertTrack('Web Development',   v_dept, v_id);
    CALL InsertTrack('Network & Security', v_dept, v_id);
    -- CS Department tracks
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Computer Science';
    CALL InsertTrack('Software Engineering', v_dept, v_id);
    CALL InsertTrack('Mobile Development', v_dept, v_id);
    -- DS & AI Department tracks
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Data Science & AI';
    CALL InsertTrack('Machine Learning', v_dept, v_id);
    CALL InsertTrack('Data Engineering', v_dept, v_id);
    
END;
$$;

-- Verify
SELECT
    t.trackid,
    t.trackname,
    d.departmentname
FROM track t
JOIN department d ON t.departmentid = d.departmentid
ORDER BY d.departmentid, t.trackid;

-- ========================
-- COURSES
-- ========================
DO $$
DECLARE
    v_id INT;
BEGIN
    CALL InsertCourse('Database Design & SQL',        50, 100, v_id);
    CALL InsertCourse('Python Programming',           50, 100, v_id);
    CALL InsertCourse('Web Technologies (HTML/CSS)',  40,  80, v_id);
    CALL InsertCourse('Data Structures & Algorithms', 50, 100, v_id);
    CALL InsertCourse('Network Fundamentals',         50, 100, v_id);
    CALL InsertCourse('Machine Learning Basics',      60, 120, v_id);
    CALL InsertCourse('Mobile App Development',       50, 100, v_id);
    
END;
$$;

-- Verify
SELECT courseid, coursename, mindegree, maxdegree FROM course;

-- ========================
-- TRACK_COURSE (junction)
-- ========================
DO $$
DECLARE
    v_track_web     INT;
    v_track_net     INT;
    v_track_se      INT;
    v_track_mob     INT;
    v_track_ml      INT;
    v_track_de      INT;

    v_course_db     INT;
    v_course_py     INT;
    v_course_web    INT;
    v_course_ds     INT;
    v_course_nf     INT;
    v_course_ml     INT;
    v_course_mob    INT;
BEGIN
    -- Resolve all track IDs
    SELECT trackid INTO v_track_web FROM track WHERE trackname = 'Web Development';
    SELECT trackid INTO v_track_net FROM track WHERE trackname = 'Network & Security';
    SELECT trackid INTO v_track_se  FROM track WHERE trackname = 'Software Engineering';
    SELECT trackid INTO v_track_mob FROM track WHERE trackname = 'Mobile Development';
    SELECT trackid INTO v_track_ml  FROM track WHERE trackname = 'Machine Learning';
    SELECT trackid INTO v_track_de  FROM track WHERE trackname = 'Data Engineering';

    -- Resolve all course IDs
    SELECT courseid INTO v_course_db  FROM course WHERE coursename = 'Database Design & SQL';
    SELECT courseid INTO v_course_py  FROM course WHERE coursename = 'Python Programming';
    SELECT courseid INTO v_course_web FROM course WHERE coursename = 'Web Technologies (HTML/CSS)';
    SELECT courseid INTO v_course_ds  FROM course WHERE coursename = 'Data Structures & Algorithms';
    SELECT courseid INTO v_course_nf  FROM course WHERE coursename = 'Network Fundamentals';
    SELECT courseid INTO v_course_ml  FROM course WHERE coursename = 'Machine Learning Basics';
    SELECT courseid INTO v_course_mob FROM course WHERE coursename = 'Mobile App Development';

    -- Web Development track
    CALL AssignCourseToTrack(v_track_web, v_course_db);
    CALL AssignCourseToTrack(v_track_web, v_course_py);
    CALL AssignCourseToTrack(v_track_web, v_course_web);

    -- Network & Security track
    CALL AssignCourseToTrack(v_track_net, v_course_nf);
    CALL AssignCourseToTrack(v_track_net, v_course_py);

    -- Software Engineering track
    CALL AssignCourseToTrack(v_track_se, v_course_db);
    CALL AssignCourseToTrack(v_track_se, v_course_ds);
    CALL AssignCourseToTrack(v_track_se, v_course_py);

    -- Mobile Development track
    CALL AssignCourseToTrack(v_track_mob, v_course_mob);
    CALL AssignCourseToTrack(v_track_mob, v_course_db);

    -- Machine Learning track
    CALL AssignCourseToTrack(v_track_ml, v_course_ml);
    CALL AssignCourseToTrack(v_track_ml, v_course_py);
    CALL AssignCourseToTrack(v_track_ml, v_course_ds);

    -- Data Engineering track
    CALL AssignCourseToTrack(v_track_de, v_course_db);
    CALL AssignCourseToTrack(v_track_de, v_course_ml);
    CALL AssignCourseToTrack(v_track_de, v_course_py);

    
$$;

-- Verify
SELECT
    t.trackname,
    COUNT(tc.courseid) AS course_count
FROM track t
JOIN track_course tc ON t.trackid = tc.trackid
GROUP BY t.trackname
ORDER BY t.trackname;

-- ========================
-- INSTRUCTORS
-- ========================
DO $$
DECLARE
    v_id    INT;
    v_dept  INT;
BEGIN
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Information Technology';
    CALL InsertInstructor('Ahmed Hassan', 'ahmed.hassan@iti.gov.eg', v_dept, v_id);
    CALL InsertInstructor('Nour El-Din',  'nour.eldin@iti.gov.eg',  v_dept, v_id);
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Computer Science';
    CALL InsertInstructor('Sara Mohamed', 'sara.mohamed@iti.gov.eg', v_dept, v_id);
    CALL InsertInstructor('Mona Adel',    'mona.adel@iti.gov.eg',   v_dept, v_id);
    SELECT departmentid INTO v_dept
    FROM department WHERE departmentname = 'Data Science & AI';
    CALL InsertInstructor('Khaled Nasser', 'khaled.nasser@iti.gov.eg', v_dept, v_id);
    
END;
$$;

-- Verify
SELECT
    i.instructorid,
    i.name,
    i.email,
    d.departmentname
FROM instructor i
JOIN department d ON i.departmentno = d.departmentid
ORDER BY i.instructorid;


-- ========================
-- INSTRUCTOR_COURSE (junction)
-- ========================
DO $$
DECLARE
    v_ahmed     INT;
    v_sara      INT;
    v_khaled    INT;
    v_nour      INT;
    v_mona      INT;

    v_course_db  INT;
    v_course_py  INT;
    v_course_web INT;
    v_course_ds  INT;
    v_course_nf  INT;
    v_course_ml  INT;
    v_course_mob INT;
BEGIN
    -- Resolve instructor IDs by email (email is UNIQUE so safe to use)
    SELECT instructorid INTO v_ahmed  FROM instructor WHERE email = 'ahmed.hassan@iti.gov.eg';
    SELECT instructorid INTO v_sara   FROM instructor WHERE email = 'sara.mohamed@iti.gov.eg';
    SELECT instructorid INTO v_khaled FROM instructor WHERE email = 'khaled.nasser@iti.gov.eg';
    SELECT instructorid INTO v_nour   FROM instructor WHERE email = 'nour.eldin@iti.gov.eg';
    SELECT instructorid INTO v_mona   FROM instructor WHERE email = 'mona.adel@iti.gov.eg';

    -- Resolve course IDs
    SELECT courseid INTO v_course_db  FROM course WHERE coursename = 'Database Design & SQL';
    SELECT courseid INTO v_course_py  FROM course WHERE coursename = 'Python Programming';
    SELECT courseid INTO v_course_web FROM course WHERE coursename = 'Web Technologies (HTML/CSS)';
    SELECT courseid INTO v_course_ds  FROM course WHERE coursename = 'Data Structures & Algorithms';
    SELECT courseid INTO v_course_nf  FROM course WHERE coursename = 'Network Fundamentals';
    SELECT courseid INTO v_course_ml  FROM course WHERE coursename = 'Machine Learning Basics';
    SELECT courseid INTO v_course_mob FROM course WHERE coursename = 'Mobile App Development';

    -- Ahmed Hassan: DB + Networks
    CALL AssignInstructorToCourse(v_ahmed, v_course_db);
    CALL AssignInstructorToCourse(v_ahmed, v_course_nf);

    -- Sara Mohamed: Python + Data Structures
    CALL AssignInstructorToCourse(v_sara, v_course_py);
    CALL AssignInstructorToCourse(v_sara, v_course_ds);

    -- Khaled Nasser: ML + DB
    CALL AssignInstructorToCourse(v_khaled, v_course_ml);
    CALL AssignInstructorToCourse(v_khaled, v_course_db);

    -- Nour El-Din: Web Technologies + Python
    CALL AssignInstructorToCourse(v_nour, v_course_web);
    CALL AssignInstructorToCourse(v_nour, v_course_py);

    -- Mona Adel: Mobile + Data Structures
    CALL AssignInstructorToCourse(v_mona, v_course_mob);
    CALL AssignInstructorToCourse(v_mona, v_course_ds);

    
END;
$$;

-- Verify
SELECT
    i.name       AS instructor,
    c.coursename AS course
FROM instructor i
JOIN instructor_course ic ON i.instructorid = ic.instructorid
JOIN course c             ON ic.courseid    = c.courseid
ORDER BY i.name, c.coursename;

-- ========================
-- FINAL SUMMARY
-- ========================
SELECT 'Departments'             AS entity, COUNT(*) AS total FROM department
UNION ALL
SELECT 'Tracks',                            COUNT(*) FROM track
UNION ALL
SELECT 'Courses',                           COUNT(*) FROM course
UNION ALL
SELECT 'Track-Course links',                COUNT(*) FROM track_course
UNION ALL
SELECT 'Instructors',                       COUNT(*) FROM instructor
UNION ALL
SELECT 'Instructor-Course links',           COUNT(*) FROM instructor_course;