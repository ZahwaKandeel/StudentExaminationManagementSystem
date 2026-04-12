-- =============================================================
-- File    : tests/Performance.sql
-- Purpose : Full performance test for the exam lifecycle
--           GenerateExam → SubmitExamAnswers → CorrectExam
--           Measures NFR-01 (GenerateExam < 2s for 50 Qs)
--           and NFR-02 (CorrectExam < 1s per student)
-- Run after: sample_data.sql + performance_seed.sql + all procs
-- =============================================================

-- -------------------------------------------------------
-- Prepare temp table upfront (before any test runs)
-- -------------------------------------------------------
DROP TABLE IF EXISTS test_state;
CREATE TEMP TABLE test_state (
    key   TEXT PRIMARY KEY,
    value TEXT
);

-- ========================================================
-- PRE-CHECK: verify question bank has enough data
-- ========================================================
DO $$
DECLARE
    v_courseid  INT;
    v_mcq_count INT;
    v_tf_count  INT;
BEGIN
    -- Resolve course by name — matches performance_seed.sql
    SELECT courseid INTO v_courseid
    FROM course
    WHERE coursename = 'Software Engineering Fundamentals';

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Course "Software Engineering Fundamentals" not found. '
            'Run data/performance_seed.sql first.';
    END IF;

    SELECT COUNT(*) INTO v_mcq_count
    FROM question
    WHERE courseid = v_courseid AND type = 'MCQ';

    SELECT COUNT(*) INTO v_tf_count
    FROM question
    WHERE courseid = v_courseid AND type = 'TF';

    RAISE NOTICE '=== PRE-CHECK ===';
    RAISE NOTICE 'Course ID    : %', v_courseid;
    RAISE NOTICE 'MCQ questions: %', v_mcq_count;
    RAISE NOTICE 'TF questions : %', v_tf_count;

    IF v_mcq_count < 30 THEN
        RAISE EXCEPTION 'Not enough MCQ questions. Need 30, have %.', v_mcq_count;
    END IF;

    IF v_tf_count < 20 THEN
        RAISE EXCEPTION 'Not enough TF questions. Need 20, have %.', v_tf_count;
    END IF;

    RAISE NOTICE 'PRE-CHECK PASSED — enough questions available.';

    -- Save courseid for later tests
    INSERT INTO test_state (key, value)
    VALUES ('course_id', v_courseid::TEXT);
END;
$$;

-- ========================================================
-- TEST 1: GenerateExam — valid inputs (30 MCQ + 20 TF)
-- Expected: exam created, 50 questions inserted, no dupes,
--           sequential orderno, execution < 2 seconds
-- ========================================================
DO $$
DECLARE
    v_courseid    INT;
    v_examid      INT;
    v_q_count     INT;
    v_mcq_count   INT;
    v_tf_count    INT;
    v_has_dupes   BOOLEAN;
    v_start       TIMESTAMP;
    v_elapsed     INTERVAL;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 1: GenerateExam (30 MCQ + 20 TF = 50 Qs) ===';

    SELECT value::INT INTO v_courseid FROM test_state WHERE key = 'course_id';

    v_start := clock_timestamp();

    CALL GenerateExam(
        v_courseid,
        'Performance Exam ' || to_char(NOW(), 'YYYYMMDDHH24MISS'),
        30,
        20,
        v_examid
    );

    v_elapsed := clock_timestamp() - v_start;

    RAISE NOTICE 'Exam created. ID: %', v_examid;
    RAISE NOTICE 'GenerateExam execution time: %', v_elapsed;

    -- NFR-01: must complete in under 2 seconds
    IF v_elapsed > INTERVAL '2 seconds' THEN
        RAISE WARNING 'NFR-01 FAILED: GenerateExam took % (limit: 2s)', v_elapsed;
    ELSE
        RAISE NOTICE 'NFR-01 PASSED: GenerateExam completed in % (< 2s)', v_elapsed;
    END IF;

    -- Check total question count = 50
    SELECT COUNT(*) INTO v_q_count
    FROM examquestion
    WHERE examid = v_examid;

    RAISE NOTICE 'Total questions in exam: % (expected 50)', v_q_count;

    IF v_q_count <> 50 THEN
        RAISE EXCEPTION 'FAIL: Expected 50 questions, got %', v_q_count;
    END IF;

    -- Check MCQ count
    SELECT COUNT(*) INTO v_mcq_count
    FROM examquestion eq
    JOIN question q ON eq.questionid = q.questionid
    WHERE eq.examid = v_examid AND q.type = 'MCQ';

    RAISE NOTICE 'MCQ count: % (expected 30)', v_mcq_count;

    IF v_mcq_count <> 30 THEN
        RAISE EXCEPTION 'FAIL: Expected 30 MCQ questions, got %', v_mcq_count;
    END IF;

    -- Check TF count
    SELECT COUNT(*) INTO v_tf_count
    FROM examquestion eq
    JOIN question q ON eq.questionid = q.questionid
    WHERE eq.examid = v_examid AND q.type = 'TF';

    RAISE NOTICE 'TF count: % (expected 20)', v_tf_count;

    IF v_tf_count <> 20 THEN
        RAISE EXCEPTION 'FAIL: Expected 20 TF questions, got %', v_tf_count;
    END IF;

    -- Check for duplicate questions
    SELECT COUNT(*) > COUNT(DISTINCT questionid) INTO v_has_dupes
    FROM examquestion
    WHERE examid = v_examid;

    IF v_has_dupes THEN
        RAISE EXCEPTION 'FAIL: Duplicate questions found in exam %', v_examid;
    END IF;

    RAISE NOTICE 'No duplicate questions found.';

    -- Check orderno values are sequential starting from 1
    IF NOT EXISTS (
        SELECT 1 FROM examquestion
        WHERE examid = v_examid
        HAVING MAX(orderno) = COUNT(*)
           AND MIN(orderno) = 1
    ) THEN
        RAISE EXCEPTION 'FAIL: orderno values are not sequential from 1.';
    END IF;

    RAISE NOTICE 'Order numbers are sequential.';
    RAISE NOTICE 'TEST 1 PASSED';

    -- Save for later tests
    INSERT INTO test_state (key, value)
    VALUES ('exam_id', v_examid::TEXT);

END;
$$;

-- ========================================================
-- TEST 2: SubmitExamAnswers — full submission (50 answers)
-- Expected: StudentExam row + 50 StudentAnswer rows
-- ========================================================
DO $$
DECLARE
    v_examid        INT;
    v_studentid     INT;
    v_studentexamid INT;
    v_answer_count  INT;
    v_q_count       INT;
    v_answers_json  JSONB;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 2: SubmitExamAnswers (full — 50 answers) ===';

    SELECT value::INT INTO v_examid FROM test_state WHERE key = 'exam_id';

    -- Resolve student by email — stable regardless of seed order
    SELECT studentid INTO v_studentid
    FROM student
    WHERE email = 'ayman.mohamed@gmail.com';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Student "ayman.mohamed@gmail.com" not found. Run sample_data.sql first.';
    END IF;

    -- Build JSONB: pick first choice for each question
    SELECT jsonb_agg(
        jsonb_build_object(
            'question_id',      eq.questionid,
            'chosen_option_id', (
                SELECT optionid FROM choice
                WHERE questionid = eq.questionid
                ORDER BY optionorder
                LIMIT 1
            )
        )
    )
    INTO v_answers_json
    FROM examquestion eq
    WHERE eq.examid = v_examid;

    RAISE NOTICE 'Answers JSON built: % answers', jsonb_array_length(v_answers_json);

    CALL SubmitExamAnswers(
        v_studentid,
        v_examid,
        NOW() - INTERVAL '30 minutes',
        NOW(),
        v_answers_json,
        v_studentexamid
    );

    RAISE NOTICE 'StudentExam created. ID: %', v_studentexamid;

    -- Verify StudentExam row exists
    IF NOT EXISTS (
        SELECT 1 FROM studentexam WHERE studentexamid = v_studentexamid
    ) THEN
        RAISE EXCEPTION 'FAIL: StudentExam row was not created.';
    END IF;

    -- Verify answer count matches question count
    SELECT COUNT(*) INTO v_q_count
    FROM examquestion WHERE examid = v_examid;

    SELECT COUNT(*) INTO v_answer_count
    FROM studentanswer WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'Questions in exam: %, Answers submitted: %',
        v_q_count, v_answer_count;

    IF v_answer_count <> v_q_count THEN
        RAISE EXCEPTION 'FAIL: Expected % answer rows, got %.',
            v_q_count, v_answer_count;
    END IF;

    -- Verify endtime was saved
    IF NOT EXISTS (
        SELECT 1 FROM studentexam
        WHERE studentexamid = v_studentexamid
          AND endtime IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'FAIL: endtime was not saved on StudentExam.';
    END IF;

    RAISE NOTICE 'All answer rows inserted correctly.';
    RAISE NOTICE 'TEST 2 PASSED';

    -- Save for Test 3
    INSERT INTO test_state (key, value)
    VALUES ('studentexam_id', v_studentexamid::TEXT);
END;
$$;

-- ========================================================
-- TEST 3: CorrectExam — verify grade calculation
-- Expected: TotalGrade = SUM(points) for correct answers only
--           Execution < 1 second (NFR-02)
-- ========================================================
DO $$
DECLARE
    v_studentexamid INT;
    v_totalgrade    INT;
    v_expected      INT;
    v_start         TIMESTAMP;
    v_elapsed       INTERVAL;
    r               RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 3: CorrectExam (mixed answers) ===';

    SELECT value::INT INTO v_studentexamid
    FROM test_state WHERE key = 'studentexam_id';

    -- Calculate expected grade BEFORE calling CorrectExam
    SELECT COALESCE(SUM(
        CASE
            WHEN sa.chosenoptionid = ma.correctoptionid
            THEN q.points
            ELSE 0
        END
    ), 0)
    INTO v_expected
    FROM studentanswer sa
    JOIN question    q  ON sa.questionid    = q.questionid
    JOIN modelanswer ma ON sa.questionid    = ma.questionid
    WHERE sa.studentexamid = v_studentexamid;

    RAISE NOTICE 'Expected total grade (manual calc): %', v_expected;

    v_start := clock_timestamp();

    CALL CorrectExam(v_studentexamid);

    v_elapsed := clock_timestamp() - v_start;

    RAISE NOTICE 'CorrectExam execution time: %', v_elapsed;

    -- NFR-02: must complete in under 1 second
    IF v_elapsed > INTERVAL '1 second' THEN
        RAISE WARNING 'NFR-02 FAILED: CorrectExam took % (limit: 1s)', v_elapsed;
    ELSE
        RAISE NOTICE 'NFR-02 PASSED: CorrectExam completed in % (< 1s)', v_elapsed;
    END IF;

    -- Read the grade CorrectExam wrote
    SELECT totalgrade INTO v_totalgrade
    FROM studentexam
    WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'TotalGrade written by CorrectExam: %', v_totalgrade;

    IF v_totalgrade <> v_expected THEN
        RAISE EXCEPTION 'FAIL: Expected grade %, got %.', v_expected, v_totalgrade;
    END IF;

    -- Per-question breakdown
    RAISE NOTICE '--- Per-question breakdown ---';
    FOR r IN
        SELECT
            q.questionid,
            q.type,
            q.points,
            sa.chosenoptionid,
            ma.correctoptionid,
            CASE WHEN sa.chosenoptionid = ma.correctoptionid
                 THEN q.points ELSE 0 END AS earned
        FROM studentanswer sa
        JOIN question    q  ON sa.questionid = q.questionid
        JOIN modelanswer ma ON sa.questionid = ma.questionid
        WHERE sa.studentexamid = v_studentexamid
        ORDER BY q.questionid
    LOOP
        RAISE NOTICE 'Q% [%] | chosen: % | correct: % | earned: %/%',
            r.questionid, r.type,
            r.chosenoptionid, r.correctoptionid,
            r.earned, r.points;
    END LOOP;

    RAISE NOTICE 'TEST 3 PASSED';
END;
$$;

-- ========================================================
-- FINAL SUMMARY
-- ========================================================
DO $$
DECLARE
    v_examid        INT;
    v_studentexamid INT;
BEGIN
    SELECT value::INT INTO v_examid       FROM test_state WHERE key = 'exam_id';
    SELECT value::INT INTO v_studentexamid FROM test_state WHERE key = 'studentexam_id';

    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '  PERFORMANCE TEST SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Exam ID           : %', v_examid;
    RAISE NOTICE 'StudentExam ID    : %', v_studentexamid;

    SELECT
        'Exam questions'   AS metric, COUNT(*)::TEXT AS value
    FROM examquestion WHERE examid = v_examid
    UNION ALL
    SELECT 'Student answers', COUNT(*)::TEXT
    FROM studentanswer WHERE studentexamid = v_studentexamid
    UNION ALL
    SELECT 'Total grade',     COALESCE(totalgrade::TEXT, 'NULL')
    FROM studentexam WHERE studentexamid = v_studentexamid;
END;
$$;
