module GobiertoPeople
  class ExecutiveCategoryPastPersonEventsController < PastPersonEventsController
    def index
      super
      @person_event_scope = "executive_category"
      @person_category = Person.categories["executive"]
      @events = @events.by_person_category(@person_category)
      @calendar_events = @calendar_events.by_person_category(@person_category)
      @people = @people.executive
    end
  end
end
