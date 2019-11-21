# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    class << self

      def execute_query(site, query)
        with_connection(db_config(site), fallback: null_query) do
          connection.execute(query) || null_query
        end
      rescue ActiveRecord::StatementInvalid => e
        failed_query(e.message)
      end

      def tables(site)
        with_connection(db_config(site)) do
          connection.tables
        end
      end

      def db_config(site)
        site&.gobierto_data_settings&.db_config
      end

      def test_connection_config(config)
        with_connection(config) do
          connection.present?
        end
      end

      private

      def with_connection(db_conf, fallback: nil)
        base_connection_config = connection_config
        return fallback if db_conf.nil?

        establish_connection(db_conf)
        yield
      ensure
        establish_connection(base_connection_config)
      end

      def null_query
        []
      end

      def failed_query(message)
        { errors: [{ sql: message }] }
      end

    end
  end
end
