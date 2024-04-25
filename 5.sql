--1) Збережені процедури:
--a. запит для створення тимчасової таблиці через змінну типу TABLE;
create or replace procedure table_proc (in my_table regclass) as $$
begin
-- 	create or replace view proc_view as
-- 	select * from my_table;
	execute 'create or replace view proc_view as select * from ' || my_table;
end;
$$ language plpgsql;

call table_proc('division');

drop procedure if exists table_proc;

--b. запит з використанням умовної конструкції IF
	--процедура, що при передачі їй аргументом 666 видаляє останній запис в таблиці military_base
create or replace procedure devil_proc (devil_num int) as $$
begin
	if devil_num = 666 then
		delete from military_base 
		where id = (select max(id) from military_base);
	end if;
	
end;
$$ language plpgsql;

select * from military_base;

insert into military_base(name, address, capacity, date_of_creation, brigade_id, commander_id,district_id)
values
('for_delete', null, null, null, null, null, null);

call devil_proc(666);

drop  procedure if exists devil_proc;

--c. запит з використанням циклу WHILE;
create or replace procedure while_loop () as $$
declare 
	counter int = 0;
begin
	while counter < 5
	loop
		raise notice '%', counter;
		counter=counter+1;
	end loop;
end;
$$ language plpgsql;

call while_loop();
	
--d. створення процедури без параметрів; 
	--процедура, яка створює запис у military_base, де усі значення заповненні null
create or replace procedure insertion_into_mbase () as $$
begin
	insert into military_base(name, address, capacity, date_of_creation, brigade_id, commander_id,district_id)
	values
	(null, null, null, null, null, null, null);
end;
$$ language plpgsql;

call insertion_into_mbase();
select * from military_base;

-- e. створення процедури з вхідним параметром;
	-- процедура для видалення рядового з певним ім'ям
create or replace procedure delete_rank_and_file(v_name varchar(50)) as $$
	delete from rank_and_file_specialty
	where rank_and_file_id = (select id from rank_and_file raf
							  where raf.name = v_name
							  limit 1);

	delete from rank_and_file raf
	where raf.name = v_name;
$$ language sql;

select * from rank_and_file;

call delete_rank_and_file('Emily Johnson');

--f. створення процедури з вхідним параметром та RETURN;
	-- процедура, що обчислює кількість офіцерів
create or replace procedure officer_q(out result int)
language plpgsql
as $$
begin
    select count(*) into result from officer;
end;
$$;

do $$
declare
	result int;
begin
	call officer_q(result);
	raise notice 'кількість офіцерів: %', result;
end$$;

--g. створення процедури оновлення даних в деякій таблиці БД;
	-- збільшити вартість обслуговування усієї військової техніки на певний коефіцієнт
create or replace procedure update_service_cost(n float) as $$
begin
	update military_tech
	set service_cost = service_cost*n;
end;
$$ language plpgsql;

select * from military_tech;

call update_service_cost(1.1);

--h. створення процедури, в котрій робиться вибірка даних.
	-- створити процедуру, що видаляє дублікати з таблиці rank_and_file_specialty
create or replace procedure clean_rank_and_file_specialty() as $$
	delete from rank_and_file_specialty rfs
	using (select specialty_id, rank_and_file_id, min(id) id from rank_and_file_specialty
		  group by specialty_id, rank_and_file_id
		  having count(*) > 1) keep_rows
	where rfs.specialty_id in (keep_rows.specialty_id)
		and rfs.rank_and_file_id in (keep_rows.rank_and_file_id)
		and rfs.id not in (keep_rows.id);
$$ language sql;

call clean_rank_and_file_specialty();

select * from rank_and_file_specialty;

insert into rank_and_file_specialty (rank_and_file_id, specialty_id)
values
(1,5), (1,7), (1,15), (2,5), (3,5),
(2,10), (10,1), (3,11), (9,10), (11,13),
(11,15), (4,3), (5,4), (6,5), (7,6),
(8,7), (9,8), (10,9), (11,10), (12,11),
(13,12), (14,13), (15,14), (2,15), (1,1),
(3,2), (4,3), (5,4), (6,5), (7,6);





--2) Функції:
--a. створити функцію, котра повертає деяке скалярне значення;
	--функція, що повертає n-e число Фібоначі
create or replace function fib(n int) returns int as $$
declare
	i int = 0;
	j int = 1;
begin
	if n <= 0 then
		return 0;
	end if;
	
	for counter in 1..n-1
	loop
		select j, i+j into i,j;
	end loop;
	
	return i;
end;
$$ language plpgsql immutable;

select fib(1), fib(2), fib(3), fib(4), fib(5), fib(6), fib(7), fib(8);

	--Функція, що повертає середній вік командирів заданого підрозділу
create or replace function avg_age(my_table regclass) returns int as $$
declare
	result int;
begin
	execute
	'select avg(age) 
	from  '||my_table||'  t
	join commander on t.commander_id = commander.id'
	into result;
	
	return result;
end;
$$ language plpgsql;

select avg_age('platoon');

--b. створити функцію, котра повертає таблицю з динамічним набором стовпців;
	-- повернути усереднену вартість та/або вартість обслуговування військової техніки для кожної військової частини
create or replace function avg_military_tech_for_mbase
(out military_base_id int, out avg_cost float, out avg_service_cost float)
returns setof record as $$

	select mb.id, avg(cost), avg(service_cost) from military_base mb
	left join military_tech on mb.id = base_id
	group by mb.id

$$ language sql;

select military_base_id, avg_cost from avg_military_tech_for_mbase();
select military_base_id, avg_service_cost from avg_military_tech_for_mbase();
select * from avg_military_tech_for_mbase();

--c. створити функцію, котра повертає таблицю заданої структури.
	-- Функція, що повертає зброю, що належить певній військовій частині
create or replace function weapon_of_mbase(mbase_id int) 
returns table (
		id int,
		name varchar(50),
		type varchar(50),
		purpose varchar(50),
		weight int
) as $$
	
	select w.id, w.name, w.type, w.purpose, w.weight from weaponry w
	where base_id = mbase_id;
	
$$ language sql;

select * from weapon_of_mbase(2);





-- 3) Робота з курсорами:
do $$
declare
	rec record;
	--a. створити курсор;
	cur1 refcursor;
	cur2 cursor(type varchar(50)) for select * from weaponry w where w.type = cur2.type;
begin
	--b. відкрити курсор;
	open cur1 for select * from specialty;
	open cur2('Pistol');
	
	--c. вибірка даних, робота з курсорами
	fetch cur1 into rec;
	raise notice 'cur1: %', rec;
	move cur1;
	fetch cur1 into rec;
	raise notice 'cur1: %', rec;
	
	raise notice '';
	
	loop
		fetch cur2 into rec;
		exit when not found;
		raise notice 'cur2: %', rec;
	end loop;
	
	close cur1;
	close cur2;
end$$;




--4) Робота з тригерами:

create or replace function describe_trigger() returns trigger as $$
declare
	rec record;
	str text = '';
begin
	if tg_level = 'ROW' then 
		case tg_op
			when 'DELETE' then 
				rec = old;
				str = old::text;
			when 'UPDATE' then 
				rec = new;
				str = old||'->'||new;
			when 'INSERT' then
				rec = new;
				str = new::text;
		end case;
	end if;
	raise notice '% % % % %', tg_table_name, tg_when, tg_op, tg_level, str;
	return rec;
end;
$$ language plpgsql;

--a. створити тригер, котрий буде спрацьовувати при видаленні даних;
	--тригер, що забороняє видаляти дані з таблиці officer
create or replace function stop_delete_func() returns trigger as $$
begin
	raise notice 'deletion from the officer is impossible)';
	return null;
end;
$$ language plpgsql;
	
create trigger stop_delete
before delete on officer
for each row
execute procedure stop_delete_func();

delete from officer
where age > 50;

select * from officer;

--b. створити тригер, котрий буде спрацьовувати при модифікації даних;
create trigger before_update
before update on officer
for each row
execute procedure describe_trigger();

update officer
set name = 'hbjhbjkbhh'
where id = 1;

select * from officer

--c. створити тригер, котрий буде спрацьовувати при додаванні даних.
create trigger before_insert
before insert on military_base
for each row
execute procedure describe_trigger();

call insertion_into_mbase();

select * from military_base;
