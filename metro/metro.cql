//Create constraints (and indexes)
CREATE CONSTRAINT ON (c:City) ASSERT c.name IS UNIQUE;
CREATE CONSTRAINT ON (s:Station) ASSERT s.name IS UNIQUE;
CREATE CONSTRAINT ON (di:District) ASSERT di.name IS UNIQUE;
CREATE CONSTRAINT ON (l:Line) ASSERT l.name IS UNIQUE;

//Create stations and city
//First try out query
LOAD CSV WITH HEADERS FROM "file:/stations.csv" AS line
WITH line
LIMIT 15
MERGE (c:City {name: line.city})
MERGE (s:Station {name: line.name})
ON CREATE SET
s.uid = toInt(line.id),
s.traffic = toInt(line.traffic),
s.longitude = toFloat(line.longitude),
s.latitude = toFloat(line.latitude)
//MERGE (s)-[:IS_IN_CITY]->(c)

//Managing Paris districts (station is linekd to district and district to city)
//(Station)-[:IS_IN_DISTRICT]->(District)-[:IS_IN_CITY]->(City)
FOREACH ( x IN (CASE WHEN line.city = 'Paris' THEN [1] ELSE [] END) |
    MERGE (di:District {name: toInt(line.district)})-[:IS_IN_CITY]->(c)
    MERGE (s)-[:IS_IN_DISTRICT]->(di)
)

//Managing non-Paris cities (station is linked directly to city)
//(Station)-[:IS_IN_CITY]->(City)
FOREACH ( x IN (CASE WHEN line.city <> 'Paris' THEN [1] ELSE [] END) |
    MERGE (s)-[:IS_IN_CITY]->(c)
)

RETURN COUNT(s);

//Then lauch it really
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:/stations.csv" AS line
MERGE (c:City {name: line.city})
MERGE (s:Station {name: line.name})
ON CREATE SET
s.uid = toInt(line.id),
s.traffic = toInt(line.traffic),
s.longitude = toFloat(line.longitude),
s.latitude = toFloat(line.latitude)

//Managing Paris districts (station is linekd to district and district to city)
//(Station)-[:IS_IN_DISTRICT]->(District)-[:IS_IN_CITY]->(City)
FOREACH ( x IN (CASE WHEN line.city = 'Paris' THEN [1] ELSE [] END) |
    MERGE (di:District {name: toInt(line.district)})-[:IS_IN_CITY]->(c)
    MERGE (s)-[:IS_IN_DISTRICT]->(di)
)

//Managing non-Paris cities (station is linked directly to city)
//(Station)-[:IS_IN_CITY]->(City)
FOREACH ( x IN (CASE WHEN line.city <> 'Paris' THEN [1] ELSE [] END) |
    MERGE (s)-[:IS_IN_CITY]->(c)
)

RETURN COUNT(s);

//Oh oh the eager thing.


//It is possible to load JSOn from an url like this:
WITH "http://ekseerg.com/playing/metro/lines.json" AS url
CALL apoc.load.json(url) YIELD value AS line
RETURN line;

//Add line infos, link stations and add distance between stations
WITH "http://ekseerg.com/playing/metro/lines.json" AS url
CALL apoc.load.json(url) YIELD value AS data
WITH data.features as line
UNWIND line AS data
WITH data.properties.LINE AS name, data.properties.COLOR AS color, data.geometry.coordinates AS stations_pos, range(1, size(data.geometry.coordinates) -1) AS inc
MERGE (l:Line {name: name, color: color})
FOREACH(ind IN inc |
	MERGE(prev:Station {longitude: toFloat(stations_pos[ind-1][1]), latitude: toFloat(stations_pos[ind-1][0])})
	MERGE(next:Station {longitude: toFloat(stations_pos[ind][1]), latitude: toFloat(stations_pos[ind][0])})
	MERGE (prev)-[:NEXT_STATION {dist: distance(point(prev), point(next))}]->(next)
    MERGE(prev)-[:IS_OF_LINE]->(l)
    MERGE(next)-[:IS_OF_LINE]->(l)
)
RETURN name, color, inc;


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