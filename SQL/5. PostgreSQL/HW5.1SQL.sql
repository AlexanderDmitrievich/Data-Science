select *,
row_number() over (partition by rental.customer_id order by rental.rental_date) as usernumber
from rental

select cu.first_name || ' ' || cu.last_name username,
count(f.special_features)
from film f
inner join inventory i on f.film_id=i.film_id
inner join rental r on i.inventory_id=r.inventory_id
inner join customer cu on r.customer_id=cu.customer_id
where f.special_features::text ilike '%Behind the Scenes%'
group by username

create materialized view filmfeatures as
select cu.first_name || ' ' || cu.last_name username,
count(f.special_features)
from film f
inner join inventory i on f.film_id=i.film_id
inner join rental r on i.inventory_id=r.inventory_id
inner join customer cu on r.customer_id=cu.customer_id
where f.special_features::text ilike '%Behind the Scenes%'
group by username

refresh materialized view filmfeatures

select title, special_features 
from film 
where special_features::text ilike '%Behind the Scenes%'

select * from 
(select title, unnest(special_features) from film) as features
where features.unnest = 'Behind the Scenes'

select title, special_features, array_position(special_features, 'Behind the Scenes')
from film 
where array_position(special_features, 'Behind the Scenes') is not null





