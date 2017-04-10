require 'mechanize'

module LotusNotes
  class Api

    def self.get_person_events(calendar_endpoint)
      response_page = make_request(calendar_endpoint)
      person_events = JSON.parse(response_page.body)["events"]
      person_events
    end

    private

    def self.make_request(calendar_endpoint)
      signin_page = agent.get(calendar_endpoint)
      page = signin_page.form_with(action: "/names.nsf?Login") do |form|
        form.Username = lotus_username
        form.Password = lotus_password
      end.submit
    end

    def self.agent
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent
    end

    def self.lotus_username
      # TODO
    end

    def self.lotus_password
      # TODO
    end
  end
end
