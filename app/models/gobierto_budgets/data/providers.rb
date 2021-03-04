# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Providers
      class UnsupportedFormat < StandardError; end

      FORMATS = {
        json: { deserializer: ->(content) { JSON.parse(content) },
                invalid: ->(data) { data.blank? || (data.is_a?(Hash) && data.keys.include?("error")) },
                content_type: "application/json; charset=utf-8" },
        csv:  { deserializer: ->(content) { CSV.parse(content) },
                invalid: ->(data) { data.blank? || data[0].include?("error_code") },
                content_type: "text/csv; charset=utf-8" }
      }.freeze

      attr_accessor :site, :year

      def initialize(options = {})
        @year = options[:year]
        @site = options[:site]
        @data = {}
      end

      def any_data?
        FORMATS.any? do |format, configuration|
          format_data(format) && !configuration[:invalid].call(configuration[:deserializer].call(format_data(format)))
        end
      end

      def get_url(format)
        file = GobiertoCommon::FileUploadService.new(file_name: filename(format))
        file.uploaded_file_exists? && file.call
      end

      def any_file?
        FORMATS.any? do |format, _|
          get_url(format)
        end
      end

      def generate_files
        file_urls = []
        return file_urls unless any_data?

        FORMATS.each do |format_key, configuration|
          file_urls << GobiertoCommon::FileUploadService.new(
            file_name: filename(format_key),
            content: format_data(format_key),
            content_type: configuration[:content_type]
          ).upload!
        end
        file_urls
      end

      protected

      def filename(format)
        raise UnsupportedFormat unless FORMATS.keys.include?(format.to_sym)
        ["gobierto_budgets", site.organization_id, "data", "providers", "#{ year }.#{ format }"].join("/")
      end

      def format_data(format)
        @data[format] ||= request_response(format)
      end

      private

      def date_range
        @date_range ||= "#{ year }0101-#{ year }1231"
      end

      def format_uri(format)
        URI("https://#{site.domain}/presupuestos/proveedores-facturas.#{ format }?filter_by_location_id=#{ site.organization_id }&date_date_range=#{ date_range }&sort_asc_by=date")
      end

      def request_response(format)
        uri = format_uri(format)

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          req = Net::HTTP::Get.new uri
          http.request req
        end

        return nil unless res.is_a? Net::HTTPSuccess
        res.body
      end
    end
  end
end
