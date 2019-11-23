# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    class << self

      def execute_query(site, query, include_stats: true)
        with_connection(db_config(site), fallback: null_query) do

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
