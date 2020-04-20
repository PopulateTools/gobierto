# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    class << self

      def execute_query(site, query, include_stats: true, write: false, include_draft: false)
        with_connection(db_config(site), fallback: null_query, connection_key: connection_key_from_options(write, include_draft)) do
          connection.execute("CREATE SCHEMA IF NOT EXISTS draft") if write
          connection.execute("SET search_path TO draft, public") if write || include_draft

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

      def execute_write_query_from_file_using_stdin(site, query, file_path: nil, include_draft: false)
        return unless file_path.present?

        with_connection(db_config(site), fallback: null_query, connection_key: :write_db_config) do
          connection.execute("CREATE SCHEMA IF NOT EXISTS draft") if include_draft

          raw_connection = connection.raw_connection

          execution = raw_connection.copy_data(query) do
            File.open(file_path, "r").each do |line|
              raw_connection.put_copy_data line
            end
          end
          { result: execution }
        end
      rescue ActiveRecord::StatementInvalid => e
        failed_query(e.message)
      rescue PG::Error => e
        failed_query(e.message)
      end

      def tables(site, include_draft: false)
        with_connection(db_config(site), connection_key: connection_key_from_options(false, include_draft)) do
          connection.execute("SET search_path TO draft, public") if include_draft
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

      def connection_key_from_options(write, include_draft)
        access_mode_key = write ? "write_" : "read_"
        draft_key = include_draft && !write ? "draft_" : ""
        :"#{access_mode_key}#{draft_key}db_config"
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
