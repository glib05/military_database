--1)
--a. запит з використанням функції COUNT
	-- вивести кількість техніки кожної військової частини
select name, (select count(*) from military_tech
			 where base_id = military_base.id) as quantity_mtech
from military_base;

--b. запит з використанням функції SUM
	--підрахувати загальну площу усіх військових округів
select sum(area) area from military_district;

--c. запит з використанням групування по декільком стовпцям
	-- порахувати скільки є транспортної техніки кожного типу
select type, count(*) quantity from transport_tech
group by type;

--d. запит з використанням умови відбору груп HAVING
	-- визначити типи військової техніки, у яких в середньому
	--вартість сервісного обслуговуання не перевищує 15000
select military_tech.type, count(*) quantity, avg(service_cost) average_service_cost from military_tech
group by type
having avg(service_cost) < 15000;

--e. запит з використанням HAVING без GROUP BY
	-- визначити середнб вартість військової техніки якщо сердня
	-- вартість сервісного обслуговування більша за 5000
select avg(cost) from military_tech
having avg(service_cost) > 5000;


--f. запит з використанням функцій row_number() over …
	-- пронумерувати військові частини за датою створення
select row_number() over(order by date_of_creation asc) as row,
	id, name, date_of_creation 
from military_base;

--g. запит з використанням сортування по декільком стовпцям
	-- відсортувати сержантів за званням, 
	--якщо звання однакове, то відсортувати за іменем
select rank, name from sergeants
order by rank, name;

--h. запити згідно варіанту завдання
	--а) Яка частина має найбільшу кількість офіцерського складу та найменшу кількість озброєння
select b_id, base_name, quantity_of_officer, quantity_of_weaponry 
from
	(select military_district.id, count(officer.id) quantity_of_officer 
	from military_district
	left join officer on officer.district_id = military_district.id
	group by military_district.id) t1
join 
	(select military_base.id b_id, military_base.name base_name, district_id, count(weaponry.id) quantity_of_weaponry  
	from military_base
	left join weaponry on weaponry.base_id = military_base.id
	group by military_base.id) t2
on t2.district_id = t1.id
order by quantity_of_officer desc, quantity_of_weaponry asc
limit 1;

	--b)Визначить яким типом підрозділу найчастіше командують офіцери зі званням підполковника.
select type, count(*) quantity_of_Lieutenant_colonel from
		(select rank, 'army' type from commander
		join army on army.commander_id = commander.id
		union all
		select rank, 'branch' type from commander
		join branch on branch.commander_id = commander.id
		union all
		select rank, 'brigade' type from commander
		join brigade on brigade.commander_id = commander.id
		union all
		select rank, 'corps' type from commander
		join corps on corps.commander_id = commander.id
		union all
		select rank, 'division' type from commander
		join division on division.commander_id = commander.id
		union all
		select rank, 'military_base' type from commander
		join military_base on military_base.commander_id = commander.id
		union all
		select rank, 'platoon' type from commander
		join platoon on platoon.commander_id = commander.id
		union all
		select rank, 'squadron' type from commander
		join squadron on squadron.commander_id = commander.id)
where rank = 'Lieutenant colonel'
group by type
order by quantity_of_Lieutenant_colonel desc
limit 1;




-- 2)
-- a. створити представлення, котре містить дані з декількох таблиць;
	-- створити представлення, що містить кількість офіцерів у кожному військовому окрузі
create or replace view dist_ofi_q as
	select military_district.id, military_district.name, count(officer.id) q_of_officer 
	from military_district
	left join officer on officer.district_id = military_district.id
	group by military_district.id;
	
select * from dist_ofi_q;

drop view if exists dist_ofi_qua;

-- b. створити представлення, котре містить дані з декількох таблиць та
-- використовує представлення, котре створене в п.a;
	-- створити представлення, у якому відображатимуться
	-- кількість офіцерів та кількість військових частин у кожному окрузі
create or replace view dis_more_b_ofi as
	select dist_ofi_q.id, dist_ofi_q.name, q_of_officer, count(military_base.id) q_of_bases 
	from dist_ofi_q
	left join military_base on military_base.district_id = dist_ofi_q.id
	group by dist_ofi_q.id, dist_ofi_q.name, q_of_officer;
	
select * from dis_more_b_ofi;

drop view if exists dis_more_b_ofi;

-- c. модифікувати представлення з використанням команди ALTER VIEW;
	-- перейменувати поле id на district_id
alter view dis_more_b_ofi rename column id to district_id;
	
-- d. отримати довідникову інформацію про ці представлення з
-- використанням вбудованих процедур (наприклад в MsSQL sp_help, sp_helptext).
select * from information_schema.views where table_schema = 'public';
select * from information_schema.views where table_name = 'dis_more_b_ofi';
select * from pg_views where schemaname = 'public';
select * from pg_views where viewname = 'dist_ofi_q';
