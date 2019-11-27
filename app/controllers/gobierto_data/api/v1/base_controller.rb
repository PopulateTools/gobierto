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

      end
    end
  end
end
