create type lib_test.results as
(
    name          varchar,
    success       boolean,
    error_message varchar,
    duration      interval
);
