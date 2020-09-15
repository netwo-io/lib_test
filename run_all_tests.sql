select json_agg(row_to_json(results)) from lib_test.run_all() results;
