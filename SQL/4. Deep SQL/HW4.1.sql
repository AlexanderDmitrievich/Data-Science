create table alexander_country
(country_id serial primary key,
country_name varchar (50) unique not null)

insert into alexander_country(country_name) 
values 
('Russia'),
('England'),
('Germany'),
('Ukraine'),
('France')

create table alexander_nationality 
(nationality_id serial primary key,
nationality_name varchar (50) unique not null)

insert into alexander_nationality(nationality_name)
values
('Russian'),
('English'),
('German'),
('Ukrainan'),
('French')

create table alexander_language
(language_id serial primary key,
language_name varchar (50) unique not null)

insert into alexander_language(language_name)
values
('Russkiy'),
('Angliskiy'),
('Germanskiy'),
('Ukrainskiy'),
('Francuskiy')

create table alexander_country_nationality
(country_id integer unique not null,
nationality_id integer unique not null,
primary key (country_id,nationality_id),
foreign key (country_id) references alexander_country(country_id),
foreign key (nationality_id) references alexander_nationality(nationality_id))

insert into alexander_country_nationality(country_id,nationality_id)
values 
(1,1),
(2,2),
(3,3),
(4,4),
(5,5)

create table alexander_language_nationality
(language_id integer unique not null,
nationality_id integer unique not null,
primary key (language_id,nationality_id),
foreign key (language_id) references alexander_language(language_id),
foreign key (nationality_id) references alexander_nationality(nationality_id))

insert into alexander_language_nationality(language_id,nationality_id)
values 
(1,1),
(2,2),
(3,3),
(4,4),
(5,5)