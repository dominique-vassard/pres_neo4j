// Create node Tinity
CREATE (t:Person) 
SET t.name = "Trinity"
RETURN t;

// Create node Neo
CREATE (n:Person) 
SET n.name = "Neo",
    n.originalName = "Mr Anderson"
RETURN n;

//Match all nodes
MATCH (n) RETURN n;

// Create another node Neo
CREATE (n:Person) 
SET n.name = "Neo",
    n.originalName = "Mr Anderson"
RETURN n;

//Match all nodes
MATCH (n) RETURN n;

// Wow, there's a Neo node that shouldn't be here
//Delete that node
MATCH(n) WHERE id(n) = 3 DELETE n;
//or
MATCH (n:Person {name:"Neo"})
WITH MAX(id(n)) AS maxId
MATCH (toDel:Person {name:"Neo"})
WHERE id(toDel) = maxId
DELETE toDel;

//Doesn't work
//Now use MERGE
// MERGE (n:Person) 
// WHERE n.name = "Neo"
// SET n.originalName = "Mr Anderson"
// RETURN n;

// What about NULL?
MATCH (t:Person)
WHERE t.name = "Trinity"
SET t.originalName = NULL
RETURN t;

// Create some other nodes
CREATE (m:Person)
SET m.name = "Morpheus"
CREATE (c:Agent)
SET c.name = "Smith"
CREATE (n:Hovercraft)
SET n.name = "Nebuchadnezzar";

//Inspect what we've created
MATCH (n) RETURN n;

//Get a node
MATCH (n:Person)
WHERE n.name = "Neo"
RETURN n;
//is equals to
MATCH (n:Person {name: "Neo"})
RETURN n;


//Add a relationship
MATCH (n:Person {name:"Trinity"}),
      (t:Person {name:"Neo"})
MERGE (t)-[r:LOVES]->(n)
RETURN t, r, n;
//Oh oh, cartesian product...

//Try this now
MERGE (n:Person {name:"Neo"})<-[r:BELIEVES_IN]-(m:person {name:"Morpheus"})
RETURN n,r,m;

//Inspect what we've created
MATCH (n) RETURN n;

//Oh god, what have Id done...
//Relationship beween Neo and trinity is in the wrong way
//And I created additional Morpheus and Neo nodes...

//Fix relationship
MATCH (n:Person {name:"Neo"})-[r:LOVES]->(t:Person {name:"Trinity"})
DELETE r
MERGE (n)<-[newRel:LOVES]-(t)
RETURN n, type(newRel), t;

//Fix node
MATCH (m:person {name:"Morpheus"})-[oldRel]->(n:Person {name:"Neo"})
DELETE oldRel
DELETE m
DELETE n
WITH 1 AS none
MATCH (realM:Person {name:"Morpheus"}),
      (realN:Person {name:"Neo"})
MERGE (realM)-[:BELIEVES_IN]->(realN)
RETURN realM, realN;

//Inspect what we've done
MATCH (n) RETURN n;

//OK fixed

//Now let's create a bunch of relationships
MATCH (m:Person {name:"Morpheus"}),
      (nebu:Hovercraft {name:"Nebuchadnezzar"}),
      (s:Agent {name:"Smith"}),
      (n:Person {name:"Neo"}),
      (t:Person {name:"Trinity"})
MERGE (m)-[:OWNS]->(nebu)
MERGE (s)-[:HATES]->(m)
MERGE (s)-[:HATES]->(n)
MERGE (s)-[:HATES]->(t)
MERGE (c:Person {name:"Cypher"})<-[:CORRUPTS]-(s)
MERGE (c)-[:BETRAYED]->(t)
MERGE (c)-[:BETRAYED]->(m)
MERGE (c)-[:BETRAYED]->(n)
MERGE (a:Person {name: "Apoc"})<-[:KILLED]-(c)
MERGE (a)-[:CREW_OF]->(nebu)
MERGE (z:City {name:"Zion"})
MERGE (m)-[:IS_FROM]->(z)
MERGE (a)-[:IS_FROM]->(z)
MERGE (s)-[:WANTED_TO_DESTROY]->(z);

//Inspect what we've done
MATCH (n) RETURN n;

//Seems that our base lacks some important information
//Let's add it
MATCH(n)
SET n.firstAppearance = 'Matrix I';

//Adds some other node
MATCH (n:Person {name:"Neo"})
MERGE (o:Exile {name: "The Oracle", firstAppearance:"Matrix I"})-[:HELPED]->(n)
MERGE (s:Exile {name:"Seraph", firstAppearance:"Matrix II"})-[:PROTECTS]->(o)
MERGE (s)-[:ONCE_SERVED]->(m:Exile {name:"The Merovingian", firstAppearance:"Matrix II"});

//Inspect what we've done
MATCH (n) RETURN n;

//Well that's not clever if we want to get everyone first appearance
//Then update all the things!
MATCH (n)
WHERE EXISTS(n.firstAppearance)
MERGE (m:Movie {title: n.firstAppearance})
MERGE (n)-[:FIRST_APPEARED_IN]->(m)
REMOVE n.firstAppearance;

//Inspect what we've done
MATCH (n) RETURN n;

//Now some simple queries
//Who Smith hates?
MATCH (s:Agent {name:"Smith"}),
(s)-[:HATES]->(who)
RETURN s, who;

//Relation between Smith and Person 
MATCH (s:Agent {name:"Smith"}), 
(s)-[]->(who:Person) RETURN s, who;
//Looks at this interesting thing (triangles!!)


// Get the shortests path between Neo And Zion
MATCH (n:Person {name:"Neo"}),
(z:City {name:"Zion"}),
path = allShortestPaths((n)-[*]-(z))
RETURN nodes(path);
// RETURN EXTRACT (node in nodes(path) | node.name + ":" + head(labels(node))) AS nodes_in_path; 

//Beware of [*]
MATCH (n:Person {name:"Neo"}),
(z:City {name:"Zion"}),
path = (n)-[*]-(z)
RETURN EXTRACT (node in nodes(path) | node.name + ":" + head(labels(node))) AS nodes_in_path
ORDER BY length(path);
 
