# frozen_string_literal: true

module GobiertoCalendars
  class FilteringResult
    attr_accessor :action
    attr_accessor :event_attributes

    def initialize(event_attributes, action)
      @event_attributes = event_attributes
      @action = action
    end
  end
end
