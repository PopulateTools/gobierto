require 'mechanize'

module IbmNotes
  class InvalidCredentials < StandardError; end
  class ServiceUnavailable < StandardError; end

  class Api

    def self.get_person_events(params)
      response_page = make_request(params)
      begin
        if response_page.uri.path == URI.parse(params[:endpoint]).path
          if response_page.code.to_i == 200
            JSON.parse(response_page.body)["events"]
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
    end

    private

    def self.make_request(params)
      signin_page = agent.get params[:endpoint]
      signin_page.form_with(action: "/names.nsf?Login") do |form|
        form.Username = params[:username]
        form.Password = params[:password]
      end.submit
    end

    def self.agent
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent
    end

  end
end
