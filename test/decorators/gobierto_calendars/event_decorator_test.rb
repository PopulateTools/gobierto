# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class EventDecoratorTest < ActiveSupport::TestCase

    def event
      @event ||= gobierto_calendars_events(:richard_published)
    end

    def test_formatted_html_description
      description = "<script>alert(1);</script><!-- C1 -->Content<!-- C2 -->More content<!-- C3 -->"
      event.update(description: description)
      decorator = EventDecorator.new(event)
      expected_output = "<p>alert(1);ContentMore content</p>"

      assert_equal expected_output, decorator.formatted_html_description

      event.description_translations = { "ca" => nil, "es" => nil, "en" => nil }
      decorator = EventDecorator.new(event)
      assert_equal "", decorator.formatted_html_description
    end

  end
end
