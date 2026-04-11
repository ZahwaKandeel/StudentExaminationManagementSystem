-- =============================================================
-- File    : reports/rpt_instructor_courses.sql
-- Purpose : Report all courses taught by an instructor
--           with the count of enrolled students per course
-- REQ     : REQ-14 — Report_InstructorCourses
-- Returns : CourseName, TrackName, StudentCount
-- =============================================================

CREATE OR REPLACE PROCEDURE Report_InstructorCourses(
    p_instructorid INT, INOUT result REFCURSOR
)

LANGUAGE plpgsql
AS $$
BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM instructor WHERE instructorid = p_instructorid
    ) THEN
        RAISE EXCEPTION 'Instructor with ID % does not exist.', p_instructorid;
    END IF;

    
    IF NOT EXISTS (
        SELECT 1 FROM instructor_course WHERE instructorid = p_instructorid
    ) THEN
        RAISE EXCEPTION 'Instructor % is not assigned to any course.', p_instructorid;
    END IF;

    OPEN result FOR
    SELECT
        c.coursename::TEXT,
        t.trackname::TEXT,
        COUNT(DISTINCT st.studentid)    AS studentcount
    FROM instructor_course ic

    
    JOIN course c
        ON ic.courseid = c.courseid
    JOIN track_course tc
        ON c.courseid = tc.courseid
    JOIN track t
        ON tc.trackid = t.trackid

    LEFT JOIN student_track st
        ON t.trackid = st.trackid

    WHERE ic.instructorid = p_instructorid

    GROUP BY c.coursename, t.trackname
    ORDER BY c.coursename, t.trackname;

END;
$$;

