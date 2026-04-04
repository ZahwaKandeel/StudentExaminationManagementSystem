# Constraints Reference

## FK ON DELETE Rules

| FK Column                          | References               | ON DELETE  | Reason                                      |
|------------------------------------|--------------------------|------------|---------------------------------------------|
| track.departmentid                 | department(departmentid) | RESTRICT   | Cannot delete dept with active tracks       |
| track_course.trackid               | track(trackid)           | CASCADE    | Junction row, safe to cascade               |
| track_course.courseid              | course(courseid)         | CASCADE    | Junction row, safe to cascade               |
| instructor.departmentno            | department(departmentid) | SET NULL   | Instructor stays even if dept removed       |
| instructor_course.instructorid     | instructor(instructorid) | CASCADE    | Junction row                                |
| instructor_course.courseid         | course(courseid)         | CASCADE    | Junction row                                |
| student_track.studentid            | student(studentid)       | RESTRICT   | Don't silently remove enrollment            |
| student_track.trackid              | track(trackid)           | RESTRICT   | Don't silently remove enrollment            |
| question.courseid                  | course(courseid)         | RESTRICT   | Cannot delete course with questions         |
| choice.questionid                  | question(questionid)     | CASCADE    | Choices are meaningless without question    |
| modelanswer.questionid             | question(questionid)     | CASCADE    | Answer meaningless without question         |
| modelanswer.correctoptionid        | choice(optionid)         | CASCADE    | If choice deleted, answer is invalid        |
| exam.courseid                      | course(courseid)         | RESTRICT   | Cannot delete course with exams             |
| examquestion.examid                | exam(examid)             | CASCADE    | Exam deleted = its questions deleted        |
| examquestion.questionid            | question(questionid)     | RESTRICT   | Cannot delete question used in an exam      |
| studentexam.studentid              | student(studentid)       | RESTRICT   | Preserve exam history                       |
| studentexam.examid                 | exam(examid)             | RESTRICT   | Preserve exam history                       |
| studentanswer.studentexamid        | studentexam(studentexamid)| CASCADE   | Attempt deleted = answers deleted           |
| studentanswer.questionid           | question(questionid)     | RESTRICT   | Preserve answer history                     |
| studentanswer.chosenoptionid       | choice(optionid)         | RESTRICT   | Preserve answer history                     |

## CHECK Constraints

| Table        | Column       | Constraint                              |
|--------------|--------------|-----------------------------------------|
| question     | type         | type IN ('MCQ', 'TF')                   |
| question     | points       | points > 0                              |
| choice       | optionorder  | optionorder BETWEEN 1 AND 4             |
| studentexam  | totalgrade   | totalgrade >= 0                         |
| studentexam  | times        | endtime > starttime                     |
| course       | degrees      | mindegree >= 0 AND maxdegree > mindegree|

## NOT NULL Rules
All columns are NOT NULL by default UNLESS listed here:
  instructor.departmentno   → nullable (SET NULL on dept delete)
  studentexam.totalgrade    → nullable until CorrectExam runs
  studentexam.endtime       → nullable (exam may still be running)

  