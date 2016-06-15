//Recommend product of the same category when a customer add a porduct to his cart
//Example: a customer adds "Terror" to his cart
MATCH (p:Product {name: "Terror"})-[:IS_IN_CATEGORY]->(c:Category),
      (p)<-[:ORDERED]-(cu:Customer),
      (cu)-[:ORDERED]->(rec:Product)-[:IS_IN_CATEGORY]->(c)
WHERE rec <> p
RETURN rec;

//Recommendations depending on age
MATCH (p:Product {name: "S.I.V.A"}),
      (p)<-[:ORDERED]-(cu:Customer),
      (cu)-[:ORDERED]->(rec:Product)
WHERE rec <> p
AND cu.age + 5 >= 25 AND cu.age - 5 <= 25
RETURN DISTINCT rec;

//We noticed that Kenny didn't order anything
//and we want to send him an email with few products he might like
//Maybe somthing in his town
MATCH (c:Customer {firstName: "Kenny"}),
      (p:Product)
WHERE p.location = c.city
RETURN DISTINCT p;

//Send him what was ordered by customer with same gender and approximatively the same age!
MATCH (c:Customer {firstName: "Kenny"}),
      (cu:Customer)-[:ORDERED]->(rec:Product)
WHERE cu.gender = c.gender
AND cu.age + 5 >= c.age AND cu.age - 5 <= c.age
RETURN DISTINCT rec;

//Finally, Kenny ordered something
MATCH  (c:Customer {firstName: "Kenny"}),
       (p:Product {name:"Motorhead at Madison Garden"})
CREATE (c)-[:ORDERED]->(p);

//Now we want to send email with recommendations to customer with similar profiles
//First we need to compute similarities
//Add info for comparison
MATCH (c:Customer)-[:ORDERED]->(p:Product),
      (p)-[:IS_IN_CATEGORY]->(cat:Category)
WITH c, cat, COUNT(p) AS nb_products
MERGE (c)-[r:LIKES]->(cat)
SET r.strength = nb_products;

//Shortcut: add strength 0 relationships
MATCH (cat:Category),
      (c:Customer)
WHERE NOT (c)-[:LIKES]->(cat)
WITH c, cat
MERGE (c)-[r:LIKES]->(cat)
ON CREATE sET r.strength = 0;

//Add similarities relationships
MATCH (c1:Customer)-[c1likes:LIKES]->(cat:Category),
      (c2:Customer)-[c2likes:LIKES]->(cat)
WHERE id(c1) > id(c2)
WITH c1, c2, COLLECT((c1likes.strength - c2likes.strength)^2) AS plikes
WITH c1, c2, SQRT(REDUCE(total = 0.0, like IN plikes | total + like)) AS distance
// RETURN c1.firstName, c2.firstName, distance, 1 / ( 1 + distance) AS similarity;
MERGE (c1)-[s:SIMILAR_TO]->(c2)
SET s.similarity = 1 / ( 1 + distance);

//get category where customer has no score
// MATCH (cat:Category),
//       (c:Customer)
// WHERE NOT (c)-[:LIKES]->(cat)
// RETURN c.firstName, cat.name
// ORDER BY c.firstName, cat.name;

//Add orders for Test in order to have Jane and Stan identical
MATCH (c:Customer {firstName:"Jane"}),
      (p:Product {name: "Terror"})
CREATE (c)-[:ORDERED]->(p)
RETURN c, p;

MATCH (c:Customer {firstName: "Stan"}),
      (p:Product {name:"Matrix"})
CREATE (c)-[:ORDERED]->(p)
RETURN c, p;

//Get similarities
MATCH (c:Customer)-[r:SIMILAR_TO]->(c2:Customer)
RETURN c.firstName, c2.firstName, r.similarity
ORDER BY c.firstName, c2.firstName;

//Now we can recommend products based on similarity
//Similarity is a two-way relationship!
MATCH (c:Customer)-[r:SIMILAR_TO]-(c2:Customer),
      (c)-[:ORDERED]->(p:Product),
      (c2)-[:ORDERED]->(p2:Product)
WHERE p <> p2 AND r.similarity > 0.25
RETURN c.firstName,COLLECT(DISTINCT p2.name);

//Well, we want to biased similarity
//Based it only on common order

//Remove 0 strength likes relationships
MATCH (c:Customer)-[r:LIKES {strength: 0}]->(cat:Category)
DELETE r;

//rebuilt similarity
MATCH (c1:Customer)-[c1likes:LIKES]->(cat:Category),
      (c2:Customer)-[c2likes:LIKES]->(cat)
WHERE id(c1) > id(c2)
WITH c1, c2, COLLECT((c1likes.strength - c2likes.strength)^2) AS plikes
WITH c1, c2, SQRT(REDUCE(total = 0.0, like IN plikes | total + like)) AS distance
// RETURN c1.firstName, c2.firstName, distance, 1 / ( 1 + distance) AS similarity;
MERGE (c1)-[s:SIMILAR_TO]->(c2)
SET s.similarity = 1 / ( 1 + distance);

//What we got now?
MATCH (c:Customer)-[r:SIMILAR_TO]->(c2:Customer)
RETURN c.firstName, c2.firstName, r.similarity
ORDER BY c.firstName, c2.firstName;

//And redo recommendation
MATCH (c:Customer {firstName:"Stan"})-[r:SIMILAR_TO]->(c2:Customer),
      (c)-[:ORDERED]->(p:Product),
      (c2)-[:ORDERED]->(p2:Product)
WHERE p <> p2 AND r.similarity > 0.5
RETURN c.firstName,COLLECT(DISTINCT p2.name);

//Recommendation based on age
MATCH (p:Product {name: "S.I.V.A"}),
      (p)<-[:ORDERED]-(cu:Customer),
      (cu)-[:ORDERED]->(rec:Product)
WHERE rec <> p
AND cu.age + 5 >= 25 AND cu.age - 5 <= 25
RETURN DISTINCT rec;

//We don't want to use this odd value all the time
//So what can we do?
//Clustering
MATCH (c:Customer)
SET c.ageCluster = 
CASE 
    WHEN c.age < 18  THEN 1
    WHEN c.age >= 18 AND c.age < 24 THEN 2
    WHEN c.age >= 25 AND c.age < 34 THEN 3
    WHEN c.age >= 35 AND c.age < 45 THEN 4
    ELSE 5
END;

//Control results
MATCH (c:Customer)
RETURN c.firstName, c.age, c.ageCluster;

//Now, recommend
MATCH (c:Customer)-[:ORDERED]->(p:Product)
RETURN c.ageCluster, COLLECT(p.name);

//We want to sned email with articles of popular categories
//What people prefer in the same age cluster
MATCH (c:Customer {firstName: "Kenny"}),
      (c2:Customer)-[r:LIKES]->(cat:Category)
WHERE c2 <> c AND c.ageCluster = c2.ageCluster
RETURN cat.name
ORDER BY r.strength DESC
LIMIT 1;

//What has most success in the age cluster
MATCH (c:Customer {firstName: "Kenny"}),
      (c2:Customer)-[r:ORDERED]->(p:Product),
      (p)-[:IS_IN_CATEGORY]->(cat:Category)
WHERE c2 <> c AND c.ageCluster = c2.ageCluster
WITH cat, COUNT(r) AS nb_orders
RETURN cat.name
ORDER BY nb_orders DESC
LIMIT 1;