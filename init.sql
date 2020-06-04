-- some setting to make the output less verbose
\set QUIET on
\set ON_ERROR_STOP on
set client_min_messages to warning;

begin;

\echo # Loading helper libs

\ir _schema.sql

select * from test.run_all();

commit;

\echo # ==========================================
