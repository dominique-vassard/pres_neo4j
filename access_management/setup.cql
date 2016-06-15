//[Access management] Setup

CREATE
//Person
(jane:Person {name: "Jane"}),
(emily:Person {name: "Emily"}),
(stan:Person {name: "Stan"}),
(kenny:Person {name: "Kenny"}),
(sue:Person {name: "Sue"}),

//Resource types
(doc:ResourceType {name:"document"}),
(computer:ResourceType {name:"computer"}),
(level:ResourceType {name:"level"}),
(website:ResourceType {name:"website"}),

//Documents
(figures2013:Resource {name: "Key figures 2013"}),
(figures2014:Resource {name: "Key figures 2014"}),
(figures2015:Resource {name: "Key figures 2015"}),

//Computers
(pcJane:Resource {name: "Computer Jane"}),
(pcEmily:Resource {name: "Computer Emily"}),
(pcStan:Resource {name: "Computer Stan"}),
(pcKenny:Resource {name: "Computer Kenny"}),
(pcSue:Resource {name: "Computer Sue"}),

//Levels
(level1:Resource {name: "Level 1"}), //Reception
(level2:Resource {name: "Level 2"}), //Admin
(level3:Resource {name: "Level 3"}), //employee
(level4:Resource {name: "Level 4"}), //employee
(level5:Resource {name: "Level 5"}), //Canteen
(level6:Resource {name: "Level 6"}), //Management

//Websites
(google:Resource {name: "www.google.com"}),
(intranet:Resource {name: "www.intra.net"}),
(adminIntern:Resource {name: "www.admin.intra.net"}),
(facebook:Resource {name: "www.facebook.com"}),
(gmail:Resource {name: "www.gmail.com"}),

//Groups
(marketing:Group {name: "Marketing"}),
(sysAdmin:Group {name: "System Administrator"}),
(trainee:Group {name: "Trainee"}),
(manager:Group {name: "Manager"}),
(employee:Group {name: "Employee"}),
(accounting:Group {name: "Accounting"}),
(temp:Group {name: "Temporary worker"}),

//Person -> Group
(jane)-[:IS_IN_GROUP]->(marketing),
(jane)-[:IS_IN_GROUP]->(manager),
(jane)-[:IS_IN_GROUP]->(employee),
(emily)-[:IS_IN_GROUP]->(sysAdmin),
(emily)-[:IS_IN_GROUP]->(manager),
(emily)-[:IS_IN_GROUP]->(employee),
(stan)-[:IS_IN_GROUP]->(trainee),
(stan)-[:IS_IN_GROUP]->(sysAdmin),
(stan)-[:IS_IN_GROUP]->(employee),
(sue)-[:IS_IN_GROUP]->(accounting),
(sue)-[:IS_IN_GROUP]->(employee),
(kenny)-[:IS_IN_GROUP]->(temp),
(kenny)-[:IS_IN_GROUP]->(marketing),

//Resource -> ResourceType
(figures2013)-[:IS_OF_TYPE]->(doc),
(figures2014)-[:IS_OF_TYPE]->(doc),
(figures2015)-[:IS_OF_TYPE]->(doc),
(pcJane)-[:IS_OF_TYPE]->(computer),
(pcEmily)-[:IS_OF_TYPE]->(computer),
(pcStan)-[:IS_OF_TYPE]->(computer),
(pcKenny)-[:IS_OF_TYPE]->(computer),
(pcSue)-[:IS_OF_TYPE]->(computer),
(level1)-[:IS_OF_TYPE]->(level),
(level2)-[:IS_OF_TYPE]->(level),
(level3)-[:IS_OF_TYPE]->(level),
(level4)-[:IS_OF_TYPE]->(level),
(level5)-[:IS_OF_TYPE]->(level),
(level6)-[:IS_OF_TYPE]->(level),
(google)-[:IS_OF_TYPE]->(website),
(intranet)-[:IS_OF_TYPE]->(website),
(adminIntern)-[:IS_OF_TYPE]->(website),
(facebook)-[:IS_OF_TYPE]->(website),
(gmail)-[:IS_OF_TYPE]->(website),

//Person -> Computer
(jane)-[:HAS_ACCESS]->(pcJane),
(emily)-[:HAS_ACCESS]->(pcEmily),
(stan)-[:HAS_ACCESS]->(pcStan),
(kenny)-[:HAS_ACCESS]->(pcKenny),
(sue)-[:HAS_ACCESS]->(pcSue),

// SysAdmins has access to all computer
(sysAdmin)-[:HAS_ACCESS]->(computer),

//Group -> Resource
(employee)-[:HAS_ACCESS]->(figures2015),
(employee)-[:HAS_ACCESS]->(level3),
(employee)-[:HAS_ACCESS]->(level4),
(employee)-[:HAS_ACCESS]->(level5),
(employee)-[:HAS_ACCESS]->(google),
(employee)-[:HAS_ACCESS]->(intranet),
(employee)-[:HAS_ACCESS]->(gmail),

(marketing)-[:HAS_ACCESS]->(facebook),
(marketing)-[:HAS_ACCESS]->(adminIntern),

(sysAdmin)-[:HAS_ACCESS]->(level2),
(sysAdmin)-[:HAS_ACCESS]->(adminIntern),

(manager)-[:HAS_ACCESS]->(level6),
(manager)-[:HAS_ACCESS]->(figures2013),
(manager)-[:HAS_ACCESS]->(figures2014),
(manager)-[:HAS_ACCESS]->(facebook),

(accounting)-[:HAS_ACCESS]->(figures2013),
(accounting)-[:HAS_ACCESS]->(figures2014),

(temp)-[:HAS_ACCESS]->(level3),
(temp)-[:HAS_NO_ACCESS]->(adminIntern),
(temp)-[:HAS_NO_ACCESS]->(level5),

(trainee)-[:HAS_NO_ACCESS]->(facebook),
(trainee)-[:HAS_NO_ACCESS]->(intranet),
(trainee)-[:HAS_NO_ACCESS]->(adminIntern);