explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

-- Узкое место - Nested loop. В составе Nested loop  узкое место Hash Right join
-- В Hash Right join узкое место - Subquery Scan on inv, в составе которого узкое место - ProjectSet
-- По сути самые узкие места - сканирование и объединение

explain analyze
select cu.first_name || ' ' || cu.last_name username,
count(f.special_features)
from film f
inner join inventory i on f.film_id=i.film_id
inner join rental r on i.inventory_id=r.inventory_id
inner join customer cu on r.customer_id=cu.customer_id
where f.special_features::text ilike '%Behind the Scenes%'
group by username

-- Точно так же узкое место - Nested loop, что является объединением,
-- но, по сравнению с предыдущим запросом, данный запрос более оптимизирован,
-- так как сокращены некоторое количество действий 

explain analyze
select cu.customer_id, count(f.film_id)
from customer cu
left join rental r on cu.customer_id=r.customer_id
left join inventory i on r.inventory_id=i.inventory_id
left join film f on i.film_id=f.film_id
where 'Behind the Scenes' = any(f.special_features)
group by cu.customer_id

--Справа - налево: 1 оепарция - Сканирование inventory и запоминание результата в Hash
-- Затем идут 3 подпроцесса в 2 процессах
-- После сканирования inventory происходит сканирование rental и соответственно Hash join inventory 
-- из уже отсканированных таблиц rental и inventory по inventory_id
-- Параллельно идет сканирование таблицы Фильм с фильтром special features через any, где отбрасывается 462 значения из 538 начальных
-- и запомниание результата сканирования в Hash
-- После вышеописанных операций с таблицами inventory & film происходит их джойн по film_id
-- Параллельно идет процесс сканирования table customer и запоминание в hash
-- и их последующее объединение с rental on customer_id
-- и как итог агрегация вышеописанных результатов с выполнением запроса на количество фильмов
-- но ключом в данном случае является не film_id, так как мы его не запрашиваем, а customer_id