# frozen_string_literal: true

module GobiertoPeople
  class PastPersonEventsController < PersonEventsController
    def index
      @past_events = true
      super
    end
  end
end
