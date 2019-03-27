# frozen_string_literal: true

module GobiertoPeople
  class OppositionPartyPersonEventsController < PersonEventsController
    def index
      @person_event_scope = "opposition_party"
      @person_party = Person.parties["opposition"]
      super
    end
  end
end
