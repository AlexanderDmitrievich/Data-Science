select store_id, count(customer_id) from customer 
group by store_id having count(customer_id)>300;

select c.first_name || ' ' || c.last_name "Имя Фамилия", city from customer c 
inner join address a on a.address_id=c.address_id 
inner join city ci on ci.city_id=a.city_id
order by "Имя Фамилия";