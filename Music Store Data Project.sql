
-- Q1. Who is the Senior Most Employee Based on the Job Title ?
 
 select * from employee 
 order by levels desc 
 limit 1;
 
 -- Q2. Which Countries have the most Invoices ?
 
 select billing_country as Country,
 count(total) as total_invoice
  from invoice
  group by country;

-- Q3. What are the Top 3 Values of Total Invoice ?

select total from invoice
order by total desc
limit 3;

-- Q4. Which city has the best Customers? We Would like to throw a promotional Music Festival in the City that has the highest 
--     sum of invoice totals.Return both the city name & sum of all invoice totals.

Select billing_city as city,
sum(total) as invoice_total 
from invoice 
group by city 
order by invoice_total desc; 
 
 -- Q5. Who is the best Customer? The Customer who has spent the most money will be declared the best customer.
 --     write a query that returns the person who has spent the most money.
 
 select c.customer_id, concat(c.first_name," ",c.last_name) as customer_name,sum(i.total) as total from customer c join invoice i on 
 c.customer_id = i.customer_id group by customer_id, customer_name order by total desc limit 1;
 
 -- Q6. write a query to return the email,first_name,last_name, & Genre of all Rock Music listiners.Return your list ordered alphabetically 
 --     by email starting with A
 
SELECT DISTINCT
    c.email, c.first_name, c.last_name, g.name AS genre_name
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
ORDER BY email;

-- Q7. Let's invite the artist who have written the most rock music in our dataset.Write a query that returns the Artist name 
--     and total track count of the top 10 rock bands.

SELECT 
    a.artist_id, a.name, COUNT(a.artist_id) AS num_of_song
FROM
    artist a
        JOIN
    album2 al ON a.artist_id = al.artist_id
        JOIN
    track t ON al.album_id = t.album_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
GROUP BY artist_id,name
ORDER BY num_of_song DESC
LIMIT 10 ;

-- Q8. Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each
--     track. Order by the song length with the longest songs listed first.

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;


-- Q9. Find how much amount spent by each customer on artists? Write a query to return customer name,artist name and total spent.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    album2 al ON t.album_id = al.album_id
        JOIN
    artist a ON al.artist_id = a.artist_id
GROUP BY customer_name , artist_name
ORDER BY total_spent DESC;


-- Q10. We want to find the most popular music Genre for each country.We determine the most popular genre as the genre with the highest
--      amount of purchases.Write a query that returns each country along with the top Genre.For countries where the maximum number of 
--      purchases is shared return all Genres.

with popular_genre as 
(

    Select count(il.quantity) as purchases,c.country,g.name,g.genre_id,
    Row_number() over(partition by c.country order by count(il.quantity) desc) as rowno 
    From invoice_line il 
    Join invoice i on il.invoice_id = i.invoice_id 
    Join customer c on i.customer_id = c.customer_id 
    Join track t on il.track_id = t.track_id 
    Join genre g on t.genre_id = g.genre_id 
    Group by country,g.name,genre_id
    Order by purchases desc , country
)

Select * from popular_genre where rowno <= 1;

-- Q11. Write a query that determine the customer that has spent the most on music for each country.Write a query that returns the country
--      along with the top customer and how much they spent.For countries where the top amount spent is shared,provide all customers
--      who spent this amount.

with recursive
   customer_with_country as (
   select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending from customer c join invoice i on c.customer_id
   = i.customer_id group by customer_id,first_name,last_name,billing_country order by billing_country,total_spending desc),
   
   customer_max_spending as(
   select billing_country,max(total_spending) as max_spending from customer_with_country group by billing_country)
   
   select cwc.billing_country,total_spending,cwc.customer_id,cwc.first_name,cwc.last_name from customer_with_country cwc join 
   customer_max_spending cmc on cwc.billing_country = cmc.billing_country where cwc.total_spending = cmc.max_spending 
   order by billing_country;
   
   
with customer_with_country as(
select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as rowno
from customer c join invoice i on c.customer_id = i.customer_id
group by customer_id,first_name,last_name,billing_country
order by billing_country,total_spending desc)

select * from customer_with_country where rowno <=1
