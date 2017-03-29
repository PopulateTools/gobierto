module GobiertoPeople
  class ExecutiveCategoryPersonEventsController < PersonEventsController
    def index
      super
      @person_event_scope = "executive_category"
      @person_category = Person.categories["executive"]
      @events = @events.by_person_category(@person_category)

      @no_upcoming_events = @events.empty?

      if @no_upcoming_events
        @events = current_site.person_events.past.by_person_category(@person_category)
      end
    end
  end
end
