//Get accessible resources for a specific person
MATCH (p:Person {name:"Emily"}),
(p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource)
WHERE NOT (p)-[:HAS_NO_ACCESS]->(res)
AND NOT (p)-[:IS_IN_GROUP]->(:Group)-[:HAS_NO_ACCESS]->(res)
RETURN p.name, COLLECT (res.name);



//Better
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

MATCH (p:Person {name: "Sue"}),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource {name: "www.gmail.com"})
WHERE NOT (p)-[:HAS_NO_ACCESS]->(res)
AND NOT (p)-[:IS_IN_GROUP]->(:Group)-[:HAS_NO_ACCESS]->(res)
RETURN COUNT(res);

//Add temporary access to a resource to a person
//Stan is an admin, and should have access to aminIntern evn if he's a trainee
MATCH (p:Person {name:"Stan"}),
      (res:Resource {""})

//Remove a person from the organisation
