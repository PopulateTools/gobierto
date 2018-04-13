# frozen_string_literal: true

module GobiertoCalendars
  class EventDecorator < BaseDecorator

    include ActionView::Helpers::TextHelper

    def initialize(event)
      @object = event
    end

    def formatted_html_description
      return "" if description.blank?
      simple_format description.gsub(/<!--(.*?)-->/, '')
    end

  end
end
