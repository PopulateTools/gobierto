module GobiertoPeople
  class GovernmentPartyPersonEventsController < PersonEventsController
    def index
      super
      @person_event_scope = "government_party"
      @person_party = Person.parties["government"]
      @events = @events.by_person_party(@person_party)
      @calendar_events = @calendar_events.by_person_party(@person_party)

      check_past_events
    end

    private

    def past_events
      current_site.person_events.past.by_person_party(@person_party)
    end
  end
end
