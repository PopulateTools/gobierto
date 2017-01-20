module GobiertoPeople
  class GovernmentPartyPersonEventsController < PersonEventsController
    def index
      super
      @person_event_scope = "government_party"
      @person_party = Person.parties["government"]
      @events = @events.by_person_party(@person_party)
    end
  end
end
