# frozen_string_literal: true

require "uri"
require "net/http"
require "json"

module PopulateData
  module Gobierto
    class Client
      include Logging

      BASE_URI = APP_CONFIG["populate_data"]["endpoint"]

      def initialize(options = {})
        @origin = options.fetch(:origin)
        @api_token = options.fetch(:api_token)

        Client.logger.debug("Initializing #{self.class.name} with options #{options}")
      end

      def fetch
        Client.logger.debug("Fetching #{request_uri} with body #{request_body}")

        response = http_client.request(request)
        JSON.parse(response.read_body)
      rescue StandardError => error
        Client.logger.error(error)

        []
      end

      private

      attr_reader :origin, :api_token

      def http_client
        @http_client ||= setup_http_client
      end

      def request
        @request ||= build_request
      end

      protected

      def build_request
        request = Net::HTTP::Get.new(request_uri)

        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json"
        request["Authorization"] = "Bearer #{api_token}"
        request["Origin"] = origin

        request.body = request_body

        request
      end

      def request_body
        {}.to_json
      end

      def request_uri
        @request_uri ||= URI(BASE_URI + self.class::ENDPOINT_URI)
      end

      def setup_http_client
        http_client = Net::HTTP.new(request_uri.host, request_uri.port)
        # http_client.use_ssl = true

        http_client
      end
    end
  end
end
