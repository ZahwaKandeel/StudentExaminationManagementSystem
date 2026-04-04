# Database Dictionary — ITI Exam Management System

## How to use this file
Each developer fills in the tables they own (assigned in the roadmap).
Copy the template block below for each new table.
Follow the constraints_reference.md for FK and CHECK decisions.

---

## TEMPLATE (copy this block for each table)

### Table: `table_name`
**Purpose:** One sentence describing what this table stores.
**Owner:** Dev X
**Schema file:** schema/0X_filename.sql

#### Columns
| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| id | SERIAL | NO | auto | — | Primary key |

#### Constraints
| Type | Name | Definition |
|------|------|-----------|
| PK | pk_tablename | (id) |
| FK | fk_tablename_col | col → other_table(col) ON DELETE ACTION |
| UQ | uq_tablename_col | (col) |
| CHK | chk_tablename_col | col condition |

#### Indexes
| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| idx_tablename_col | col | BTREE | Speeds up X query |

#### Notes
- Any special behavior worth documenting

---

## FILLED EXAMPLE

### Table: `question`
**Purpose:** Stores all exam questions linked to a course,
supporting MCQ (4 choices) and True/False types.
**Owner:** Mostafa Abd Elqawy
**Schema file:** schema/03_exam.sql

#### Columns
| Column | Type | Nullable | Default | Collation | Description |
|--------|------|----------|---------|-----------|-------------|
| questionid | SERIAL | NO | auto | — | Primary key |
| courseid | INT | NO | — | — | FK to course table |
| questiontext | TEXT | NO | — | arabic_icu | Full question body, Arabic or English |
| type | TEXT | NO | — | — | 'MCQ' or 'TF' only |
| points | INT | NO | 1 | — | Score if answered correctly |

#### Constraints
| Type | Name | Definition |
|------|------|-----------|
| PK | pk_question | (questionid) |
| FK | fk_question_course | courseid → course(courseid) ON DELETE RESTRICT |
| CHK | chk_question_type | type IN ('MCQ', 'TF') |
| CHK | chk_question_points | points > 0 |

#### Indexes
| Name | Column(s) | Type | Reason |
|------|-----------|------|--------|
| idx_question_courseid | courseid | BTREE | Fast lookup during GenerateExam |
| idx_question_type | type | BTREE | Filter by MCQ or TF during exam generation |

#### Notes
- questiontext uses arabic_icu collation to support Arabic text
- When type = 'TF', exactly 2 choices must exist in the choice table
- When type = 'MCQ', exactly 4 choices must exist