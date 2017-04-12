require 'mechanize'

module LotusNotes
  class Api

    def self.get_person_events(params)
      response_page = make_request(params)
      person_events = JSON.parse(response_page.body)["events"]
      person_events
    end

    private

    def self.make_request(params)
      signin_page = agent.get params[:endpoint]
      page = signin_page.form_with(action: "/names.nsf?Login") do |form|
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
