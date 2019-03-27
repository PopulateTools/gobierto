# frozen_string_literal: true

module GobiertoPeople
  class OppositionPartyPastPersonEventsController < PastPersonEventsController
    def index
      @person_event_scope = "opposition_party"
      @person_party = Person.parties["opposition"]
      super
    end
  end
end
