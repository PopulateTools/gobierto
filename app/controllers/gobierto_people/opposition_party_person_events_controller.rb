module GobiertoPeople
  class OppositionPartyPersonEventsController < PersonEventsController
    def index
      super
      @person_event_scope = "opposition_party"
      @person_party = Person.parties["opposition"]
      @events = @events.by_person_party(@person_party)

      @no_upcoming_events = @events.empty?

      if @no_upcoming_events
        @events = current_site.person_events.past.by_person_party(@person_party)
      end
    end
  end
end
