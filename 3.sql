--1)
--a.
-- виводить назви та площу військових округів, у яких площа більше ніж 30000
select name, area from military_district
where area>30000;

-- виводить записи таблиці specialty, у яких дисципліна CBRN Defense
select * from specialty
where discipline = 'CBRN Defense';

--b.
-- вивести на екран усі військові частини, де адреса не дорівнює 1010 Galaxy Street, Galaxytown,
--місткість більше 4000 та створені раніше ніж 2019-01-01
select * from military_base
where (address != '1010 Galaxy Street, Galaxytown') 
and (capacity>4000 or date_of_creation<'2019-01-01');

-- вивести командирів, у яких ім'я не починається з літери P та всередині імені нема літери а
select * from commander
where not (name like 'P%' or name like '%a%');

--c.
-- вивести на екран рік народження кожного командира
select (extract(year from current_date) - age) as year_of_birth  
from commander

--d.
--i.
--вивести командирів зі званням капітана або полковника
select  name, rank, age from commander
where rank in ('Captain', 'Lieutenant');

--ii.
--вивести усі відділення , які входять у склад 7-10 взводів
select name, platoon_id from branch
where platoon_id between 7 and 10;

--iii.
-- вивести командирів, у яких в імені є літера s
select * from commander
where name like('%s%');

--iv.
--вивести усю наявну зброю, у якої зазначена її вага
select name from weaponry
where weight is not null;

--2)
--a.
--вивести офіцерів, які отримали своє звання раніже, ніж усі сержанти
select * from officer 
where date_of_awarding_the_rank < (select min(date_of_awarding_the_rank) from sergeants);

-- вивести кількість техніки кожної військової частини
select name, (select count(*) from military_tech
			 where base_id = military_base.id) as quantity_mtech
from military_base;

--b.
--вивести на екран назви армій, у яких командир молодше 30 років
select army.name army_name from army
where army.commander_id in (select id from commander
						   where age < 30)

-- вивести на екран, усі спеціальності, якими не володіє жоден рядовий
select s.name from specialty s
where not exists(select * from rank_and_file_specialty rs
				where rs.specialty_id = s.id);

--с.
-- вивести декартовий добуток взводів та рот
select * from platoon
cross join squadron;

--d.
-- вивести кожного офіцера та його спеціальність
select s.name sname, o.name oname from officer o
full join officer_specialty os on os.officer_id = o.id
full join specialty s on s.id = os.specialty_id;

--e.
-- вивести назви усіх дивізионів, що входять до складу армій, назва яких починається на А.
select d.name division from division d
left join army on army.id = d.army_id
where army.name like 'A%';

--f.
--вивести на екран у якій базі перебуває кожна одиниця техніки
select tt.name transport_tech, mb.id base_id, mb.name military_base from transport_tech tt
inner join military_base mb on tt.base_id = mb.id;

--g.
--вивести на екран імена офіцерів, що мають спеціальність у галузі медицини
select o.name from officer o
left join officer_specialty os on o.id = os.officer_id
left join specialty s on s.id = os.specialty_id
where s.discipline = 'Medical';

--h.
-- вивести на екран id та назви спеціальностей, які має рядовий під номером 1.
select s.id, s.name from specialty s
right join rank_and_file_specialty rs on s.id = rs.specialty_id
right join rank_and_file r on rs.rank_and_file_id = r.id
where r.id = 1;

--i.
--вивести на екран усі назви
--армій, дивізій, корпусів, бригад, військових частин,
--рот, взводів та відділень, у яких командир старше 55 років
select 'army' as type, army.name name from army
where army.commander_id in (select id from commander
						   where age > 55)
union
select 'division' as type, division.name from division
where division.commander_id in (select id from commander
								where age > 55)
union								
select 'corps' as type, corps.name from corps
where corps.commander_id in (select id from commander
							 where age > 55)		
union								
select 'brigade' as type, brigade.name from brigade
where brigade.commander_id in (select id from commander
							   where age > 55)		
union								
select 'military_base' as type, military_base.name from military_base
where military_base.commander_id in (select id from commander
									 where age > 55)		
union								
select 'squadron' as type, squadron.name from squadron
where squadron.commander_id in (select id from commander
								where age > 55)	
union								
select 'platoon' as type, platoon.name from platoon
where platoon.commander_id in (select id from commander
							   where age > 55)	
union								
select 'branch' as type, branch.name from branch
where branch.commander_id in (select id from commander
							  where age > 55)
order by type;

--4)
--a. Визначить всі частини певного військового округу, котрі мають в
--наявному озброєнні БМП
--(нехай це будуть частини вiйськовго округу №1)
select mb.id id, mb.name name from military_base mb
where mb.id in (select mt.base_id from military_tech mt
			   where mt.name like 'BMP%')
	and district_id = 1;
	
--b. Визначить військові підрозділи, котрими командують офіцери
-- щонайменше зі званням підполковника.

select 'army' as type, army.name name from army
where army.commander_id in (select c.id from commander c
							where (c.rank = 'Colonel') 
								or (c.rank = 'Major General') 
								or (c.rank = 'Lieutenant General') 
								or (c.rank = 'General'))
union
select 'division' as type, division.name from division
where division.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
union								
select 'corps' as type, corps.name from corps	
where corps.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
union								
select 'brigade' as type, brigade.name from brigade	
where brigade.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
union								
select 'military_base' as type, military_base.name from military_base		
where military_base.commander_id in (select commander.id from commander
									where (commander.rank = 'Colonel') 
										or (commander.rank = 'Major General') 
										or (commander.rank = 'Lieutenant General') 
										or (commander.rank = 'General'))
union								
select 'squadron' as type, squadron.name from squadron
where squadron.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
union								
select 'platoon' as type, platoon.name from platoon
where platoon.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
union								
select 'branch' as type, branch.name from branch
where branch.commander_id in (select commander.id from commander
								where (commander.rank = 'Colonel') 
									or (commander.rank = 'Major General') 
									or (commander.rank = 'Lieutenant General') 
									or (commander.rank = 'General'))
order by type;
