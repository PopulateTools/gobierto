# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds

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

        def csv_from_relation(relation, options = {})
          serialized_data_as_json = ActiveModelSerializers::SerializableResource.new(relation, exclude_links: true, string_output: true).as_json
          new = ActiveModelSerializers::SerializableResource.new(relation.new, exclude_links: true, string_output: true).as_json

          return "" if serialized_data_as_json.blank?

          CSV.generate(**options) do |csv|
            csv << new.keys
            serialized_data_as_json.each do |row|
              csv << new.merge(row).values
            end
          end.force_encoding("utf-8")
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
