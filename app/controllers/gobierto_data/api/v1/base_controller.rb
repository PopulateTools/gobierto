# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds
        include ::PreviewTokenHelper

        before_action { module_enabled!(current_site, "GobiertoData", false) }

        private

        def cache_service
          @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoData")
        end

        def csv_options_params
          separator_tr = {
            "semicolon" => ";",
            "colon" => ":",
            "comma" => ","
          }
          {}.tap do |options|
            if (separator = params[:csv_separator]).present?
              options[:col_sep] = separator_tr.fetch(separator, separator)
            else
              options[:col_sep] = separator_tr["comma"]
            end
          end
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
            content = ActiveModelSerializers::SerializableResource.new(content).to_json unless content.is_a? String
            send_data(
              content,
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
          headers["Content-Disposition"] = "inline"
          headers["Content-Type"] = "text/plain; charset=utf-8"
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

      end
    end
  end
end
