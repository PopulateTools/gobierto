# frozen_string_literal: true

require "mechanize"

module IbmNotes
  class InvalidCredentials < StandardError; end
  class ServiceUnavailable < StandardError; end

  class Api
    def self.get_person_events(params)
      make_request params
    end

    def self.get_event(params)
      make_request params
    end

    def self.get_recurrent_event_instances(params)
      params[:endpoint] += "/instances"
      make_request params
    end

    private

    def self.make_request(params)
      response_page = get_response_page(params)
      begin
        if response_page.uri.path == URI.parse(params[:endpoint]).path
          log_message "[GET #{params[:endpoint]}][HTTP #{response_page.code}]"
          if response_page.code.to_i == 200
            JSON.parse(response_page.body)
          else
            raise IbmNotes::ServiceUnavailable
          end
        else
          raise IbmNotes::InvalidCredentials
        end
      rescue JSON::ParserError
        if response_page.body == ""
          []
        else
          raise JSON::ParserError
        end
      end
    rescue ::Mechanize::ResponseCodeError
      log_message "[GET #{params[:endpoint]}][Mechanize response code error]"
      return nil
    end

    def self.get_response_page(params)
      signin_page = agent.get params[:endpoint]
      signin_page.form_with(action: "/names.nsf?Login") do |form|
        form.Username = params[:username]
        form.Password = params[:password]
      end.submit
    end

    def self.agent
      agent = Mechanize.new
      agent.user_agent_alias = "Mac Safari"
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent
    end

    def self.log_message(message)
      Rails.logger.info "[SYNC-AGENDAS][IBM Notes]#{message}"
    end
  end
end
