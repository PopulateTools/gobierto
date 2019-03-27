# frozen_string_literal: true

module GobiertoPeople
  class ExecutiveCategoryPastPersonEventsController < PastPersonEventsController
    def index
      @person_event_scope = "executive_category"
      @person_category = Person.categories["executive"]
      super
    end
  end
end
