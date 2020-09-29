select json_agg(row_to_json(results)) from lib_test.run_all() results;

-- @todo upgrade CLI to select tests to run, see:
-- select json_agg(row_to_json(results)) from lib_test.run_suite('lib_cloudinary') results;
