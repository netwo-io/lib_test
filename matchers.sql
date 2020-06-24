
create or replace function lib_test.assert_true(message varchar, condition boolean) returns void as
$$
begin
    if condition then
        null;
    else
        raise exception 'assert_true failure: %', message using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left boolean, _right boolean, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, _left::text, _right::text using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left integer, _right integer, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, _left, _right using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left text, _right text, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, _left, _right using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_not_equal(_left text, _right text, message varchar default '') returns void as
$$
begin
    if _left != _right then
        null;
    else
        raise exception 'assert_not_equal failure %: % != %', message, _left, _right using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left jsonb, _right jsonb, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, jsonb_pretty(_left), jsonb_pretty(_right) using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left timestamptz, _right timestamptz, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, _left, _right using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_equal(_left uuid, _right uuid, message varchar default '') returns void as
$$
begin
    if _left = _right then
        null;
    else
        raise exception 'assert_equal failure %: % != %', message, _left::text, _right::text using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_true(condition boolean) returns void as
$$
begin
    if condition then
        null;
    else
        raise exception 'assert_true failure' using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_false(condition boolean) returns void as
$$
begin
    if not condition then
        null;
    else
        raise exception 'assert_false failure' using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_not_null(val$ anyelement, message$ text default '') returns void as
$$
begin
    if val$ is null then
        raise exception 'assert_not_null failure: %', message$ using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.assert_null(val$ anyelement, message$ text default '') returns void as
$$
begin
    if val$ is not null then
        raise exception 'assert_null failure: %', message$ using errcode = 'triggered_action_exception';
    end if;
end;
$$ language plpgsql set search_path from current
                    immutable;

create or replace function lib_test.fail(varchar) returns void as
$$
begin
    raise exception 'test failure: %', $1 using errcode = 'triggered_action_exception';
end;
$$ language plpgsql set search_path from current
                    immutable;
