//Get accessible resources for a specific person
// MATCH (p:Person {name:"Emily"}),
// (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource)
// WHERE NOT (p)-[:HAS_NO_ACCESS]->(res)
// AND NOT (p)-[:IS_IN_GROUP]->(:Group)-[:HAS_NO_ACCESS]->(res)
// RETURN p.name, COLLECT (res.name);

//Better
// Notice that we consider that there is no relationship of kind:
// - (:Person)-(:HAS_NO_ACCESS)->[:ResourceType]
// - (:Group)-(:HAS_NO_ACCESS)->[:ResourceType]
MATCH (p:Person {name:"Sue"}),
      (p)-[:IS_IN_GROUP]->(g:Group)
OPTIONAL MATCH
      (p)-[:HAS_NO_ACCESS]->(noResP:Resource)
OPTIONAL MATCH
      (g)-[:HAS_NO_ACCESS]->(noResG:Resource)
WITH p, COLLECT(DISTINCT noResP.name) + COLLECT(DISTINCT noResG.name) AS no_access_resources
MATCH (p)-[:IS_IN_GROUP]->(g:Group),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(resP:Resource)
WHERE NOT resP.name IN no_access_resources
OPTIONAL MATCH
      (g)-[:HAS_ACCESS]->(resType:ResourceType)<-[:IS_OF_TYPE]-(resG:Resource)
WHERE NOT resG.name IN no_access_resources
// RETURN p.name, COLLECT(DISTINCT resP.name) + COLLECT(DISTINCT resG.name);
WITH p, COLLECT (DISTINCT resP.name) + COLLECT(DISTINCT resG.name) AS resources
UNWIND resources AS resList
WITH p, resList
ORDER BY resList
RETURN p.name, COLLECT(DISTINCT resList);

//Get a look on a person relationship
MATCH (p:Person {name:"Stan"}),
(p)-->(res:Resource),
(p)-->(g:Group)-->(res2:Resource)
RETURN p, res, g, res2;

//Sue was too much on gmail, remove her access
MATCH (p:Person {name:"Sue"}),
      (r:Resource {name: "www.gmail.com"})
MERGE (p)-[:HAS_NO_ACCESS]->(r);

//Has this person got an access to this resource
MATCH (p:Person {name: "Jane"}),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource {name: "www.facebook.com"})
WHERE NOT (p)-[:HAS_NO_ACCESS]->(res)
AND NOT (p)-[:IS_IN_GROUP]->(:Group)-[:HAS_NO_ACCESS]->(res)
RETURN COUNT(res);

MATCH (p:Person {name:"Sue"}),
      (p)-[:IS_IN_GROUP]->(g:Group)
OPTIONAL MATCH
      (p)-[:HAS_NO_ACCESS]->(noResP:Resource {name: "www.facebook.com"})
OPTIONAL MATCH
      (g)-[:HAS_NO_ACCESS]->(noResG:Resource {name: "www.facebook.com"})
WITH p, COLLECT(DISTINCT noResP.name) + COLLECT(DISTINCT noResG.name) AS no_access_resources
MATCH (p)-[:IS_IN_GROUP]->(g:Group),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(resP:Resource {name: "www.facebook.com"})
WHERE NOT resP.name IN no_access_resources
OPTIONAL MATCH
      (g)-[:HAS_ACCESS]->(resType:ResourceType)<-[:IS_OF_TYPE]-(resG:Resource {name: "www.facebook.com"})
WHERE NOT resG.name IN no_access_resources
RETURN size(COLLECT (DISTINCT resP.name) + COLLECT(DISTINCT resG.name)) as nb_access;

//Optimization OK
MATCH (p:Person {name:"Sue"}),
      (p)-[:IS_IN_GROUP]->(g:Group)
OPTIONAL MATCH
      (p)-[:HAS_NO_ACCESS]->(noResP:Resource)
OPTIONAL MATCH
      (g)-[:HAS_NO_ACCESS]->(noResG:Resource)
WITH p, COLLECT(DISTINCT noResP.name) + COLLECT(DISTINCT noResG.name) AS no_access_resources
MATCH (p)-[:IS_IN_GROUP]->(g:Group),
      (res:Resource {name: "www.facebook.com"}),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res)
WHERE NOT res.name IN no_access_resources
OPTIONAL MATCH
      (g)-[:HAS_ACCESS]->(resType:ResourceType)<-[:IS_OF_TYPE]-(res)
WHERE NOT res.name IN no_access_resources
RETURN size(COLLECT (DISTINCT res.name)) as nb_access;


//Add temporary access to a resource to a person
//Stan is an admin, and should have access to aminIntern evn if he's a trainee
// Access granted on Person override access non granted!
// CALL apoc.date.toSeconds('2016-03-05 00:00:00') => 1457136000
// CALL apoc.date.toSeconds('2016-07-31 23:59:59') => 1470009599
// CALL apoc.date.toSeconds('2016-02-29 16:35:00') => 1456763700
// CALL apoc.date.toSeconds('2016-07-05 16:35:00') => 1467736500
// CALL apoc.date.toSeconds('2016-08-05 16:35:00') => 1470414900
MATCH (p:Person {name:"Stan"}),
      (adminIntern:Resource {name: "www.admin.intra.net"})
MERGE (p)-[r:HAS_ACCESS]->(adminIntern)
ON CREATE SET r.from = 1457136000,
              r.to = 1470009599;

// WITH apoc.date.parseDefault('2016-03-05 00:00:00', 's') AS start_date, apoc.date.parseDefault('2016-07-31 23:59:59', 's') AS end_date
MATCH (p:Person {name:"Stan"}),
      (adminIntern:Resource {name: "www.admin.intra.net"})
WITH p, adminIntern
CALL apoc.date.parseDefault('2016-03-05 00:00:00', 's') YIELD value AS start_date
CALL apoc.date.parseDefault('2016-07-31 23:59:59', 's') YIELD value AS end_date
MERGE (p)-[r:HAS_ACCESS]->(adminIntern)
ON CREATE SET r.from = start_date,
              r.to = end_date;
              
//Check access dates
MATCH (p:Person {name:"Stan"}),
      (p)-[r:HAS_ACCESS]->(adminIntern:Resource {name: "www.admin.intra.net"})
// WITH p, r, adminIntern
CALL apoc.date.formatDefault(r.from, 's') YIELD value AS start_date
CALL apoc.date.formatDefault(r.to, 's') YIELD value AS end_date
RETURN p.name, type(r), start_date, end_date;

//Now get accesses
CALL apoc.date.parseDefault('2016-02-05 00:00:00', 's') YIELD value AS check_date
MATCH (p:Person {name:"Stan"}),
      (p)-[:IS_IN_GROUP]->(g:Group)
OPTIONAL MATCH
      (p)-[:HAS_NO_ACCESS]->(noResP:Resource)
OPTIONAL MATCH
      (g)-[:HAS_NO_ACCESS]->(noResG:Resource)
WITH p, COLLECT(DISTINCT noResP.name) + COLLECT(DISTINCT noResG.name) AS no_access_resources, check_date
MATCH (p)-[:IS_IN_GROUP]->(g:Group),
      // (p)-[accP:HAS_ACCESS|IS_IN_GROUP*0..2]->(resP:Resource)
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(resP:Resource)
WHERE NOT resP.name IN no_access_resources
OPTIONAL MATCH
      (p)-[accP:HAS_ACCESS]->(resD:Resource)
WHERE check_date >= accP.from AND check_date <= accP.to
OPTIONAL MATCH
      (g)-[HAS_ACCESS]->(resType:ResourceType)<-[:IS_OF_TYPE]-(resG:Resource)
WHERE NOT resG.name IN no_access_resources
// RETURN p.name, COLLECT(DISTINCT resP.name) + COLLECT(DISTINCT resG.name);
WITH p, COLLECT (DISTINCT resP.name) + COLLECT (DISTINCT resD.name) + COLLECT(DISTINCT resG.name) AS resources
UNWIND resources AS resList
WITH p, resList
ORDER BY resList
RETURN p.name, COLLECT(DISTINCT resList);

//Remove a person from the organisation
MATCH (p:Person {name: "Kenny"})
DETACH DELETE p;
