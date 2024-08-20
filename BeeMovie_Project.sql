SELECT * FROM movie
WHERE year = 2019
LIMIT 10;
-- Q1. Find the total number of rows in each table of the schema?
-- COUNT COLUMN IN director_mapping
SELECT COUNT(*) as count_director_mapping FROM director_mapping;
-- COUNT COLUMN IN genre
SELECT COUNT(*) as count_genre FROM genre ;
-- COUNT COLUMN IN movie
SELECT COUNT(*)as count_movie FROM movie;
-- COUNT COLUMN IN names
SELECT COUNT(*)as count_names FROM names;
-- COUNT COLUMN IN ratings
SELECT COUNT(*)as count_ratings FROM ratings;
-- COUNT COLUMN IN role_mapping
SELECT COUNT(*) as count_role_mapping FROM role_mapping;

-- Q2. Which columns in the movie table have null values?
-- SELECT *
-- FROM movie
-- WHERE 
-- 	id IS NULL OR 
-- 	title IS NULL OR
-- 	year IS NULL OR
-- 	date_published IS NULL OR
-- 	duration IS NULL OR
-- 	country IS NULL OR
-- 	worlwide_gross_income IS NULL OR
-- 	languages IS NULL OR
-- 	production_company IS NULL;
    
SELECT
    CONCAT_WS(', ',
        CASE WHEN id IS NULL THEN 'id' ELSE NULL END,
        CASE WHEN title IS NULL THEN 'title' ELSE NULL END,
        CASE WHEN year IS NULL THEN 'year' ELSE NULL END,
		CASE WHEN date_published IS NULL THEN 'date_published' ELSE NULL END,
        CASE WHEN duration IS NULL THEN 'duration' ELSE NULL END,
        CASE WHEN country IS NULL THEN 'country' ELSE NULL END,
		CASE WHEN worlwide_gross_income IS NULL THEN 'worlwide_gross_income' ELSE NULL END,
        CASE WHEN languages IS NULL THEN 'languages' ELSE NULL END,
        CASE WHEN production_company IS NULL THEN 'production_company' ELSE NULL END
        -- Add more columns as needed
    ) AS columns_with_nulls
FROM movie
WHERE 
    id IS NULL OR
    title IS NULL OR
    year IS NULL OR
    date_published IS NULL OR
    duration IS NULL OR
    country IS NULL OR
    worlwide_gross_income IS NULL OR
    languages IS NULL OR
    production_company IS NULL;
-- -- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
SELECT year, COUNT(id) as number_of_movies FROM movie
GROUP BY year;

SELECT MONTH(date_published) as month_num, 
COUNT(id) as number_of_movies 
FROM movie
GROUP BY month_num
ORDER BY month_num;

-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT year, country, COUNT(*) as number_of_movie FROM movie
WHERE year = 2019 AND (country LIKE '%USA%' OR country LIKE '%India%')
GROUP BY country,year;
-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT distinct(genre) as genre_unique FROM genre;
/* So, Bee Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT gen.genre, COUNT(gen.genre) as number_of_movie_genre FROM genre gen
INNER JOIN movie movi ON gen.movie_id = movi.id
GROUP BY gen.genre
order by number_of_movie_genre desc;

/* So, based on the insight that you just drew, Bee Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT COUNT(*) AS number_of_movies_with_one_genre
FROM (
    SELECT movie_id FROM genre
    GROUP BY movie_id
    HAVING COUNT(genre) = 1
) AS single_genre_movies;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of Bee Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
SELECT AVG(duration),genre FROM movie m
INNER JOIN genre g ON m.id = g.movie_id
GROUP BY genre;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
WITH GenreCount AS (
	SELECT g.genre, COUNT(*) AS movie_count FROM movie m
    INNER JOIN genre g ON m.id = g.movie_id
    GROUP BY g.genre
)
SELECT genre, movie_count,
rank() OVER (ORDER by movie_count DESC) as Ranking
FROM GenreCount;

-- Q10.  Find the minimum and maximum values in each column of the ratings table except the movie_id column?
SELECT MAX(avg_rating) as max_avg_rating,
	   MAX(total_votes) as max_total_votes,
	   MAX(median_rating) as max_median_rating,
       MIN(avg_rating) as min_avg_rating,
	   MIN(total_votes) as min_total_votes,
	   MIN(median_rating) as min_median_rating
 from ratings;
 -- Q11. Which are the top 10 movies based on average rating?
 SELECT movie_id,m.title, avg_rating FROM ratings r
 INNER JOIN movie m ON r.movie_id = m.id
 ORDER BY avg_rating DESC
 LIMIT 10;
 
/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
SELECT median_rating,COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating ASC;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
WITH hit_movies AS (
    SELECT 
        production_company,
        COUNT(movie_id) AS movie_count
    FROM 
        movie m
    INNER JOIN 
        ratings r ON m.id = r.movie_id
	 WHERE
        r.avg_rating > 8 AND production_company is not null
    GROUP BY 
        production_company
   
)
SELECT production_company, movie_count,
    DENSE_RANK() OVER (ORDER BY movie_count DESC) AS prod_company_rank
FROM hit_movies
ORDER BY prod_company_rank ASC;










-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
 SELECT 
    g.genre,
    COUNT(DISTINCT m.id) AS movie_count
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE 
    m.country LIKE '%USA%'
    AND m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
    AND r.total_votes > 1000
GROUP BY g.genre, date_published
ORDER BY movie_count DESC;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT m.title, r.avg_rating, genre
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE title LIKE 'The%' and r.avg_rating > 8 and g.genre = 'thriller';


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT COUNT(*), median_rating
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating;









-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
-- vote for Italian movies
WITH votes_summary AS(
SELECT 
    'Italy' AS country,
    SUM(r.total_votes) AS total_votes
FROM 
    movie m
JOIN 
    ratings r ON m.id = r.movie_id
WHERE 
    m.country LIKE '%Italy%'

UNION ALL
SELECT 'Germany' AS country,
    SUM(r.total_votes) AS total_votes
FROM 
    movie m
JOIN 
    ratings r ON m.id = r.movie_id
WHERE m.country LIKE '%Germany%'
)
SELECT *,CASE WHEN total_votes = (SELECT MAX(total_votes) FROM votes_summary) THEN 'Higher Vote Count'
        ELSE 'Lower Vote Count' END AS vote_status
FROM votes_summary;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) as name_nulls,
	   SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) as height_nulls,
       SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) as date_of_birth_nulls,
       SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) as known_for_movies_nulls
FROM names;
       







/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by Bee Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH filtered_movies AS (
    SELECT m.id, m.title, g.genre, dm.name_id AS director_id, n.name AS director_name,
		AVG(r.avg_rating) AS avg_rating
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
    JOIN genre g ON m.id = g.movie_id
    JOIN director_mapping dm ON m.id = dm.movie_id
    JOIN names n ON dm.name_id = n.id
    GROUP BY m.id, m.title, g.genre, dm.name_id, n.name
    HAVING AVG(r.avg_rating) > 8
),
top_genres AS (
    SELECT genre, COUNT(*) AS movie_count
    FROM filtered_movies
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),
top_directors AS (
    SELECT fm.director_name, fm.genre, COUNT(*) AS movie_count,
        ROW_NUMBER() OVER (PARTITION BY fm.genre ORDER BY COUNT(*) DESC) AS director_rank
    FROM filtered_movies fm
    JOIN top_genres tg ON fm.genre = tg.genre
    GROUP BY fm.director_name, fm.genre
)
SELECT 
    genre,
    director_name,
    movie_count,
    director_rank
FROM 
    top_directors
WHERE 
    director_rank <= 3
ORDER BY 
    genre, director_rank;



/* James Mangold can be hired as the director for Bee's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH rating_movie AS(
SELECT m.id,
        m.title,
        rm.name_id AS actor_id,
        n.name AS actor_name,
        r.median_rating FROM ratings r
JOIN role_mapping rm ON rm.movie_id = r.movie_id
JOIN names n ON n.id = rm.name_id 
JOIN movie m ON m.id = rm.movie_id 
WHERE r.median_rating >=8
)    
SELECT actor_name, COUNT(*) AS movie_count
FROM rating_movie
GROUP BY actor_name
ORDER BY movie_count DESC;




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
Bee Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT production_company, SUM(total_votes) as vote_count,
dense_rank() OVER (ORDER BY SUM(total_votes) DESC) as prod_comp_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE production_company is not null
GROUP BY production_company;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since Bee Movies is based out of Mumbai, India also wants to woo its local audience. 
Bee Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH indian_movies AS (
    SELECT 
        m.id AS movie_id,
        rm.name_id AS actor_id,
        n.name AS actor_name,
        r.avg_rating,
        r.total_votes
    FROM 
        movie m
    JOIN 
        ratings r ON m.id = r.movie_id
    JOIN 
        role_mapping rm ON m.id = rm.movie_id
    JOIN 
        names n ON rm.name_id = n.id
    WHERE 
        m.country LIKE '%India%'
    AND 
        rm.category = 'actor' -- Assuming 'category' specifies the role as actor
),
actor_stats AS (
    SELECT 
        actor_name,
        SUM(avg_rating * total_votes) / SUM(total_votes) AS actor_avg_rating,
        SUM(total_votes) AS total_votes,
        COUNT(DISTINCT movie_id) AS movie_count
    FROM 
        indian_movies
    GROUP BY 
        actor_name
    HAVING 
        COUNT(DISTINCT movie_id) >= 5
)
SELECT 
        actor_name,
        total_votes,
        movie_count,
        actor_avg_rating,
        RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM actor_stats;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH hindi_movies AS (
    SELECT 
        m.id AS movie_id,
        rm.name_id AS actress_id,
        n.name AS actress_name,
        r.avg_rating,
        r.total_votes
    FROM 
        movie m
    JOIN 
        ratings r ON m.id = r.movie_id
    JOIN 
        role_mapping rm ON m.id = rm.movie_id
    JOIN 
        names n ON rm.name_id = n.id
    WHERE 
        m.country ='India'
    AND 
        m.languages = 'Hindi'
    AND 
        rm.category = 'actress' -- Assuming 'category' specifies the role as actress
),
actress_stats AS (
    SELECT 
        actress_name,
        SUM(avg_rating * total_votes) / SUM(total_votes) AS actress_avg_rating,
        SUM(total_votes) AS total_votes,
        COUNT(DISTINCT movie_id) AS movie_count
    FROM 
        hindi_movies
    GROUP BY 
        actress_name
    HAVING 
        COUNT(DISTINCT movie_id) >= 3
)
SELECT actress_name,total_votes,movie_count, actress_avg_rating,
dense_rank() over (ORDER BY actress_avg_rating DESC , total_votes DESC) as ranking
FROM actress_stats;



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT 
    m.title AS movie_title,
    r.avg_rating,
    CASE 
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        WHEN r.avg_rating < 5 THEN 'Flop movies'
    END AS movie_category
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE g.genre = 'thriller'
ORDER BY r.avg_rating DESC;




/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/
-- Segment 4:
-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
WITH Genre_Avg_Duration AS (
    SELECT g.genre, AVG(m.duration) AS avg_duration
    FROM movie m
    JOIN genre g ON m.id = g.movie_id
    GROUP BY g.genre
)
SELECT  genre,avg_duration,
    SUM(avg_duration) OVER (ORDER BY genre) AS running_total_duration,
    AVG(avg_duration) OVER ( ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM Genre_Avg_Duration
ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_genres AS (
	SELECT g.genre, COUNT(*) as count_genres FROM genre g
    join movie m ON m.id = g.movie_id
    GROUP BY genre
    ORDER BY count_genres DESC
    LIMIT 3 
),
highest_gross_movie AS(
	SELECT g.genre,year,title as movie_name,worlwide_gross_income FROM genre g
    join movie m ON m.id = g.movie_id
    WHERE genre IN ('Drama', 'Comedy', 'Thriller') and worlwide_gross_income is not null
    ORDER BY worlwide_gross_income DESC
)
select *,
DENSE_RANK() OVER(ORDER BY worlwide_gross_income DESC)from highest_gross_movie as movie_rank
LIMIT 5;

-- Top 3 Genres based on most number of movies
SELECT g.genre, COUNT(*) as count_genres FROM genre g
    join movie m ON m.id = g.movie_id
    GROUP BY genre
    ORDER BY count_genres DESC
    LIMIT 3 ;







-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT production_company, COUNT(*) AS movie_count,
dense_rank() over (order by COUNT(*) DESC ) as prod_comp_rank 
FROM movie m 
JOIN ratings r ON m.id =r.movie_id
WHERE r.median_rating >=8 and production_company is not null and POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH super_hit_movies as (
	SELECT 
	m.id,
    m.title AS movie_title,
    r.avg_rating,g.genre, r.total_votes,
    CASE 
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        WHEN r.avg_rating < 5 THEN 'Flop movies'
    END AS movie_category
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.avg_rating DESC
)
SELECT n.name,sphm.total_votes, COUNT(*)as movie_count, AVG(sphm.avg_rating) as actress_avg_rating,
dense_rank() over (order by AVG(sphm.avg_rating) DESC) AS ranking
FROM super_hit_movies sphm
JOIN role_mapping rm ON sphm.id = rm.movie_id
JOIN names n on n.id = rm.name_id
WHERE category = 'actress' and sphm.genre = 'Drama'
GROUP BY n.name,sphm.total_votes;

 





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH DirectorMovieDates AS (
    SELECT
        dm.name_id AS director_id,
        n.name AS director_name,
        m.id AS movie_id,
        m.date_published,
        m.duration,
        r.avg_rating,
        r.total_votes,
        LEAD(m.date_published) OVER (PARTITION BY dm.name_id ORDER BY m.date_published) AS next_movie_date
    FROM
        director_mapping dm
    JOIN names n ON dm.name_id = n.id
    JOIN movie m ON dm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
),
DirectorStats AS (
    SELECT
        director_id,
        director_name,
        COUNT(movie_id) AS number_of_movies,
        AVG(DATEDIFF(next_movie_date, date_published)) AS avg_inter_movie_days,
        AVG(avg_rating) AS avg_rating,
        SUM(total_votes) AS total_votes,
        MIN(avg_rating) AS min_rating,
        MAX(avg_rating) AS max_rating,
        SUM(duration) AS total_duration
    FROM DirectorMovieDates
    WHERE next_movie_date IS NOT NULL
    GROUP BY director_id, director_name
)

SELECT
    director_id,
    director_name,
    number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration
FROM DirectorStats
ORDER BY number_of_movies DESC
LIMIT 9;


 














