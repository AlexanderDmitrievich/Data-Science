select table_name, constraint_name from information_schema.table_constraints 
where constraint_type = 'PRIMARY KEY' and table_schema = 'public'
order by table_name;

select tc.table_name, kcu.column_name, tc.constraint_name, c.data_type
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.constraint_name = tc.constraint_name 
	and tc.table_name = kcu.table_name 
	and tc.constraint_schema = kcu.constraint_schema
left join information_schema.columns c on c.column_name = kcu.column_name 
	and kcu.table_name = c.table_name 
	and kcu.constraint_schema = c.table_schema
where tc.constraint_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'