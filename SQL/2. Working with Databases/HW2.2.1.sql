select table_name, constraint_name from information_schema.table_constraints 
where constraint_type = 'PRIMARY KEY' and table_schema = 'public'
order by table_name;

select customer_id,first_name,last_name,active from customer where active=0;

select film_id,title,release_year from film where release_year=2006 order by film_id;

select customer_id,payment_date from payment order by payment_date desc limit 10 offset 0;
