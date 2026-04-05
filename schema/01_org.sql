CREATE TABLE Course (
	CourseID SERIAL PRIMARY KEY,
	CourseName TEXT NOT NULL,
	MinDegree INT,
	MaxDegree INT
	
	CONSTRAINT chk_course_degree
	CHECK (MinDegree >= 0 AND MaxDegree > MinDegree)
);

CREATE TABLE Department(
	DepartmentID SERIAL PRIMARY KEY,
	DepartmentName TEXT NOT NULL,
	Location TEXT
);

CREATE TABLE Track(
	TrackID SERIAL PRIMARY KEY,
	TrackName TEXT NOT NULL,
	DepartmentID INT,
	
	CONSTRAINT fk_track_department
		FOREIGN KEY (DepartmentID)
		REFERENCES Department(DepartmentID)
		ON DELETE CASCADE
);

CREATE TABLE Track_Course (
    TrackID INT,
    CourseID INT,

    PRIMARY KEY (TrackID, CourseID),

    CONSTRAINT fk_tc_track
        FOREIGN KEY (TrackID)
        REFERENCES Track(TrackID)
        ON DELETE CASCADE,

    CONSTRAINT fk_tc_course
        FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID)
        ON DELETE CASCADE
);
