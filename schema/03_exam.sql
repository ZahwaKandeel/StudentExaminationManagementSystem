CREATE TABLE question (
    questionid    SERIAL          PRIMARY KEY,
    courseid      INT             NOT NULL,
    questiontext  TEXT            COLLATE arabic_icu NOT NULL,
    type          TEXT            NOT NULL,
    points        INT             NOT NULL DEFAULT 1,

    
    CONSTRAINT fk_question_course
        FOREIGN KEY (courseid)
        REFERENCES course(courseid)
        ON DELETE RESTRICT,

    
    CONSTRAINT chk_question_type
        CHECK (type IN ('MCQ', 'TF')),

    
    CONSTRAINT chk_question_points
        CHECK (points > 0)
);

CREATE INDEX idx_question_courseid ON question(courseid);
CREATE INDEX idx_question_type     ON question(type);

CREATE TABLE choice (
    optionid      SERIAL    PRIMARY KEY,
    questionid    INT       NOT NULL,
    optiontext    TEXT      COLLATE arabic_icu NOT NULL,
    optionorder   INT       NOT NULL,

    
    CONSTRAINT fk_choice_question
        FOREIGN KEY (questionid)
        REFERENCES question(questionid)
        ON DELETE CASCADE,

    
    CONSTRAINT chk_choice_order
        CHECK (optionorder BETWEEN 1 AND 4),

   
    CONSTRAINT uq_choice_order
        UNIQUE (questionid, optionorder)
);

CREATE INDEX idx_choice_questionid ON choice(questionid);

CREATE TABLE modelanswer (
    questionid      INT    NOT NULL,
    correctoptionid INT    NOT NULL,

    
    CONSTRAINT pk_modelanswer
        PRIMARY KEY (questionid),

    
    CONSTRAINT fk_modelanswer_question
        FOREIGN KEY (questionid)
        REFERENCES question(questionid)
        ON DELETE CASCADE,

    
    CONSTRAINT fk_modelanswer_choice
        FOREIGN KEY (correctoptionid)
        REFERENCES choice(optionid)
        ON DELETE CASCADE
);

CREATE TABLE exam (
    examid          SERIAL      PRIMARY KEY,
    examname        TEXT        COLLATE arabic_icu NOT NULL,
    courseid        INT         NOT NULL,
    createddate     TIMESTAMP   NOT NULL DEFAULT NOW(),
    totalquestions  INT         NOT NULL,

    CONSTRAINT fk_exam_course
        FOREIGN KEY (courseid)
        REFERENCES course(courseid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_exam_totalquestions
        CHECK (totalquestions > 0)
);

CREATE INDEX idx_exam_courseid ON exam(courseid);

CREATE TABLE examquestion (
    examid      INT    NOT NULL,
    questionid  INT    NOT NULL,
    orderno     INT    NOT NULL,

    
    CONSTRAINT pk_examquestion
        PRIMARY KEY (examid, questionid),

    CONSTRAINT fk_examquestion_exam
        FOREIGN KEY (examid)
        REFERENCES exam(examid)
        ON DELETE CASCADE,

    
    CONSTRAINT fk_examquestion_question
        FOREIGN KEY (questionid)
        REFERENCES question(questionid)
        ON DELETE RESTRICT,

    
    CONSTRAINT uq_examquestion_order
        UNIQUE (examid, orderno),

    CONSTRAINT chk_examquestion_order
        CHECK (orderno > 0)
);

CREATE INDEX idx_examquestion_examid ON examquestion(examid);

CREATE TABLE studentexam (
    studentexamid   SERIAL      PRIMARY KEY,
    studentid       INT         NOT NULL,
    examid          INT         NOT NULL,
    starttime       TIMESTAMP   NOT NULL,
    endtime         TIMESTAMP,
    totalgrade      INT         DEFAULT 0,

    
    CONSTRAINT uq_studentexam
        UNIQUE (studentid, examid),

    CONSTRAINT fk_studentexam_student
        FOREIGN KEY (studentid)
        REFERENCES student(studentid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_studentexam_exam
        FOREIGN KEY (examid)
        REFERENCES exam(examid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_studentexam_grade
        CHECK (totalgrade >= 0),

    
    CONSTRAINT chk_studentexam_times
        CHECK (endtime IS NULL OR endtime > starttime)
);

CREATE INDEX idx_studentexam_studentid ON studentexam(studentid);
CREATE INDEX idx_studentexam_examid    ON studentexam(examid);

CREATE TABLE studentanswer (
    studentanswerid   SERIAL    PRIMARY KEY,
    studentexamid     INT       NOT NULL,
    questionid        INT       NOT NULL,
    chosenoptionid    INT       NOT NULL,

    
    CONSTRAINT uq_studentanswer
        UNIQUE (studentexamid, questionid),

    CONSTRAINT fk_studentanswer_studentexam
        FOREIGN KEY (studentexamid)
        REFERENCES studentexam(studentexamid)
        ON DELETE CASCADE,

    CONSTRAINT fk_studentanswer_question
        FOREIGN KEY (questionid)
        REFERENCES question(questionid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_studentanswer_choice
        FOREIGN KEY (chosenoptionid)
        REFERENCES choice(optionid)
        ON DELETE RESTRICT
);

CREATE INDEX idx_studentanswer_studentexamid ON studentanswer(studentexamid);