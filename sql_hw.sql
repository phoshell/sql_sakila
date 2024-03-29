USE sakila;

-- 1a OUR STARZ
SELECT first_name, last_name
FROM actor;

-- 1b actor_name Column 
SELECT CONCAT(UPPER(first_name), ' ' , UPPER(last_name))
AS actor_name
FROM sakila.actor;

SELECT * FROM sakila.actor;

-- 2a, finding JOE
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name='JOE';

-- 2b, Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c, Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries:
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor.
-- You don't think you will be performing queries on a description, so create a column in the
-- table actor named description and use the data type BLOB.
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.
ALTER TABLE actor 
DROP description;

SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS last_name_count
FROM actor
GROUP BY last_name
HAVING last_name_count>1;

-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS last_name_count
FROM actor
GROUP BY last_name
HAVING last_name_count>=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.
UPDATE actor SET first_name='HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name='GROUCHO' WHERE first_name='HARPO';
SELECT * FROM actor;

-- 5a. You cannot locate the schema of the address table.
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
-- Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON address.address_id=staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Use tables staff and payment.
SELECT staff.first_name, SUM(payment.amount)
FROM staff
JOIN payment ON payment.staff_id=staff.staff_id
GROUP BY staff.first_name;

-- 6c. List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join
SELECT film.title, SUM(film_actor.film_id)
FROM film
JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM film f
LEFT OUTER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title LIKE 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_paid_amount
FROM customer c
JOIN payment p USING(customer_id)
GROUP BY (p.customer_id)
ORDER BY (c.last_name) ASC
LIMIT 19;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT film_id, title, language_id FROM film
WHERE (
	film.title LIKE 'K%' OR film.title LIKE 'Q%')
    AND language_id IN (
		SELECT language_id
        FROM language
        WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
FROM film_actor
    WHERE film_id IN (
		SELECT film_id
	FROM film
	WHERE title = 'Alone Trip')
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need
-- the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address ON
	customer.address_id = address.address_id
		JOIN city ON
			address.city_id = city.city_id
				JOIN country ON
					city.country_id = country.country_id
						WHERE country.country = 'Canada';
                        
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT title
FROM film 
WHERE film_id IN (
	SELECT film_id
    FROM film_category
    WHERE category_id IN (
		SELECT category_id
        FROM category
        WHERE name = 'Family')
        );
        
-- 7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, COUNT(rental.inventory_id) AS rental_count
FROM inventory
JOIN rental ON
inventory.inventory_id = rental.inventory_id
GROUP BY film_id
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT customer.store_id, SUM(payment.amount) AS total_payment
FROM customer
JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
	JOIN address ON
		store.address_id = address.address_id
			JOIN city ON
				address.city_id = city.city_id
					JOIN country ON
						city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT customer.store_id, SUM(payment.amount) AS total_payment
FROM customer
JOIN payment ON
	customer.store_id = payment.customer_id
	GROUP BY store_id;

-- View of the Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS 
SELECT category.name AS Film_Category, SUM(payment.amount) as Gross_Sum
FROM category
JOIN film_category ON
	category.category_id = film_category.category_id
		JOIN inventory ON
			film_category.film_id = inventory.film_id
				JOIN rental ON 
					inventory.inventory_id = rental.inventory_id
						JOIN payment ON 
							rental.rental_id = payment.rental_id
                            GROUP BY name
                            ORDER BY gross_sum DESC
                            LIMIT 5;
                            
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
