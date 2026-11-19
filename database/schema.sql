-- OEMS schema (MySQL 8). Run: mysql -u root -p < database/schema.sql
CREATE DATABASE IF NOT EXISTS oems; USE oems;
DROP TABLE IF EXISTS answers,results,attempts,questions,exams,enrollments,subjects,notifications,announcements,audit_logs,settings,users;
CREATE TABLE users(id INT AUTO_INCREMENT PRIMARY KEY,role ENUM('student','admin') NOT NULL,name VARCHAR(80) NOT NULL,email VARCHAR(120) UNIQUE NOT NULL,password_hash CHAR(64) NOT NULL,roll_no VARCHAR(20),dept VARCHAR(30),phone VARCHAR(20),status ENUM('active','inactive') DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE subjects(id INT AUTO_INCREMENT PRIMARY KEY,code VARCHAR(10) UNIQUE NOT NULL,title VARCHAR(120) NOT NULL,credits TINYINT DEFAULT 3);
CREATE TABLE enrollments(user_id INT,subject_id INT,enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(user_id,subject_id),FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE);
CREATE TABLE exams(id INT AUTO_INCREMENT PRIMARY KEY,subject_id INT NOT NULL,title VARCHAR(120) NOT NULL,start_time DATETIME NOT NULL,end_time DATETIME NOT NULL,duration_min INT NOT NULL,total_marks INT NOT NULL,pass_percent INT DEFAULT 40,results_published BOOLEAN DEFAULT FALSE,FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE);
CREATE TABLE questions(id INT AUTO_INCREMENT PRIMARY KEY,exam_id INT NOT NULL,type ENUM('mcq','descriptive') NOT NULL,text TEXT NOT NULL,options JSON,correct_option TINYINT,marks INT DEFAULT 1,FOREIGN KEY(exam_id) REFERENCES exams(id) ON DELETE CASCADE);
CREATE TABLE attempts(id INT AUTO_INCREMENT PRIMARY KEY,exam_id INT NOT NULL,user_id INT NOT NULL,started_at DATETIME,submitted_at DATETIME,status ENUM('in_progress','submitted') DEFAULT 'in_progress',mcq_score INT DEFAULT 0,desc_score INT DEFAULT 0,eval_status ENUM('pending','done') DEFAULT 'pending',UNIQUE(exam_id,user_id),FOREIGN KEY(exam_id) REFERENCES exams(id) ON DELETE CASCADE,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);
CREATE TABLE answers(attempt_id INT,question_id INT,selected_option TINYINT,answer_text TEXT,marked BOOLEAN DEFAULT FALSE,marks_awarded INT DEFAULT 0,PRIMARY KEY(attempt_id,question_id),FOREIGN KEY(attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE);
CREATE TABLE results(attempt_id INT PRIMARY KEY,exam_id INT,user_id INT,total INT,percentage DECIMAL(5,2),grade VARCHAR(3),published BOOLEAN DEFAULT FALSE,FOREIGN KEY(attempt_id) REFERENCES attempts(id) ON DELETE CASCADE);
CREATE TABLE notifications(id INT AUTO_INCREMENT PRIMARY KEY,user_id INT,message VARCHAR(255),is_read BOOLEAN DEFAULT FALSE,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);
CREATE TABLE announcements(id INT AUTO_INCREMENT PRIMARY KEY,title VARCHAR(120),body TEXT,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE audit_logs(id INT AUTO_INCREMENT PRIMARY KEY,user_id INT,action VARCHAR(60),detail VARCHAR(255),created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE settings(k VARCHAR(40) PRIMARY KEY,v VARCHAR(255));
CREATE INDEX idx_attempt_user ON attempts(user_id); CREATE INDEX idx_exam_time ON exams(start_time,end_time);
-- SAMPLE DATA (DEMO ONLY: SHA-256 password hashes). Mirrors js/demo-data.js.
-- Login emails/passwords: kapoor@exam.demo & sharma@exam.demo = Admin@123 ; aanya/palak/aduita/moksh@exam.demo = Student@123
INSERT INTO users(role,name,email,password_hash,roll_no,dept,phone) VALUES
('admin','Mrs. Kapoor','kapoor@exam.demo',SHA2('Admin@123',256),NULL,NULL,NULL),
('admin','Mr. Sharma','sharma@exam.demo',SHA2('Admin@123',256),NULL,NULL,NULL);
INSERT INTO users(role,name,email,password_hash,roll_no,dept,phone) VALUES
('student','Aanya','aanya@exam.demo',SHA2('Student@123',256),'R1001','CSE','9000000001'),
('student','Palak','palak@exam.demo',SHA2('Student@123',256),'R1002','IT','9000000002'),
('student','Aduita','aduita@exam.demo',SHA2('Student@123',256),'R1003','ECE','9000000003'),
('student','Moksh','moksh@exam.demo',SHA2('Student@123',256),'R1004','CSE','9000000004');
INSERT INTO subjects(code,title,credits) VALUES
('DBMS','Database Management Systems',4),
('OS','Operating Systems',3),
('CN','Computer Networks',3),
('DSA','Data Structures',4),
('SE','Software Engineering',3),
('WEB','Web Technologies',3);
INSERT INTO enrollments(user_id,subject_id) VALUES
(3,1),(3,2),(3,3),(4,1),(4,2),(4,3),(5,1),(5,2),(5,3),(6,1),(6,2),(6,3);
INSERT INTO exams(subject_id,title,start_time,end_time,duration_min,total_marks,pass_percent,results_published) VALUES
(1,'DBMS Mid-Term',NOW()-INTERVAL 24 HOUR,NOW()+INTERVAL 720 HOUR,30,10,40,FALSE),
(2,'OS Quiz 1',NOW()-INTERVAL 2 HOUR,NOW()+INTERVAL 48 HOUR,20,10,40,FALSE),
(3,'CN Unit Test',NOW()+INTERVAL 48 HOUR,NOW()+INTERVAL 72 HOUR,25,10,40,FALSE),
(4,'DSA Practice Test',NOW()+INTERVAL 72 HOUR,NOW()+INTERVAL 96 HOUR,30,10,40,FALSE),
(5,'SE Quiz',NOW()-INTERVAL 300 HOUR,NOW()-INTERVAL 290 HOUR,20,10,40,TRUE),
(6,'WEB Basics Test',NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 190 HOUR,20,10,40,FALSE);
INSERT INTO questions(exam_id,type,text,options,correct_option,marks) VALUES
(1,'mcq','Which normal form removes transitive dependency?','["1NF","2NF","3NF","BCNF"]',2,1),
(1,'mcq','Which SQL clause filters grouped rows?','["WHERE","HAVING","ORDER BY","LIMIT"]',1,1),
(1,'mcq','Which ACID property means all-or-nothing?','["Atomicity","Consistency","Isolation","Durability"]',0,1),
(1,'mcq','A foreign key enforces...','["Uniqueness","Referential integrity","Indexing","Encryption"]',1,1),
(1,'mcq','Which join returns unmatched left rows?','["INNER","LEFT","CROSS","SELF"]',1,1),
(1,'descriptive','Explain the ACID properties of a transaction with an example.',NULL,NULL,5),
(2,'mcq','Which scheduling algorithm can cause starvation?','["FCFS","Round Robin","Priority Scheduling","FIFO queue"]',2,1),
(2,'mcq','Which is NOT a necessary condition for deadlock?','["Mutual exclusion","Hold and wait","Preemption","Circular wait"]',2,1),
(2,'mcq','Belady''s anomaly occurs with which page replacement?','["LRU","FIFO","Optimal","MRU"]',1,1),
(2,'mcq','Which semaphore operation acquires a resource?','["wait (P)","signal (V)","fork","exec"]',0,1),
(2,'mcq','A thread is best described as...','["A separate program","Smallest unit of CPU execution in a process","A disk block","A device driver"]',1,1),
(2,'descriptive','Explain deadlock and the four conditions required for it.',NULL,NULL,5),
(3,'mcq','Which OSI layer is responsible for routing?','["Physical","Data Link","Network","Transport"]',2,1),
(3,'mcq','Which protocol is connectionless?','["TCP","UDP","FTP","SMTP"]',1,1),
(3,'mcq','Default port for HTTPS?','["80","443","21","25"]',1,1),
(3,'mcq','Which service maps domain names to IP addresses?','["DHCP","DNS","ARP","NAT"]',1,1),
(3,'mcq','Subnet mask for a /24 network?','["255.255.0.0","255.255.255.0","255.255.255.128","255.0.0.0"]',1,1),
(3,'descriptive','Describe the TCP three-way handshake.',NULL,NULL,5),
(4,'mcq','Time complexity of binary search?','["O(n)","O(log n)","O(n log n)","O(1)"]',1,1),
(4,'mcq','Which data structure is used for BFS?','["Stack","Queue","Heap","Tree"]',1,1),
(4,'mcq','Worst-case time of quick sort?','["O(n log n)","O(n^2)","O(n)","O(log n)"]',1,1),
(4,'mcq','Inorder traversal of a BST gives...','["Random order","Ascending order","Descending order","Level order"]',1,1),
(4,'mcq','Which is a collision resolution technique in hashing?','["Open addressing","Merge","Partition","Rotation"]',0,1),
(4,'descriptive','Differentiate between a stack and a queue with examples.',NULL,NULL,5),
(5,'mcq','Which SDLC model is sequential?','["Agile","Waterfall","Spiral","Scrum"]',1,1),
(5,'mcq','Which is a functional requirement?','["Respond within 2 seconds","Users can reset their password","99.9% availability","Portable code"]',1,1),
(5,'mcq','Black-box testing focuses on...','["Internal code structure","Inputs and outputs","Compiler errors","Memory usage"]',1,1),
(5,'mcq','Which UML diagram shows interactions over time?','["Class diagram","Sequence diagram","ER diagram","Gantt chart"]',1,1),
(5,'mcq','Which is an Agile framework?','["Scrum","Waterfall","V-Model","COCOMO"]',0,1),
(5,'descriptive','Explain the difference between the Waterfall and Agile models.',NULL,NULL,5),
(6,'mcq','Which HTML tag creates a hyperlink?','["<link>","<a>","<href>","<url>"]',1,1),
(6,'mcq','Which CSS property changes text colour?','["font-style","color","text-align","background"]',1,1),
(6,'mcq','Which JS method adds an element at the end of an array?','["push()","pop()","shift()","slice()"]',0,1),
(6,'mcq','HTTP status code for "Not Found"?','["200","301","404","500"]',2,1),
(6,'mcq','Which can store small data in the browser?','["localStorage","MySQL","Node.js","Apache"]',0,1),
(6,'descriptive','Explain the difference between GET and POST HTTP methods.',NULL,NULL,5);
INSERT INTO attempts(exam_id,user_id,started_at,submitted_at,status,mcq_score,desc_score,eval_status) VALUES
(5,3,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',5,4,'done'),
(5,4,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',2,5,'done'),
(5,5,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',3,1,'done'),
(5,6,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',4,2,'done'),
(6,3,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',4,5,'done'),
(6,4,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',2,1,'done'),
(6,5,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',4,2,'done'),
(6,6,NOW()-INTERVAL 200 HOUR,NOW()-INTERVAL 200 HOUR+INTERVAL 20 MINUTE,'submitted',2,3,'done'),
(1,5,NOW()-INTERVAL 3 HOUR,NOW()-INTERVAL 3 HOUR+INTERVAL 25 MINUTE,'submitted',3,0,'pending');
INSERT INTO results(attempt_id,exam_id,user_id,total,percentage,grade,published) VALUES
(1,5,3,9,90.00,'A+',TRUE),
(2,5,4,7,70.00,'B',TRUE),
(3,5,5,4,40.00,'E',TRUE),
(4,5,6,6,60.00,'C',TRUE),
(5,6,3,9,90.00,'A+',TRUE),
(6,6,4,3,30.00,'F',TRUE),
(7,6,5,6,60.00,'C',TRUE),
(8,6,6,5,50.00,'D',TRUE);
INSERT INTO answers(attempt_id,question_id,answer_text) VALUES(9,6,'Demo descriptive answer awaiting evaluation.');
INSERT INTO announcements(title,body) VALUES('Welcome','The DBMS Mid-Term is now open. Read the instructions carefully before you start.');
INSERT INTO notifications(user_id,message) VALUES(NULL,'DBMS Mid-Term is now open.');
INSERT INTO audit_logs(user_id,action,detail) VALUES(1,'SEED','Initial data loaded');
INSERT INTO settings VALUES('passPercent','40'),('allowRetake','false'),('maintenance','false');