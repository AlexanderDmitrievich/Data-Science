select st.first_name || ' ' || st.last_name "ÔÈÎ",c.city "Ãîðîä", count(customer_id) "Ñóììà"
from store s
inner join customer cu on s.store_id=cu.store_id
inner join staff st on s.store_id=st.store_id
inner join address a on s.address_id=a.address_id
inner join city c on a.city_id=c.city_id 
group by c.city,"ÔÈÎ"
having count(customer_id)>300

 select count(a.actor_id)
from actor a
inner join film_actor fa on a.actor_id=fa.actor_id 
inner join film f on fa.film_id=f.film_id
where f.rental_rate = 2.99