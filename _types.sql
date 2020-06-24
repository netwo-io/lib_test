create type lib_test.results as
(
    name          varchar,
    failed        boolean,
    error_message varchar,
    duration      interval
);
