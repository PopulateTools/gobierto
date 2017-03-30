module GobiertoPeople
  class OppositionPartyPastPersonEventsController < PastPersonEventsController
    def index
      super
      @person_event_scope = "opposition_party"
      @person_party = Person.parties["opposition"]
      @events = @events.by_person_party(@person_party)
      @calendar_events = @calendar_events.by_person_party(@person_party)
    end
  end
end
