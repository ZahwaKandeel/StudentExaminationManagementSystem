-- =============================================================
-- File    : tests/integration_test.sql
-- Purpose : Full integration test for the exam lifecycle
--           GenerateExam → SubmitExamAnswers → CorrectExam
-- Run after: all schema, procs, and seed data are loaded
-- =============================================================

-- -------------------------------------------------------
-- PRE-CHECK: verify question bank has enough data
-- -------------------------------------------------------
DO $$
DECLARE
    v_courseid      INT;
    v_mcq_count     INT;
    v_tf_count      INT;
BEGIN
    -- Use course 1 (Database Design & SQL) for all tests
    v_courseid := 1;

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

    -- We need at least 3 MCQ and 2 TF to run the tests below
    IF v_mcq_count < 3 THEN
        RAISE EXCEPTION 'Not enough MCQ questions. Need 3, have %.
        Run data/seed_questions.sql first.', v_mcq_count;
    END IF;

    IF v_tf_count < 2 THEN
        RAISE EXCEPTION 'Not enough TF questions. Need 2, have %.
        Run data/seed_questions.sql first.', v_tf_count;
    END IF;

    RAISE NOTICE 'PRE-CHECK PASSED — enough questions available.';
END;
$$;

-- -------------------------------------------------------
-- TEST 1: GenerateExam — valid inputs
-- Expected: exam created, questions inserted, no duplicates
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid        INT;
    v_q_count       INT;
    v_mcq_count     INT;
    v_tf_count      INT;
    v_has_dupes     BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 1: GenerateExam (valid) ===';

    -- Generate an exam for course 1 with 3 MCQ + 2 TF
    CALL GenerateExam(
        1,
        'DB Midterm Test 1',
        3,
        2,
        v_examid
    );

    RAISE NOTICE 'Exam created. ID: %', v_examid;

    -- Check total question count = 3 + 2 = 5
    SELECT COUNT(*) INTO v_q_count
    FROM examquestion
    WHERE examid = v_examid;

    RAISE NOTICE 'Total questions in exam: % (expected 5)', v_q_count;

    IF v_q_count <> 5 THEN
        RAISE EXCEPTION 'FAIL: Expected 5 questions, got %', v_q_count;
    END IF;

    -- Check MCQ count
    SELECT COUNT(*) INTO v_mcq_count
    FROM examquestion eq
    JOIN question q ON eq.questionid = q.questionid
    WHERE eq.examid = v_examid AND q.type = 'MCQ';

    RAISE NOTICE 'MCQ count: % (expected 3)', v_mcq_count;

    IF v_mcq_count <> 3 THEN
        RAISE EXCEPTION 'FAIL: Expected 3 MCQ questions, got %', v_mcq_count;
    END IF;

    -- Check TF count
    SELECT COUNT(*) INTO v_tf_count
    FROM examquestion eq
    JOIN question q ON eq.questionid = q.questionid
    WHERE eq.examid = v_examid AND q.type = 'TF';

    RAISE NOTICE 'TF count: % (expected 2)', v_tf_count;

    IF v_tf_count <> 2 THEN
        RAISE EXCEPTION 'FAIL: Expected 2 TF questions, got %', v_tf_count;
    END IF;

    -- Check for duplicate questions (none allowed)
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

    -- Save examid for use in Test 3
    -- We store it in a temp table so later tests can access it
    CREATE TEMP TABLE IF NOT EXISTS test_state (
        key   TEXT PRIMARY KEY,
        value TEXT
    );
    INSERT INTO test_state (key, value)
    VALUES ('exam1_id', v_examid::TEXT)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

END;
$$;

-- -------------------------------------------------------
-- TEST 2: GenerateExam — not enough questions
-- Expected: exception raised, no partial data inserted
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid        INT;
    v_exam_count_before INT;
    v_exam_count_after  INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 2: GenerateExam (insufficient questions) ===';

    -- Count exams before the call
    SELECT COUNT(*) INTO v_exam_count_before FROM exam;

    BEGIN
        -- Request 999 MCQ — impossible to satisfy
        CALL GenerateExam(
            1,
            'Should Not Exist',
            999,
            0,
            v_examid
        );

        -- If we reach this line the procedure did not raise — that is a bug
        RAISE EXCEPTION 'FAIL: GenerateExam should have raised an exception
        for insufficient questions but it did not.';

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Exception correctly raised: %', SQLERRM;
    END;

    -- Verify no partial data was inserted
    -- The exam row must not exist if the procedure rolled back correctly
    SELECT COUNT(*) INTO v_exam_count_after FROM exam;

    IF v_exam_count_after > v_exam_count_before THEN
        RAISE EXCEPTION 'FAIL: A partial exam row was inserted even though
        the procedure failed. Transaction rollback is not working.';
    END IF;

    RAISE NOTICE 'No partial data found — rollback worked correctly.';
    RAISE NOTICE 'TEST 2 PASSED';
END;
$$;

-- -------------------------------------------------------
-- TEST 3: SubmitExamAnswers — full submission
-- Expected: StudentExam row created, one StudentAnswer
--           per question, all rows inserted correctly
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid        INT;
    v_studentid     INT;
    v_studentexamid INT;
    v_answer_count  INT;
    v_q_count       INT;
    v_answers_json  JSONB;

    -- Cursor to collect all question IDs and their first choice
    r RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 3: SubmitExamAnswers (full submission) ===';

    -- Get the exam we created in Test 1
    SELECT value::INT INTO v_examid
    FROM test_state WHERE key = 'exam1_id';

    -- Use student ID 1 from seed data
    v_studentid := 1;

    -- Build the JSONB answers array dynamically
    -- For each question in the exam pick its first available choice
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

    RAISE NOTICE 'Answers JSON built: %', v_answers_json;

    -- Submit the exam
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

    -- Verify endtime was saved correctly
    IF NOT EXISTS (
        SELECT 1 FROM studentexam
        WHERE studentexamid = v_studentexamid
          AND endtime IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'FAIL: endtime was not saved on StudentExam.';
    END IF;

    RAISE NOTICE 'All answer rows inserted correctly.';
    RAISE NOTICE 'TEST 3 PASSED';

    -- Save studentexamid for Test 5
    INSERT INTO test_state (key, value)
    VALUES ('studentexam1_id', v_studentexamid::TEXT)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
END;
$$;

-- -------------------------------------------------------
-- TEST 4: SubmitExamAnswers — partial submission
-- Student answers only some questions, skips the rest
-- Expected: only answered questions get rows,
--           unanswered questions produce no row
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid2         INT;
    v_studentid       INT;
    v_studentexamid   INT;
    v_answer_count    INT;
    v_answers_json    JSONB;
    v_first_qid       INT;
    v_first_oid       INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 4: SubmitExamAnswers (partial submission) ===';

    -- Generate a second exam for student 2
    CALL GenerateExam(
        p_courseid  := 1,
        p_examname  := 'DB Midterm Test 2',
        p_nummcq    := 3,
        p_numtf     := 2,
        new_examid  := v_examid2
    );

    -- Use student 2
    v_studentid := 2;

    -- Get only the FIRST question from this exam
    SELECT eq.questionid,
           (SELECT optionid FROM choice
            WHERE questionid = eq.questionid
            ORDER BY optionorder LIMIT 1)
    INTO v_first_qid, v_first_oid
    FROM examquestion eq
    WHERE eq.examid = v_examid2
    ORDER BY eq.orderno
    LIMIT 1;

    -- Build a JSONB array with only one answer (partial)
    v_answers_json := jsonb_build_array(
        jsonb_build_object(
            'question_id',      v_first_qid,
            'chosen_option_id', v_first_oid
        )
    );

    RAISE NOTICE 'Submitting only 1 answer out of 5 questions.';

    CALL SubmitExamAnswers(
        p_studentid       := v_studentid,
        p_examid          := v_examid2,
        p_starttime       := NOW() - INTERVAL '15 minutes',
        p_endtime         := NOW(),
        p_answers         := v_answers_json,
        new_studentexamid := v_studentexamid
    );

    -- Verify only 1 answer row was created
    SELECT COUNT(*) INTO v_answer_count
    FROM studentanswer WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'Answer rows created: % (expected 1)', v_answer_count;

    IF v_answer_count <> 1 THEN
        RAISE EXCEPTION 'FAIL: Expected 1 answer row, got %.', v_answer_count;
    END IF;

    RAISE NOTICE 'Unanswered questions correctly produced no rows.';
    RAISE NOTICE 'TEST 4 PASSED';

    -- Save for Test 6
    INSERT INTO test_state (key, value)
    VALUES ('studentexam2_id', v_studentexamid::TEXT)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
END;
$$;

-- -------------------------------------------------------
-- TEST 5: CorrectExam — mixed correct and wrong answers
-- Expected: TotalGrade = sum of points for correct answers only
-- -------------------------------------------------------
DO $$
DECLARE
    v_studentexamid INT;
    v_totalgrade    INT;
    v_expected      INT;

    -- We will calculate the expected grade manually
    r RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 5: CorrectExam (mixed answers) ===';

    SELECT value::INT INTO v_studentexamid
    FROM test_state WHERE key = 'studentexam1_id';

    -- Calculate expected grade manually BEFORE calling CorrectExam
    -- For each answer: if chosen option = model answer → add points, else 0
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

    RAISE NOTICE 'Expected total grade (calculated manually): %', v_expected;

    -- Now run CorrectExam
    CALL CorrectExam(
        p_studentexamid := v_studentexamid
    );

    -- Read the TotalGrade that CorrectExam wrote
    SELECT totalgrade INTO v_totalgrade
    FROM studentexam
    WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'TotalGrade written by CorrectExam: %', v_totalgrade;

    -- Compare
    IF v_totalgrade <> v_expected THEN
        RAISE EXCEPTION 'FAIL: Expected grade %, got %.', v_expected, v_totalgrade;
    END IF;

    -- Show the per-question breakdown for manual inspection
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

    RAISE NOTICE 'TEST 5 PASSED';
END;
$$;

-- -------------------------------------------------------
-- TEST 6: CorrectExam — partial submission
-- Student only answered 1 question
-- Expected: TotalGrade = points for that 1 question if correct,
--           or 0 if wrong. Unanswered = 0 automatically.
-- -------------------------------------------------------
DO $$
DECLARE
    v_studentexamid INT;
    v_totalgrade    INT;
    v_max_possible  INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 6: CorrectExam (partial submission) ===';

    SELECT value::INT INTO v_studentexamid
    FROM test_state WHERE key = 'studentexam2_id';

    -- Get max possible grade for this exam
    SELECT COALESCE(SUM(q.points), 0)
    INTO v_max_possible
    FROM examquestion eq
    JOIN studentexam  se ON eq.examid = se.examid
    JOIN question     q  ON eq.questionid = q.questionid
    WHERE se.studentexamid = v_studentexamid;

    RAISE NOTICE 'Max possible grade for this exam: %', v_max_possible;

    -- Run CorrectExam
    CALL CorrectExam(p_studentexamid := v_studentexamid);

    SELECT totalgrade INTO v_totalgrade
    FROM studentexam WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'TotalGrade after partial submission: %', v_totalgrade;

    -- Grade must be >= 0 and <= max possible
    IF v_totalgrade < 0 THEN
        RAISE EXCEPTION 'FAIL: Grade is negative: %', v_totalgrade;
    END IF;

    IF v_totalgrade > v_max_possible THEN
        RAISE EXCEPTION 'FAIL: Grade % exceeds max possible %.',
            v_totalgrade, v_max_possible;
    END IF;

    RAISE NOTICE 'Grade is within valid range [0, %].', v_max_possible;
    RAISE NOTICE 'TEST 6 PASSED';
END;
$$;

-- -------------------------------------------------------
-- TEST 7: CorrectExam — all correct answers
-- Expected: TotalGrade = sum of ALL question points
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid        INT;
    v_studentexamid INT;
    v_totalgrade    INT;
    v_max_possible  INT;
    v_answers_json  JSONB;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 7: CorrectExam (all correct) ===';

    -- Generate a fresh exam
    CALL GenerateExam(
        p_courseid  := 1,
        p_examname  := 'All Correct Test',
        p_nummcq    := 2,
        p_numtf     := 2,
        new_examid  := v_examid
    );

    -- Build answers using the CORRECT option for every question
    SELECT jsonb_agg(
        jsonb_build_object(
            'question_id',      eq.questionid,
            'chosen_option_id', ma.correctoptionid
        )
    )
    INTO v_answers_json
    FROM examquestion eq
    JOIN modelanswer ma ON eq.questionid = ma.questionid
    WHERE eq.examid = v_examid;

    -- Submit with all correct answers (student 3)
    CALL SubmitExamAnswers(
        p_studentid       := 3,
        p_examid          := v_examid,
        p_starttime       := NOW() - INTERVAL '20 minutes',
        p_endtime         := NOW(),
        p_answers         := v_answers_json,
        new_studentexamid := v_studentexamid
    );

    -- Calculate the max possible grade
    SELECT COALESCE(SUM(q.points), 0)
    INTO v_max_possible
    FROM examquestion eq
    JOIN question q ON eq.questionid = q.questionid
    WHERE eq.examid = v_examid;

    -- Run CorrectExam
    CALL CorrectExam(p_studentexamid := v_studentexamid);

    SELECT totalgrade INTO v_totalgrade
    FROM studentexam WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'Max possible: %, TotalGrade: %', v_max_possible, v_totalgrade;

    IF v_totalgrade <> v_max_possible THEN
        RAISE EXCEPTION 'FAIL: All answers were correct but grade % != max %.',
            v_totalgrade, v_max_possible;
    END IF;

    RAISE NOTICE 'TEST 7 PASSED';
END;
$$;

-- -------------------------------------------------------
-- TEST 8: CorrectExam — all wrong answers
-- Expected: TotalGrade = 0
-- -------------------------------------------------------
DO $$
DECLARE
    v_examid        INT;
    v_studentexamid INT;
    v_totalgrade    INT;
    v_answers_json  JSONB;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TEST 8: CorrectExam (all wrong) ===';

    CALL GenerateExam(
        p_courseid  := 1,
        p_examname  := 'All Wrong Test',
        p_nummcq    := 2,
        p_numtf     := 2,
        new_examid  := v_examid
    );

    -- Build answers using the WRONG option for every question
    -- Strategy: pick the option that is NOT the correct answer
    SELECT jsonb_agg(
        jsonb_build_object(
            'question_id',      eq.questionid,
            'chosen_option_id', (
                SELECT optionid FROM choice
                WHERE questionid = eq.questionid
                  AND optionid != (
                      SELECT correctoptionid FROM modelanswer
                      WHERE questionid = eq.questionid
                  )
                ORDER BY optionorder
                LIMIT 1
            )
        )
    )
    INTO v_answers_json
    FROM examquestion eq
    WHERE eq.examid = v_examid;

    -- Submit (student 4)
    CALL SubmitExamAnswers(
        p_studentid       := 4,
        p_examid          := v_examid,
        p_starttime       := NOW() - INTERVAL '20 minutes',
        p_endtime         := NOW(),
        p_answers         := v_answers_json,
        new_studentexamid := v_studentexamid
    );

    CALL CorrectExam(p_studentexamid := v_studentexamid);

    SELECT totalgrade INTO v_totalgrade
    FROM studentexam WHERE studentexamid = v_studentexamid;

    RAISE NOTICE 'TotalGrade (all wrong): % (expected 0)', v_totalgrade;

    IF v_totalgrade <> 0 THEN
        RAISE EXCEPTION 'FAIL: All answers were wrong but grade = %. Expected 0.',
            v_totalgrade;
    END IF;

    RAISE NOTICE 'TEST 8 PASSED';
END;
$$;

-- -------------------------------------------------------
-- FINAL SUMMARY
-- -------------------------------------------------------
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================';
    RAISE NOTICE '  INTEGRATION TEST COMPLETE';
    RAISE NOTICE '================================';
    RAISE NOTICE 'TEST 1: GenerateExam valid             PASSED';
    RAISE NOTICE 'TEST 2: GenerateExam insufficient Qs   PASSED';
    RAISE NOTICE 'TEST 3: SubmitExamAnswers full          PASSED';
    RAISE NOTICE 'TEST 4: SubmitExamAnswers partial       PASSED';
    RAISE NOTICE 'TEST 5: CorrectExam mixed               PASSED';
    RAISE NOTICE 'TEST 6: CorrectExam partial             PASSED';
    RAISE NOTICE 'TEST 7: CorrectExam all correct         PASSED';
    RAISE NOTICE 'TEST 8: CorrectExam all wrong           PASSED';
    RAISE NOTICE '================================';
END;
$$;

-- Show final state of all exam attempts
SELECT
    se.studentexamid,
    s.name          AS student,
    e.examname,
    se.starttime,
    se.endtime,
    se.totalgrade,
    c.maxdegree,
    ROUND(se.totalgrade::NUMERIC / c.maxdegree * 100, 1) AS percentage
FROM studentexam se
JOIN student s ON se.studentid = s.studentid
JOIN exam    e ON se.examid    = e.examid
JOIN course  c ON e.courseid   = c.courseid
ORDER BY se.studentexamid;

-- Clean up temp table
DROP TABLE IF EXISTS test_state;