-- some setting to make the output less verbose
\set QUIET on
\set ON_ERROR_STOP on
\pset footer off
set client_min_messages to warning;

begin;
\ir _schema.sql
\ir _types.sql
\ir _functions.sql
\ir matchers.sql

\t on
\ir run_all_tests.sql
\t off
commit;
