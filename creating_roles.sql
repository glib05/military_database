create role public_user login password '0000';

revoke select on all tables in schema public from public_user;
grant select on table military_district to public_user;
revoke create on schema public from public_user;
alter default privileges for role public_user revoke insert, update, delete on tables from public_user;

create role officer login password '0000';

grant select on all tables in schema public to officer;
revoke create on schema public from officer;
alter default privileges for role officer revoke insert, update, delete on tables from officer;