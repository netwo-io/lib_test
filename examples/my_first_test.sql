-- test function should live inside `lib_test` schema
-- test function should always start with `test_case_` and yield `void`
create or replace function lib_test.test_case_my_first_test() returns void as $$
begin

    perform lib_test.fail('Wrongly formatted compound should fail.');
end;
$$ language plpgsql;
