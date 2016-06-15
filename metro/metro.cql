//Get distance between 2 stations
MATCH (start:Station {name:"NATION"}), 
      (end:Station {name:"RANELAGH"}),
      paths = (start)<-[:NEXT_STATION*..30]-(end)
WITH paths AS paths,
REDUCE(total_dist = 0, rel in rels(paths) | total_dist + rel.dist) AS total_dist
RETURN nodes(paths), total_dist
ORDER BY total_dist
LIMIT 5;

//Better with djisktra
MATCH (start:Station {name:"NATION"}), 
      (end:Station {name:"RANELAGH"})
WITH start, end
CALL apoc.algo.dijkstra(start, end, 'NEXT_STATION', 'dist') YIELD path, weight
RETURN path, weight;

//Get linked stations
MATCH (l:Line),
      (s:Station)-[:IS_OF_LINE]->(l),
      (s)-[r:NEXT_STATION]->(s2:Station),
      (s2:Station)-[:IS_OF_LINE]->(l)
WHERE l.name IN ["3bis", "3"]
RETURN l.name, s.name, s2.name, r.dist
ORDER BY l.name;

//Get transfers
MATCH (s:Station),
(s)-[r:IS_OF_LINE]->(l:Line)
WITH s, COUNT(r) AS nb_link
WHERE nb_link > 1
MATCH (s)-[r:IS_OF_LINE]->(l:Line)
WITH s, nb_link, COLLECT(l.name) AS corresp
CALL apoc.coll.sort(corresp) YIELD value AS lines_corresp
RETURN s.name, nb_link, lines_corresp
ORDER BY nb_link DESC, s.name;

//Add inter-station status
MATCH (s:Station)-[r:NEXT_STATION]->(s2:Station)
SET r.isOpened = true
RETURN COUNT(s);

//Get shortest route between 2 stations
MATCH (start:Station {name:"NATION"}), 
      (end:Station {name:"RANELAGH"}),
      paths = (start)<-[:NEXT_STATION*..30{isOpened: true}]-(end)
WITH paths AS paths,
REDUCE(total_dist = 0, rel in rels(paths) | total_dist + rel.dist) AS total_dist
RETURN nodes(paths), total_dist
ORDER BY total_dist
LIMIT 1;

//Close one station
MATCH (s1:Station {name:"BONNE NOUVELLE"})-[r:NEXT_STATION]->(s2:Station {name:"STRASBOURG-SAINT-DENIS"})
SET r.isOpened = false
RETURN s1, s2;