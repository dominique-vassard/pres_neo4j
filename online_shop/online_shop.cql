CREATE
//Customers
(jane:Customer {firstName:"Jane", gender: "Female", lastName: "Mitchell", city:"Los Angeles", age: 25}),
(michael:Customer {firstName:"Michael", gender: "Male", lastName: "Humpiks", city: "Birmingham", age: 31}),
(emily:Customer {firstName:"Emily", gender: "Female", lastName: "Berty", city: "Los Angeles", age: 50}),
(stan:Customer {firstName:"Stan", gender: "Male", lastName: "Kanovitch", city: "Chicago", age: 23}),
(kenny:Customer {firstName:"Kenny", gender: "Male", lastName: "Terate", city: "New York", age: 32}),

//Categorys
(book:Category {name: "Book"}),
(movie:Category {name: "Movie"}),
(game:Category {name: "Game"}),
(tvshow:Category {name: "TV Show"}),
(music:Category {name: "Music"}),

//Products
(matrix:Product {name: "Matrix", price: 15.99, director: "Wachowsky Brothers"}),
(drwho:Product {name: "Dr Who 2005", price: 25.99, creator:"Sidney Newman"}),
(motorhead:Product {name: "Motorhead at Madison Garden", price: 45.00, location: "New York"}),
(terror:Product {name: "Terror", price: 4.99, author: "Dan Simmons"}),
(fclubbook:Product {name: "Fight Club", price: 4.99, author:"Chuck Pahlaniuk"}),
(fclubmovie:Product {name: "Fight Club", price: 36.99, director: "David Fincher"}),
(fclubmusic:Product {name: "Fight Club", price: 15.99, composer:"Dust Brothers"}),
(dsouls:Product {name: "Dark Souls III", price: 69.99}),
(witcher:Product {name: "The Witcher III", price: 69.99}),
(mrrobot:Product {name: "Mr Robot", price: 15.99, creator: "Sam Esmail"}),
(scanner:Product {name: "A scanner darkly", price: 5.99, author: "Philip K. Dick"}),
(siva:Product {name: "S.I.V.A", price: 5.99, author: "Philip K. Dick"}),

//Link products and Categorys
(matrix)-[:IS_IN_CATEGORY]->(movie),
(drwho)-[:IS_IN_CATEGORY]->(tvshow),
(motorhead)-[:IS_IN_CATEGORY]->(music),
(terror)-[:IS_IN_CATEGORY]->(book),
(fclubbook)-[:IS_IN_CATEGORY]->(book),
(fclubmovie)-[:IS_IN_CATEGORY]->(movie),
(fclubmusic)-[:IS_IN_CATEGORY]->(music),
(dsouls)-[:IS_IN_CATEGORY]->(game),
(witcher)-[:IS_IN_CATEGORY]->(game),
(mrrobot)-[:IS_IN_CATEGORY]->(tvshow),
(scanner)-[:IS_IN_CATEGORY]->(book),
(siva)-[:IS_IN_CATEGORY]->(book),

//Orders
(jane)-[:ORDERED]->(matrix),
(jane)-[:ORDERED]->(fclubmovie),
(jane)-[:ORDERED]->(mrrobot),

(michael)-[:ORDERED]->(dsouls),
(michael)-[:ORDERED]->(witcher),
(michael)-[:ORDERED]->(mrrobot),
(michael)-[:ORDERED]->(drwho),
(michael)-[:ORDERED]->(motorhead),

(emily)-[:ORDERED]->(fclubbook),
(emily)-[:ORDERED]->(fclubmovie),
(emily)-[:ORDERED]->(fclubmusic),
(emily)-[:ORDERED]->(terror),
(emily)-[:ORDERED]->(scanner),
(emily)-[:ORDERED]->(witcher),

(stan)-[:ORDERED]->(fclubmovie),
(stan)-[:ORDERED]->(siva),
(stan)-[:ORDERED]->(mrrobot);

CREATE INDEX ON :Customer(name);
CREATE INDEX ON :Category(name);
CREATE INDEX ON :Product(name);

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
ON CREATE SET r.strength = nb_products;

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
CREATE (c1)-[s:SIMILAR_TO]->(c2)
SET s.similarity = 1 / ( 1 + distance);

//get category where customer has no score
MATCH (cat:Category),
      (c:Customer)
WHERE NOT (c)-[:LIKES]->(cat)
RETURN c.firstName, cat.name
ORDER BY c.firstName, cat.name;

//Add orders for Test
MATCH (c:Customer {firstName:"Jane"}),
      (p:Product {name: "Terror"})
CREATE (c)-[:ORDERED]->(p)
RETURN c, p ;