CREATE TABLE Student (
    StudentID   SERIAL          PRIMARY KEY,
    Name        TEXT            COLLATE arabic_icu NOT NULL,
    Email       TEXT            NOT NULL UNIQUE,
    Phone       TEXT
);

CREATE TABLE Instructor (
    InstructorID    SERIAL      PRIMARY KEY,
    Name            TEXT        COLLATE arabic_icu NOT NULL,
    Email           TEXT        NOT NULL UNIQUE,
    DepartmentNo    INT ,

    CONSTRAINT fk_instructor_department
        FOREIGN KEY (DepartmentNo)
        REFERENCES Department (DepartmentID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Student_Track (
    StudentID   INT     NOT NULL,
    TrackID     INT     NOT NULL,

    CONSTRAINT pk_student_track
        PRIMARY KEY (StudentID, TrackID),

    CONSTRAINT fk_st_student
        FOREIGN KEY (StudentID)
        REFERENCES Student (StudentID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_st_track
        FOREIGN KEY (TrackID)
        REFERENCES Track (TrackID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX idx_st_trackid ON student_track(trackid);


CREATE TABLE Instructor_Course (
    InstructorID    INT     NOT NULL,
    CourseID        INT     NOT NULL,

    CONSTRAINT pk_instructor_course
        PRIMARY KEY (InstructorID, CourseID),

    CONSTRAINT fk_ic_instructor
        FOREIGN KEY (InstructorID)
        REFERENCES Instructor (InstructorID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_ic_course
        FOREIGN KEY (CourseID)
        REFERENCES Course (CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_ic_instructorid ON instructor_course(instructorid);
CREATE INDEX idx_ic_courseid ON instructor_course(courseid);
