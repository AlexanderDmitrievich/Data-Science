create table alexander_language_nationality
(language_id integer unique not null,
nationality_id integer unique not null,
primary key (language_id,nationality_id),
foreign key (language_id) references alexander_language(language_id),
foreign key (nationality_id) references alexander_nationality(nationality_id))

alter table alexander_language_nationality 
add foreign key (language_id) references alexander_language(language_id)

alter table alexander_language add column greeting text 

update alexander_language set greeting = 'Privet'
where language_id=1

update alexander_language set greeting = 'Hello'
where language_id=2

update alexander_language set greeting = 'Hallo'
where language_id=3

update alexander_language set greeting = 'Privit'
where language_id=4

update alexander_language set greeting = 'Bonjour'
where language_id=5

alter table alexander_country add column cccp boolean 

update alexander_country set cccp = true
where country_id=1

update alexander_country set cccp = false
where country_id=2

update alexander_country set cccp = false
where country_id=3

update alexander_country set cccp = true
where country_id=4

update alexander_country set cccp = false
where country_id=5

alter table alexander_nationality add column time_zone timestamp

update alexander_nationality set time_zone = '2021/03/21 03:00:00'
where nationality_id=1

update alexander_nationality set time_zone = '2021/03/21 00:00:00'
where nationality_id=2

update alexander_nationality set time_zone = '2021/03/21 01:00:00'
where nationality_id=3

update alexander_nationality set time_zone = '2021/03/21 02:00:00'
where nationality_id=4

update alexander_nationality set time_zone = '2021/03/21 00:00:00'
where nationality_id=5