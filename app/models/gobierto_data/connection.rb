# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    class << self

      def execute_query(site, query, include_stats: true, write: false)
        connection_key = write ? :write_db_config : :read_db_config

        with_connection(db_config(site), fallback: null_query, connection_key: connection_key) do
          event = nil
          if include_stats
            ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
              if event.blank? && payload[:sql] == query
                event = ActiveSupport::Notifications::Event.new(name, start, finish, id, payload)
              end
            end
          end

          execution = connection.execute(query) || null_query

          {
            result: execution,
            duration: event&.duration,
            rows: execution.ntuples,
            status: execution.cmd_status
          }
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
        site&.gobierto_data_settings&.db_config&.with_indifferent_access
      end

      def test_connection_config(config, connection_key = :read_db_config)
        with_connection(config&.with_indifferent_access, connection_key: connection_key) do
          connection.present?
        end
      end

      private

      def with_connection(db_conf, fallback: nil, connection_key: :read_db_config)
        base_connection_config = connection_config
        return fallback if db_conf.nil?

        db_conf = db_conf[connection_key] if db_conf.has_key?(connection_key)
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
