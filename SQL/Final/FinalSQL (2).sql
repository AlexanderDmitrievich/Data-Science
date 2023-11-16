--1--

select city
from airports a 
group by city 
having count(airport_name) > 1

-- Выбрать города из таблицы "аэропорты", где количество "Названий аэропортов" (Тоесть, в принципе, количество аэропортов) > 1

--2--

select departure_airport
from flights 
where aircraft_code = (select aircraft_code from aircrafts a 
order by range desc limit 1)
group by departure_airport

-- В подзапросе выделяем код самолета, который имеет максимальную дальность полета (через сортировку выделяем 1 место по дальности)
-- В основном запросе выбираем аэропорт вылета (так как рейс считается приписанным к аэропорту отправления, а не прибытия.)
-- В принципе, в данном случае, данный запрос распространяется и на аэропорты вылета и прилета, так как рейсы работают туда-обратно,
-- поэтому при перемене в запросе аэропорта вылета на аэропорт прилета результат не меняется
-- Затем после того как мы выбрали аэропорты вылета мы через подзапрос фильтруем только те аэропорты,
-- где код самолета равен тому, который занимает первое место по дальности полета
-- Группируем по аэропорту отправления, чтобы отображались только уникальные названия в единственном числе а не в виде множества

--3--

select flight_no
from flights f 
order by (scheduled_departure - actual_departure) limit 10

-- Выбираем номера рейсов из таблицы полетов
-- Затем считаем разницу между запланированным временем вылета и фактическим
-- Сортируем их по возрастанию (точнее, фактически, по убыванию)  и оставляем топ 10 с самым большим временем задержки

--4--

select b.book_ref
from bookings b
left join tickets t using (book_ref)
left join ticket_flights tf using (ticket_no)
left join boarding_passes bp using (ticket_no, flight_id)
where bp.boarding_no is null

-- Джойним bookings к boarding_passes таки образом, чтобы джойнилась информация с левой таблицы
-- Выбираем только те номера бронирований, где отсутствует значение посадочного, тоесть bp.boarding_no is null
-- а значит, отобразятся только те бронирования, по которым не были получены посадочные

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

-- Чтобы было удобно писать мат. формулы делаем джойны к подзапросам
-- В первом подзапросе считаем общее количество мест в самолете
-- Во втором запросе считаем количество пассажиров на рейсе
-- Обозначаем подзапросы алиасами
-- С помощью алиасов составляем необходимые формулы
-- Последнее условие задачи делаем через оконную функцию, где мы выбираем сумму посадочных в конкретном аэропорту, отсортированные по времени
-- В конце отсеиваем рейсы, которые еще не вылетели 

--6--

select f.aircraft_code,
round((count(f.aircraft_code)::numeric) / (select count (flight_id) from flights f) * 100,2)percentage
from flights f
group by f.aircraft_code

-- Сначала пишем формулу: считаем общее количество самолетов по типам и делим их на общее количество полетов
-- выбираем код самолета и группируем по нему же чтобы у нас верно отобразилась информация по типам самолетов, а не одна общая цифра

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

-- Сначала создаем 2 сте
-- В первом сте выбираем минимальную сумму бизнес класса
-- Во втором сте наоборот - максимальную сумму эконом - класса
-- Затем используя сте выводим таблицу с 2 столбцами с минимальной и максимальной суммой
-- Выбираем те варианты, где минимальная сумма бизнеса меньше максимальной эконома
-- джойним таблицу аэропортов, чтобы вывести города, где есть подобные рейсы

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

-- Создаем мат представление, где с помощью декартова произведения мы выводим все имеющиеся города отправлений и прибытия
-- Исключаем из них повторяющиеся города
-- Затем выбираем эти города из мат представления и исключаем из них те, между которыми есть прямые рейсы
-- Тем самым у нас остается подборка городов между которыми нет прямыъ рейсов

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

-- Считаем по формуле, данной в задании расстояния между городами с помощью radians
-- Значения в формулу подставляем из таблицы аэропортов, 2 раза приджойнив ее сначала по ключу аэропорта отправления, а затем прибытия
-- Затем джойним таблицу самолетов и выводим из нее максимыльную дальность полета самолета
-- Для сравнения используем разницу между максимальной дальностью и расстоянием между городами
-- Группируем данные чтобы не множить итоги







