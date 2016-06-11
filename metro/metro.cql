CREATE CONSTRAINT ON (c:City) ASSERT c.name IS UNIQUE;
CREATE CONSTRAINT ON (s:Station) ASSERT s.name IS UNIQUE;

LOAD CSV WITH HEADERS FROM "file:/stations.csv" AS line
MERGE (c:City {name: line.city})
MERGE (s:Station {name: line.name})
ON CREATE SET
s.district = line.district,
s.traffic = line.traffic,
s.longitude = line.longitude,
s.latitude = line.latitude
MERGE (s)-[:IS_IN_CITY]->(c)
RETURN s;