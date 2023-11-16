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

-- ����� ����� - Nested loop. � ������� Nested loop  ����� ����� Hash Right join
-- � Hash Right join ����� ����� - Subquery Scan on inv, � ������� �������� ����� ����� - ProjectSet
-- �� ���� ����� ����� ����� - ������������ � �����������

explain analyze
select cu.first_name || ' ' || cu.last_name username,
count(f.special_features)
from film f
inner join inventory i on f.film_id=i.film_id
inner join rental r on i.inventory_id=r.inventory_id
inner join customer cu on r.customer_id=cu.customer_id
where f.special_features::text ilike '%Behind the Scenes%'
group by username

-- ����� ��� �� ����� ����� - Nested loop, ��� �������� ������������,
-- ��, �� ��������� � ���������� ��������, ������ ������ ����� �������������,
-- ��� ��� ��������� ��������� ���������� �������� 

explain analyze
select cu.customer_id, count(f.film_id)
from customer cu
left join rental r on cu.customer_id=r.customer_id
left join inventory i on r.inventory_id=i.inventory_id
left join film f on i.film_id=f.film_id
where 'Behind the Scenes' = any(f.special_features)
group by cu.customer_id

--������ - ������: 1 �������� - ������������ inventory � ����������� ���������� � Hash
-- ����� ���� 3 ����������� � 2 ���������
-- ����� ������������ inventory ���������� ������������ rental � �������������� Hash join inventory 
-- �� ��� ��������������� ������ rental � inventory �� inventory_id
-- ����������� ���� ������������ ������� ����� � �������� special features ����� any, ��� ������������� 462 �������� �� 538 ���������
-- � ����������� ���������� ������������ � Hash
-- ����� ������������� �������� � ��������� inventory & film ���������� �� ����� �� film_id
-- ����������� ���� ������� ������������ table customer � ����������� � hash
-- � �� ����������� ����������� � rental on customer_id
-- � ��� ���� ��������� ������������� ����������� � ����������� ������� �� ���������� �������
-- �� ������ � ������ ������ �������� �� film_id, ��� ��� �� ��� �� �����������, � customer_id