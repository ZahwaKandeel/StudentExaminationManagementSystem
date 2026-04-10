DO $$
DECLARE
    v_qid INT;
    v_o1  INT;
    v_o2  INT;
    v_o3  INT;
    v_o4  INT;

    -- Course ID variables resolved by name (matches seed_org.sql insertions)
    v_c_db   INT;   -- 'Database Design & SQL'
    v_c_py   INT;   -- 'Python Programming'
    v_c_web  INT;   -- 'Web Technologies (HTML/CSS)'
    v_c_dsa  INT;   -- 'Data Structures & Algorithms'
    v_c_net  INT;   -- 'Network Fundamentals'
BEGIN

    -- Resolve course IDs safely by name
    SELECT courseid INTO v_c_db  FROM course WHERE coursename = 'Database Design & SQL';
    SELECT courseid INTO v_c_py  FROM course WHERE coursename = 'Python Programming';
    SELECT courseid INTO v_c_web FROM course WHERE coursename = 'Web Technologies (HTML/CSS)';
    SELECT courseid INTO v_c_dsa FROM course WHERE coursename = 'Data Structures & Algorithms';
    SELECT courseid INTO v_c_net FROM course WHERE coursename = 'Network Fundamentals';

-- ══════════════════════════════════════════════════
-- Course: Python Programming (12 Qs)
-- ══════════════════════════════════════════════════

-- Q1 MCQ
CALL InsertQuestion(v_c_py, 'Which keyword is used to define a function in Python?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'def',    1, v_o1);
CALL InsertOption(v_qid, 'class',  2, v_o2);
CALL InsertOption(v_qid, 'func',   3, v_o3);
CALL InsertOption(v_qid, 'define', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o1); -- def

-- Q2 MCQ
CALL InsertQuestion(v_c_py, 'What is the output of print(2 ** 3) in Python?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, '6', 1, v_o1);
CALL InsertOption(v_qid, '8', 2, v_o2);
CALL InsertOption(v_qid, '9', 3, v_o3);
CALL InsertOption(v_qid, '5', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- 8

-- Q3 MCQ
CALL InsertQuestion(v_c_py, 'Which data structure uses LIFO (Last In First Out) order?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'Queue',       1, v_o1);
CALL InsertOption(v_qid, 'Stack',       2, v_o2);
CALL InsertOption(v_qid, 'Linked List', 3, v_o3);
CALL InsertOption(v_qid, 'Hash Table',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Stack

-- Q4 MCQ
CALL InsertQuestion(v_c_py, 'What does the modulo operator (%) return?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'The quotient of the division',           1, v_o1);
CALL InsertOption(v_qid, 'The remainder of the division',          2, v_o2);
CALL InsertOption(v_qid, 'The result of integer power',            3, v_o3);
CALL InsertOption(v_qid, 'The absolute value of the difference',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- remainder

-- Q5 MCQ
CALL InsertQuestion(v_c_py, 'Which of the following is a mutable data type in Python?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Tuple',   1, v_o1);
CALL InsertOption(v_qid, 'String',  2, v_o2);
CALL InsertOption(v_qid, 'List',    3, v_o3);
CALL InsertOption(v_qid, 'Integer', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- List

-- Q6 TF
CALL InsertQuestion(v_c_py, 'A variable must be declared before it is used in Python.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- Q7 TF
CALL InsertQuestion(v_c_py, 'The index of the first element in a Python list is 1.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (it is 0)

-- Q8 MCQ
CALL InsertQuestion(v_c_py, 'Which loop is guaranteed to execute its body at least once?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'for loop',      1, v_o1);
CALL InsertOption(v_qid, 'while loop',    2, v_o2);
CALL InsertOption(v_qid, 'do-while loop', 3, v_o3);
CALL InsertOption(v_qid, 'foreach loop',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- do-while

-- Q9 MCQ
CALL InsertQuestion(v_c_py, 'What is the correct way to open a file for reading in Python?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'open("file.txt", "w")', 1, v_o1);
CALL InsertOption(v_qid, 'open("file.txt", "r")', 2, v_o2);
CALL InsertOption(v_qid, 'open("file.txt", "a")', 3, v_o3);
CALL InsertOption(v_qid, 'open("file.txt", "x")', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- "r"

-- Q10 TF
CALL InsertQuestion(v_c_py, 'Python is a compiled programming language.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (it is interpreted)

-- Q11 MCQ
CALL InsertQuestion(v_c_py, 'Which built-in function returns the number of items in a list?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'count()', 1, v_o1);
CALL InsertOption(v_qid, 'size()',  2, v_o2);
CALL InsertOption(v_qid, 'len()',   3, v_o3);
CALL InsertOption(v_qid, 'total()', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- len()

-- Q12 TF
CALL InsertQuestion(v_c_py, 'A dictionary in Python stores data as key-value pairs.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True


-- ══════════════════════════════════════════════════
-- Course: Database Design & SQL (12 Qs)
-- ══════════════════════════════════════════════════

-- Q13 MCQ
CALL InsertQuestion(v_c_db, 'Which SQL clause is used to filter rows after grouping?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'WHERE',    1, v_o1);
CALL InsertOption(v_qid, 'HAVING',   2, v_o2);
CALL InsertOption(v_qid, 'FILTER',   3, v_o3);
CALL InsertOption(v_qid, 'GROUP BY', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- HAVING

-- Q14 MCQ
CALL InsertQuestion(v_c_db, 'What does the acronym ACID stand for in database transactions?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'Atomicity, Consistency, Isolation, Durability',    1, v_o1);
CALL InsertOption(v_qid, 'Availability, Consistency, Integrity, Durability', 2, v_o2);
CALL InsertOption(v_qid, 'Atomicity, Concurrency, Isolation, Dependency',    3, v_o3);
CALL InsertOption(v_qid, 'Availability, Concurrency, Integrity, Dependency', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o1); -- Atomicity, Consistency, Isolation, Durability

-- Q15 MCQ
CALL InsertQuestion(v_c_db, 'Which normal form eliminates transitive dependencies?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, '1NF',  1, v_o1);
CALL InsertOption(v_qid, '2NF',  2, v_o2);
CALL InsertOption(v_qid, '3NF',  3, v_o3);
CALL InsertOption(v_qid, 'BCNF', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- 3NF

-- Q16 TF
CALL InsertQuestion(v_c_db, 'A PRIMARY KEY constraint allows NULL values.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- Q17 MCQ
CALL InsertQuestion(v_c_db, 'Which JOIN type returns only rows that have matching values in both tables?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'LEFT JOIN',  1, v_o1);
CALL InsertOption(v_qid, 'RIGHT JOIN', 2, v_o2);
CALL InsertOption(v_qid, 'INNER JOIN', 3, v_o3);
CALL InsertOption(v_qid, 'FULL JOIN',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- INNER JOIN

-- Q18 TF
CALL InsertQuestion(v_c_db, 'The HAVING clause can be used without a GROUP BY clause.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True (treats the whole result as one group)

-- Q19 MCQ
CALL InsertQuestion(v_c_db, 'Which SQL command permanently removes a table and all its data?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'DELETE',   1, v_o1);
CALL InsertOption(v_qid, 'TRUNCATE', 2, v_o2);
CALL InsertOption(v_qid, 'DROP',     3, v_o3);
CALL InsertOption(v_qid, 'REMOVE',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- DROP

-- Q20 MCQ
CALL InsertQuestion(v_c_db, 'What is the primary purpose of an index in a relational database?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'To enforce referential integrity',           1, v_o1);
CALL InsertOption(v_qid, 'To speed up data retrieval operations',      2, v_o2);
CALL InsertOption(v_qid, 'To compress stored data on disk',            3, v_o3);
CALL InsertOption(v_qid, 'To encrypt sensitive column values',         4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- speed up retrieval

-- Q21 TF
CALL InsertQuestion(v_c_db, 'A FOREIGN KEY can reference a non-primary unique key in another table.', 'TF', 2, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q22 MCQ
CALL InsertQuestion(v_c_db, 'Which aggregate function returns the number of non-NULL values in a column?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'SUM()',   1, v_o1);
CALL InsertOption(v_qid, 'COUNT()', 2, v_o2);
CALL InsertOption(v_qid, 'AVG()',   3, v_o3);
CALL InsertOption(v_qid, 'TOTAL()', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- COUNT()

-- Q23 TF
CALL InsertQuestion(v_c_db, 'DDL statements are automatically committed in most RDBMS systems.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q24 MCQ
CALL InsertQuestion(v_c_db, 'Which isolation level prevents dirty reads but allows non-repeatable reads?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'READ UNCOMMITTED', 1, v_o1);
CALL InsertOption(v_qid, 'READ COMMITTED',   2, v_o2);
CALL InsertOption(v_qid, 'REPEATABLE READ',  3, v_o3);
CALL InsertOption(v_qid, 'SERIALIZABLE',     4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- READ COMMITTED


-- ══════════════════════════════════════════════════
-- Course: Data Structures & Algorithms (12 Qs)
-- ══════════════════════════════════════════════════

-- Q25 MCQ
CALL InsertQuestion(v_c_dsa, 'What is the time complexity of binary search on a sorted array?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'O(n)',     1, v_o1);
CALL InsertOption(v_qid, 'O(log n)', 2, v_o2);
CALL InsertOption(v_qid, 'O(n²)',    3, v_o3);
CALL InsertOption(v_qid, 'O(1)',     4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- O(log n)

-- Q26 MCQ
CALL InsertQuestion(v_c_dsa, 'Which sorting algorithm has the best average-case time complexity?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'Bubble Sort',    1, v_o1);
CALL InsertOption(v_qid, 'Insertion Sort', 2, v_o2);
CALL InsertOption(v_qid, 'Merge Sort',     3, v_o3);
CALL InsertOption(v_qid, 'Selection Sort', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Merge Sort O(n log n)

-- Q27 TF
CALL InsertQuestion(v_c_dsa, 'A binary tree where every parent has at most two children is called a full binary tree.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (full binary tree means every node has 0 or 2 children)

-- Q28 MCQ
CALL InsertQuestion(v_c_dsa, 'What is the worst-case time complexity of QuickSort?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'O(n log n)', 1, v_o1);
CALL InsertOption(v_qid, 'O(n)',       2, v_o2);
CALL InsertOption(v_qid, 'O(n²)',      3, v_o3);
CALL InsertOption(v_qid, 'O(log n)',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- O(n²)

-- Q29 MCQ
CALL InsertQuestion(v_c_dsa, 'Which data structure is typically used to implement a breadth-first search?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Stack',      1, v_o1);
CALL InsertOption(v_qid, 'Queue',      2, v_o2);
CALL InsertOption(v_qid, 'Heap',       3, v_o3);
CALL InsertOption(v_qid, 'Hash Table', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Queue

-- Q30 TF
CALL InsertQuestion(v_c_dsa, 'A singly linked list supports O(1) random access by index.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (it is O(n))

-- Q31 MCQ
CALL InsertQuestion(v_c_dsa, 'What is the space complexity of Merge Sort?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'O(1)',     1, v_o1);
CALL InsertOption(v_qid, 'O(log n)', 2, v_o2);
CALL InsertOption(v_qid, 'O(n)',     3, v_o3);
CALL InsertOption(v_qid, 'O(n²)',    4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- O(n)

-- Q32 MCQ
CALL InsertQuestion(v_c_dsa, 'Which tree traversal visits the root node last?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Pre-order',   1, v_o1);
CALL InsertOption(v_qid, 'In-order',    2, v_o2);
CALL InsertOption(v_qid, 'Post-order',  3, v_o3);
CALL InsertOption(v_qid, 'Level-order', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Post-order

-- Q33 TF
CALL InsertQuestion(v_c_dsa, 'A hash table guarantees O(1) lookup time in the worst case.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (worst case is O(n) due to collisions)

-- Q34 MCQ
CALL InsertQuestion(v_c_dsa, 'Which algorithm finds the shortest path in an unweighted graph?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'Depth-First Search',    1, v_o1);
CALL InsertOption(v_qid, 'Breadth-First Search',  2, v_o2);
CALL InsertOption(v_qid, 'Dijkstra''s Algorithm', 3, v_o3);
CALL InsertOption(v_qid, 'Bellman-Ford',           4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- BFS

-- Q35 TF
CALL InsertQuestion(v_c_dsa, 'A stack can be implemented using two queues.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q36 MCQ
CALL InsertQuestion(v_c_dsa, 'What is the height of a complete binary tree with n nodes?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, 'O(n)',       1, v_o1);
CALL InsertOption(v_qid, 'O(log n)',   2, v_o2);
CALL InsertOption(v_qid, 'O(n²)',      3, v_o3);
CALL InsertOption(v_qid, 'O(n log n)', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- O(log n)


-- ══════════════════════════════════════════════════
-- Course: Network Fundamentals (12 Qs)
-- ══════════════════════════════════════════════════

-- Q37 MCQ
CALL InsertQuestion(v_c_net, 'Which OSI layer is responsible for end-to-end communication between hosts?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Network Layer',   1, v_o1);
CALL InsertOption(v_qid, 'Transport Layer', 2, v_o2);
CALL InsertOption(v_qid, 'Session Layer',   3, v_o3);
CALL InsertOption(v_qid, 'Data Link Layer', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Transport Layer

-- Q38 MCQ
CALL InsertQuestion(v_c_net, 'What does the acronym DNS stand for?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Dynamic Network Service', 1, v_o1);
CALL InsertOption(v_qid, 'Domain Name System',      2, v_o2);
CALL InsertOption(v_qid, 'Distributed Node Server', 3, v_o3);
CALL InsertOption(v_qid, 'Data Network Standard',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- Domain Name System

-- Q39 TF
CALL InsertQuestion(v_c_net, 'TCP is a connection-oriented protocol.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q40 MCQ
CALL InsertQuestion(v_c_net, 'Which protocol is used to automatically assign IP addresses to devices?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'FTP',  1, v_o1);
CALL InsertOption(v_qid, 'SMTP', 2, v_o2);
CALL InsertOption(v_qid, 'DHCP', 3, v_o3);
CALL InsertOption(v_qid, 'SNMP', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- DHCP

-- Q41 TF
CALL InsertQuestion(v_c_net, 'The default port number for HTTPS is 443.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q42 MCQ
CALL InsertQuestion(v_c_net, 'Which networking device operates at the Network layer of the OSI model?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Hub',    1, v_o1);
CALL InsertOption(v_qid, 'Switch', 2, v_o2);
CALL InsertOption(v_qid, 'Router', 3, v_o3);
CALL InsertOption(v_qid, 'Modem',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- Router

-- Q43 TF
CALL InsertQuestion(v_c_net, 'UDP provides guaranteed delivery of packets.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False

-- Q44 MCQ
CALL InsertQuestion(v_c_net, 'What is the maximum number of usable host addresses in a /24 subnet?', 'MCQ', 2, v_qid);
CALL InsertOption(v_qid, '256', 1, v_o1);
CALL InsertOption(v_qid, '254', 2, v_o2);
CALL InsertOption(v_qid, '255', 3, v_o3);
CALL InsertOption(v_qid, '128', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- 254

-- Q45 MCQ
CALL InsertQuestion(v_c_net, 'Which network topology connects every node directly to every other node?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'Star', 1, v_o1);
CALL InsertOption(v_qid, 'Bus',  2, v_o2);
CALL InsertOption(v_qid, 'Ring', 3, v_o3);
CALL InsertOption(v_qid, 'Mesh', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o4); -- Mesh

-- Q46 TF
CALL InsertQuestion(v_c_net, 'IPv6 addresses are 128 bits long.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q47 MCQ
CALL InsertQuestion(v_c_net, 'Which protocol is used for secure remote login over a network?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'FTP',    1, v_o1);
CALL InsertOption(v_qid, 'Telnet', 2, v_o2);
CALL InsertOption(v_qid, 'SSH',    3, v_o3);
CALL InsertOption(v_qid, 'SMTP',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- SSH

-- Q48 TF
CALL InsertQuestion(v_c_net, 'A MAC address is assigned by the Internet Assigned Numbers Authority (IANA).', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (assigned by IEEE / manufacturer)


-- ══════════════════════════════════════════════════
-- Course: Web Technologies (HTML/CSS) (12 Qs)
-- ══════════════════════════════════════════════════

-- Q49 MCQ
CALL InsertQuestion(v_c_web, 'Which HTML tag is used to create a hyperlink?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, '<link>',   1, v_o1);
CALL InsertOption(v_qid, '<a>',      2, v_o2);
CALL InsertOption(v_qid, '<href>',   3, v_o3);
CALL InsertOption(v_qid, '<url>',    4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- <a>

-- Q50 MCQ
CALL InsertQuestion(v_c_web, 'Which CSS property is used to change the text color of an element?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'font-color',  1, v_o1);
CALL InsertOption(v_qid, 'text-color',  2, v_o2);
CALL InsertOption(v_qid, 'color',       3, v_o3);
CALL InsertOption(v_qid, 'foreground',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- color

-- Q51 TF
CALL InsertQuestion(v_c_web, 'HTML5 introduced semantic elements such as <header>, <footer>, and <article>.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q52 MCQ
CALL InsertQuestion(v_c_web, 'Which CSS box model property creates space outside the border of an element?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'padding', 1, v_o1);
CALL InsertOption(v_qid, 'border',  2, v_o2);
CALL InsertOption(v_qid, 'margin',  3, v_o3);
CALL InsertOption(v_qid, 'spacing', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- margin

-- Q53 TF
CALL InsertQuestion(v_c_web, 'The <div> element is an inline HTML element.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (it is block-level)

-- Q54 MCQ
CALL InsertQuestion(v_c_web, 'Which HTML attribute specifies the destination URL of a hyperlink?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, 'src',  1, v_o1);
CALL InsertOption(v_qid, 'href', 2, v_o2);
CALL InsertOption(v_qid, 'url',  3, v_o3);
CALL InsertOption(v_qid, 'link', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- href

-- Q55 TF
CALL InsertQuestion(v_c_web, 'CSS Flexbox is a two-dimensional layout system.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o2); -- False (Flexbox is one-dimensional; Grid is two-dimensional)

-- Q56 MCQ
CALL InsertQuestion(v_c_web, 'Which CSS selector targets an element with a specific id attribute?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, '.element',  1, v_o1);
CALL InsertOption(v_qid, '#element',  2, v_o2);
CALL InsertOption(v_qid, '*element',  3, v_o3);
CALL InsertOption(v_qid, '@element',  4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- #element

-- Q57 MCQ
CALL InsertQuestion(v_c_web, 'Which HTML tag is used to embed an image on a page?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, '<image>', 1, v_o1);
CALL InsertOption(v_qid, '<img>',   2, v_o2);
CALL InsertOption(v_qid, '<pic>',   3, v_o3);
CALL InsertOption(v_qid, '<src>',   4, v_o4);
CALL SetModelAnswer(v_qid, v_o2); -- <img>

-- Q58 TF
CALL InsertQuestion(v_c_web, 'CSS styles defined inline have higher specificity than styles in an external stylesheet.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

-- Q59 MCQ
CALL InsertQuestion(v_c_web, 'Which HTML element is used to define a table row?', 'MCQ', 1, v_qid);
CALL InsertOption(v_qid, '<td>', 1, v_o1);
CALL InsertOption(v_qid, '<th>', 2, v_o2);
CALL InsertOption(v_qid, '<tr>', 3, v_o3);
CALL InsertOption(v_qid, '<tb>', 4, v_o4);
CALL SetModelAnswer(v_qid, v_o3); -- <tr>

-- Q60 TF
CALL InsertQuestion(v_c_web, 'The CSS property "display: none" removes the element from the document flow.', 'TF', 1, v_qid);
CALL InsertOption(v_qid, 'True',  1, v_o1);
CALL InsertOption(v_qid, 'False', 2, v_o2);
CALL SetModelAnswer(v_qid, v_o1); -- True

END;
$$;


