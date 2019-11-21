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
      hash_result = JSON.parse(result.to_json)

      assert_equal [{ "test_count" => 7 }], hash_result
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
