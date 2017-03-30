module GobiertoPeople
  class OppositionPartyPersonEventsController < PersonEventsController
    def index
      super
      @person_event_scope = "opposition_party"
      @person_party = Person.parties["opposition"]
      @events = @events.by_person_party(@person_party)
      @calendar_events = @calendar_events.by_person_party(@person_party)
      @people = @people.opposition

      check_past_events
    end

    private

    def past_events
      current_site.person_events.past.by_person_party(@person_party)
    end
  end
end
