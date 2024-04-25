create table commander(
	id serial primary key,
	name varchar(40) not null,
	rank varchar(20) not null,
	age int
);

create table specialty (
  id serial primary key,
  name varchar(50) not null,
  discipline varchar(20),
  description text
);

create table military_district(
	id serial primary key,
	location text not null,
	area int not null
);

create table officer(
	id serial primary key,
	name varchar(50) not null,
	rank varchar(20),
	age int,
	date_of_awarding_the_rank date,
	district_id int,
	foreign key (district_id) references military_district(id)
);

create table sergeants(
	id serial primary key,
	name varchar(50) not null,
	rank varchar(20),
	age int,
	date_of_awarding_the_rank date,
	district_id int,
	foreign key (district_id) references military_district(id)
);

create table army(
	id serial primary key,
	name varchar(50),
	commander_id int,
	foreign key (commander_id) references commander(id)
);

create table division(
	id serial primary key,
	name varchar(50),
	army_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (army_id) references army(id)
);

create table corps(
	id serial primary key,
	name varchar(50),
	division_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (division_id) references division(id)
);

create table brigade(
	id serial primary key,
	name varchar(50),
	corps_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (corps_id) references corps(id)
);

create table military_base(
	id serial primary key,
	name varchar(50),
	address text,
	capacity int,
	date_of_creation date,
	brigade_id int,
	commander_id int,
	district_id int,
	foreign key (commander_id) references commander(id),
	foreign key (brigade_id) references brigade(id),
	foreign key (district_id) references military_district(id)
);

create table squadron(
	id serial primary key,
	name varchar(50),
	base_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (base_id) references military_base(id)
);

create table platoon(
	id serial primary key,
	name varchar(50),
	squadron_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (squadron_id) references squadron(id)
);

create table branch(
	id serial primary key,
	name varchar(50),
	platoon_id int,
	commander_id int,
	foreign key (commander_id) references commander(id),
	foreign key (platoon_id) references platoon(id)
);

create table weaponry(
	id serial primary key,
	name varchar(50) not null,
	type varchar(50),
	purpose varchar(50),
	weight int,
	base_id int,
	foreign key (base_id) references military_base(id)
);

create table military_tech(
	id serial primary key,
	name varchar(50) not null,
	type varchar(50),
	purpose varchar(50),
	base_id int,
	foreign key (base_id) references military_base(id)
);

create table transport_tech(
	id serial primary key,
	name varchar(50) not null,
	type varchar(50),
	capacity int,
	base_id int,
	foreign key (base_id) references military_base(id)
);

create table rank_and_file(
	id serial primary key,
	name varchar(50) not null,
	age int,
	branch_id int,
	foreign key (branch_id) references branch(id)
);

create table officer_specialty(
	id serial primary key,
	officer_id int,
	specialty_id int,
	foreign key (officer_id) references officer(id),
	foreign key (specialty_id) references specialty(id)
);

create table sergeants_specialty(
	id serial primary key,
	sergeants_id int,
	specialty_id int,
	foreign key (sergeants_id) references sergeants(id),
	foreign key (specialty_id) references specialty(id)
);

create table rank_and_file_specialty(
	id serial primary key,
	rank_and_file_id int,
	specialty_id int,
	foreign key (rank_and_file_id) references rank_and_file(id),
	foreign key (specialty_id) references specialty(id)
);
