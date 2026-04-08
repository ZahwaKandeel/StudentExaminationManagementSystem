
-- ===================== Question procedures ======================
-- =============================================================
-- Procedure : InsertQuestion
-- Purpose   : Insert a new question into the question bank
-- Parameters:
--   p_courseid     INT    - The course this question belongs to
--   p_questiontext TEXT   - Full question body (Arabic or English)
--   p_type         TEXT   - 'MCQ' or 'TF'
--   p_points       INT    - Score for correct answer (default 1)
-- Returns   : The new questionid via OUT parameter
-- Exceptions:
--   - Raises error if p_type is not 'MCQ' or 'TF'
--   - Raises error if p_courseid does not exist
--   - Raises error if p_points <= 0
-- =============================================================

CREATE OR REPLACE PROCEDURE InsertQuestion(
    p_courseid      INT,
    p_questiontext  TEXT,
    p_type          TEXT,
    p_points        INT DEFAULT 1,
    OUT new_questionid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate type manually (belt-and-suspenders on top of CHECK constraint)
    IF p_type NOT IN ('MCQ', 'TF') THEN
        RAISE EXCEPTION 'Invalid question type: %. Must be MCQ or TF.', p_type;
    END IF;

    -- Validate points
    IF p_points <= 0 THEN
        RAISE EXCEPTION 'Points must be greater than 0. Got: %', p_points;
    END IF;

    -- Validate course exists
    IF NOT EXISTS (SELECT 1 FROM course WHERE courseid = p_courseid) THEN
        RAISE EXCEPTION 'Course with ID % does not exist.', p_courseid;
    END IF;

    -- Insert the question
    INSERT INTO question (courseid, questiontext, type, points)
    VALUES (p_courseid, p_questiontext, p_type, p_points)
    RETURNING questionid INTO new_questionid;

    RAISE NOTICE 'Question inserted successfully. ID: %', new_questionid;
END;
$$;



-- Declare a variable to receive the OUT parameter
DO $$
DECLARE
    v_id INT;
BEGIN
    CALL InsertQuestion(
        p_courseid     := 1,
        p_questiontext := 'What is the primary key in PostgreSQL?',
        p_type         := 'MCQ',
        p_points       := 2,
        new_questionid := v_id
    );
    RAISE NOTICE 'New question ID is: %', v_id;
END;
$$;

-- =============================================================
-- Procedure : UpdateQuestion
-- Purpose   : Update the text, type, or points of a question
-- Parameters:
--   p_questionid   INT  - The question to update
--   p_questiontext TEXT - New question body (pass NULL to keep existing)
--   p_type         TEXT - New type (pass NULL to keep existing)
--   p_points       INT  - New points (pass NULL to keep existing)
-- Returns   : Nothing
-- Exceptions:
--   - Raises error if question does not exist
--   - Raises error if new type is invalid
-- =============================================================

CREATE OR REPLACE PROCEDURE UpdateQuestion(
    p_questionid    INT,
    p_questiontext  TEXT    DEFAULT NULL,
    p_type          TEXT    DEFAULT NULL,
    p_points        INT     DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check question exists
    IF NOT EXISTS (SELECT 1 FROM question WHERE questionid = p_questionid) THEN
        RAISE EXCEPTION 'Question with ID % does not exist.', p_questionid;
    END IF;

    -- Validate new type if provided
    IF p_type IS NOT NULL AND p_type NOT IN ('MCQ', 'TF') THEN
        RAISE EXCEPTION 'Invalid type: %. Must be MCQ or TF.', p_type;
    END IF;

    -- Validate new points if provided
    IF p_points IS NOT NULL AND p_points <= 0 THEN
        RAISE EXCEPTION 'Points must be greater than 0. Got: %', p_points;
    END IF;

    -- Update only the columns that were passed (COALESCE keeps existing value if NULL)
    UPDATE question
    SET
        questiontext = COALESCE(p_questiontext, questiontext),
        type         = COALESCE(p_type, type),
        points       = COALESCE(p_points, points)
    WHERE questionid = p_questionid;

    RAISE NOTICE 'Question % updated successfully.', p_questionid;
END;
$$;



-- Update only the points, keep everything else the same
CALL UpdateQuestion(
    p_questionid := 5,
    p_points     := 3
);

-- Update text and type together
CALL UpdateQuestion(
    p_questionid   := 5,
    p_questiontext := 'Updated question text here',
    p_type         := 'TF'
);

-- =============================================================
-- Procedure : DeleteQuestion
-- Purpose   : Delete a question and all its related data
-- Parameters:
--   p_questionid INT - The question to delete
-- Returns   : Nothing
-- Exceptions:
--   - Raises error if question does not exist
--   - Raises error if question is currently used in an exam
--     (FK RESTRICT on examquestion will block it)
-- Notes     :
--   Deleting a question automatically cascades to:
--   choice (CASCADE) and modelanswer (CASCADE)
-- =============================================================

CREATE OR REPLACE PROCEDURE DeleteQuestion(
    p_questionid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check question exists
    IF NOT EXISTS (SELECT 1 FROM question WHERE questionid = p_questionid) THEN
        RAISE EXCEPTION 'Question with ID % does not exist.', p_questionid;
    END IF;

    -- Check it is not used in any exam (FK is RESTRICT so this would fail anyway,
    -- but we give a clear message instead of a raw FK violation error)
    IF EXISTS (SELECT 1 FROM examquestion WHERE questionid = p_questionid) THEN
        RAISE EXCEPTION
            'Cannot delete question %. It is used in one or more exams.
             Remove it from all exams first.', p_questionid;
    END IF;

    -- Delete the question
    -- choice and modelanswer rows are removed automatically via CASCADE
    DELETE FROM question WHERE questionid = p_questionid;

    RAISE NOTICE 'Question % deleted. Associated choices and model answer removed.', p_questionid;
END;
$$;

C

-- =============================================================
-- Function  : SelectQuestionsByCourse
-- Purpose   : Return all questions for a given course
-- Parameters:
--   p_courseid INT - Filter by this course
--   p_type     TEXT - Optional filter: 'MCQ', 'TF', or NULL for all
-- Returns   : Table of question rows
-- =============================================================

CREATE OR REPLACE FUNCTION SelectQuestionsByCourse(
    p_courseid  INT,
    p_type      TEXT DEFAULT NULL
)
RETURNS TABLE (
    questionid    INT,
    questiontext  TEXT,
    type          TEXT,
    points        INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        q.questionid,
        q.questiontext,
        q.type,
        q.points
    FROM question q
    WHERE q.courseid = p_courseid
      AND (p_type IS NULL OR q.type = p_type)
    ORDER BY q.questionid;
END;
$$;



-- Get all questions for course 1
SELECT * FROM SelectQuestionsByCourse(1);

-- Get only MCQ questions for course 1
SELECT * FROM SelectQuestionsByCourse(1, 'MCQ');

-- Count how many TF questions are available (used before GenerateExam)
SELECT COUNT(*) FROM SelectQuestionsByCourse(1, 'TF');


-- ===================== Choice procedures ======================

-- =============================================================
-- Procedure : InsertOption
-- Purpose   : Insert one answer choice for a question
-- Parameters:
--   p_questionid  INT  - The question this choice belongs to
--   p_optiontext  TEXT - The answer text
--   p_optionorder INT  - Display order (1-4 for MCQ, 1-2 for TF)
-- Returns   : The new optionid via OUT parameter
-- Exceptions:
--   - Raises error if question does not exist
--   - Raises error if optionorder already exists for this question
--   - Raises error if MCQ already has 4 choices
--   - Raises error if TF already has 2 choices
-- =============================================================

CREATE OR REPLACE PROCEDURE InsertOption(
    p_questionid  INT,
    p_optiontext  TEXT,
    p_optionorder INT,
    OUT new_optionid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_type          TEXT;
    v_max_choices   INT;
    v_current_count INT;
BEGIN
    -- Check question exists and get its type
    SELECT type INTO v_type
    FROM question
    WHERE questionid = p_questionid;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Question with ID % does not exist.', p_questionid;
    END IF;

    -- Set max allowed choices based on question type
    v_max_choices := CASE v_type
        WHEN 'MCQ' THEN 4
        WHEN 'TF'  THEN 2
    END;

    -- Count existing choices for this question
    SELECT COUNT(*) INTO v_current_count
    FROM choice
    WHERE questionid = p_questionid;

    -- Block if already at max
    IF v_current_count >= v_max_choices THEN
        RAISE EXCEPTION
            'Question % is type % and already has % choices (maximum).
             Cannot add more.',
            p_questionid, v_type, v_max_choices;
    END IF;

    -- Validate optionorder range
    IF p_optionorder < 1 OR p_optionorder > v_max_choices THEN
        RAISE EXCEPTION
            'Invalid optionorder % for type %. Must be between 1 and %.',
            p_optionorder, v_type, v_max_choices;
    END IF;

    -- Insert the choice
    INSERT INTO choice (questionid, optiontext, optionorder)
    VALUES (p_questionid, p_optiontext, p_optionorder)
    RETURNING optionid INTO new_optionid;

    RAISE NOTICE 'Choice inserted. ID: %, Order: %', new_optionid, p_optionorder;
END;
$$;




-- Insert all 4 choices for an MCQ question
DO $$
DECLARE v_id INT;
BEGIN
    CALL InsertOption(1, 'Primary key',        1, v_id);
    CALL InsertOption(1, 'Foreign key',        2, v_id);
    CALL InsertOption(1, 'Unique constraint',  3, v_id);
    CALL InsertOption(1, 'Check constraint',   4, v_id);
END;
$$;

-- Insert 2 choices for a TF question
DO $$
DECLARE v_id INT;
BEGIN
    CALL InsertOption(2, 'True',  1, v_id);
    CALL InsertOption(2, 'False', 2, v_id);
END;
$$;

-- =============================================================
-- Procedure : UpdateOption
-- Purpose   : Update the text of an existing choice
-- Parameters:
--   p_optionid   INT  - The choice to update
--   p_optiontext TEXT - New text for this choice
-- Returns   : Nothing
-- Exceptions:
--   - Raises error if choice does not exist
-- =============================================================

CREATE OR REPLACE PROCEDURE UpdateOption(
    p_optionid   INT,
    p_optiontext TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM choice WHERE optionid = p_optionid) THEN
        RAISE EXCEPTION 'Choice with ID % does not exist.', p_optionid;
    END IF;

    UPDATE choice
    SET optiontext = p_optiontext
    WHERE optionid = p_optionid;

    RAISE NOTICE 'Choice % updated successfully.', p_optionid;
END;
$$;



-- =============================================================
-- Procedure : DeleteOption
-- Purpose   : Delete a single answer choice
-- Parameters:
--   p_optionid INT - The choice to delete
-- Returns   : Nothing
-- Exceptions:
--   - Raises error if choice does not exist
--   - Raises error if this choice is the current model answer
--   - Raises error if this choice has been selected by a student
-- =============================================================

CREATE OR REPLACE PROCEDURE DeleteOption(
    p_optionid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM choice WHERE optionid = p_optionid) THEN
        RAISE EXCEPTION 'Choice with ID % does not exist.', p_optionid;
    END IF;

    -- Block if this choice is the current correct answer
    IF EXISTS (SELECT 1 FROM modelanswer WHERE correctoptionid = p_optionid) THEN
        RAISE EXCEPTION
            'Cannot delete choice %. It is set as the correct model answer.
             Call SetModelAnswer to change the correct answer first.', p_optionid;
    END IF;

    -- Block if a student has already selected this choice
    IF EXISTS (SELECT 1 FROM studentanswer WHERE chosenoptionid = p_optionid) THEN
        RAISE EXCEPTION
            'Cannot delete choice %. It has been selected by one or more students.',
            p_optionid;
    END IF;

    DELETE FROM choice WHERE optionid = p_optionid;

    RAISE NOTICE 'Choice % deleted successfully.', p_optionid;
END;
$$;





-- =============================================================
-- Function  : SelectOptionsByQuestion
-- Purpose   : Return all choices for a given question
-- Parameters:
--   p_questionid INT - The question to fetch choices for
-- Returns   : Table of choice rows ordered by optionorder
-- =============================================================

CREATE OR REPLACE FUNCTION SelectOptionsByQuestion(
    p_questionid INT
)
RETURNS TABLE (
    optionid    INT,
    optiontext  TEXT,
    optionorder INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM question WHERE questionid = p_questionid) THEN
        RAISE EXCEPTION 'Question with ID % does not exist.', p_questionid;
    END IF;

    RETURN QUERY
    SELECT
        c.optionid,
        c.optiontext,
        c.optionorder
    FROM choice c
    WHERE c.questionid = p_questionid
    ORDER BY c.optionorder;
END;
$$;



-- ===================== SetModelAnswer ======================

-- =============================================================
-- Procedure : SetModelAnswer
-- Purpose   : Set or replace the correct answer for a question
-- Parameters:
--   p_questionid     INT - The question to set the answer for
--   p_correctoptionid INT - The choice that is the correct answer
-- Returns   : Nothing
-- Exceptions:
--   - Raises error if question does not exist
--   - Raises error if choice does not exist
--   - Raises error if choice does not belong to the question
--     (this is the cross-check PostgreSQL cannot do automatically)
-- Notes     :
--   Uses INSERT ... ON CONFLICT to handle both insert and update
--   in one statement. Safe to call multiple times on same question.
-- =============================================================

CREATE OR REPLACE PROCEDURE SetModelAnswer(
    p_questionid      INT,
    p_correctoptionid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_belongs BOOLEAN;
BEGIN
    -- Validate question exists
    IF NOT EXISTS (SELECT 1 FROM question WHERE questionid = p_questionid) THEN
        RAISE EXCEPTION 'Question with ID % does not exist.', p_questionid;
    END IF;

    -- Validate choice exists
    IF NOT EXISTS (SELECT 1 FROM choice WHERE optionid = p_correctoptionid) THEN
        RAISE EXCEPTION 'Choice with ID % does not exist.', p_correctoptionid;
    END IF;

    -- THE CRITICAL CHECK:
    -- Verify the choice actually belongs to this question
    -- PostgreSQL FK cannot enforce this cross-relationship automatically
    SELECT EXISTS (
        SELECT 1 FROM choice
        WHERE optionid   = p_correctoptionid
          AND questionid = p_questionid
    ) INTO v_belongs;

    IF NOT v_belongs THEN
        RAISE EXCEPTION
            'Choice % does not belong to question %.
             The correct answer must be one of the question''s own choices.',
            p_correctoptionid, p_questionid;
    END IF;

    -- Insert or update the model answer
    -- ON CONFLICT handles the case where a model answer already exists
    -- and we are replacing it with a new correct answer
    INSERT INTO modelanswer (questionid, correctoptionid)
    VALUES (p_questionid, p_correctoptionid)
    ON CONFLICT (questionid)
    DO UPDATE SET correctoptionid = EXCLUDED.correctoptionid;

    RAISE NOTICE 'Model answer set for question %. Correct choice: %',
        p_questionid, p_correctoptionid;
END;
$$;



-- Set the correct answer for question 1 to option 3
CALL SetModelAnswer(
    p_questionid      := 1,
    p_correctoptionid := 3
);

-- Change the correct answer later (safe, uses ON CONFLICT)
CALL SetModelAnswer(
    p_questionid      := 1,
    p_correctoptionid := 1
);

