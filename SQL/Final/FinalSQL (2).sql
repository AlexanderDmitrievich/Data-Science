--1--

select city
from airports a 
group by city 
having count(airport_name) > 1

-- ������� ������ �� ������� "���������", ��� ���������� "�������� ����������" (������, � ��������, ���������� ����������) > 1

--2--

select departure_airport
from flights 
where aircraft_code = (select aircraft_code from aircrafts a 
order by range desc limit 1)
group by departure_airport

-- � ���������� �������� ��� ��������, ������� ����� ������������ ��������� ������ (����� ���������� �������� 1 ����� �� ���������)
-- � �������� ������� �������� �������� ������ (��� ��� ���� ��������� ����������� � ��������� �����������, � �� ��������.)
-- � ��������, � ������ ������, ������ ������ ���������������� � �� ��������� ������ � �������, ��� ��� ����� �������� ����-�������,
-- ������� ��� �������� � ������� ��������� ������ �� �������� ������� ��������� �� ��������
-- ����� ����� ���� ��� �� ������� ��������� ������ �� ����� ��������� ��������� ������ �� ���������,
-- ��� ��� �������� ����� ����, ������� �������� ������ ����� �� ��������� ������
-- ���������� �� ��������� �����������, ����� ������������ ������ ���������� �������� � ������������ ����� � �� � ���� ���������

--3--

select flight_no
from flights f 
order by (scheduled_departure - actual_departure) limit 10

-- �������� ������ ������ �� ������� �������
-- ����� ������� ������� ����� ��������������� �������� ������ � �����������
-- ��������� �� �� ����������� (������, ����������, �� ��������)  � ��������� ��� 10 � ����� ������� �������� ��������

--4--

select b.book_ref
from bookings b
left join tickets t using (book_ref)
left join ticket_flights tf using (ticket_no)
left join boarding_passes bp using (ticket_no, flight_id)
where bp.boarding_no is null

-- ������� bookings � boarding_passes ���� �������, ����� ���������� ���������� � ����� �������
-- �������� ������ �� ������ ������������, ��� ����������� �������� �����������, ������ bp.boarding_no is null
-- � ������, ����������� ������ �� ������������, �� ������� �� ���� �������� ����������

--5--

select f.flight_no, (t1.coseat - t2.cono) as vacant,
round((t1.coseat - t2.cono) / t1.coseat * 100 , 2)percentage,
sum(t2.cono) over (partition by departure_airport, date(f.actual_departure) order by f.actual_departure)
from flights f 
join (select aircraft_code, count(seat_no) as coseat from seats
group by aircraft_code) as t1 using (aircraft_code)
join (select flight_id, count(bp.boarding_no)::numeric as cono from boarding_passes bp 
group by flight_id) as t2 using (flight_id)
where f.actual_departure is not null

-- ����� ���� ������ ������ ���. ������� ������ ������ � �����������
-- � ������ ���������� ������� ����� ���������� ���� � ��������
-- �� ������ ������� ������� ���������� ���������� �� �����
-- ���������� ���������� ��������
-- � ������� ������� ���������� ����������� �������
-- ��������� ������� ������ ������ ����� ������� �������, ��� �� �������� ����� ���������� � ���������� ���������, ��������������� �� �������
-- � ����� ��������� �����, ������� ��� �� �������� 

--6--

select f.aircraft_code,
round((count(f.aircraft_code)::numeric) / (select count (flight_id) from flights f) * 100,2)percentage
from flights f
group by f.aircraft_code

-- ������� ����� �������: ������� ����� ���������� ��������� �� ����� � ����� �� �� ����� ���������� �������
-- �������� ��� �������� � ���������� �� ���� �� ����� � ��� ����� ������������ ���������� �� ����� ���������, � �� ���� ����� �����

--7--

with cte1 as 
(select flight_id, min(amount)
from ticket_flights 
where fare_conditions = 'Business'
group by flight_id),
cte2 as 
(select flight_id, max(amount)
from ticket_flights 
where fare_conditions = 'Economy'
group by flight_id)
select city, cte1.min, cte2.max
from cte1 inner join cte2 using (flight_id)
inner join flights f using (flight_id)
inner join airports a on f.arrival_airport = a.airport_code 
where cte1.min < cte2.max

-- ������� ������� 2 ���
-- � ������ ��� �������� ����������� ����� ������ ������
-- �� ������ ��� �������� - ������������ ����� ������ - ������
-- ����� ��������� ��� ������� ������� � 2 ��������� � ����������� � ������������ ������
-- �������� �� ��������, ��� ����������� ����� ������� ������ ������������ �������
-- ������� ������� ����������, ����� ������� ������, ��� ���� �������� �����

--8--

create materialized view v1 as(
select t1.city as c1, t2.city as c2 from
(select city from airports a ) as t1,
(select city from airports a ) as t2
where t1.city != t2.city)

select c1, c2 from v1
except
select a1.city, a2.city from
flights f
join airports a1 on a1.airport_code = f.departure_airport
join airports a2 on a2.airport_code = f.arrival_airport

-- ������� ��� �������������, ��� � ������� ��������� ������������ �� ������� ��� ��������� ������ ����������� � ��������
-- ��������� �� ��� ������������� ������
-- ����� �������� ��� ������ �� ��� ������������� � ��������� �� ��� ��, ����� �������� ���� ������ �����
-- ��� ����� � ��� �������� �������� ������� ����� �������� ��� ������ ������

--9--

select t.flight_no, t.range, t.frange, (t.range - t.frange) compare from
(select f.flight_no, a.range,
((acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) + cos(radians(a1.latitude))*cos(radians(a2.latitude))
*cos(radians(a1.longitude - a2.longitude))))*6371) as frange 
from flights f
join aircrafts a using (aircraft_code)
join airports a1 on a1.airport_code = f.departure_airport 
join airports a2 on a2.airport_code = f.arrival_airport
group by f.flight_no, a.range, a1.latitude, a2.latitude, a1.longitude, a2.longitude) t

-- ������� �� �������, ������ � ������� ���������� ����� �������� � ������� radians
-- �������� � ������� ����������� �� ������� ����������, 2 ���� ���������� �� ������� �� ����� ��������� �����������, � ����� ��������
-- ����� ������� ������� ��������� � ������� �� ��� ������������ ��������� ������ ��������
-- ��� ��������� ���������� ������� ����� ������������ ���������� � ����������� ����� ��������
-- ���������� ������ ����� �� ������� �����







