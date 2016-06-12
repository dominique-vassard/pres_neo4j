CREATE 
//Customers
(jane:Customer {firstName:"Jane", lastName: "Mitchell", city:"Los Angeles", age: "25"}),
(michael:Customer {firstName:"Michael", lastName: "Humpiks", city: "Birmingham", age: "31"}),
(emily:Customer {firstName:"Emily", lastName: "Berty", city: "Los Angeles", age: "50"}),
(stan:Customer {firstName:"Stan", lastName: "Kanovitch", city: "Chicago", age: "23"}),
(kenny:Customer {firstName:"Kenny", lastName: "Terate", city: "New York", age: "32"}),

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