module GobiertoPeople
  class GovernmentPartyPastPersonEventsController < PastPersonEventsController
    def index
      super
      @person_event_scope = "government_party"
      @person_party = Person.parties["government"]
      @events = @events.by_person_party(@person_party)
      @calendar_events = @calendar_events.by_person_party(@person_party)
      @people = @people.government
    end
  end
end
