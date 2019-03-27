# frozen_string_literal: true

module GobiertoPeople
  class GovernmentPartyPersonEventsController < PersonEventsController
    def index
      @person_event_scope = "government_party"
      @person_party = Person.parties["government"]
      super
    end
  end
end
