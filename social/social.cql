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

//Here we get Java language, which is not used in Hipster Promises
// This is due to Emily that worked before on Java project in Icy Software
//But there is clearly a problme in ou model: Project are not linked to Company!!!!