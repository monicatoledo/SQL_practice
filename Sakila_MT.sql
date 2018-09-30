USE sakila;

-- 1a Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor;

-- 1.b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT CONCAT(first_name," " ,last_name) AS "Actor Name"
FROM actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- Find all actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name CHAR(30) AFTER first_name;

ALTER TABLE actor 
CHANGE COLUMN middle_name middle_name BLOB NULL DEFAULT NULL ;

-- Now delete the middle_name column
ALTER TABLE actor
DROP COLUMN middle_name;

-- List the last names of actors, as well as how many actors have that last name
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' 
FROM actor 
GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count' 
FROM actor 
GROUP BY last_name 
HAVING name_count >= 2;

UPDATE actor SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor SET first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END WHERE actor_id = 172;

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address; 
CREATE SCHEMA test;
CREATE TABLE IF NOT EXISTS address ( 
address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT, 
address varchar(50) NOT NULL, 
address2 varchar(50) DEFAULT NULL, 
district varchar(20) NOT NULL, 
city_id smallint(5) unsigned NOT NULL, 
postal_code varchar(10) DEFAULT NULL, 
phone varchar(20) NOT NULL, 
location geometry NOT NULL, 
last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
PRIMARY KEY (address_id)) 
ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- Use JOIN to display the first and last names, as well as the address, of each staff member.

SELECT first_name, last_name, address
FROM staff INNER JOIN address
ON staff.address_id = address.address_id;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS sum_payment
FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id 
WHERE payment.payment_date LIKE '2005-08%' GROUP BY payment.staff_id;

--  List each film and the number of actors who are listed for that film. Use tables film_actor and film
SELECT title, COUNT(actor_id) AS numb_actors 
FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id GROUP BY title;

-- How many copies of the film Hunchback Impossible exist in the inventory system

SELECT title, COUNT(inventory_id) AS num_copies 
FROM film INNER JOIN inventory ON film.film_id = inventory.film_id WHERE title = 'Hunchback Impossible';

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(payment.amount) AS total_paid 
FROM payment INNER JOIN customer ON payment.customer_id =customer.customer_id 
GROUP BY customer.customer_id
ORDER by last_name;

-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM film WHERE language_id IN (
	SELECT language_id 
    FROM language 
    WHERE name = "English" ) 
    AND (title LIKE "K%") OR (title LIKE "Q%");

-- Use subqueries to display all actors who appear in the film Alone Trip. 
SELECT last_name, first_name 
FROM actor WHERE actor_id IN (
	SELECT actor_id 
    FROM film_actor 
    WHERE film_id IN (
		SELECT film_id 
        FROM film 
        WHERE title = "Alone Trip"));
        
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer
	INNER JOIN address on address.address_id = customer.address_id 
    INNER JOIN city c on c.city_id= address.city_id
    INNER JOIN country d on d.country_id= c.country_id
WHERE country = 'Canada';

-- Identify all movies categorized as family films.

SELECT title
FROM film WHERE film_id IN (
	SELECT film_id
    FROM film_category WHERE category_id IN (
    SELECT category_id
    FROM category WHERE name="Family"));
    
-- Display the most frequently rented movies in descending order.

SELECT title, COUNT(rental.inventory_id)
FROM film
	INNER JOIN inventory ON (film.film_id = inventory.film_id)
    INNER JOIN rental ON (inventory.inventory_id = rental.inventory_id)
GROUP BY film.title
ORDER BY COUNT(rental.inventory_id) DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) AS revenue 
FROM store INNER JOIN staff ON store.store_id = staff.store_id 
	INNER JOIN payment ON payment.staff_id = staff.staff_id 
GROUP BY store.store_id;

-- Write a query to display for each store its store ID, city, and country. 
SELECT store.store_id, city.city, country.country 
FROM store INNER JOIN address ON store.address_id = address.address_id 
	INNER JOIN city ON address.city_id = city.city_id 
    INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT name, SUM(p.amount) AS gross_revenue 
FROM category c INNER JOIN film_category fc ON fc.category_id = c.category_id 
	INNER JOIN inventory i ON i.film_id = fc.film_id 
    INNER JOIN rental r ON r.inventory_id = i.inventory_id 
    RIGHT JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.  
DROP VIEW IF EXISTS top_five_genres; 
CREATE VIEW top_five_genres AS
SELECT name, SUM(p.amount) AS gross_revenue 
FROM category c INNER JOIN film_category fc ON fc.category_id = c.category_id 
	INNER JOIN inventory i ON i.film_id = fc.film_id 
    INNER JOIN rental r ON r.inventory_id = i.inventory_id 
    RIGHT JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres
DROP VIEW top_five_genres;