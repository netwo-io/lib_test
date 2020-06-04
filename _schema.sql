drop schema if exists test cascade;
create schema test;
grant usage on schema test to public;
set search_path = pg_catalog;

\ir ./pgunit.sql
