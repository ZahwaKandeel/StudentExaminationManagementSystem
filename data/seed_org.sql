-- =============================================================
-- File    : data/seed_org.sql
-- Purpose : Seed departments, tracks, courses, instructors
-- Run after: all schema files + 00_collation.sql
-- =============================================================

-- Clear existing data first (safe for development resets)
-- Order matters: delete child tables before parent tables
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

INSERT INTO department (departmentname, location) VALUES
    ('Information Technology',          'Cairo Branch'),
    ('Computer Science',                'Alexandria Branch'),
    ('Data Science & AI',               'Giza Branch');

-- Verify
SELECT departmentid, departmentname, location FROM department;


-- ========================
-- TRACKS
-- ========================

INSERT INTO track (trackname, departmentid) VALUES
    -- IT Department tracks
    ('Web Development',
        (SELECT departmentid FROM department WHERE departmentname = 'Information Technology')),
    ('Network & Security',
        (SELECT departmentid FROM department WHERE departmentname = 'Information Technology')),

    -- CS Department tracks
    ('Software Engineering',
        (SELECT departmentid FROM department WHERE departmentname = 'Computer Science')),
    ('Mobile Development',
        (SELECT departmentid FROM department WHERE departmentname = 'Computer Science')),

    -- DS & AI Department tracks
    ('Machine Learning',
        (SELECT departmentid FROM department WHERE departmentname = 'Data Science & AI')),
    ('Data Engineering',
        (SELECT departmentid FROM department WHERE departmentname = 'Data Science & AI'));

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
-- mindegree = minimum passing grade
-- maxdegree = total marks available

INSERT INTO course (coursename, mindegree, maxdegree) VALUES
    ('Database Design & SQL',        50, 100),
    ('Python Programming',           50, 100),
    ('Web Technologies (HTML/CSS)',  40,  80),
    ('Data Structures & Algorithms', 50, 100),
    ('Network Fundamentals',         50, 100),
    ('Machine Learning Basics',      60, 120),
    ('Mobile App Development',       50, 100);

-- Verify
SELECT courseid, coursename, mindegree, maxdegree FROM course;

-- ========================
-- TRACK_COURSE (junction)
-- ========================

INSERT INTO track_course (trackid, courseid) VALUES
    -- Web Development track
    ((SELECT trackid FROM track WHERE trackname = 'Web Development'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),
    ((SELECT trackid FROM track WHERE trackname = 'Web Development'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),
    ((SELECT trackid FROM track WHERE trackname = 'Web Development'),
     (SELECT courseid FROM course WHERE coursename = 'Web Technologies (HTML/CSS)')),

    -- Network & Security track
    ((SELECT trackid FROM track WHERE trackname = 'Network & Security'),
     (SELECT courseid FROM course WHERE coursename = 'Network Fundamentals')),
    ((SELECT trackid FROM track WHERE trackname = 'Network & Security'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),

    -- Software Engineering track
    ((SELECT trackid FROM track WHERE trackname = 'Software Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),
    ((SELECT trackid FROM track WHERE trackname = 'Software Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Data Structures & Algorithms')),
    ((SELECT trackid FROM track WHERE trackname = 'Software Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),

    -- Mobile Development track
    ((SELECT trackid FROM track WHERE trackname = 'Mobile Development'),
     (SELECT courseid FROM course WHERE coursename = 'Mobile App Development')),
    ((SELECT trackid FROM track WHERE trackname = 'Mobile Development'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),

    -- Machine Learning track
    ((SELECT trackid FROM track WHERE trackname = 'Machine Learning'),
     (SELECT courseid FROM course WHERE coursename = 'Machine Learning Basics')),
    ((SELECT trackid FROM track WHERE trackname = 'Machine Learning'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),
    ((SELECT trackid FROM track WHERE trackname = 'Machine Learning'),
     (SELECT courseid FROM course WHERE coursename = 'Data Structures & Algorithms')),

    -- Data Engineering track
    ((SELECT trackid FROM track WHERE trackname = 'Data Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),
    ((SELECT trackid FROM track WHERE trackname = 'Data Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Machine Learning Basics')),
    ((SELECT trackid FROM track WHERE trackname = 'Data Engineering'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming'));

-- Verify: how many courses per track
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

INSERT INTO instructor (name, email, departmentno) VALUES
    ('Ahmed Hassan',
     'ahmed.hassan@iti.gov.eg',
     (SELECT departmentid FROM department WHERE departmentname = 'Information Technology')),

    ('Sara Mohamed',
     'sara.mohamed@iti.gov.eg',
     (SELECT departmentid FROM department WHERE departmentname = 'Computer Science')),

    ('Khaled Nasser',
     'khaled.nasser@iti.gov.eg',
     (SELECT departmentid FROM department WHERE departmentname = 'Data Science & AI')),

    ('Nour El-Din',
     'nour.eldin@iti.gov.eg',
     (SELECT departmentid FROM department WHERE departmentname = 'Information Technology')),

    ('Mona Adel',
     'mona.adel@iti.gov.eg',
     (SELECT departmentid FROM department WHERE departmentname = 'Computer Science'));

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

INSERT INTO instructor_course (instructorid, courseid) VALUES
    -- Ahmed Hassan teaches DB and Networks
    ((SELECT instructorid FROM instructor WHERE email = 'ahmed.hassan@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),
    ((SELECT instructorid FROM instructor WHERE email = 'ahmed.hassan@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Network Fundamentals')),

    -- Sara Mohamed teaches Python and Data Structures
    ((SELECT instructorid FROM instructor WHERE email = 'sara.mohamed@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),
    ((SELECT instructorid FROM instructor WHERE email = 'sara.mohamed@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Data Structures & Algorithms')),

    -- Khaled Nasser teaches ML and Data Engineering courses
    ((SELECT instructorid FROM instructor WHERE email = 'khaled.nasser@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Machine Learning Basics')),
    ((SELECT instructorid FROM instructor WHERE email = 'khaled.nasser@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Database Design & SQL')),

    -- Nour El-Din teaches Web Technologies
    ((SELECT instructorid FROM instructor WHERE email = 'nour.eldin@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Web Technologies (HTML/CSS)')),
    ((SELECT instructorid FROM instructor WHERE email = 'nour.eldin@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Python Programming')),

    -- Mona Adel teaches Mobile Development
    ((SELECT instructorid FROM instructor WHERE email = 'mona.adel@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Mobile App Development')),
    ((SELECT instructorid FROM instructor WHERE email = 'mona.adel@iti.gov.eg'),
     (SELECT courseid FROM course WHERE coursename = 'Data Structures & Algorithms'));

-- Verify: courses per instructor
SELECT
    i.name          AS instructor,
    c.coursename    AS course
FROM instructor i
JOIN instructor_course ic ON i.instructorid = ic.instructorid
JOIN course c             ON ic.courseid    = c.courseid
ORDER BY i.name, c.coursename;

-- Full summary check
SELECT
    'Departments' AS entity, COUNT(*) AS total FROM department
UNION ALL
SELECT 'Tracks',      COUNT(*) FROM track
UNION ALL
SELECT 'Courses',     COUNT(*) FROM course
UNION ALL
SELECT 'Track-Course links',      COUNT(*) FROM track_course
UNION ALL
SELECT 'Instructors', COUNT(*) FROM instructor
UNION ALL
SELECT 'Instructor-Course links', COUNT(*) FROM instructor_course;