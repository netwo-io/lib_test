-- lib_test assert functions.

-- Check equality between two boolean, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ boolean, right$ boolean, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, left$::text, right$::text using errcode='triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check equality between two integers, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ integer, right$ integer, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, left$, right$ using errcode='triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check equality between two text elements, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ text, right$ text, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, left$, right$ using errcode='triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check inequality between two text elements, otherwise fail with message.
create or replace function lib_test.assert_not_equal(left$ text, right$ text, message$ varchar default '') returns void as
$$
begin
  if left$ != right$ then
    null;
  else
    raise 'assert_not_equal failure %: % != %', message$, left$, right$ using errcode='triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check equality between two jsonb entities, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ jsonb, right$ jsonb, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, jsonb_pretty(left$), jsonb_pretty(right$) using errcode='triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check equality between two timestamptz, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ timestamptz, right$ timestamptz, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, left$, right$ using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check equality between two uuid, otherwise fail with message.
create or replace function lib_test.assert_equal(left$ uuid, right$ uuid, message$ varchar default '') returns void as
$$
begin
  if left$ = right$ then
    null;
  else
    raise 'assert_equal failure %: % != %', message$, left$::text, right$::text using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check provided condition is true, otherwise fail mith message.
create or replace function lib_test.assert_true(condition$ boolean, message$ varchar default '') returns void as
$$
begin
  if condition$ then
    null;
  else
    raise 'assert_true failure %', message$ using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check provided condition is false, otherwise fail mith message.
create or replace function lib_test.assert_false(condition$ boolean, message$ varchar default '') returns void as
$$
begin
  if not condition$ then
    null;
  else
    raise 'assert_false failure %', message$ using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check value is defined, otherwise fail with message.
create or replace function lib_test.assert_not_null(val$ anyelement, message$ text default '') returns void as
$$
begin
  if val$ is null then
    raise 'assert_not_null failure %', message$ using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Check value is not defined, otherwise fail with message.
create or replace function lib_test.assert_null(val$ anyelement, message$ text default '') returns void as
$$
begin
  if val$ is not null then
    raise exception 'assert_null failure %', message$ using errcode = 'triggered_action_exception';
  end if;
end;
$$ language plpgsql set search_path from current immutable;

-- Force test failure with message.
create or replace function lib_test.fail(message$ varchar) returns void as
$$
begin
  raise 'test failure %', message$ using errcode = 'triggered_action_exception';
end;
$$ language plpgsql set search_path from current immutable;
