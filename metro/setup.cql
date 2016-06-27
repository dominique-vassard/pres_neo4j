//[Metro] Setup

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

//Then launch it really
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