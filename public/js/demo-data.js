// DEMO DATA LAYER (simulated database). Stored in localStorage; replace with fetch('/api/...') calls during DB integration.
const KEY='oems_demo_v2';   // bumped from v1 so old cached "Student 01" data is ignored automatically

/* =====================================================================
   REAL ACCOUNTS - EDIT THESE TWO LISTS ONLY
   Login uses the EMAIL + password shown here.
   dept must be one of: CSE, IT, ECE
   ===================================================================== */
const REAL_ADMINS=[
 {name:'Mrs. Kapoor',email:'kapoor@exam.demo',password:'Admin@123'},
 {name:'Mr. Sharma', email:'sharma@exam.demo',password:'Admin@123'},
];
const REAL_STUDENTS=[
 {name:'Aanya', email:'aanya@exam.demo', password:'Student@123',roll:'R1001',dept:'CSE',phone:'9000000001'},
 {name:'Palak', email:'palak@exam.demo', password:'Student@123',roll:'R1002',dept:'IT', phone:'9000000002'},
 {name:'Aduita',email:'aduita@exam.demo',password:'Student@123',roll:'R1003',dept:'ECE',phone:'9000000003'},
 {name:'Moksh', email:'moksh@exam.demo', password:'Student@123',roll:'R1004',dept:'CSE',phone:'9000000004'},
];
/* ===================================================================== */

/* QUESTION BANK - key = subject id (1 DBMS, 2 OS, 3 CN, 4 DSA, 5 SE, 6 WEB).
   Each question: [text, [4 options], index of correct option]. Edit freely. */
const BANK={ "1": { "q": [ [ "Which normal form removes transitive dependency?", [ "1NF", "2NF", "3NF", "BCNF" ], 2 ], [ "Which SQL clause filters grouped rows?", [ "WHERE", "HAVING", "ORDER BY", "LIMIT" ], 1 ], [ "Which ACID property means all-or-nothing?", [ "Atomicity", "Consistency", "Isolation", "Durability" ], 0 ], [ "A foreign key enforces...", [ "Uniqueness", "Referential integrity", "Indexing", "Encryption" ], 1 ], [ "Which join returns unmatched left rows?", [ "INNER", "LEFT", "CROSS", "SELF" ], 1 ] ], "desc": "Explain the ACID properties of a transaction with an example." }, "2": { "q": [ [ "Which scheduling algorithm can cause starvation?", [ "FCFS", "Round Robin", "Priority Scheduling", "FIFO queue" ], 2 ], [ "Which is NOT a necessary condition for deadlock?", [ "Mutual exclusion", "Hold and wait", "Preemption", "Circular wait" ], 2 ], [ "Belady's anomaly occurs with which page replacement?", [ "LRU", "FIFO", "Optimal", "MRU" ], 1 ], [ "Which semaphore operation acquires a resource?", [ "wait (P)", "signal (V)", "fork", "exec" ], 0 ], [ "A thread is best described as...", [ "A separate program", "Smallest unit of CPU execution in a process", "A disk block", "A device driver" ], 1 ] ], "desc": "Explain deadlock and the four conditions required for it." }, "3": { "q": [ [ "Which OSI layer is responsible for routing?", [ "Physical", "Data Link", "Network", "Transport" ], 2 ], [ "Which protocol is connectionless?", [ "TCP", "UDP", "FTP", "SMTP" ], 1 ], [ "Default port for HTTPS?", [ "80", "443", "21", "25" ], 1 ], [ "Which service maps domain names to IP addresses?", [ "DHCP", "DNS", "ARP", "NAT" ], 1 ], [ "Subnet mask for a /24 network?", [ "255.255.0.0", "255.255.255.0", "255.255.255.128", "255.0.0.0" ], 1 ] ], "desc": "Describe the TCP three-way handshake." }, "4": { "q": [ [ "Time complexity of binary search?", [ "O(n)", "O(log n)", "O(n log n)", "O(1)" ], 1 ], [ "Which data structure is used for BFS?", [ "Stack", "Queue", "Heap", "Tree" ], 1 ], [ "Worst-case time of quick sort?", [ "O(n log n)", "O(n^2)", "O(n)", "O(log n)" ], 1 ], [ "Inorder traversal of a BST gives...", [ "Random order", "Ascending order", "Descending order", "Level order" ], 1 ], [ "Which is a collision resolution technique in hashing?", [ "Open addressing", "Merge", "Partition", "Rotation" ], 0 ] ], "desc": "Differentiate between a stack and a queue with examples." }, "5": { "q": [ [ "Which SDLC model is sequential?", [ "Agile", "Waterfall", "Spiral", "Scrum" ], 1 ], [ "Which is a functional requirement?", [ "Respond within 2 seconds", "Users can reset their password", "99.9% availability", "Portable code" ], 1 ], [ "Black-box testing focuses on...", [ "Internal code structure", "Inputs and outputs", "Compiler errors", "Memory usage" ], 1 ], [ "Which UML diagram shows interactions over time?", [ "Class diagram", "Sequence diagram", "ER diagram", "Gantt chart" ], 1 ], [ "Which is an Agile framework?", [ "Scrum", "Waterfall", "V-Model", "COCOMO" ], 0 ] ], "desc": "Explain the difference between the Waterfall and Agile models." }, "6": { "q": [ [ "Which HTML tag creates a hyperlink?", [ "<link>", "<a>", "<href>", "<url>" ], 1 ], [ "Which CSS property changes text colour?", [ "font-style", "color", "text-align", "background" ], 1 ], [ "Which JS method adds an element at the end of an array?", [ "push()", "pop()", "shift()", "slice()" ], 0 ], [ "HTTP status code for \"Not Found\"?", [ "200", "301", "404", "500" ], 2 ], [ "Which can store small data in the browser?", [ "localStorage", "MySQL", "Node.js", "Apache" ], 0 ] ], "desc": "Explain the difference between GET and POST HTTP methods." } };

const grade=p=>p>=90?'A+':p>=80?'A':p>=70?'B':p>=60?'C':p>=50?'D':p>=40?'E':'F';
const iso=h=>new Date(Date.now()+h*36e5).toISOString().slice(0,16);
function seed(){
 const d={users:[],subjects:[],enrollments:[],exams:[],questions:[],attempts:[],notifications:[],announcements:[],audit:[],settings:{siteName:'OEMS',defaultDuration:30,passPercent:40,allowRetake:false,maintenance:false},nid:1000};
 REAL_ADMINS.forEach((a,i)=>d.users.push({id:1+i,role:'admin',name:a.name,email:a.email,password:a.password,status:'active'}));
 const A=REAL_ADMINS.length;                       // students get ids after the admins
 REAL_STUDENTS.forEach((s,i)=>d.users.push({id:A+1+i,role:'student',name:s.name,email:s.email,password:s.password,roll:s.roll,dept:s.dept,phone:s.phone,status:s.status||'active'}));
 const students=d.users.filter(u=>u.role=='student');
 [['DBMS','Database Management Systems',4],['OS','Operating Systems',3],['CN','Computer Networks',3],['DSA','Data Structures',4],['SE','Software Engineering',3],['WEB','Web Technologies',3]].forEach((s,i)=>d.subjects.push({id:i+1,code:s[0],title:s[1],credits:s[2]}));
 students.forEach(u=>[1,2,3].forEach(s=>d.enrollments.push({uid:u.id,sid:s})));
 const ex=[['DBMS Mid-Term',1,-24,720,30,-1],['OS Quiz 1',2,-2,48,20,-1],['CN Unit Test',3,48,72,25,-1],['DSA Practice Test',4,72,96,30,-1],['SE Quiz',5,-300,-290,20,1],['WEB Basics Test',6,-200,-190,20,1]];
 ex.forEach((e,i)=>d.exams.push({id:i+1,title:e[0],sid:e[1],start:iso(e[2]),end:iso(e[3]),duration:e[4],pass:40,published:i==4,total:0}));
 let qid=1;d.exams.forEach(e=>{const sb=BANK[e.sid];
  sb.q.forEach(q=>{d.questions.push({id:qid++,eid:e.id,type:'mcq',text:q[0],options:q[1],ans:q[2],marks:1});e.total++});
  d.questions.push({id:qid++,eid:e.id,type:'descriptive',text:sb.desc,marks:5});e.total+=5});
 // past attempts for the real students (fixed: no longer assumes user ids 3..14 exist)
 students.slice(0,12).forEach(s=>[5,6].forEach(eid=>{const u=s.id,m=2+(u*eid)%4,ds=1+(u+eid)%5;d.attempts.push({id:d.nid++,eid,uid:u,answers:{},mcq:m,desc:ds,evaluated:true,status:'submitted',at:iso(-200)});}));
 // one attempt waiting for admin evaluation
 const pending=students[Math.min(2,students.length-1)];
 if(pending){
  d.attempts.push({id:d.nid++,eid:1,uid:pending.id,answers:{},mcq:3,desc:0,evaluated:false,status:'submitted',at:iso(-3)});
  const last=d.attempts[d.attempts.length-1];
  last.answers={[d.questions.find(q=>q.eid==1&&q.type=='descriptive').id]:{text:'Demo descriptive answer awaiting evaluation.'}};
 }
 d.announcements.push({id:1,title:'Welcome',body:'The DBMS Mid-Term is now open. Read the instructions carefully before you start.',date:iso(-48)});
 d.notifications.push({id:1,uid:0,msg:'DBMS Mid-Term is now open.',date:iso(-24),read:false});
 d.audit.push({id:1,user:REAL_ADMINS[0].name,action:'SEED',detail:'Initial data loaded',date:iso(-1)});
 return d;}
let DB=JSON.parse(localStorage.getItem(KEY)||'null')||seed();
const save=()=>localStorage.setItem(KEY,JSON.stringify(DB));
const resetDemo=()=>{localStorage.removeItem(KEY);location.reload()};
const nid=()=>++DB.nid;
const log=(action,detail)=>{const u=me();DB.audit.unshift({id:nid(),user:u?u.name:'System',action,detail,date:new Date().toISOString().slice(0,16)});save()};
const me=()=>{const id=sessionStorage.getItem('uid');return DB.users.find(u=>u.id==id)};
const notify=(uid,msg)=>{DB.notifications.unshift({id:nid(),uid,msg,date:new Date().toISOString().slice(0,16),read:false});save()};
const examStatus=e=>{const n=iso(0);return n<e.start?'Upcoming':n>e.end?'Closed':'Open'};
const resultOf=a=>{const e=DB.exams.find(x=>x.id==a.eid),t=a.mcq+a.desc,p=+(t*100/e.total).toFixed(1);return{total:t,pct:p,grade:grade(p),pass:p>=e.pass,e}};