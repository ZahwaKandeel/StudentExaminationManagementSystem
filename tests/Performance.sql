-- =============================================================
-- File    : tests/Performance.sql
-- Purpose : Full Performance test for the exam lifecycle
--           GenerateExam → SubmitExamAnswers → CorrectExam
-- Run after: all schema, procs, and seed data are loaded
-- =============================================================

--===========================================================
--  NFR-01  Exam generation (up to 50 questions) < 2 seconds 
--NFR-02  Exam correction per student < 1 second
--===========================================================

--============================================================
--  Insert 30 MCQ and 20 TF question to a course for testing
--============================================================

DO $$
DECLARE
    v_qid INT;
    v_o1  INT;
    v_o2  INT;
    v_o3  INT;
    v_o4  INT;

    -- Course ID variables resolved by name (matches seed_org.sql insertions)
    v_c_se   INT;   -- 'Software Engineering Fundamentals'
BEGIN
-- ============================================================
-- Course: Software Engineering Fundamentals
-- ============================================================
CALL InsertCourse('Software Engineering Fundamentals',        50, 100);

SELECT courseid INTO v_c_se FROM course WHERE coursename = 'Software Engineering Fundamentals';


-- ============================================================
-- MCQ QUESTIONS (30)
-- ============================================================

-- Q1
CALL InsertQuestion(v_qid, v_c_se, 'What does SDLC stand for?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Software Development Life Cycle',    1, v_o1);
CALL InsertOption(v_qid, 'System Design Language Compiler',    2, v_o2);
CALL InsertOption(v_qid, 'Software Design Logic Concept',      3, v_o3);
CALL InsertOption(v_qid, 'Structured Development Logic Cycle', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o1); -- Software Development Life Cycle

-- Q2
CALL InsertQuestion(v_qid, v_c_se, 'Which SDLC phase involves gathering requirements from stakeholders?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Design',                1, v_o1);
CALL InsertOption(v_qid, 'Testing',               2, v_o2);
CALL InsertOption(v_qid, 'Requirements Analysis', 3, v_o3);
CALL InsertOption(v_qid, 'Deployment',            4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Requirements Analysis

-- Q3
CALL InsertQuestion(v_qid, v_c_se, 'Which SDLC model follows a strict linear sequential flow of phases?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Agile',     1, v_o1);
CALL InsertOption(v_qid, 'Spiral',    2, v_o2);
CALL InsertOption(v_qid, 'Waterfall', 3, v_o3);
CALL InsertOption(v_qid, 'Scrum',     4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Waterfall

-- Q4
CALL InsertQuestion(v_qid, v_c_se, 'What is the main purpose of version control?', 'MCQ', 1);
CALL InsertOption(v_qid, 'To test software',                    1, v_o1);
CALL InsertOption(v_qid, 'To track and manage changes to code', 2, v_o2);
CALL InsertOption(v_qid, 'To deploy applications',              3, v_o3);
CALL InsertOption(v_qid, 'To write documentation',              4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- To track and manage changes to code

-- Q5
CALL InsertQuestion(v_qid, v_c_se, 'Which of the following is a popular distributed version control system?', 'MCQ', 1);
CALL InsertOption(v_qid, 'MySQL',  1, v_o1);
CALL InsertOption(v_qid, 'Git',    2, v_o2);
CALL InsertOption(v_qid, 'Apache', 3, v_o3);
CALL InsertOption(v_qid, 'Docker', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Git

-- Q6
CALL InsertQuestion(v_qid, v_c_se, 'What does UML stand for?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Universal Modeling Language', 1, v_o1);
CALL InsertOption(v_qid, 'Unified Modeling Language',   2, v_o2);
CALL InsertOption(v_qid, 'Unified Machine Logic',       3, v_o3);
CALL InsertOption(v_qid, 'Universal Machine Language',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Unified Modeling Language

-- Q7
CALL InsertQuestion(v_qid, v_c_se, 'Which UML diagram is used to show the structure of a system''s classes and relationships?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Use Case Diagram', 1, v_o1);
CALL InsertOption(v_qid, 'Sequence Diagram', 2, v_o2);
CALL InsertOption(v_qid, 'Class Diagram',    3, v_o3);
CALL InsertOption(v_qid, 'Activity Diagram', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Class Diagram

-- Q8
CALL InsertQuestion(v_qid, v_c_se, 'What is a "bug" in software?', 'MCQ', 1);
CALL InsertOption(v_qid, 'A feature request',              1, v_o1);
CALL InsertOption(v_qid, 'An error or flaw in software',   2, v_o2);
CALL InsertOption(v_qid, 'A design pattern',               3, v_o3);
CALL InsertOption(v_qid, 'A type of database',             4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- An error or flaw in software

-- Q9
CALL InsertQuestion(v_qid, v_c_se, 'Which type of testing is performed by end users before a product is officially released?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Unit Testing',             1, v_o1);
CALL InsertOption(v_qid, 'Integration Testing',      2, v_o2);
CALL InsertOption(v_qid, 'System Testing',           3, v_o3);
CALL InsertOption(v_qid, 'User Acceptance Testing',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o4); -- User Acceptance Testing

-- Q10
CALL InsertQuestion(v_qid, v_c_se, 'What is the main goal of software testing?', 'MCQ', 1);
CALL InsertOption(v_qid, 'To write more code',       1, v_o1);
CALL InsertOption(v_qid, 'To find and fix defects',  2, v_o2);
CALL InsertOption(v_qid, 'To deploy software',       3, v_o3);
CALL InsertOption(v_qid, 'To gather requirements',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- To find and fix defects

-- Q11
CALL InsertQuestion(v_qid, v_c_se, 'Which Agile framework organizes work into short cycles called sprints?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Waterfall', 1, v_o1);
CALL InsertOption(v_qid, 'Scrum',     2, v_o2);
CALL InsertOption(v_qid, 'V-Model',   3, v_o3);
CALL InsertOption(v_qid, 'RAD',       4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Scrum

-- Q12
CALL InsertQuestion(v_qid, v_c_se, 'What is a use case in software engineering?', 'MCQ', 1);
CALL InsertOption(v_qid, 'A type of bug',                                     1, v_o1);
CALL InsertOption(v_qid, 'A description of how a user interacts with a system', 2, v_o2);
CALL InsertOption(v_qid, 'A programming language',                              3, v_o3);
CALL InsertOption(v_qid, 'A database table',                                    4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- A description of how a user interacts with a system

-- Q13
CALL InsertQuestion(v_qid, v_c_se, 'What does IDE stand for?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Integrated Development Environment', 1, v_o1);
CALL InsertOption(v_qid, 'Internal Design Engine',             2, v_o2);
CALL InsertOption(v_qid, 'Internet Development Engine',        3, v_o3);
CALL InsertOption(v_qid, 'Integrated Design Editor',           4, v_o4);
CALL SetModelAnswer(v_qid, v_o1); -- Integrated Development Environment

-- Q14
CALL InsertQuestion(v_qid, v_c_se, 'Which of the following is an example of an IDE?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Google Chrome',      1, v_o1);
CALL InsertOption(v_qid, 'Visual Studio Code', 2, v_o2);
CALL InsertOption(v_qid, 'Microsoft Word',     3, v_o3);
CALL InsertOption(v_qid, 'VLC Media Player',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Visual Studio Code

-- Q15
CALL InsertQuestion(v_qid, v_c_se, 'What is "refactoring" in software engineering?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Rewriting software completely from scratch',              1, v_o1);
CALL InsertOption(v_qid, 'Improving code structure without changing its behavior',  2, v_o2);
CALL InsertOption(v_qid, 'Adding new features to the software',                     3, v_o3);
CALL InsertOption(v_qid, 'Deploying the application to production',                 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Improving code structure without changing its behavior

-- Q16
CALL InsertQuestion(v_qid, v_c_se, 'What is a software prototype?', 'MCQ', 1);
CALL InsertOption(v_qid, 'The final released version of software',               1, v_o1);
CALL InsertOption(v_qid, 'An early model of software used to test concepts',     2, v_o2);
CALL InsertOption(v_qid, 'A type of software bug',                               3, v_o3);
CALL InsertOption(v_qid, 'A version control branch',                             4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- An early model of software used to test concepts

-- Q17
CALL InsertQuestion(v_qid, v_c_se, 'Which document formally describes what a software system must do?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Test Plan',                                   1, v_o1);
CALL InsertOption(v_qid, 'Software Requirements Specification (SRS)',   2, v_o2);
CALL InsertOption(v_qid, 'Source Code File',                            3, v_o3);
CALL InsertOption(v_qid, 'Deployment Manual',                           4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Software Requirements Specification (SRS)

-- Q18
CALL InsertQuestion(v_qid, v_c_se, 'Which of the following is an example of a functional requirement?', 'MCQ', 1);
CALL InsertOption(v_qid, 'The system shall process 1000 requests per second', 1, v_o1);
CALL InsertOption(v_qid, 'The system shall allow users to reset their password', 2, v_o2);
CALL InsertOption(v_qid, 'The system should be available 99.9% of the time',  3, v_o3);
CALL InsertOption(v_qid, 'The system should load pages within 2 seconds',     4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- The system shall allow users to reset their password

-- Q19
CALL InsertQuestion(v_qid, v_c_se, 'What does "open source" software mean?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Software that is very expensive',                      1, v_o1);
CALL InsertOption(v_qid, 'Software whose source code is publicly available',     2, v_o2);
CALL InsertOption(v_qid, 'Software that contains no bugs',                       3, v_o3);
CALL InsertOption(v_qid, 'Software intended only for large businesses',          4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Software whose source code is publicly available

-- Q20
CALL InsertQuestion(v_qid, v_c_se, 'In the Waterfall model, which phase comes immediately after Design?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Requirements', 1, v_o1);
CALL InsertOption(v_qid, 'Testing',      2, v_o2);
CALL InsertOption(v_qid, 'Implementation', 3, v_o3);
CALL InsertOption(v_qid, 'Maintenance',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Implementation

-- Q21
CALL InsertQuestion(v_qid, v_c_se, 'What is the purpose of code documentation?', 'MCQ', 1);
CALL InsertOption(v_qid, 'To make code execute faster',                       1, v_o1);
CALL InsertOption(v_qid, 'To explain code functionality to developers',       2, v_o2);
CALL InsertOption(v_qid, 'To automatically test the code',                    3, v_o3);
CALL InsertOption(v_qid, 'To deploy the application',                         4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- To explain code functionality to developers

-- Q22
CALL InsertQuestion(v_qid, v_c_se, 'What best describes "software architecture"?', 'MCQ', 1);
CALL InsertOption(v_qid, 'The physical office where developers work',                        1, v_o1);
CALL InsertOption(v_qid, 'The high-level structure and organization of a software system',   2, v_o2);
CALL InsertOption(v_qid, 'The full list of known software bugs',                             3, v_o3);
CALL InsertOption(v_qid, 'The graphical design of the user interface',                       4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- The high-level structure and organization of a software system

-- Q23
CALL InsertQuestion(v_qid, v_c_se, 'What is "black-box testing"?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Testing with full knowledge of the source code',      1, v_o1);
CALL InsertOption(v_qid, 'Testing without knowledge of internal implementation', 2, v_o2);
CALL InsertOption(v_qid, 'Testing performed only at night',                     3, v_o3);
CALL InsertOption(v_qid, 'Testing limited to the database layer only',          4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Testing without knowledge of internal implementation

-- Q24
CALL InsertQuestion(v_qid, v_c_se, 'What does "deployment" mean in software engineering?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Writing the application code',         1, v_o1);
CALL InsertOption(v_qid, 'Releasing software for users to use',  2, v_o2);
CALL InsertOption(v_qid, 'Designing the database schema',        3, v_o3);
CALL InsertOption(v_qid, 'Gathering user requirements',          4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Releasing software for users to use

-- Q25
CALL InsertQuestion(v_qid, v_c_se, 'What is the role of a software project manager?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Only writing application code',                              1, v_o1);
CALL InsertOption(v_qid, 'Planning, coordinating, and overseeing the software project', 2, v_o2);
CALL InsertOption(v_qid, 'Only performing software testing',                           3, v_o3);
CALL InsertOption(v_qid, 'Only designing the user interface',                          4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Planning, coordinating, and overseeing the software project

-- Q26
CALL InsertQuestion(v_qid, v_c_se, 'Which of the following is a non-functional requirement?', 'MCQ', 1);
CALL InsertOption(v_qid, 'The system shall allow users to log in',                   1, v_o1);
CALL InsertOption(v_qid, 'The system shall process 1000 transactions per second',   2, v_o2);
CALL InsertOption(v_qid, 'The system shall send email notifications',                3, v_o3);
CALL InsertOption(v_qid, 'The system shall display a registration form',             4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- The system shall process 1000 transactions per second

-- Q27
CALL InsertQuestion(v_qid, v_c_se, 'What is "unit testing"?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Testing the entire system as a whole',          1, v_o1);
CALL InsertOption(v_qid, 'Testing individual components or functions',    2, v_o2);
CALL InsertOption(v_qid, 'Testing done by end users',                     3, v_o3);
CALL InsertOption(v_qid, 'Testing the network infrastructure',            4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Testing individual components or functions

-- Q28
CALL InsertQuestion(v_qid, v_c_se, 'What is a software development methodology?', 'MCQ', 1);
CALL InsertOption(v_qid, 'A specific programming language',                        1, v_o1);
CALL InsertOption(v_qid, 'A structured approach to planning and building software', 2, v_o2);
CALL InsertOption(v_qid, 'A type of relational database',                          3, v_o3);
CALL InsertOption(v_qid, 'An automated testing tool',                              4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- A structured approach to planning and building software

-- Q29
CALL InsertQuestion(v_qid, v_c_se, 'What is a "sprint" in the Scrum framework?', 'MCQ', 1);
CALL InsertOption(v_qid, 'A critical software bug',                    1, v_o1);
CALL InsertOption(v_qid, 'A short, time-boxed development iteration',  2, v_o2);
CALL InsertOption(v_qid, 'A production deployment step',               3, v_o3);
CALL InsertOption(v_qid, 'A category of software tests',               4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- A short, time-boxed development iteration

-- Q30
CALL InsertQuestion(v_qid, v_c_se, 'What is "maintenance" in the context of the SDLC?', 'MCQ', 1);
CALL InsertOption(v_qid, 'Writing the initial requirements',                      1, v_o1);
CALL InsertOption(v_qid, 'Updating and fixing software after it is released',     2, v_o2);
CALL InsertOption(v_qid, 'Designing the application user interface',              3, v_o3);
CALL InsertOption(v_qid, 'Writing test cases before development',                 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Updating and fixing software after it is released


-- ============================================================
-- TRUE / FALSE QUESTIONS (20)
-- ============================================================

-- TF1
CALL InsertQuestion(v_qid, v_c_se, 'The Waterfall model allows teams to easily go back to a previous phase at any time.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF2
CALL InsertQuestion(v_qid, v_c_se, 'Git is a distributed version control system.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF3
CALL InsertQuestion(v_qid, v_c_se, 'A functional requirement describes system performance characteristics such as speed or reliability.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF4
CALL InsertQuestion(v_qid, v_c_se, 'Unit testing focuses on verifying individual components of software in isolation.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF5
CALL InsertQuestion(v_qid, v_c_se, 'Agile methodology uses iterative and incremental development cycles.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF6
CALL InsertQuestion(v_qid, v_c_se, 'A Software Requirements Specification (SRS) is typically written during the Design phase.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (written during Requirements phase)

-- TF7
CALL InsertQuestion(v_qid, v_c_se, 'A use case diagram shows the interactions between users (actors) and the system.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF8
CALL InsertQuestion(v_qid, v_c_se, 'Debugging is the process of identifying and fixing errors in software code.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF9
CALL InsertQuestion(v_qid, v_c_se, 'Open source software cannot be modified or distributed by the public.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF10
CALL InsertQuestion(v_qid, v_c_se, 'The V-Model is an extension of the Waterfall model that emphasizes testing at each development stage.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF11
CALL InsertQuestion(v_qid, v_c_se, 'User Acceptance Testing (UAT) is typically performed by the development team.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (performed by end users)

-- TF12
CALL InsertQuestion(v_qid, v_c_se, 'Refactoring changes the external behavior of software to add new features.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF13
CALL InsertQuestion(v_qid, v_c_se, 'A software prototype represents the final, fully tested deliverable of a project.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF14
CALL InsertQuestion(v_qid, v_c_se, 'Non-functional requirements define specific actions or features the system must perform.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (that describes functional requirements)

-- TF15
CALL InsertQuestion(v_qid, v_c_se, 'Scrum is a widely used framework that falls under the Agile methodology.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF16
CALL InsertQuestion(v_qid, v_c_se, 'Software maintenance involves only fixing bugs and does not include adding new features.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (also includes enhancements and updates)

-- TF17
CALL InsertQuestion(v_qid, v_c_se, 'Good code documentation helps developers understand and maintain the codebase over time.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF18
CALL InsertQuestion(v_qid, v_c_se, 'Black-box testing requires the tester to have full knowledge of the internal source code.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- TF19
CALL InsertQuestion(v_qid, v_c_se, 'Deployment is the phase in which software is made available and released to end users.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- TF20
CALL InsertQuestion(v_qid, v_c_se, 'A class diagram in UML is used to model the dynamic runtime behavior of a system.', 'TF', 1);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (class diagrams show static structure)

END;
$$;

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
    v_courseid := 9;

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
    IF v_mcq_count < 30 THEN
        RAISE EXCEPTION 'Not enough MCQ questions. Need 30, have %.', v_mcq_count;
    END IF;

    IF v_tf_count < 20 THEN
        RAISE EXCEPTION 'Not enough TF questions. Need 20, have %.', v_tf_count;
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
        9,
        'DB Midterm Test 1',
        30,
        20,
        v_examid
    );

    RAISE NOTICE 'Exam created. ID: %', v_examid;

    -- Check total question count = 3 + 2 = 5
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
        v_studentexamid
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
