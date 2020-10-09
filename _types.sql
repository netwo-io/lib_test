create type lib_test.status as enum ('OK', 'FAILED', 'CRASHED');

create type lib_test.results as
(
  name          varchar,
  status        lib_test.status,
  error_message varchar,
  duration      interval
);
