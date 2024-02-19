# frozen_string_literal: true

require_relative "../gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    BLACKLISTED_TABLES = %w(
      schemata
      information_schema.schemata
      pg_stat_activity
      pg_roles
    )

    BLACKLISTED_FUNCTIONS = %w(
      version
      current_database
    )


    class << self

      def execute_query(site, query, include_stats: false, write: false, include_draft: false)
        if !secure_query?(query) && !write
          puts "Insecure!!!"
          raise ActiveRecord::StatementInvalid.new("Query not allowed")
        end

        with_connection(db_config(site), fallback: null_query, connection_key: connection_key_from_options(write, include_draft)) do
          connection_pool.connection.execute("SET search_path TO draft, public") if write || include_draft

          event = nil
          if include_stats
            ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
              if event.blank? && payload[:sql] == query
                event = ActiveSupport::Notifications::Event.new(name, start, finish, id, payload)
              end
            end
          end

          execution = connection_pool.connection.execute(query) || null_query

          return execution unless include_stats

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

      def execute_query_output_csv(site, query, csv_options_params, include_draft: false)
        unless secure_query?(query)
          raise ActiveRecord::StatementInvalid.new("Query not allowed")
        end

        with_connection(db_config(site), fallback: null_query, connection_key: connection_key_from_options(false, include_draft)) do
          connection_pool.connection.execute("SET search_path TO draft, public") if include_draft

          csv  = []
          # Get the raw connection (in our case the pg connection object)
          pg_connection = connection_pool.connection.raw_connection
          pg_connection.copy_data("COPY (#{query}) TO STDOUT WITH (FORMAT CSV, HEADER TRUE, DELIMITER '#{csv_options_params[:col_sep]}', FORCE_QUOTE *);") do
            while row = pg_connection.get_copy_data
              csv.push(row)
            end
          end
          return csv.join('')
        end
      rescue ActiveRecord::StatementInvalid, PG::Error => e
        failed_query(e.message)
      end

      def execute_query_output_xlsx(site, query, xlsx_options_params, include_draft: false)
        result = execute_query(site, query, include_draft: include_draft)

        return result if result.is_a?(Hash) && result.has_key?(:errors)

        row_index = 0
        book = RubyXL::Workbook.new

        sheet = book.worksheets.first
        sheet.sheet_name = xlsx_options_params.fetch(:name, "data")
        result.fields.each_with_index do |value, col_index|
          sheet.add_cell(row_index, col_index, value)
        end
        result.each_row do |row|
          row_index += 1
          row.each_with_index do |value, col_index|
            sheet.add_cell(row_index, col_index, value)
          end
        end

        book.stream.read
      rescue ActiveRecord::StatementInvalid => e
        failed_query(e.message)
      end

      def execute_write_query_from_file_using_stdin(site, query, file_path: nil, include_draft: false)
        return unless file_path.present?

        with_connection(db_config(site), fallback: configuration_missing_error, connection_key: :write_db_config) do
          connection_pool.connection.execute("CREATE SCHEMA IF NOT EXISTS draft") if include_draft

          raw_connection = connection_pool.connection.raw_connection

          execution = raw_connection.copy_data(query) do
            File.open(file_path, "r").each do |line|
              next if line.blank?

              raw_connection.put_copy_data line
            end
          end
          { result: execution }
        end
      rescue ActiveRecord::StatementInvalid => e
        failed_query(e.message)
      end

      def tables(site, include_draft: false)
        with_connection(db_config(site), connection_key: connection_key_from_options(false, include_draft)) do
          connection_pool.connection.execute("SET search_path TO draft, public") if include_draft
          connection_pool.connection.tables
        end
      end

      def db_config(site)
        site&.gobierto_data_settings&.db_config&.with_indifferent_access
      end

      def test_connection_config(config, connection_key = :read_db_config)
        with_connection(config&.with_indifferent_access, connection_key: connection_key) do
          connection_pool.connection.present?
        end
      end

      private

      def with_connection(db_conf, fallback: nil, connection_key: :read_db_config)
        return fallback if db_conf.nil?

        db_conf = db_conf[connection_key] if db_conf.has_key?(connection_key)
        establish_connection(db_conf)
        yield
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

      def configuration_missing_error
        failed_query(I18n.t("activerecord.errors.models.gobierto_data/connection.missing_configuration"))
      end

      def secure_query?(query)
        parsed_query = PgQuery.parse(query)

        secure_tables_called?(parsed_query) &&
          secure_functions_called?(parsed_query)
      rescue PgQuery::ParseError
        # Invalid queries are considered insecure
        false
      end

      def secure_tables_called?(parsed_query)
        return false if parsed_query.tables.empty?
        return false if parsed_query.tables.any? { |t| BLACKLISTED_TABLES.include?(t) }
        return false if parsed_query.tables.any? { |t| t.starts_with?("pg_") || t.starts_with?("information_schema") || t.starts_with?("scalegrid") }

        true
      end

      def secure_functions_called?(parsed_query)
        parsed_query.functions.none? do |f|
          BLACKLISTED_FUNCTIONS.include?(f) ||
            f.starts_with?("pg_") ||
            f.starts_with?("current_") ||
            f.starts_with?("inet_") ||
            f.starts_with?("get")
        end
      end
    end
  end
end
