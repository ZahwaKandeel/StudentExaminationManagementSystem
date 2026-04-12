-- =============================================================
-- File    : data/seed_student_submissions.sql
-- Purpose : Assign students to tracks, submit exam answers,
--           and correct exams so all reports return meaningful data
-- Run after: sample_data.sql + seed_exams.sql
-- Usage   : psql -d exam_db -f data/seed_student_submissions.sql
-- =============================================================

DO $$
DECLARE
    -- Track IDs
    v_track_web     INT;
    v_track_net     INT;
    v_track_se      INT;
    v_track_mob     INT;
    v_track_ml      INT;
    v_track_de      INT;

    -- Exam IDs (by name)
    v_exam1         INT;  -- DB Design Midterm
    v_exam2         INT;  -- Python Final Exam
    v_exam3         INT;  -- Web Tech Midterm
    v_exam4         INT;  -- DSA Final Exam
    v_exam5         INT;  -- Network Midterm

    -- Student IDs (by email — stable lookup)
    v_s1  INT; v_s2  INT; v_s3  INT; v_s4  INT; v_s5  INT;
    v_s6  INT; v_s7  INT; v_s8  INT; v_s9  INT; v_s10 INT;
    v_s11 INT; v_s12 INT; v_s13 INT; v_s14 INT; v_s15 INT;
    v_s16 INT; v_s17 INT; v_s18 INT; v_s19 INT; v_s20 INT;
    v_s21 INT; v_s22 INT; v_s23 INT; v_s24 INT; v_s25 INT;

    -- Exam question lists for building answer JSONB
    v_qid       INT;
    v_correct   INT;
    v_wrong     INT;
    v_answers   JSONB;

    v_sx_id     INT;
BEGIN

    -- ============================================================
    -- Resolve track IDs
    -- ============================================================
    SELECT trackid INTO v_track_web FROM track WHERE trackname = 'Web Development';
    SELECT trackid INTO v_track_net FROM track WHERE trackname = 'Network & Security';
    SELECT trackid INTO v_track_se  FROM track WHERE trackname = 'Software Engineering';
    SELECT trackid INTO v_track_mob FROM track WHERE trackname = 'Mobile Development';
    SELECT trackid INTO v_track_ml  FROM track WHERE trackname = 'Machine Learning';
    SELECT trackid INTO v_track_de  FROM track WHERE trackname = 'Data Engineering';

    -- ============================================================
    -- Resolve exam IDs
    -- ============================================================
    SELECT examid INTO v_exam1 FROM exam WHERE examname = 'DB Design Midterm';
    SELECT examid INTO v_exam2 FROM exam WHERE examname = 'Python Final Exam';
    SELECT examid INTO v_exam3 FROM exam WHERE examname = 'Web Tech Midterm';
    SELECT examid INTO v_exam4 FROM exam WHERE examname = 'DSA Final Exam';
    SELECT examid INTO v_exam5 FROM exam WHERE examname = 'Network Midterm';

    -- ============================================================
    -- Resolve student IDs
    -- ============================================================
    SELECT studentid INTO v_s1  FROM student WHERE email = 'ayman.mohamed@gmail.com';
    SELECT studentid INTO v_s2  FROM student WHERE email = 'sarah.ahmed@yahoo.com';
    SELECT studentid INTO v_s3  FROM student WHERE email = 'omar.hassan@outlook.com';
    SELECT studentid INTO v_s4  FROM student WHERE email = 'laila.m@gmail.com';
    SELECT studentid INTO v_s5  FROM student WHERE email = 'youssef.ibrahim@protonmail.com';
    SELECT studentid INTO v_s6  FROM student WHERE email = 'mariam.ali@gmail.com';
    SELECT studentid INTO v_s7  FROM student WHERE email = 'khaled.said@icloud.com';
    SELECT studentid INTO v_s8  FROM student WHERE email = 'nour.eldin@gmail.com';
    SELECT studentid INTO v_s9  FROM student WHERE email = 'hana.tarek@yahoo.com';
    SELECT studentid INTO v_s10 FROM student WHERE email = 'ziad.amr@gmail.com';
    SELECT studentid INTO v_s11 FROM student WHERE email = 'mona.zaki@gmail.com';
    SELECT studentid INTO v_s12 FROM student WHERE email = 'ahmed.fouad@outlook.com';
    SELECT studentid INTO v_s13 FROM student WHERE email = 'salma.gamal@gmail.com';
    SELECT studentid INTO v_s14 FROM student WHERE email = 'mostafa.bakr@yahoo.com';
    SELECT studentid INTO v_s15 FROM student WHERE email = 'reem.adel@gmail.com';
    SELECT studentid INTO v_s16 FROM student WHERE email = 'fady.nessim@gmail.com';
    SELECT studentid INTO v_s17 FROM student WHERE email = 'dina.samir@icloud.com';
    SELECT studentid INTO v_s18 FROM student WHERE email = 'amir.raafat@gmail.com';
    SELECT studentid INTO v_s19 FROM student WHERE email = 'nada.yasser@yahoo.com';
    SELECT studentid INTO v_s20 FROM student WHERE email = 'sherif.mounir@gmail.com';
    SELECT studentid INTO v_s21 FROM student WHERE email = 'habiba.h@outlook.com';
    SELECT studentid INTO v_s22 FROM student WHERE email = 'kareem.walid@gmail.com';
    SELECT studentid INTO v_s23 FROM student WHERE email = 'farah.ismail@gmail.com';
    SELECT studentid INTO v_s24 FROM student WHERE email = 'tarek.aziz@yahoo.com';
    SELECT studentid INTO v_s25 FROM student WHERE email = 'nour.eldin@gmail.com';

    -- ============================================================
    -- ASSIGN STUDENTS TO TRACKS (for Report_StudentsByDepartment
    --   and Report_InstructorCourses student counts)
    -- ============================================================

    -- Web Development track students
    CALL AssignStudentToTrack(v_s1,  v_track_web);
    CALL AssignStudentToTrack(v_s2,  v_track_web);
    CALL AssignStudentToTrack(v_s9,  v_track_web);
    CALL AssignStudentToTrack(v_s10, v_track_web);

    -- Network & Security track students
    CALL AssignStudentToTrack(v_s3,  v_track_net);
    CALL AssignStudentToTrack(v_s7,  v_track_net);
    CALL AssignStudentToTrack(v_s14, v_track_net);

    -- Software Engineering track students
    CALL AssignStudentToTrack(v_s4,  v_track_se);
    CALL AssignStudentToTrack(v_s5,  v_track_se);
    CALL AssignStudentToTrack(v_s11, v_track_se);
    CALL AssignStudentToTrack(v_s12, v_track_se);

    -- Mobile Development track students
    CALL AssignStudentToTrack(v_s6,  v_track_mob);
    CALL AssignStudentToTrack(v_s15, v_track_mob);
    CALL AssignStudentToTrack(v_s16, v_track_mob);

    -- Machine Learning track students
    CALL AssignStudentToTrack(v_s8,  v_track_ml);
    CALL AssignStudentToTrack(v_s13, v_track_ml);
    CALL AssignStudentToTrack(v_s17, v_track_ml);

    -- Data Engineering track students
    CALL AssignStudentToTrack(v_s18, v_track_de);
    CALL AssignStudentToTrack(v_s19, v_track_de);
    CALL AssignStudentToTrack(v_s20, v_track_de);
    CALL AssignStudentToTrack(v_s21, v_track_de);

    -- Extra students in multiple tracks (realistic scenario)
    CALL AssignStudentToTrack(v_s22, v_track_web);
    CALL AssignStudentToTrack(v_s22, v_track_se);
    CALL AssignStudentToTrack(v_s23, v_track_ml);
    CALL AssignStudentToTrack(v_s23, v_track_de);
    CALL AssignStudentToTrack(v_s24, v_track_net);
    CALL AssignStudentToTrack(v_s25, v_track_se);

    RAISE NOTICE 'Student-track assignments complete.';

    -- ============================================================
    -- SUBMIT EXAM ANSWERS & CORRECT
    -- ============================================================

    -- ---------------------------------------------------------------
    -- STUDENT 1 (Ayman Mohamed) → Exam 1 (DB Design Midterm)
    -- All correct answers
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam1
        ORDER BY eq.orderno
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s1, v_exam1, '2026-04-10 09:00:00+02', '2026-04-10 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 1 submitted Exam 1 (all correct), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 1 (Ayman Mohamed) → Exam 2 (Python Final Exam)
    -- Mix of correct and wrong answers
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam2
        ORDER BY eq.orderno
    LOOP
        -- Make the 2nd and 4th questions wrong
        IF (SELECT orderno FROM examquestion WHERE examid = v_exam2 AND questionid = v_qid) IN (2, 4) THEN
            -- Pick a wrong option: any option that is NOT the correct one
            SELECT optionid INTO v_wrong
            FROM choice
            WHERE questionid = v_qid AND optionid != v_correct
            LIMIT 1;
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_wrong);
        ELSE
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
        END IF;
    END LOOP;
    CALL SubmitExamAnswers(v_s1, v_exam2, '2026-04-11 09:00:00+02', '2026-04-11 10:30:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 1 submitted Exam 2 (mixed), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 2 (Sarah Ahmed) → Exam 1 (DB Design Midterm)
    -- Partial submission (only answer 3 out of 5 questions)
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam1
        ORDER BY eq.orderno
        LIMIT 3
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s2, v_exam1, '2026-04-10 09:00:00+02', '2026-04-10 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 2 submitted Exam 1 (partial — 3 answers), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 2 (Sarah Ahmed) → Exam 2 (Python Final Exam)
    -- All correct
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam2
        ORDER BY eq.orderno
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s2, v_exam2, '2026-04-11 09:00:00+02', '2026-04-11 10:30:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 2 submitted Exam 2 (all correct), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 3 (Omar Hassan) → Exam 1 (DB Design Midterm)
    -- All wrong answers
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam1
        ORDER BY eq.orderno
    LOOP
        SELECT optionid INTO v_wrong
        FROM choice
        WHERE questionid = v_qid AND optionid != v_correct
        LIMIT 1;
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_wrong);
    END LOOP;
    CALL SubmitExamAnswers(v_s3, v_exam1, '2026-04-10 09:00:00+02', '2026-04-10 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 3 submitted Exam 1 (all wrong), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 3 (Omar Hassan) → Exam 5 (Network Midterm)
    -- All correct
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam5
        ORDER BY eq.orderno
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s3, v_exam5, '2026-04-12 09:00:00+02', '2026-04-12 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 3 submitted Exam 5 (all correct), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 4 (Laila Mahmoud) → Exam 3 (Web Tech Midterm)
    -- Mix correct/wrong
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam3
        ORDER BY eq.orderno
    LOOP
        IF (SELECT orderno FROM examquestion WHERE examid = v_exam3 AND questionid = v_qid) = 1 THEN
            SELECT optionid INTO v_wrong
            FROM choice
            WHERE questionid = v_qid AND optionid != v_correct
            LIMIT 1;
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_wrong);
        ELSE
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
        END IF;
    END LOOP;
    CALL SubmitExamAnswers(v_s4, v_exam3, '2026-04-10 11:00:00+02', '2026-04-10 12:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 4 submitted Exam 3 (mixed), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 4 (Laila Mahmoud) → Exam 4 (DSA Final Exam)
    -- All correct
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam4
        ORDER BY eq.orderno
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s4, v_exam4, '2026-04-11 11:00:00+02', '2026-04-11 12:30:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 4 submitted Exam 4 (all correct), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 5 (Youssef Ibrahim) → Exam 2 (Python Final Exam)
    -- Partial submission (only 2 answers)
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam2
        ORDER BY eq.orderno
        LIMIT 2
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s5, v_exam2, '2026-04-11 09:00:00+02', '2026-04-11 10:30:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 5 submitted Exam 2 (partial — 2 answers), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 6 (Mariam Ali) → Exam 4 (DSA Final Exam)
    -- All wrong
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam4
        ORDER BY eq.orderno
    LOOP
        SELECT optionid INTO v_wrong
        FROM choice
        WHERE questionid = v_qid AND optionid != v_correct
        LIMIT 1;
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_wrong);
    END LOOP;
    CALL SubmitExamAnswers(v_s6, v_exam4, '2026-04-11 11:00:00+02', '2026-04-11 12:30:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 6 submitted Exam 4 (all wrong), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 8 (Nour El-Din) → Exam 5 (Network Midterm)
    -- Mix correct/wrong
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam5
        ORDER BY eq.orderno
    LOOP
        IF (SELECT orderno FROM examquestion WHERE examid = v_exam5 AND questionid = v_qid) = 3 THEN
            SELECT optionid INTO v_wrong
            FROM choice
            WHERE questionid = v_qid AND optionid != v_correct
            LIMIT 1;
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_wrong);
        ELSE
            v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
        END IF;
    END LOOP;
    CALL SubmitExamAnswers(v_s8, v_exam5, '2026-04-12 09:00:00+02', '2026-04-12 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 8 submitted Exam 5 (mixed), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 9 (Hana Tarek) → Exam 3 (Web Tech Midterm)
    -- All correct
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam3
        ORDER BY eq.orderno
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s9, v_exam3, '2026-04-10 11:00:00+02', '2026-04-10 12:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 9 submitted Exam 3 (all correct), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    -- ---------------------------------------------------------------
    -- STUDENT 14 (Mostafa Bakr) → Exam 5 (Network Midterm)
    -- Partial (2 answers only)
    -- ---------------------------------------------------------------
    v_answers := '[]'::jsonb;
    FOR v_qid, v_correct IN
        SELECT eq.questionid, ma.correctoptionid
        FROM examquestion eq
        JOIN modelanswer ma ON eq.questionid = ma.questionid
        WHERE eq.examid = v_exam5
        ORDER BY eq.orderno
        LIMIT 2
    LOOP
        v_answers := v_answers || jsonb_build_object('question_id', v_qid, 'chosen_option_id', v_correct);
    END LOOP;
    CALL SubmitExamAnswers(v_s14, v_exam5, '2026-04-12 09:00:00+02', '2026-04-12 10:00:00+02', v_answers, v_sx_id);
    RAISE NOTICE 'Student 14 submitted Exam 5 (partial — 2 answers), SX_ID: %', v_sx_id;
    CALL CorrectExam(v_sx_id);

    RAISE NOTICE 'All student submissions complete.';

END;
$$;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Student-exam submissions with grades
SELECT
    s.studentid,
    s.name          AS student_name,
    e.examid,
    e.examname,
    sx.starttime,
    sx.endtime,
    sx.totalgrade
FROM studentexam sx
JOIN student s ON sx.studentid = s.studentid
JOIN exam e ON sx.examid = e.examid
ORDER BY s.studentid, e.examid;

-- Answer counts per submission
SELECT
    sx.studentexamid,
    s.name          AS student_name,
    e.examname,
    COUNT(sa.studentanswerid)  AS answers_count,
    sx.totalgrade
FROM studentexam sx
JOIN student s ON sx.studentid = s.studentid
JOIN exam e ON sx.examid = e.examid
LEFT JOIN studentanswer sa ON sa.studentexamid = sx.studentexamid
GROUP BY sx.studentexamid, s.name, e.examname, sx.totalgrade
ORDER BY sx.studentexamid;
