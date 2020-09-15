-- Largely inspired from pgunit

--
-- use select * from run_all() to execute all test cases
--
create or replace function lib_test.run_all() returns setof lib_test.results as
$$
begin
    return query select * from lib_test.run_suite(null);
end;
$$ language plpgsql set search_path from current;

--
-- executes all test cases part of a suite and returns the test results.
--
-- each test case will have a setup procedure run first, then a precondition,
-- then the test itself, followed by a postcondition and a tear down.
--
-- the test case stored procedure name has to match 'test_case_<p_suite>%' patern.
-- it is assumed the setup and precondition procedures are in the same schema as
-- the test stored procedure.
--
-- select * from lib_test.run_suite('my_test'); will run all tests that will have
-- 'test_case_my_test' prefix.
create or replace function lib_test.run_suite(p_suite text) returns setof lib_test.results as
$$
declare
    l_proc              record;
    l_sid               integer;
    l_row               lib_test.results%rowtype;
    l_start_ts          timestamp;
    l_cmd               text;
    l_condition         text;
    l_precondition_cmd  text;
    l_postcondition_cmd text;
begin
    l_sid := pg_backend_pid();
    for l_proc in select p.proname, n.nspname
                  from pg_catalog.pg_proc p
                           join pg_catalog.pg_namespace n
                                on p.pronamespace = n.oid
                  where p.proname like 'test/_case/_' || coalesce(p_suite, '') || '%' escape '/'
			order by p.proname loop
    -- check for setup
    l_condition := lib_test.get_procname(l_proc.proname, 2, 'test_setup');
    if l_condition is not null then
        l_cmd := 'do $body$ begin perform ' || quote_ident(l_proc.nspname) || '.' || quote_ident(l_condition)
            || '(); end; $body$';
      perform lib_test.autonomous(l_cmd);
    end if;
    l_row.name := quote_ident(l_proc.proname);
    -- check for precondition
    l_condition := lib_test.get_procname(l_proc.proname, 2, 'test_precondition');
    if l_condition is not null then
      l_precondition_cmd := 'perform lib_test.run_condition(''' || quote_ident(l_proc.nspname) || '.' || quote_ident(l_condition)
        || '''); ';
    else
      l_precondition_cmd := '';
    end if;
    -- check for postcondition
    l_condition := lib_test.get_procname(l_proc.proname, 2, 'test_postcondition');
    if l_condition is not null then
      l_postcondition_cmd := 'perform lib_test.run_condition(''' || quote_ident(l_proc.nspname) || '.' || quote_ident(l_condition)
        || '''); ';
    else
      l_postcondition_cmd := '';
    end if;
    -- execute the test
    l_start_ts := clock_timestamp();
    l_row.duration = clock_timestamp() - l_start_ts;
    begin
        l_cmd := 'do $body$ begin ' || l_precondition_cmd || 'perform ' || quote_ident(l_proc.nspname) || '.' ||
                 quote_ident(l_proc.proname)
                     || '(); ' || l_postcondition_cmd || ' end; $body$';
      perform lib_test.autonomous(l_cmd);
      l_row.failed := false;
      l_row.error_message := 'ok';
      return next l_row;
    exception
      when others then
          l_row.failed := true;
          l_row.error_message := sqlerrm;
          return next l_row;
    end;
    -- check for teardown
    l_condition := lib_test.get_procname(l_proc.proname, 2, 'test_teardown');
    if l_condition is not null then
        l_cmd := 'do $body$ begin perform ' || quote_ident(l_proc.nspname) || '.' || quote_ident(l_condition)
            || '(); end; $body$';
      perform lib_test.autonomous(l_cmd);
    end if;
  end loop;
end;
$$ language plpgsql set search_path from current;

--
-- recreates a _ separated string from parts array
--
create or replace function lib_test.build_procname(parts text[], p_from integer default 1, p_to integer default null) returns text as
$$
declare
    name text := '';
    idx  integer;
begin
    if p_to is null then
        p_to := array_length(parts, 1);
    end if;
    name := parts[p_from];
    for idx in (p_from + 1) .. p_to
        loop
            name := name || '_' || parts[idx];
        end loop;

  return name;
end;
$$ language plpgsql set search_path from current immutable;

--
-- returns the procedure name matching the pattern below
--   <result_prefix>_<test_case_name>
-- ex: result_prefix = test_setup and test_case_name = company_finance_invoice then it searches for:
--   test_setup_company_finance_invoice()
--   test_setup_company_finance()
--   test_setup_company()
--
-- it returns the name of the first stored procedure present in the database
--
create or replace function lib_test.get_procname(test_case_name text, expected_name_count integer, result_prefix text) returns text as
$$
declare
    array_name text[];
    array_proc text[];
    idx        integer;
    len        integer;
    proc_name  text;
    is_valid   integer;
begin
    array_name := string_to_array(test_case_name, '_');
    len := array_length(array_name, 1);
  for idx in expected_name_count + 1 .. len loop
    array_proc := array_proc || array_name[idx];
  end loop;

  len := array_length(array_proc, 1);
  for idx in reverse len .. 1 loop
    proc_name := result_prefix || '_'
      || lib_test.build_procname(array_proc, 1, idx);
    select 1 into is_valid from pg_catalog.pg_proc where proname = proc_name;
    if is_valid = 1 then
      return proc_name;
    end if;
  end loop;

  return null;
end;
$$ language plpgsql set search_path from current;

--
-- executes a condition boolean function
--
create or replace function lib_test.run_condition(proc_name text) returns void as
$$
declare
    status boolean;
begin
    execute 'select ' || proc_name || '()' into status;
    if status then
        return;
    end if;
    raise exception 'condition failure: %()', proc_name using errcode = 'triggered_action_exception';
end;
$$ language plpgsql set search_path from current;

--
-- use: select test_terminate('db name'); to terminate all locked processes
--
create or replace function lib_test.terminate(db varchar) returns setof record as
$$
select pg_terminate_backend(pid), query
from pg_stat_activity
where pid != pg_backend_pid()
  and datname = db
  and state = 'active';
$$ language sql;

--
-- use: perform lib_test.autonomous('update|insert|delete|select sp() ...'); to
-- change data in a separate transaction.
--
create or replace function lib_test.autonomous(p_statement varchar) returns void as
$$
begin
    execute p_statement;
end;
$$ language plpgsql set search_path from current;
