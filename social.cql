//Add some individuals, company, project, knowledges and relationships
CREATE (nj:Person {name: "Jane"}),
       (nm:Person {name: "Michael"}),
       (ne:Person {name: "Emily"}),
       (ns:Person {name: "Stan"}),
       (nb:Person {name: "Brian"}),
       (nk:Person {name: "Kenny"}),

       (cis:Company {name: "Icy Software Ltd."}),
       (chp:Company {name: "Hipster Promises Ltd."}),

       (pic:Project {name: "Iceberg", description: "Backup system"}),
       (pif:Project {name: "IceFloe", description: "Build manager"}),
       (pbg:Project {name: "BeardGrower", description: "Project manager"}),
       (peb:Project {name: "ExpertBarber", description: "Project refactoring manager"}),

       (lj:Language {name: "Java"}),
       (lr:Language {name: "R"}),
       (lp:Language {name: "Python"}),
       (ls:Language {name: "Javascript"}),

       (dn:Database {name: "Neo4j"}),
       (dp:Database {name: "PostgreSQL"}),
       (dm:Database {name: "MongoDB"}),

       (pic)-[:USE_LANGUAGE]->(lj),
       (pic)-[:USE_LANGUAGE]->(lp),
       (pic)-[:USE_DATABASE]->(dp),

       (pif)-[:USE_LANGUAGE]->(lp),
       (pic)-[:USE_DATABASE]->(dp),

       (pbg)-[:USE_LANGUAGE]->(ls),
       (pbg)-[:USE_DATABASE]->(dm),

       (peb)-[:USE_LANGUAGE]->(ls),
       (peb)-[:USE_DATABASE]->(dm),

       (nj)-[:EMPLOYED_BY {from: 200501}]->(cis),
       (nj)-[:WORKED_ON]->(pic),
       (nj)-[:WORKED_ON]->(pif),
       (nj)-[:KNOWS_TECHNO {strength: 5}]->(lj),
       (nj)-[:KNOWS_TECHNO {strength: 3}]->(lr),
       (nj)-[:KNOWS_TECHNO {strength: 3}]->(lp),
       (nj)-[:KNOWS_TECHNO {strength: 4}]->(ls),
       (nj)-[:KNOWS_TECHNO {strength: 5}]->(dn),
       (nj)-[:KNOWS_TECHNO {strength: 5}]->(dp),
       (nj)-[:KNOWS_TECHNO {strength: 5}]->(dm),

       (nm)-[:EMPLOYED_BY {from: 201012}]->(cis),
       (nm)-[:WORKED_ON]->(pif),
       (nm)-[:KNOWS_TECHNO {strength: 2}]->(lj),
       (nm)-[:KNOWS_TECHNO {strength: 3}]->(lp),
       (nm)-[:KNOWS_TECHNO {strength: 3}]->(dp),

       (ne)-[:EMPLOYED_BY {from: 200501, to: 201101}]->(cis),
       (ne)-[:EMPLOYED_BY {from: 201102}]->(chp),
       (ne)-[:WORKED_ON]->(pic),
       (ne)-[:WORKED_ON]->(pbg),
       (ne)-[:WORKED_ON]->(peb),
       (ne)-[:KNOWS_TECHNO {strength: 3}]->(lj),
       (ne)-[:KNOWS_TECHNO {strength: 1}]->(lp),
       (ne)-[:KNOWS_TECHNO {strength: 3}]->(ls),
       (ne)-[:KNOWS_TECHNO {strength: 2}]->(dn),
       (ne)-[:KNOWS_TECHNO {strength: 4}]->(dp),
       (ne)-[:KNOWS_TECHNO {strength: 4}]->(dm),

       (ns)-[:EMPLOYED_BY {from: 201102}]->(chp),
       (ns)-[:WORKED_ON]->(pbg),
       (ns)-[:WORKED_ON]->(peb),
       (ns)-[:KNOWS_TECHNO {strength: 3}]->(ls),
       (ns)-[:KNOWS_TECHNO {strength: 3}]->(dm),

       (nk)-[:EMPLOYED_BY {from: 201102}]->(chp),
       (nk)-[:WORKED_ON]->(pbg),
       (nk)-[:WORKED_ON]->(peb),
       (nk)-[:KNOWS_TECHNO {strength: 3}]->(ls),
       (nk)-[:KNOWS_TECHNO {strength: 3}]->(dm),

       (nb)-[:EMPLOYED_BY {from: 201601}]->(chp),
       (nb)-[:WORKED_ON]->(pbg),
       (nb)-[:WORKED_ON]->(peb),
       (nb)-[:KNOWS_TECHNO {strength: 1}]->(ls),
       (nb)-[:KNOWS_TECHNO {strength: 3}]->(lr),
       (nb)-[:KNOWS_TECHNO {strength: 3}]->(dn),
       (nb)-[:KNOWS_TECHNO {strength: 1}]->(dm);

//Get all persons knowing a particular language
MATCH (n:Person)-[:KNOWS_TECHNO]->(l:Language {name:"R"})
RETURN n.name;

//Get person sorted by total skill
MATCH (n:Person)-[r:KNOWS_TECHNO]->(k)
RETURN n.name, SUM(r.strength) AS score
ORDER BY score DESC;

//Get senior dev
MATCH (n:Person)-[emp:EMPLOYED_BY]->(c:Company),
(n)-[r:KNOWS_TECHNO]->(l:Language)
WHERE emp.from < 201606 AND emp.to IS NULL
WITH c, l, MAX(r.strength) AS max_skill
ORDER BY c.name, l.name
MATCH (senior:Person)-[emp:EMPLOYED_BY]->(c),
(senior)-[r:KNOWS_TECHNO ]->(l:Language)
WHERE emp.from < 201606 AND emp.to IS NULL
AND r.strength = max_skill
RETURN c.name, l.name, senior.name,  r.strength AS language_level;

//We start a partnership between Icy Software Ltd and Hipster Promises Ltd.
//where one senior dev in IS will train devs in Hipster Promises
//Is it useful
MATCH (n:Person)-[emp:EMPLOYED_BY]->(c:Company {name: "Icy Software Ltd."}),
(n)-[r:KNOWS_TECHNO]->(l:Language)
WHERE emp.from < 201606 AND emp.to IS NULL
WITH c, l, MAX(r.strength) AS max_skill
ORDER BY c.name, l.name
MATCH (senior:Person)-[emp:EMPLOYED_BY]->(c),
(senior)-[r:KNOWS_TECHNO ]->(l:Language)
WHERE emp.from < 201606 AND emp.to IS NULL
AND r.strength = max_skill
WITH c.name AS formComp, l.name AS formlanguage, senior.name AS trainer,  r.strength AS language_level
MATCH (trainee:Person)-[emp:EMPLOYED_BY]->(c:Company {name: "Hipster Promises Ltd."}),
(trainee)-[:WORKED_ON]->(p:Project)-[:USE_LANGUAGE]->(l:Language {name: formlanguage}),
(trainee)-[r:KNOWS_TECHNO]->(l)
WHERE emp.from < 201606 AND emp.to IS NULL
AND r.strength < language_level
RETURN DISTINCT formComp, formlanguage, trainer,  language_level, trainee.name, r.strength AS trainee_level;