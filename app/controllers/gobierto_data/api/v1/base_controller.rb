# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds
        include ::User::ApiAuthenticationHelper
        include ::PreviewTokenHelper

        before_action { module_enabled!(current_site, "GobiertoData", false) }

        private

        def csv_options_params
          separator_tr = {
            "semicolon" => ";",
            "colon" => ":",
            "comma" => ","
          }
          {}.tap do |options|
            if (separator = params[:csv_separator]).present?
              options[:col_sep] = separator_tr.fetch(separator, separator)
            end
          end
        end

        def csv_from_query_result(result, options = {})
          return if result.blank?

          CSV.generate(**options) do |csv|
            csv << result.fields
            result.each_row do |row|
              csv << row
            end
          end.force_encoding("utf-8")
        end

        def xlsx_from_query_result(result, options = {})
          row_index = 0
          book = RubyXL::Workbook.new

          sheet = book.worksheets.first
          sheet.sheet_name = options.fetch(:name, "data")
          result.fields.each_with_index do |value, col_index|
            sheet.add_cell(row_index, col_index, value)
          end
          result.each_row do |row|
            row_index += 1
            row.each_with_index do |value, col_index|
              sheet.add_cell(row_index, col_index, value)
            end
          end

          book.stream
        end

        def csv_from_relation(relation, options = {})
          with_serialized_data_from_relation(relation) do |data, new|
            return "" if data.blank?

            CSV.generate(**options) do |csv|
              csv << new.keys
              data.each do |row|
                csv << new.merge(row).values
              end
            end.force_encoding("utf-8")
          end
        end

        def xlsx_from_relation(relation, options = {})
          row_index = 0
          book = RubyXL::Workbook.new

          sheet = book.worksheets.first
          sheet.sheet_name = options.fetch(:name, "data")

          with_serialized_data_from_relation(relation) do |data, new|
            new.keys.each_with_index do |value, col_index|
              sheet.add_cell(row_index, col_index, value.to_s)
            end
            data.each do |row|
              row_index += 1
              new.merge(row).values.each_with_index do |value, col_index|
                sheet.add_cell(row_index, col_index, value.is_a?(Numeric) ? value : value.to_s)
              end
            end
          end
          book.stream
        end

        def with_serialized_data_from_relation(relation)
          yield(
            ActiveModelSerializers::SerializableResource.new(
              relation,
              exclude_links: true,
              exclude_relationships: true,
              string_output: true
            ).as_json,
            ActiveModelSerializers::SerializableResource.new(
              relation.model.new,
              exclude_links: true,
              exclude_relationships: true,
              string_output: true,
              site: current_site
            ).as_json
          )
        end

        def send_download(content, format, base_filename)
          case format
          when :json
            send_data(
              ActiveModelSerializers::SerializableResource.new(
                content
              ).to_json,
              filename: "#{base_filename}.json"
            )
          when :csv
            headers["Content-Disposition"] = "attachment"
            render(
              csv: content,
              filename: base_filename
            )
          when :xlsx
            send_data(
              content,
              filename: "#{base_filename}.xlsx"
            )
          end
        end

        def render_csv(content)
          set_csv_headers
          render(
            plain: content
          )
        end

        def available_locales_hash
          @available_locales_hash ||= current_site.configuration.available_locales.inject({}) do |hash, locale|
            hash.update(
              locale => nil
            )
          end
        end

        def set_streaming_headers
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers.delete("Content-Length")
        end

        def set_csv_headers
          headers["Content-Disposition"] = "inline"
          headers["Content-Type"] = "text/plain; charset=utf-8"
        end

        def json_stream_data(sql, total_rows)
          row_num = 0
          Enumerator.new do |lines|
            lines << "{\"data\":["
            execute_stream_query(sql) do |execution|
              time = Benchmark.measure do
                execution.stream_each do |row|
                  row_num += 1
                  lines << row.to_json
                  lines << "," unless row_num == total_rows
                end
              end
              lines << "],\"meta\":{\"duration\":#{time.real},\"rows\":#{total_rows},\"status\":\"#{execution.cmd_status}\"}}"
            end
          end
        end

        def csv_stream_data(sql, options = {})
          Enumerator.new do |lines|
            execute_stream_query(sql) do |execution|
              lines << CSV.generate_line(execution.fields, **options)
              execution.stream_each_row do |row|
                lines << CSV.generate_line(row, **options)
              end
            end
          end
        end

        def query_rows_count(sql)
          return if sql.blank?

          query_result = GobiertoData::Connection.execute_query(current_site, Arel.sql("select count(*) from (#{sql}) as query"), include_draft: valid_preview_token?)

          return query_result if query_result.has_key?(:errors)

          query_result[:result].first["count"]
        end

        def execute_stream_query(sql)
          GobiertoData::Connection.execute_stream_query(current_site, Arel.sql(sql), include_draft: valid_preview_token?) do |execution|
            yield(execution)
          end
        end
      end
    end
  end
end
