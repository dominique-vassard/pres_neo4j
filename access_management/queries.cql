//Get accessible resourcs for a specific person
MATCH (p:Person {name: "Emily"}),
      (p)-[HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource)
RETURN p.name, COLLECT (res.name);

//Has this person got an access to this resource
MATCH (p:Person {name: "Jane"}),
      (p)-[:HAS_ACCESS|IS_IN_GROUP*0..2]->(res:Resource {name: "www.facebook.com"})
RETURN COUNT(res);


//Add temporary access to a resource to a person

//Remove a person from the organisation